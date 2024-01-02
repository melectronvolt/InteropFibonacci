__author__ = "Rémi MEVAERE"
__copyright__ = "Copyright (c) 2024 Rémi MEVAERE"
__license__ = "MIT License"

__version__ = "1.0.0"
__maintainer__ = "Rémi MEVAERE"
__email__ = "your.email@example.com"
__status__ = "Development"
__date__ = "2024-01-01"

from typing import List
from benchParameters import parameters


def mean(lst: List[float]) -> float:
    """Calculate the mean.

       :param lst: List[float]
          The list of values.
       :type lst: list of float

       :return: float
          The mean.
    """

    return sum(lst) / len(lst)


def standard_error(lst: List[float]) -> float:
    """Calculate the standard error.

       :param lst: List[float]
          The list of values.
       :type lst: list of float

       :return: float
          The standard error or -1 if failure.
    """
    # Calculate the variance (average of squared differences from the mean)
    if (len(lst) > 1):
        variance_correct = sum((x - mean(lst)) ** 2 for x in lst) / (len(lst) - 1)
        # Standard deviation is the square root of the variance
        std_dev_correct = variance_correct ** 0.5
        se = std_dev_correct / len(lst) ** 0.5
        return se
    else:
        return -1


def standard_deviation(lst: List[float]) -> float:
    """Calculate the standard deviation.

       :param lst: List[float]
          The list of values.
       :type lst: list of float

       :return: float
          The standard deviation.
    """
    # Calculate the variance (average of squared differences from the mean)
    variance = sum((x - mean(lst)) ** 2 for x in lst) / len(lst)
    # Standard deviation is the square root of the variance
    std_dev = variance ** 0.5
    return std_dev


def printResults(arPrimes, arTerms, goldenNbr, maxTerms, listTimeCount, nameTest):
    """Print the results of the test, exploit value from the arrays.

   :param arPrimes: array of bool
      If it is True it is a prime number.
   :type arPrimes: list of bool
   :param arTerms: array of int64 items (max)
      Each term of the fibonacci sequence is stored in this array.
      For each 50 items, the first is the current term, the 49 others are the factors.
   :type arTerms: list of int64 items (max)
   :param goldenNbr: float
      The golden number, not calculated by the division, but directly with (1 + sqrt(5)) / 2.
   :type goldenNbr: float
   :param maxTerms: unsigned char
      The maximum number of terms that can be calculated, it must fit in int64.
   :type maxTerms: unsigned char
   :param listTimeCount: array of float
      The time taken for the test.
   :type listTimeCount: list of float
   :param nameTest: str
      The name of the test.
   :type nameTest: str

   :return: None
      This function does not return anything. It prints the results.

   :notes:
      This function prints the results of a test, including the prime numbers,
      terms, the golden number, the maximum number of terms, the time taken,
      and the name of the test.
    """
    if parameters.showResult:
        for i in range(0, maxTerms):
            ligne = ''
            baseIndex = i * 50
            if arTerms[baseIndex]:
                if arPrimes[baseIndex]:
                    ligne += f"{i + 1} - [{arTerms[baseIndex]}] : "
                else:
                    ligne += f"{i + 1} - {arTerms[baseIndex]} : "
                addValue = False
                for position in range(1, 50):
                    index = baseIndex + position
                    if arTerms[index]:
                        if arPrimes[index]:
                            ligne += f"[{arTerms[index]}] x "
                        else:
                            ligne += f"{arTerms[index]} x "
                        addValue = True
                if addValue:
                    ligne = ligne[:- 3]
                else:
                    ligne += "Factor not found"
            if ligne:
                print(ligne)
    print("--------------------------------------------------")
    print(nameTest)
    print("Golden Number : ", goldenNbr)
    print("Mean execution time(s) : " + str(mean(listTimeCount)))
    print("Standard Deviation (s) : " + str(standard_deviation(listTimeCount)))
    print("Standard Error (s) : " + str(standard_error(listTimeCount)))
