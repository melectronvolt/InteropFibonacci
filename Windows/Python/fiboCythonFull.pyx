# cython: language_level=3

# Cythonized version 2 of the Fibonacci program

__author__ = "Rémi MEVAERE"
__copyright__ = "Copyright (c) 2024 Rémi MEVAERE"
__license__ = "MIT License"
__version__ = "1.0.0"
__maintainer__ = "Rémi MEVAERE"
__email__ = "your.email@example.com"
__status__ = "Development"
__date__ = "2024-01-01"

from libc.math cimport sqrt
from libc.stdlib cimport malloc, free
from libc.time cimport clock, CLOCKS_PER_SEC
from printResults import printResults

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
                                  unsigned long long * arTerms, char * arPrimes, float * arError, double * goldenNbr):
    cdef double goldenConst = (1 + sqrt(5)) / 2
    cdef int currentTerm, baseIndex

    if fbStart < 1 or maxFibo < 1 or maxTerms < 3 or maxFactor < 2 or nbrOfLoops < 1:
        return fbReturn.PRM_ERR

    if maxTerms > 74:
        return fbReturn.TMT

    if maxFibo > 1304969544928657:
        return fbReturn.TB

    for _ in range(nbrOfLoops):
        arTerms[0] = fbStart
        arTerms[50] = fbStart
        factorization(arTerms, arPrimes, 0, maxFactor)
        factorization(arTerms, arPrimes, 50, maxFactor)

        for currentTerm in range(2, maxTerms):
            baseIndex = currentTerm * 50
            arTerms[baseIndex] = arTerms[baseIndex - 50] + arTerms[baseIndex - 2 * 50]
            arPrimes[baseIndex] = isPrime(arTerms[baseIndex], maxFactor)
            arError[currentTerm] = abs(goldenConst - (arTerms[baseIndex] / arTerms[baseIndex - 50]))
            factorization(arTerms, arPrimes, baseIndex, maxFactor)
        goldenNbr[0] = (arTerms[(maxTerms - 1) * 50] / arTerms[(maxTerms - 2) * 50])

    return fbReturn.OK

cdef list convert_to_pylist(unsigned long long *c_array, int size):
    cdef list py_list = []
    cdef int i
    for i in range(size):
        py_list.append(c_array[i])
    return py_list

cdef list convert_double_array_to_pylist(double *c_array, int size):
    cdef list py_list = []
    cdef int i
    for i in range(size):
        py_list.append(c_array[i])
    return py_list


cpdef void fibonacci_interop_cython_full(unsigned long long fbStart, unsigned char maxTerms, unsigned long long maxFibo, unsigned long long maxFactor,
                                 unsigned char nbrOfLoops):
    cdef unsigned long long * arTerms
    cdef char * arPrimes
    cdef float * arError
    cdef double * timeArray
    cdef double goldenNbr
    cdef int array_size

    # Dynamically allocate memory
    array_size = maxTerms * 50
    arTerms = <unsigned long long *> malloc(array_size * sizeof(unsigned long long))
    arPrimes = <char *> malloc(array_size * sizeof(char))
    arError = <float *> malloc(maxTerms * sizeof(float))
    timeArray = <double *> malloc(nbrOfLoops * sizeof(double))

    if not arTerms or not arPrimes or not arError or not timeArray:
        # Handle memory allocation failure
        if arTerms: free(arTerms)
        if arPrimes: free(arPrimes)
        if arError: free(arError)
        if timeArray: free(timeArray)
        raise MemoryError("Failed to allocate memory")

    for loop in range(nbrOfLoops):
        start_time = clock()
        result = fibonacci_interop_c(fbStart, maxTerms, maxFibo, maxFactor, nbrOfLoops,
                                     &arTerms[0], &arPrimes[0], &arError[0], &goldenNbr)
        end_time = clock()
        timeArray[loop] = (end_time - start_time) / CLOCKS_PER_SEC

    # Usage
    py_arTerms = convert_to_pylist(arTerms, maxTerms)
    py_timeArray = convert_double_array_to_pylist(timeArray, nbrOfLoops)


    printResults(arPrimes, py_arTerms, goldenNbr, maxTerms, py_timeArray, "Cython Full")

    free(arTerms)
    free(arPrimes)
    free(arError)
    free(timeArray)
