from enum import Enum
from math import sqrt
from typing import List
import time
from fibonacci import fibonacci_interop
from fibonacci2 import fibonacci_fullinterop
from array import array
from ctypes import byref, c_double
from pythonnet import load

load("coreclr")
import clr  # Import CLR from Python.NET


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


def main_dotnet():
    # Load the DLL (provide the full path if it's not in the same directory)
    clr.AddReference('System')
    clr.AddReference(
        'F:\\OtherProjects\\InteropFibonacci\\Windows\\C#\\InteropFibonacci\\DllFibonacci\\bin\\Debug\\net8.0\\DllFibonacci.dll')
    # Import the namespace
    from DllFibonacci import MyFiboClass
    from System import Array
    from System import UInt64, Boolean, Single, Double
    from System.Runtime.InteropServices import GCHandle, GCHandleType

    # Prepare parameters
    fbStart = 1
    maxTerms = 74
    maxFibo = 1304969544928657
    maxFactor = 4000000
    nbrOfLoops = 7

    # Since arrays in C# are different from Python lists, we need to create them in a compatible way
    timeCount = []

    for _ in range(20):
        start_time = time.time()  # Start the timer
        # Correctly create the arrays using .NET types
        arTerms = Array[UInt64](range(maxTerms * 50))
        arPrimes = Array[Boolean]([False] * (maxTerms * 50))
        arError = Array[Single]([0.0] * maxTerms)

        # Call the method
        # Initialize the out parameter as a reference
        goldenNbr = Array[Double]([0.0])

        fibonacciResult = MyFiboClass.FibonacciInterop(fbStart, maxTerms, maxFibo, maxFactor, nbrOfLoops, arTerms, arPrimes, arError)

        result = fibonacciResult.Result
        goldenNumberValue = fibonacciResult.GoldenNumber
        end_time = time.time()  # End the timer
        timeCount.append(end_time - start_time)

    # Check the result and process the output
    for i in range(0, maxTerms):
        ligne = ''
        baseIndex = i * 50
        if arTerms[baseIndex]:
            if arPrimes[baseIndex]:
                ligne += f"{i} - [{arTerms[baseIndex]}] : "
            else:
                ligne += f"{i} - {arTerms[baseIndex]} : "
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
        print(ligne)

    print("Golden Number : ", goldenNumberValue)

    print("DOTNET C# ---------------------------------")
    print("Durée moyenne : " + str(mean(timeCount)))
    print("Standard Deviation : " + str(standard_deviation(timeCount)))


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


def main_cython():
    maxTerms = 74
    timeCount = []

    for _ in range(20):
        start_time = time.time()  # Start the timer
        arTerms = array('Q', [0] * maxTerms * 50)  # 'Q' for unsigned long long
        arPrimes = array('b', [0] * maxTerms * 50)  # 'b' for signed char
        arError = array('f', [0] * maxTerms)  # 'f' for float

        fbRet, goldenNbr = fibonacci_interop(1, maxTerms, 1304969544928657, 4000000, 7, arTerms, arPrimes, arError)

        end_time = time.time()  # End the timer
        timeCount.append(end_time - start_time)

    for i in range(0, maxTerms):
        ligne = ''
        baseIndex = i * 50
        if arTerms[baseIndex]:
            if arPrimes[baseIndex]:
                ligne += f"{i} - [{arTerms[baseIndex]}] : "
            else:
                ligne += f"{i} - {arTerms[baseIndex]} : "
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
        print(ligne)

    print("Golden Number : ", goldenNbr)

    print("CYTHON ---------------------------------")
    print("Durée moyenne : " + str(mean(timeCount)))
    print("Standard Deviation : " + str(standard_deviation(timeCount)))


def main_dll():
    import ctypes

    # Load the DLL
    lib = ctypes.CDLL(
        'F:\\OtherProjects\\InteropFibonacci\\Windows\\Python\\InteropFibonacciWin.dll')  # Update with the correct path to your DLL

    # Set the argument types for the fibonacci_interop function
    lib.fibonacci_interop.argtypes = [
        ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_int, ctypes.c_int,
        ctypes.POINTER(ctypes.c_ulonglong), ctypes.POINTER(ctypes.c_bool), ctypes.POINTER(ctypes.c_float),
        ctypes.POINTER(ctypes.c_double)
    ]

    # Set the return type for the fibonacci_interop function
    lib.fibonacci_interop.restype = ctypes.c_int

    # Prepare to call the function (example, replace with actual values)
    fbStart = 1
    maxTerms = 74
    maxFibo = 1304969544928657
    maxFactor = 4000000
    nbrOfLoops = 7
    arTerms = (ctypes.c_ulonglong * (maxTerms * 50))()  # Adjust size as needed
    arPrimes = (ctypes.c_bool * (maxTerms * 50))()  # Adjust size as needed
    arError = (ctypes.c_float * maxTerms)()  # Adjust size as needed
    goldenNbr = ctypes.c_double()

    timeCount = []

    # Call the function
    for _ in range(10):
        start_time = time.time()  # Start the timer
        result = lib.fibonacci_interop(fbStart, maxTerms, maxFibo, maxFactor, nbrOfLoops, arTerms, arPrimes, arError,
                                       ctypes.byref(goldenNbr))
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
    # print("Golden Number : ", goldenNbr.value)

    print("DLL ---------------------------------")
    print("Durée moyenne : " + str(mean(timeCount)))
    print("Standard Deviation : " + str(standard_deviation(timeCount)))

def main_dll_ASM():
    import ctypes

    # Load the DLL
    lib = ctypes.CDLL(
        'F:\\OtherProjects\\InteropFibonacci\\Windows\\Python\\FiboASMx64.dll')  # Update with the correct path to your DLL

    # Set the argument types for the fibonacci_interop function
    lib.fibonacci_interop_asm.argtypes = [
        ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_int, ctypes.c_int,
        ctypes.POINTER(ctypes.c_ulonglong), ctypes.POINTER(ctypes.c_bool), ctypes.POINTER(ctypes.c_float),
        ctypes.POINTER(ctypes.c_double)
    ]

    # Set the return type for the fibonacci_interop function
    lib.fibonacci_interop_asm.restype = ctypes.c_int

    # Prepare to call the function (example, replace with actual values)
    fbStart = 1
    maxTerms = 74
    maxFibo = 1304969544928657
    maxFactor = 4000000
    nbrOfLoops = 7
    arTerms = (ctypes.c_ulonglong * (maxTerms * 50))()  # Adjust size as needed
    arPrimes = (ctypes.c_bool * (maxTerms * 50))()  # Adjust size as needed
    arError = (ctypes.c_float * maxTerms)()  # Adjust size as needed
    goldenNbr = ctypes.c_double()

    timeCount = []

    # Call the function
    for _ in range(20):
        start_time = time.time()  # Start the timer
        result = lib.fibonacci_interop_asm(fbStart, maxTerms, maxFibo, maxFactor, nbrOfLoops, arTerms, arPrimes, arError,
                                       ctypes.byref(goldenNbr))
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
    # print("Golden Number : ", goldenNbr.value)

    print("DLL ASM ---------------------------------")
    print("Durée moyenne : " + str(mean(timeCount)))
    print("Standard Deviation : " + str(standard_deviation(timeCount)))

def main_cython_full():
    fibonacci_fullinterop(1, 74, 1304969544928657, 4000000, 7)


if __name__ == "__main__":
    main_cython()
    # main_cython_full()
    # main_dll()
    # main_dll_ASM()
    # main()
    # main_dotnet()
