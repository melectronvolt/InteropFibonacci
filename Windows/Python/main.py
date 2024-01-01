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

# List of time taken for the test to calculate the mean and the standard deviation
listTimeCount: List[float] = []

def execute_loop(nameTest: str, functionToTest)->None:
    for _ in range(loopTime):
        start_time: float = time.time()  # Start the timer
        fbRet, arTerms, arPrimes, arError, goldenNbr = functionToTest(parameters.fiboStart, parameters.fiboMaxTerms, parameters.fiboMaxValue,
                                                                      parameters.fiboMaxFactor, parameters.fiboNbrOfLoops)
        end_time: float = time.time()  # End the timer
        listTimeCount.append(end_time - start_time)  # Add the time taken in the list

    printResults(arPrimes, arTerms, goldenNbr, fiboMaxTerms, listTimeCount, nameTest)


# Parameters for the test
fiboMaxTerms: int = 74  # 74 is the maximum number of terms that can be calculated, it must fit in int64
loopTime: int = 1  # Number of times the test is performed
fiboStart: int = 1  # The first term of the fibonacci sequence
fiboMaxValue: int = 1304969544928657  # The maximum value of the fibonacci sequence, it must fit in int64
fiboMaxFactor: int = 4000000  # The maximum value of the factorization
fiboNbrOfLoops: int = 1  # The number of times the test is performed

def main_python():
    nameTest: str = "Python"
    execute_loop(nameTest, fibonacci_interop_python)

if __name__ == "__main__":
    main_python()
