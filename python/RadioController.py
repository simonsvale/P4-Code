import os
import io

# Matlab
import matlab.engine

from attack_mode import AttackMode



class RadioController():
    """The class for interfacing with the radio through the matlab engine"""

    def __init__(self) -> None:
        # Start the matlab by either finding a session or creating a new engine
        # To start session: Open matlab -> Command window -> "matlab.engine.shareEngine"
        if matlab.engine.find_matlab():
            print("Found matlab session", matlab.engine.find_matlab())
            self.matlab_engine = matlab.engine.connect_matlab(matlab.engine.find_matlab()[0])
        else:
            print("Starting matlab engine")
            self.matlab_engine = matlab.engine.start_matlab()

        # Add all subfolders from MATLAB to working directory
        matlab_working_directory = os.path.join(os.getcwd(), "MATLAB")
        self.matlab_engine.addpath(self.matlab_engine.genpath(matlab_working_directory), nargout=0)
        
        self.radioFound: bool = False

    def __del__(self) -> None:
        # MATLAB engine must be quit before exit
        # print("Quitting matlab engine")
        self.matlab_engine.quit()
            
    def discover_radio(self, platform: str="B210", serial_number: str = "") -> None:
        out = io.StringIO()
        err = io.StringIO()
        radios = self.matlab_engine.configureSDR(platform, serial_number, nargout=2, stdout=out, stderr=err)
        self.validateMatlabOutput(out, err)
        self.rx = radios[0]
        self.tx = radios[1]
        self.radioFound = True

    def frequency_sweep(self, frequencies: list[int]):
        if not self.radioFound:
            raise Exception("Radio not found")


    def SSB_attack(self, frequency: int, attack_mode: AttackMode=AttackMode.SMART) -> None:
        raise NotImplementedError
        print("SSB attacking mode:", attack_mode)
    
    def PRACH_jam(self):
        raise NotImplementedError


    @staticmethod
    def validateMatlabOutput(out: io.StringIO, err: io.StringIO):
        if err.getvalue():
            raise Exception(err.getvalue())
        if "Warning:" in out.getvalue():
            start_index = out.getvalue().find('Warning:')
            end_index = out.getvalue().find('\n',start_index)
            start_string = out.getvalue()[start_index:end_index]
            raise Exception(start_string)
        
    @staticmethod
    def ARFCN_to_frequency(ARFCNs: list[int]) -> list[int]:
        """ Convert ARFCN to frequency in Hertz
        
        >>> RadioController.ARFCN_to_frequency([12345])
        [61725000]
        """
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
            else:
                raise ValueError(f"The ARFCN number: {ARFCN} is invalid!")

            # Calculate frequency
            centerFrequency = fRefOffset + (deltaFGlobal * (ARFCN - nRefOffset))
            res.append(centerFrequency)
        return res


    @staticmethod
    def GSCN_to_frequency(GSCNs: list[int]) -> list[int]:
        raise NotImplementedError
    
    """
        function getSSRef(gscn) {
        var retRes = -1;
        
        if ((gscn >= 2) && (gscn <= 7498)) {
            retRes = (gscn/3) * 1.200;
        } else if ((gscn >= 7499) && (gscn <= 22255)) {
            retRes = 3000 + (gscn - 7499) * 1.44;
        } else if ((gscn >= 22256) && (gscn <= 26639)) {
            retRes = 24250.08 + (gscn - 22256) * 17.28;
        } else {
            return - 1;
        }
        return Math.round(retRes*100)/100;
        }

        res = []
        for GSCN in GSCNs:
            if GSCN >= 2 and GSCN <= 7498:
                pass

            elif GSCN >= 7499 and GSCN <= 22255: 
                pass
                
            elif gscn >= 22256 and GSCN <= 26639:
                pass
                
            else:
                raise ValueError(f"The GSCN number: {GSCN} is invalid!")
            
            centerFrequency = round()
                
            res.append()
    """


if __name__ == "__main__":
    # Unit test
    # import doctest
    # doctest.testmod()
    
    # Example of use
    RC = RadioController()
    RC.discover_radio()
    print("Found radio")
    f = RC.ARFCN_to_frequency([155050, 371570, 423170, 628032, 628704, 630048, 636768, 647328])
    print("Performing ARFCN sweep with frequencies", f)
    RC.frequency_sweep(f)
    