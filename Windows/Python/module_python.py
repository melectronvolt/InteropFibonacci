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


class fbReturn(Enum):
    OK = 0
    TMT = 1
    TB = 2
    PRM_ERR = 3


def fibonacci_interop_python(fbStart: int, maxTerms: int, maxFibo: int, maxFactor: int, nbrOfLoops: int) \
        -> Tuple[fbReturn, List, List, List, float]:
    """ Calculate Fibonacci sequence values and related information.
       :param fbStart: int
          The two first terms of the Fibonacci sequence.
       :type fbStart: int
       :param maxTerms: int
          The maximum number of terms that can be calculated; it must fit in int64.
       :type maxTerms: int
       :param maxFibo: int
          The maximum value of the Fibonacci sequence; it must fit in int64.
       :type maxFibo: int
       :param maxFactor: int
          The maximum value of the factorization.
       :type maxFactor: int
       :param nbrOfLoops: int
          The number of times the test is performed.
       :type nbrOfLoops: int

       :return: Tuple[int, List, List, List, float]
          A tuple with the following components:
          - 0 (int): fbReturn.OK if the test is OK
          - 1 (List[int]): arTerms, a list of integer values (empty by default)
          - 2 (List[bool]): arPrimes, a list of boolean values (empty by default)
          - 3 (List[float]): arError, a list of float values (empty by default)
          - 4 (float): goldenConst, the golden constant

          Possible return values:
          - fbReturn.OK: Test is OK
          - fbReturn.TMT: maxTerms is too high
          - fbReturn.TB: maxFibo is too high
          - fbReturn.PRM_ERR: One of the parameters is not correct
    """
    arTerms: List[int] = []
    arPrimes: List[bool] = []
    arError: List[float] = []

    def isPrime(numberPrime: int) -> bool:
        """Check if the number is a prime number.

       :param numberPrime: int
          The number to be tested.
       :type numberPrime: int

       :return: bool
          True if the number is a prime number, False otherwise.

       :notes:
          This algorithm is a brute-force, non-optimized version. The goal is not to optimize it.

          If you want to optimize it, you can consider the following tips:
          - Avoid testing even numbers.
          - Stop testing when the divisor is greater than the square root of the number.

          You can also explore more efficient algorithms such as:
          - The sieve of Eratosthenes tables.
          - The Miller-Rabin algorithm, although it is not the purpose of this test.
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
        """Factorize the number and fill the array after the baseIndex with the factors.

               :param baseIndex: int
                  The base index of the array, which is a multiple of 50.
               :type baseIndex: int

               :return: None
                  This function does not return anything. It fills the arrays.

               :notes:
                  The maximum number of factors is 49.

                  The algorithm used here is not optimized; it's just a straightforward implementation.
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
