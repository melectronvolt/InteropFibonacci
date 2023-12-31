from enum import Enum
from math import sqrt
from typing import List
import time

class fbReturn(Enum):
    OK = 0
    NOL = 1
    OF_P = 2
    OF = 3
    TMT = 4
    TB = 5
    PRM_ERR = 6
    ERR = 7


def fibonacci_interop_python(fbStart, maxTerms=74, maxFibo=1304969544928657, maxFactor=5000, nbrOfLoops=1):
    # Declare the lists
    arTerms: List[int] = []
    arPrimes: List[bool] = []
    arError: List[float] = []

    def isPrime(numberPrime):
        maxSearch = numberPrime if numberPrime < maxFactor else maxFactor
        for i in range(2, maxSearch):
            if (numberPrime % i) == 0:
                return False
        return True

    def factorization(baseIndex):
        # Prime number and factorization
        position = 0
        result = arTerms[baseIndex]
        testNbr = 2

        while result != 1:
            if (result % testNbr) == 0:
                position += 1
                arTerms[baseIndex + position] = testNbr
                arPrimes[baseIndex + position] = isPrime(testNbr)
                result /= testNbr
                if position == 49:
                    break
                continue
            testNbr += 1
            if testNbr > maxFactor:
                break

    if (fbStart < 1) or (maxFibo < 1) or (maxTerms < 3) or (maxFactor < 2) or (nbrOfLoops < 1):
        return fbReturn.PRM_ERR, None, None, None

    if maxTerms > 74:
        return fbReturn.TMT, None, None, None

    if maxFibo > 1304969544928657:
        return fbReturn.TB, None, None, None

    # Get the golden value
    goldenConst = (1 + sqrt(5)) / 2

    for _ in range(nbrOfLoops):
        # Fill the lists
        arTerms = [0] * maxTerms * 50
        arTerms[0] = fbStart
        arTerms[50] = fbStart
        arPrimes = [0] * maxTerms * 50
        arError = [0] * maxTerms

        factorization(0)
        factorization(50)

        for currentTerm in range(2, maxTerms):
            baseIndex = currentTerm * 50
            arTerms[baseIndex] = arTerms[baseIndex - 50] + arTerms[baseIndex - 2 * 50]
            arPrimes[baseIndex] = isPrime(arTerms[baseIndex])
            arError[currentTerm] = abs(goldenConst - (arTerms[baseIndex] / arTerms[baseIndex - 50]))
            factorization(baseIndex)
        goldenNbr = (arTerms[(maxTerms - 1) * 50] / arTerms[(maxTerms - 2) * 50])

    return fbReturn.OK, arTerms, arPrimes, arError, goldenNbr


def mean(lst):
    # Calculate the mean
    return sum(lst) / len(lst)


def standard_deviation(lst):
    # Calculate the mean
    mean = sum(lst) / len(lst)

    # Calculate the variance (average of squared differences from the mean)
    variance = sum((x - mean) ** 2 for x in lst) / len(lst)

    # Standard deviation is the square root of the variance
    std_dev = variance ** 0.5
    return std_dev



def main():
    maxTerms = 74

    timeCount = []

    for _ in range(20):
        start_time = time.time()  # Start the timer
        fbRet, arTerms, arPrimes, arError, goldenNbr = fibonacci_interop_python(1, maxTerms, 1304969544928657, 4000000,
                                                                                7)
        end_time = time.time()  # End the timer
        timeCount.append(end_time - start_time)

    # for i in range(0, maxTerms):
    #     ligne = ''
    #     baseIndex = i * 50
    #     if arTerms[baseIndex]:
    #         if arPrimes[baseIndex]:
    #             ligne += f"{i} - [{arTerms[baseIndex]}] : "
    #         else:
    #             ligne += f"{i} - {arTerms[baseIndex]} : "
    #         addValue = False
    #         for position in range(1, 50):
    #             index = baseIndex + position
    #             if arTerms[index]:
    #                 if arPrimes[index]:
    #                     ligne += f"[{arTerms[index]}] x "
    #                 else:
    #                     ligne += f"{arTerms[index]} x "
    #                 addValue = True
    #
    #         if addValue:
    #             ligne = ligne[:- 3]
    #         else:
    #             ligne += "Factor not found"
    #     print(ligne)
    #
    # print("Golden Number : ", goldenNbr)

    print("PYTHON ---------------------------------")
    print("Durée moyenne : " + str(mean(timeCount)))
    print("Standard Deviation : " + str(standard_deviation(timeCount)))

if __name__ == "__main__":
    main()
