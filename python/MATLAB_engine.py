class MATLAB_engine():
    """
    Call this class as a with-object to ensure the connection is closed correctly:
    >>> with MATLAB_engine() as matlab:
    >>>    result = matlab.start_test_multiply_numbers(5, 2)
    >>>    print(result)
    """
    
    from os import getcwd
    import matlab.engine

    def __init__(self) -> None:
        script_folder = "\\MATLAB\\functions"
        self.cwd = self.getcwd() + script_folder
        self.cwd.replace("\\", "\\\\")

        self.eng = self.matlab.engine.start_matlab()
        self.eng.cd(self.cwd, nargout=0)
        # nargout er Num ARGuments OUT - eller antallet af outputs man forventer

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        self.eng.quit()
        
    def find_radio(self, gain:int, serial_number:str|None = None) -> object:
        """
        Takes in a radio serial number and gain and returns a matlab.object with the radio settings
        
        :param serial_number: The serial number of the radio you wish to connect to
        :param gain:          The antenna gain in dBm (range 0-76)
        
        """
        if not serial_number in ["8000748", "8000758", None]:
            raise Exception(f"Unknown serial number. Allowed inputs: '8000748', '8000758', or None. Current value: serial_number = {serial_number}")
        if not 0 <= gain <= 76:
            raise Exception(f"Gain-value is out of range. Allowed input is from 0 to 76, current value: gain = {gain}")
        
        output = self.eng.find_radio(serial_number, gain)
        return output
    
    # ARFCNSweep(rx, ARFCNFile, captureDurationMiliseconds)

    def ARFCNSweep(self, radio_object:object, ARFCN_file:str, gain:int|None = None) -> object:
        """
        Takes in a radio object and uses it to scan entries in the ARFCN-list also attached
        
        :param radio_object:    The radio_object (rx object) to use when scanning the 
        :param ARFCN_File:      A list of which ARFCNs to scan for, formatted as a string with \\n as seperator
        :param gain:            Override for the antenna gain in dBm (range 0-76). If none is chosen, the one configured in the radio_object is used
        """
        #
        # <--------- Some code should be here, to configure paramters used in ARFCN Sweep
        #
        if not 0 <= gain <= 76 or None:
            raise Exception(f"Gain-value is out of range. Allowed input is from 0 to 76 or None, current value: gain = {gain}")        
        
        output = self.eng.ARFCNSweep()
        return output    

if __name__ == "__main__":
    # Example of use
    with MATLAB_engine() as matlab:
        radio_object = matlab.find_radio("8000748", 16)