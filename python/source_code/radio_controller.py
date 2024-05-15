import os
import io
import nrarfcn as nr
import matlab.engine
from .attack_mode import AttackMode


class RadioController:
    """A class for interfacing with the SDR through MATLAB engine."""

    def __init__(self) -> None:
        # A MATLAB session can either be started by creating one, or
        # hooking to an existing session. To hook a current session do:
        # Open MATLAB -> Command Windows type -> "matlab.engine.shareEngine"

        # Check if we can use an existing MATLAB session
        if matlab.engine.find_matlab():
            print("Attaching to existing MATLAB session")
            print(f"Sessions={list(matlab.engine.find_matlab())}")
            self.matlab_engine = matlab.engine.connect_matlab(
                matlab.engine.find_matlab()[0]
            )

        # Otherwise we create a MATLAB session from scratch
        else:
            print("Starting MATLAB engine")
            self.matlab_engine = matlab.engine.start_matlab()

        # Append MATLAB folders to MATLAB engine
        matlab_project_folder = os.path.join(os.getcwd(), "MATLAB")
        self.matlab_engine.addpath(
            self.matlab_engine.genpath(matlab_project_folder), nargout=0
        )

        # Keep track on if the selected SDR is configured or not
        self.radio_configured: bool = False

    def __del__(self) -> None:
        # MATLAB engine must be terminated before exit
        self.matlab_engine.quit()

    def discover_radio(self, platform: str = "B210", serial_number: str = "") -> None:
        """Check and configure any given SDR platform and serial number.

        Args:
            platform (str, optional): The SDR platform. Defaults to "B210".
            serial_number (str, optional): The SDRs serial number. Defaults to "".
        
        Note:
            This method mst be called before trying to attack or scan.
        """        

        # Setup input and output streams for warnings from MATLAB engine
        out = io.StringIO()
        err = io.StringIO()

        # Call MATLAB engine
        radios = self.matlab_engine.configureSDR(
            platform, serial_number, nargout=2, stdout=out, stderr=err
        )

        # Check for any warnings from MATLAB engine
        # Any warnings and errors will from now on be checked
        self._assert_matlab_exception(out, err)

        # Convert the returned values from MATLAB engine to tx, rx radio
        self.rx = radios[0]
        self.tx = radios[1]

        # We now have a connected SDR radio
        self.radio_configured = True

    def frequency_sweep(self, frequencies: list[int]) -> tuple[list[int], list[float]]:
        """Check if the given frequencies contain any SSBs and if so
           return their absolute frequency and timestamp.

        Args:
            frequencies (list[int]): The frequencies to scan.

        Returns:
            tuple[list[int], list[float]]: The frequencies that contain SSBs and their timestamps.
        """

        # Check if the SDR has been configured
        if not self.radio_configured:
            raise Exception("Radio not found")

        # Preform the SSB sweep
        SSB_frequencies, first_SSB_time_stamp = self.matlab_engine.frequencySweep(
            self.rx, matlab.double(frequencies), matlab.double(40), nargout=2
        )

        # If MATLAB only discoverd one SSB
        if type(SSB_frequencies) == float:
            print("Only one SSB found")
            SSB_frequencies = [int(SSB_frequencies)]
            first_SSB_time_stamp = [first_SSB_time_stamp]

        # If MATLAB did not found any SSBs
        elif type(SSB_frequencies) == matlab.double and SSB_frequencies.size == (0, 0):
            print("No SSBs found")
            SSB_frequencies = []

        # Otherwise MATLAB has found multiple SSBs
        else:
            # Convert matlab double(array) to list[int]
            SSB_frequencies = [int(frequency) for _, frequency in enumerate(SSB_frequencies[0])]
            first_SSB_time_stamp = first_SSB_time_stamp[0]

        return (SSB_frequencies, first_SSB_time_stamp)

    def SSB_attack(
        self, frequency: int, duration: int, attack_mode: AttackMode = AttackMode.SMART
    ) -> None:
        print(f"SSB attacking mode: {attack_mode.name}")
        """Execute the given SSB attack."""

        # Check if the provided attack mode is supported
        if not isinstance(attack_mode, AttackMode):
            raise ValueError("Unknown attack mode!")

        # Check if the SDR has been configured
        if not self.radio_configured:
            raise Exception("Radio not found")

        # Run the specified attack mode
        match attack_mode:
            case AttackMode.SMART:
                self.matlab_engine.smartSSBJam(
                    self.rx,
                    self.tx,
                    matlab.double(frequency),
                    duration,
                    False,
                    nargout=0,
                )
            case AttackMode.DUMB:
                self.matlab_engine.dumbSSBJam(
                    self.rx, 
                    self.tx, 
                    matlab.double(frequency), 
                    duration, 
                    nargout=0
                )
            case AttackMode.OFDM:
                self.matlab_engine.smartSSBJam(
                    self.rx,
                    self.tx,
                    matlab.double(frequency),
                    duration,
                    True,
                    nargout=0,
                )

    @staticmethod
    def _assert_matlab_exception(out: io.StringIO, err: io.StringIO) -> None:
        """Check for any errors and warnings from MATLAB engine.

        Args:
            out (io.StringIO): MATLABs standard output stream.
            err (io.StringIO): MATLABs standard error stream.
        """

        # Check if any errors has been raised from MATLAB engine
        if err.getvalue():
            raise Exception(err.getvalue())
        
        # Check for any warnings from MATLAB engine
        if "Warning:" in out.getvalue():
            # Then raise the warning as an exception
            start_index: int = out.getvalue().find("Warning:")
            end_index: int = out.getvalue().find("\n", start_index)
            warning: str = out.getvalue()[start_index:end_index]
            raise Exception(warning)

    @staticmethod
    def ARFCN_to_frequency(ARFCNs: list[int]) -> list[int]:
        """Convert a list of ARFCNs to absolute frequency in Hz."""

        # Check if the provided ARFCNs are not within spec
        if not any(0 <= ARFCN < 3279166 for ARFCN in ARFCNs):
            raise ValueError(f"ARFCN must be between 0 and 3279165")
        
        res = []
        for ARFCN in ARFCNs:
            if ARFCN >= 0 and ARFCN < 600000:
                fRefOffset = 0
                nRefOffset = 0
                deltaFGlobal = 5000
            elif ARFCN >= 600000 and ARFCN < 2016667:
                fRefOffset = 3e9
                nRefOffset = 6e5
                deltaFGlobal = 15000
            elif ARFCN >= 2016667 and ARFCN < 3279166:
                fRefOffset = 24250.08 * 10e6
                nRefOffset = 2016667
                deltaFGlobal = 60000

            # Calculate frequency
            centerFrequency = fRefOffset + (deltaFGlobal * (ARFCN - nRefOffset))
            res.append(int(centerFrequency))

        return res

    @staticmethod
    def GSCN_to_frequency(GSCNs: list[int]) -> list[int]:
        """Covert a list of GSCN to absolute frequency in Hz."""
        return [int(nr.get_frequency_by_gscn(gscn) * 1_000_000) for gscn in GSCNs]
