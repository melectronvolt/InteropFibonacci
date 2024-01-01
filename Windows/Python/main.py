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

# List of time taken for the test to calculate the mean and the standard deviation
listTimeCount: List[float] = []


def execute_loop(nameTest: str, functionToTest)->None:
    for _ in range(parameters.loopTime):
        start_time: float = time.time()  # Start the timer
        fbRet, arTerms, arPrimes, arError, goldenNbr = functionToTest()
        end_time: float = time.time()  # End the timer
        listTimeCount.append(end_time - start_time)  # Add the time taken in the list

    printResults(arPrimes, arTerms, goldenNbr, parameters.fiboMaxTerms, listTimeCount, nameTest)

def execute_python():
    return fibonacci_interop_python(parameters.fiboStart, parameters.fiboMaxTerms,
                                                                  parameters.fiboMaxValue,
                                                                  parameters.fiboMaxFactor, parameters.fiboNbrOfLoops)

def execute_cython():
    arTerms = array('Q', [0] * parameters.fiboMaxTerms * 50)  # 'Q' for unsigned long long
    arPrimes = array('b', [0] * parameters.fiboMaxTerms * 50)  # 'b' for signed char
    arError = array('f', [0] * parameters.fiboMaxTerms)  # 'f' for float

    fbRet, goldenNbr = fibonacci_interop_cython(parameters.fiboStart, parameters.fiboMaxTerms, parameters.fiboMaxValue, parameters.fiboMaxFactor, parameters.fiboNbrOfLoops, arTerms, arPrimes, arError)
    return fbRet, arTerms, arPrimes, arError, goldenNbr



def main_python():
    nameTest: str = "Python"
    execute_loop(nameTest, execute_python)

def main_cython():
    nameTest: str = "Cython"
    execute_loop(nameTest, execute_cython)


def main_cython_full():
    fibonacci_interop_cython_full(parameters.fiboStart, parameters.fiboMaxTerms, parameters.fiboMaxValue, parameters.fiboMaxFactor, parameters.fiboNbrOfLoops)

if __name__ == "__main__":
    # main_python()
    # main_cython()
    main_cython_full()
