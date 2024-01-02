_author__ = "Rémi MEVAERE"
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
import os


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


def execute_python():
    """Execute the test in Python."""
    return fibonacci_interop_python(parameters.fiboStart, parameters.fiboMaxTerms,
                                    parameters.fiboMaxValue,
                                    parameters.fiboMaxFactor, parameters.fiboNbrOfLoops)


def main_python():
    nameTest: str = "Python"
    execute_loop(nameTest, execute_python)


if __name__ == "__main__":
    main_python()
