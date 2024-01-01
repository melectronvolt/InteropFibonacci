__author__ = "Rémi MEVAERE"
__copyright__ = "Copyright (c) 2024 Rémi MEVAERE"
__license__ = "MIT License"
__version__ = "1.0.0"
__maintainer__ = "Rémi MEVAERE"
__email__ = "your.email@example.com"
__status__ = "Development"
__date__ = "2024-01-01"



import time
from printResults import printResults
from benchParameters import parameters
from module_python import fibonacci_interop_python
from typing import List
from fiboCython import fibonacci_interop_cython
from fiboCythonFull import fibonacci_interop_cython_full
from array import array
import ctypes

from pythonnet import load
load("coreclr")
import clr  # Import CLR from Python.NET
import os
clr.AddReference('System')
current_directory = os.getcwd()
clr.AddReference(os.path.join(current_directory, 'DllFibonacci.dll'))
from DllFibonacci import MyFiboClass
from System import Array
from System import UInt64, Boolean, Single, Double
from System.Runtime.InteropServices import GCHandle, GCHandleType

# Load the DLL
lib = ctypes.CDLL(os.path.join(current_directory, 'InteropFibonacciWinCPP.dll'))  # Update with the correct path to your DLL

# Set the argument types for the fibonacci_interop function
lib.fibonacci_interop_cpp.argtypes = [
    ctypes.c_ulonglong, ctypes.c_ubyte, ctypes.c_longlong, ctypes.c_ulonglong, ctypes.c_ubyte,
    ctypes.POINTER(ctypes.c_ulonglong), ctypes.POINTER(ctypes.c_bool), ctypes.POINTER(ctypes.c_double),
    ctypes.POINTER(ctypes.c_double)
]

# Set the return type for the fibonacci_interop function
lib.fibonacci_interop_cpp.restype = ctypes.c_int

# List of time taken for the test to calculate the mean and the standard deviation
listTimeCount: List[float] = []

def execute_loop(nameTest: str, functionToTest)->None:
    """Execute a test loop for a given function and print the results.

   This function performs a test loop for a specified function and prints the results.
   It runs the function `parameters.numberRun` times, measuring the time taken for each run.
   After the loop, it calculates and prints the results, including prime numbers,
   terms, the golden number, and the time taken.

   :param nameTest: str
      The name of the test.
   :type nameTest: str
   :param functionToTest: callable
      The function to be tested. It should have the signature `() -> Tuple`.
   :type functionToTest: callable

   :return: None
      This function does not return anything but prints the test results."""

    for _ in range(parameters.numberRun):
        start_time: float = time.time()  # Start the timer
        fbRet, arTerms, arPrimes, arError, goldenNbr = functionToTest()
        end_time: float = time.time()  # End the timer
        listTimeCount.append(end_time - start_time)  # Add the time taken in the list

    printResults(arPrimes, arTerms, goldenNbr, parameters.fiboMaxTerms, listTimeCount, nameTest)

def execute_python():
    """Execute the test in Python."""
    return fibonacci_interop_python(parameters.fiboStart, parameters.fiboMaxTerms,
                                                                  parameters.fiboMaxValue,
                                                                  parameters.fiboMaxFactor, parameters.fiboNbrOfLoops)

def execute_cython():
    """Execute the test in Cython."""
    arTerms = array('Q', [0] * parameters.fiboMaxTerms * 50)  # 'Q' for unsigned long long
    arPrimes = array('b', [0] * parameters.fiboMaxTerms * 50)  # 'b' for signed char
    arError = array('d', [0] * parameters.fiboMaxTerms)  # 'f' for double

    fbRet, goldenNbr = fibonacci_interop_cython(parameters.fiboStart, parameters.fiboMaxTerms, parameters.fiboMaxValue, parameters.fiboMaxFactor, parameters.fiboNbrOfLoops, arTerms, arPrimes, arError)
    return fbRet, arTerms, arPrimes, arError, goldenNbr


def execute_dotnet():
    arTerms = Array[UInt64](range(parameters.fiboMaxTerms * 50))
    arPrimes = Array[Boolean]([False] * (parameters.fiboMaxTerms * 50))
    arError = Array[Double]([0.0] * parameters.fiboMaxTerms)

    # Call the method
    # Initialize the out parameter as a reference
    goldenNbr = Array[Double]([0.0])

    fibonacciResult = MyFiboClass.fibonacci_interop_cs(parameters.fiboStart, parameters.fiboMaxTerms, parameters.fiboMaxValue, parameters.fiboMaxFactor, parameters.fiboNbrOfLoops, arTerms,
                                                   arPrimes, arError)

    result = fibonacciResult.Result
    return result, arTerms, arPrimes, arError, fibonacciResult.GoldenNumber

def execute_cpp():
    arTerms = (ctypes.c_ulonglong * (parameters.fiboMaxTerms * 50))()  # Adjust size as needed
    arPrimes = (ctypes.c_bool * (parameters.fiboMaxTerms * 50))()  # Adjust size as needed
    arError = (ctypes.c_double * parameters.fiboMaxTerms)()  # Adjust size as needed
    goldenNbr = ctypes.c_double()

    result = lib.fibonacci_interop_cpp(parameters.fiboStart, parameters.fiboMaxTerms, parameters.fiboMaxValue, parameters.fiboMaxFactor, parameters.fiboNbrOfLoops, arTerms, arPrimes, arError,
                                   ctypes.byref(goldenNbr))
    return result, arTerms, arPrimes, arError, goldenNbr.value

def main_dotnet():
    nameTest: str = "Dotnet Core"
    execute_loop(nameTest, execute_dotnet)

def main_cython_full():
    """Execute the test in Cython Full Version."""
    fibonacci_interop_cython_full(parameters.fiboStart, parameters.fiboMaxTerms, parameters.fiboMaxValue, parameters.fiboMaxFactor, parameters.fiboNbrOfLoops, parameters.numberRun)

def main_python():
    nameTest: str = "Python"
    execute_loop(nameTest, execute_python)

def main_cython():
    nameTest: str = "Cython"
    execute_loop(nameTest, execute_cython)

def main_cpp_dll():
    nameTest: str = "C++ DLL"
    execute_loop(nameTest, execute_cpp)

if __name__ == "__main__":
    # main_python()
    # main_cython()
    # main_cython_full()
    # main_dotnet()
    main_cpp_dll()