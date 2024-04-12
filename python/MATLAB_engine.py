from os import getcwd
import matlab.engine

class MATLAB_engine():
    """
    Requirement:
        Installation af matlab.engine på Windows:
        > cd "[Matlab-path]\extern\engines\python"
          fx C:\Program Files\MATLAB\R2023b\extern\engines\python
        > py -m pip install .
    """
    
    def __init__(self) -> None:
        script_folder = "\code"
        cwd = getcwd() + script_folder
        cwd.replace('\\', '\\\\')

        self.eng = matlab.engine.start_matlab()
        self.eng.cd(cwd, nargout=0)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        self.eng.quit()

    def start_test_script(self):
        self.eng._test_function("hej med dig", nargout=0)

    def start_device_test_script(self):
        self.eng.matlab_test(nargout=0)


if __name__ == "__main__":
    with MATLAB_engine() as matlab:
        #matlab.start_test_script()
        matlab.start_device_test_script()