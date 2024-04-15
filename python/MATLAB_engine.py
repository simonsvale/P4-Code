class MATLAB_engine():
    """
    Call this class as a with-object to ensure the connection is closed correctly:
    with MATLAB_engine() as matlab:
        result = matlab.start_test_multiply_numbers(5, 2)
        print(result)

    Requirement: matlab.engine-pakke i Python
        Installation på Windows:
        > cd "[Matlab-path]\extern\engines\python"
          fx C:\Program Files\MATLAB\R2023b\extern\engines\python
        > py -m pip install .
    """
    
    from os import getcwd
    import matlab.engine

    def __init__(self) -> None:
        script_folder = "\code"
        self.cwd = self.getcwd() + script_folder
        self.cwd.replace('\\', '\\\\')

        self.eng = self.matlab.engine.start_matlab()
        self.eng.cd(self.cwd, nargout=0)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        self.eng.quit()

    def start_test_multiply_numbers(self, number_1:int, number_2:int) -> int:
        """Takes two integers as a parameter, passes the parameter to MATLAB, to multiply, and captures and returns the output"""
        output = self.eng._test_multiply_numbers(number_1, number_2)
        return output

    def start_device_test_script(self):
        self.eng._test_device_test(nargout=0)
        # nargout er Num ARGuments OUT - eller antallet af outputs man forventer

    def function_find_radio(self, serial_number:str, gain:int) -> object:
        """Takes in a radio serial number and gain and returns a matlab.object with the radio settings
        
        :param serial_number: The serial number of the radio you wish to connect to
        :param gain:          The antenna gain in dBm. (range 0-76)
        
        """
        if not serial_number in ["8000748", "8000758"]:
            raise Exception(f"Unknown serial number. Allowed inputs: '8000748' or '8000758'. Current value: serial_number = {serial_number}")
        if not 0 <= gain <= 76:
            raise Exception(f"Gain-value is out of range. Allowed input is from 0 to 76, current value: gain = {gain}")
        
        output = self.eng.function_find_radio(serial_number, gain)
        return output

class test():
    from os import getcwd

    def __init__(self) -> None:
        script_folder = "\code"
        self.cwd = self.getcwd() + script_folder
        self.cwd.replace('\\', '\\\\')

    def function_arfcn_sweep(self):
        
        with open(self.cwd + "\\ARFCNDanmark.csv") as file:
            print(file.read())

if __name__ == "__main__":
    test().function_arfcn_sweep()
    
    #with MATLAB_engine() as matlab:
        #result = matlab.start_test_multiply_numbers(5, 2)
        
        