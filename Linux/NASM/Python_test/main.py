import os
import ctypes
from benchParameters import parameters
from typing import List
from array import array
import time
from printResults import printResults
from benchParameters import parameters

import os
current_directory = os.path.dirname(os.path.abspath(__file__))
lib3 = ctypes.CDLL(os.path.join(current_directory, 'CleanNASM.so'))

# Set the argument types for the fibonacci_interop function
lib3.fibonacci_interop_nasm.argtypes = [
    ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_int, ctypes.c_int,
    ctypes.POINTER(ctypes.c_ulonglong), ctypes.POINTER(ctypes.c_bool), ctypes.POINTER(ctypes.c_double),
    ctypes.POINTER(ctypes.c_double)
]
lib3.fibonacci_interop_nasm.restype = ctypes.c_int

def execute_loop(nameTest: str, functionToTest) -> None:
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

    # List of time taken for the test to calculate the mean and the standard deviation
    listTimeCount: List[float] = []

    for _ in range(parameters.numberRun):
        start_time: float = time.time()  # Start the timer
        fbRet, arTerms, arPrimes, arError, goldenNbr = functionToTest()
        end_time: float = time.time()  # End the timer
        listTimeCount.append(end_time - start_time)  # Add the time taken in the list

    printResults(arPrimes, arTerms, goldenNbr, parameters.fiboMaxTerms, listTimeCount, nameTest)


def execute_nasm():
    arTerms = (ctypes.c_ulonglong * (parameters.fiboMaxTerms * 50))()  # Adjust size as needed
    arPrimes = (ctypes.c_bool * (parameters.fiboMaxTerms * 50))()  # Adjust size as needed
    arError = (ctypes.c_double * parameters.fiboMaxTerms)()  # Adjust size as needed
    goldenNbr = ctypes.c_double()

    result = lib3.fibonacci_interop_nasm(parameters.fiboStart, parameters.fiboMaxTerms, parameters.fiboMaxValue,
                                         parameters.fiboMaxFactor, parameters.fiboNbrOfLoops, arTerms, arPrimes, arError,
                                         ctypes.byref(goldenNbr))

    return result, arTerms, arPrimes, arError, goldenNbr.value

def main_nasm():
    nameTest: str = "NASM x64 SO"
    execute_loop(nameTest, execute_nasm)

if __name__ == "__main__":
    main_nasm()