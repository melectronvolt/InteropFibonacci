# cython: language_level=3

# Cythonized version of the Fibonacci program (only functions)
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

# Import the C functions
from libc.math cimport sqrt
from cpython.array cimport array

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
            return 0
    return 1

cdef void factorization(unsigned long long* arTerms, char* arPrimes, int baseIndex, unsigned long long maxFactor):
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
                                  unsigned long long* arTerms, char* arPrimes, double* arError, double* goldenNbr):
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

cpdef tuple fibonacci_interop_cython(unsigned long long fbStart, unsigned char maxTerms, unsigned long long maxFibo, unsigned long long maxFactor, unsigned char nbrOfLoops,
                                 array arTermsArray, array arPrimesArray, array arErrorArray):
    cdef unsigned long long[:] arTerms = arTermsArray
    cdef char[:] arPrimes = arPrimesArray
    cdef double[:] arError = arErrorArray
    cdef double goldenNbr

    # Call the C function
    result = fibonacci_interop_c(fbStart, maxTerms, maxFibo, maxFactor, nbrOfLoops,
                                         &arTerms[0], &arPrimes[0], &arError[0], &goldenNbr)

    # Return the result and golden number
    return result, goldenNbr
