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
        cwd = self.getcwd() + script_folder
        cwd.replace('\\', '\\\\')

        self.eng = self.matlab.engine.start_matlab()
        self.eng.cd(cwd, nargout=0)

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


if __name__ == "__main__":
    with MATLAB_engine() as matlab:
        result = matlab.start_test_multiply_numbers(5, 2)
        print(result)
        
        #matlab.start_device_test_script()