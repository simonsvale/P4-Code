from oct2py import Oct2Py

def initialize_octave():
    oc = Oct2Py()
    oc.source('code/ARFCNSweep.m')
    return oc

def cleanup_octave(oc):
    oc.exit()

def ARFCNSweep(oc: Oct2Py):
    sweepResult = oc.ARFCNSweep()
    return sweepResult

if __name__ == '__main__':
    oc = initialize_octave()
    result = ARFCNSweep(oc)
    print("Result of the sweep:", result)