import os
import matlab.engine
from matlab import double


class RadioController():
    """
    Call this class as a with-object to ensure the connection is closed correctly:
    >>> with MATLAB_engine() as matlab:
    >>>    result = matlab.start_test_multiply_numbers(5, 2)
    >>>    print(result)
    """

    def __init__(self) -> None:
        matlabWD = os.path.join(os.getcwd(), "MATLAB")
        # Add all subfolders of MATLAB to path
        self.eng = matlab.engine.start_matlab()
        self.eng.addpath(self.eng.genpath(matlabWD), nargout=0)
        # nargout er Num ARGuments OUT - eller antallet af outputs man forventer

    def __enter__(self): return self

    def __exit__(self, exc_type, exc_value, traceback) -> None: self.eng.quit()
        
    def find_radio(self, serial_number: str = "") -> object:
        """Takes in a radio serial number and gain and returns a matlab.object with the radio settings
        :param serial_number: The serial number of the radio you wish to connect to
        :param gain:          The antenna gain in dBm. (range 0-76)
        """
        radio = self.eng.find_radio(serial_number)
        return radio

    def ARFCNSweep(self, radio_object:object, ARFCN_file:str, gain:int|None = None) -> object:
        out = self.eng.ARFCNSweep(radio_object, 'ARFCNDanmark.csv', double(40))
        print("Swept SSB's")
        print(out[0])
        return 1


if __name__ == "__main__":
    # Example of use
    with RadioController() as matlab:
        radio_object = matlab.find_radio()
        print("Found radio")
        matlab.ARFCNSweep(radio_object, "Idk")


