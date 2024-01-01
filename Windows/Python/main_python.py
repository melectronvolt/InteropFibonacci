__author__ = "Rémi MEVAERE"
__copyright__ = "Copyright (c) 2024 Rémi MEVAERE"
__license__ = "MIT License"
__version__ = "1.0.0"
__maintainer__ = "Rémi MEVAERE"
__email__ = "your.email@example.com"
__status__ = "Development"
__date__ = "2024-01-01"


from enum import Enum
from math import sqrt
from typing import List, Tuple
import time


class fbReturn(Enum):
    OK = 0
    TMT = 1
    TB = 2
    PRM_ERR = 3




# List of time taken for the test to calculate the mean and the standard deviation
listTimeCount: List[float] = []


def fibonacci_interop_python(fbStart: int, maxTerms: int, maxFibo: int, maxFactor: int, nbrOfLoops: int) -> Tuple[
    fbReturn, List, List, List, float]:
    """

    Parameters
    ----------
    fbStart: int
        The two first terms of the fibonacci sequence.
    maxTerms: int
        The maximum number of terms that can be calculated, it must fit in int64.
    maxFibo: int
        The maximum value of the fibonacci sequence, it must fit in int64.
    maxFactor: int
        The maximum value of the factorization.
    nbrOfLoops: int
        The number of times the test is performed.

    Returns
    -------
    Tuple[int, List, List, List, float]
        - fbReturn.OK if the test is OK
        - fbReturn.TMT if the maxTerms is too high
        - fbReturn.TB if the maxFibo is too high
        - fbReturn.PRM_ERR if one of the parameters is not correct
        - arTerms: List[int] = []
        - arPrimes: List[bool] = []
        - arError: List[float] = []
        - goldenConst: float
    """
    arTerms: List[int] = []
    arPrimes: List[bool] = []
    arError: List[float] = []

    def isPrime(numberPrime: int) -> bool:
        """
        Check if the number is a prime number.

        Parameters
        ----------
        numberPrime: int
            The number to be tested.

        Returns
        -------
        bool:
            True if the number is a prime number, False otherwise.

        Notes
        -----
        This algorithm is bruteforce stupid version, it is not optimized, the goal is not to optimize it.

        If you want to optimize it, you can use the following tips :
            You can avoid :
                - the even numbers,
                - the number greater than the square root of the number to be tested

            You can use :
                - the sieve of Eratosthenes tables
                - the Miller-Rabin algorithm, but it is not the purpose of this test.
        """

        # MaxSearch to don't test all the numbers
        maxSearch: int = numberPrime if numberPrime < maxFactor else maxFactor

        for i in range(2, maxSearch):
            # It's not a prime number if it is divisible by another number (except 1 and itself)
            # The module operator (%) returns the remainder of the division
            if (numberPrime % i) == 0:
                return False
        return True

    def factorization(baseIndex: int) -> None:
        """
        Factorize the number, and fill the array after the baseIndex with the factors.
        The maximum number of factors is 49.
        The algorithm is not optimized at all, it's just straightforward.

        Parameters
        ----------
        baseIndex:int
            The base index of the array which is a multiple of 50.

        Returns
        -------
            None
                This function does not return anything. It fills the arrays.
        """
        position: int = 0  # The offset in the array after baseIndex
        result = arTerms[baseIndex]  # The number to be factorized
        testNbr = 2  # The number to be tested (1 is not tested, it is useless)

        while result != 1:  # While the number is not factorized
            if (result % testNbr) == 0:  # If the number is divisible by the test number
                position += 1  # We increment the offset in the array
                arTerms[baseIndex + position] = testNbr  # We add the factor in the array
                arPrimes[baseIndex + position] = isPrime(
                    testNbr)  # We check if the factor is a prime number and we add it in the array
                result /= testNbr  # We divide the number by the factor
                if position == 49:  # If the offset is 49, leave the loop, it was the last factor that could be entered in the array
                    break
                continue
            testNbr += 1  # We test the next number
            if testNbr > maxFactor:  # If the test number is greater than the maximum factor, leave the loop
                break

    # Check the parameters
    if (fbStart < 1) or (maxFibo < 1) or (maxTerms < 3) or (maxFactor < 2) or (nbrOfLoops < 1):
        return fbReturn.PRM_ERR, None, None, None, None

    if maxTerms > 74:
        return fbReturn.TMT, None, None, None, None

    if maxFibo > 1304969544928657:
        return fbReturn.TB, None, None, None, None

    # Compute the golden number
    goldenConst: float = (1 + sqrt(5)) / 2

    # Loop for benchmarks
    for _ in range(nbrOfLoops):

        # Fill the lists with 0, or false
        arTerms = [0] * maxTerms * 50
        arTerms[0] = fbStart
        arTerms[50] = fbStart
        arPrimes = [0] * maxTerms * 50
        arError = [0] * maxTerms

        # Factorize the first two terms
        factorization(0)
        factorization(50)

        for currentTerm in range(2, maxTerms):  # Loop for the fibonacci sequence
            baseIndex = currentTerm * 50  # The base index of the array which is a multiple of 50
            nextValue = arTerms[baseIndex - 50] + arTerms[
                baseIndex - 2 * 50]  # The next value of the fibonacci sequence

            if nextValue > maxFibo:  # If the next value is greater than the maximum value, leave the loop
                return fbReturn.OK, arTerms, arPrimes, arError, goldenConst

            arTerms[baseIndex] = nextValue  # We add the next value in the array
            arPrimes[baseIndex] = isPrime(
                arTerms[baseIndex])  # We check if the next value is a prime number and we add it in the array
            arError[currentTerm] = abs(
                goldenConst - (arTerms[baseIndex] / arTerms[baseIndex - 50]))  # We calculate the error
            factorization(baseIndex)  # We factorize this value

    return fbReturn.OK, arTerms, arPrimes, arError, goldenConst


def mean(lst: List[float]) -> float:
    """
        Calculate the mean

    Parameters
    ----------
    lst: List[float]
        The list of values

    Returns
    -------
    float
        The mean
    """

    return sum(lst) / len(lst)


def standard_deviation(lst: List[float]) -> float:
    """
        Calculate the standard deviation
    Parameters
    ----------
    lst : List[float]
        The list of values

    Returns
    -------
    float
        The standard deviation
    """
    # Calculate the variance (average of squared differences from the mean)
    variance = sum((x - mean(lst)) ** 2 for x in lst) / len(lst)
    # Standard deviation is the square root of the variance
    std_dev = variance ** 0.5
    return std_dev


def main_python():
    nameTest: str = "Python"

    for _ in range(loopTime):
        start_time: float = time.time()  # Start the timer
        fbRet, arTerms, arPrimes, arError, goldenNbr = fibonacci_interop_python(fiboStart, fiboMaxTerms, fiboMaxValue,
                                                                                fiboMaxFactor, fiboNbrOfLoops)
        end_time: float = time.time()  # End the timer
        listTimeCount.append(end_time - start_time)  # Add the time taken in the list

    printResults(arPrimes, arTerms, goldenNbr, fiboMaxTerms, listTimeCount, nameTest)


def printResults(arPrimes, arTerms, goldenNbr, maxTerms, listTimeCount, nameTest):
    """
    Print the results of the test, exploit value from the arrays.

    Parameters
    ----------
    arPrimes : array of bool
        If it is True it is a prime number.
    arTerms : array of int64 items (max)
        Each terms of the fibonacci sequence is stored in this array
        For each 50 items, the first is the current term, the 49 others are the factors.
    goldenNbr : float
        The golden number, not calculated by the division, but directly with (1 + sqrt(5)) / 2
    maxTerms : unsigned char
        The maximum number of terms that can be calculated, it must fit in int64.
    listTimeCount : array of float
        The time taken for the test.
    nameTest : str
        The name of the test.

    Returns
    -------
    None
        This function does not return anything. It prints the results.

    Notes
    -----
    This function prints the results of a test, including the prime numbers,
    terms, the golden number, the maximum number of terms, the time taken,
    and the name of the test.
    """
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
    print("Durée moyenne : " + str(mean(listTimeCount)))
    print("Standard Deviation : " + str(standard_deviation(listTimeCount)))
    print("--------------------------------------------------")


if __name__ == "__main__":
    main_python()
