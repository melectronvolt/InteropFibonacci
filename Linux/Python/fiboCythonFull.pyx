# cython: language_level=3

# Cythonized version 2 of the Fibonacci program
# No Docstring for this file, it's essentially the same as the Python version with type declarations
# Some comments are added to explain the Cython specificities

__author__ = "Rémi MEVAERE"
__copyright__ = "Copyright (c) 2024 Rémi MEVAERE"
__license__ = "MIT License"
__version__ = "1.0.0"
__maintainer__ = "Rémi MEVAERE"
__email__ = "github@volt.melectron.fr"
__website__ = "spnet.fr"
__status__ = "Development"
__date__ = "2024-01-01"

from libc.math cimport sqrt
from libc.stdlib cimport malloc, free
from libc.time cimport clock, CLOCKS_PER_SEC
from printResults import printResults
from ctypes import c_double
import time


cdef enum fbReturn:
    OK = 0
    TMT = 1
    TB = 2
    PRM_ERR = 3

cdef char isPrime(unsigned long long numberPrime, unsigned long long maxFactor):
    cdef unsigned long long i
    cdef unsigned long long maxSearch = numberPrime if numberPrime < maxFactor else maxFactor
    for i in range(2, maxSearch):
        if numberPrime % i == 0:
            return 0  # False
    return 1  # True

cdef void factorization(unsigned long long * arTerms, char * arPrimes, int baseIndex, unsigned long long maxFactor):
    cdef int position = 0
    cdef unsigned long long result = arTerms[baseIndex]
    cdef unsigned long long testNbr = 2

    while result != 1:
        if result % testNbr == 0:
            position += 1
            arTerms[baseIndex + position] = testNbr
            arPrimes[baseIndex + position] = isPrime(testNbr, maxFactor)
            result /= testNbr
            if position == 49:
                break
            continue
        testNbr += 1
        if testNbr > maxFactor:
            break

cdef fbReturn fibonacci_interop_c(unsigned long long fbStart, unsigned char maxTerms, unsigned long long maxFibo, unsigned long long maxFactor, unsigned char nbrOfLoops,
                                  unsigned long long * arTerms, char * arPrimes, double * arError, double * goldenNbr):
    cdef int  baseIndex
    cdef int currentTerm
    cdef unsigned long long nextValue
    goldenNbr[0] = (1 + sqrt(5)) / 2

    if fbStart < 1 or maxFibo < 1 or maxTerms < 3 or maxFactor < 2 or nbrOfLoops < 1:
        return fbReturn.PRM_ERR

    if maxTerms > 93:
        return fbReturn.TMT

    if maxFibo > 18446744073709551615 or maxFactor > 18446744073709551615:
        return fbReturn.TB

    for _ in range(nbrOfLoops):
        arTerms[0] = fbStart
        arTerms[50] = fbStart
        factorization(arTerms, arPrimes, 0, maxFactor)
        factorization(arTerms, arPrimes, 50, maxFactor)

        for currentTerm in range(2, maxTerms):
            baseIndex = currentTerm * 50
            nextValue = arTerms[baseIndex - 50] + arTerms[
                baseIndex - 2 * 50]  # The next value of the fibonacci sequence

            if nextValue > maxFibo:  # If the next value is greater than the maximum value, leave the loop
                return fbReturn.OK

            arTerms[baseIndex] = nextValue
            arPrimes[baseIndex] = isPrime(arTerms[baseIndex], maxFactor)
            arError[currentTerm] = abs(goldenNbr[0] - (arTerms[baseIndex] / arTerms[baseIndex - 50]))
            factorization(arTerms, arPrimes, baseIndex, maxFactor)

    return fbReturn.OK

cdef list convert_ull_array_to_pylist(unsigned long long *c_array, int size):
    cdef list py_list = []
    cdef int i
    for i in range(size):
        py_list.append(c_array[i])
    return py_list

cdef list convert_double_array_to_pylist(double *c_array, int size):
    cdef int i
    cdef list py_list = []
    for i in range(size):
        py_list.append(float(c_array[i]))
    return py_list

cpdef void fibonacci_interop_cython_full(unsigned long long fbStart, unsigned char maxTerms, unsigned long long maxFibo, unsigned long long maxFactor,
                                 unsigned char nbrOfLoops, unsigned char nbrOfRuns):
    cdef unsigned long long * arTerms
    cdef char * arPrimes
    cdef double * arError
    cdef double * timeArray
    cdef double goldenNbr
    cdef int array_size


    # Dynamically allocate memory
    array_size = maxTerms * 50
    arTerms = <unsigned long long *> malloc(array_size * sizeof(unsigned long long))
    arPrimes = <char *> malloc(array_size * sizeof(char))
    arError = <double *> malloc(maxTerms * sizeof(double))
    timeArray = <double *> malloc(nbrOfRuns * sizeof(double))

    # Check if memory allocation was successful but we don't care
    if not arTerms or not arPrimes or not arError or not timeArray:
        # Handle memory allocation failure
        if arTerms: free(arTerms)
        if arPrimes: free(arPrimes)
        if arError: free(arError)
        if timeArray: free(timeArray)
        raise MemoryError("Failed to allocate memory")

    for i in range(nbrOfRuns):

        start_time = time.time()
        result = fibonacci_interop_c(fbStart, maxTerms, maxFibo, maxFactor, nbrOfLoops,
                                     &arTerms[0], &arPrimes[0], &arError[0], &goldenNbr)
        end_time = time.time()
        timeArray[i] = end_time - start_time

    # Convert C arrays to Python lists
    py_arTerms = convert_ull_array_to_pylist(arTerms, maxTerms)
    py_timeArray = convert_double_array_to_pylist(timeArray, nbrOfRuns)

    # Print results
    printResults(arPrimes, py_arTerms, goldenNbr, maxTerms, py_timeArray, "Cython Full")

    # Free memory
    free(arTerms)
    free(arPrimes)
    free(arError)
    free(timeArray)