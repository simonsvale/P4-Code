# P4-Matlab-Code
 
## MATLAB

### How to open MATLAB project
To open the MATLAB project:
1. Open MATLAB.
2. Navigate to **HOME**. Then under **FILE** chose **OPEN**.
3. Open the `MATLAB.prj` file.

### How to run MATLAB scripts from MATLAB
1. Start MATLAB and open the project.
2. Navigate to `scripts` and open a file.
3. To run it, press **RUN** under the **EDITOR** section or use the keyboard shortcut **F5**.

### Run unit test
To run every test use the following command in MATLAB
```
>> runtests
```

## Python

### Requirements
| package | version |
|---|---|
| matlabengine | 23.2 |    

### How to install Python MATLAB engine

#### Linux
For Linux, is is recommended to install MATLAB engine via a virtual Python environment. 

> **_NOTE:_**    that you must have install symbolic links for MATLAB in order for MATLAB engine to function. Please see the [pypi.org/project/matlabengine/](https://pypi.org/project/matlabengine/) docs for more detail.

1. Setup a virtual environment called `.venv`
    ```
    $ python3 -m venv .venv
    ```
2. Activate the virtual environment
    ```
    $ source .venv/bin/activate
    ```
3. Install dependencies
    ```
    pip install -r python/requirements.txt
    ```

#### Windows
    cd "C:\Program Files\MATLAB\R2023b\extern\engines\python"
    $ python -m pip install .

### Run unit test
1. To execute all unit tests, navigating to the python folder  
    ```
    $ cd python
    ```
2. Then, run every test
    ```
    $ python3 -m unittest discover
    ```
