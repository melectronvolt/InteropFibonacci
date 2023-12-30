# fibonacci.pyx
from libc.math cimport sqrt
from cpython.array cimport array, clone

cdef enum fbReturn:
    OK = 0
    NOL = 1
    OF_P = 2
    OF = 3
    TMT = 4
    TB = 5
    PRM_ERR = 6
    ERR = 7

cdef char isPrime(int numberPrime, int maxFactor):
    cdef int i
    cdef int maxSearch = numberPrime if numberPrime < maxFactor else maxFactor
    for i in range(2, maxSearch):
        if numberPrime % i == 0:
            return 0  # False
    return 1  # True

cdef void factorization(unsigned long long* arTerms, char* arPrimes, int baseIndex, int maxFactor):
    cdef int position = 0
    cdef unsigned long long result = arTerms[baseIndex]
    cdef int testNbr = 2

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

cdef fbReturn fibonacci_interop_c(int fbStart, int maxTerms, long long maxFibo, int maxFactor, int nbrOfLoops,
                                  unsigned long long* arTerms, char* arPrimes, float* arError, double* goldenNbr):
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

cpdef tuple fibonacci_interop(int fbStart, int maxTerms, long long maxFibo, int maxFactor, int nbrOfLoops,
                                 array arTermsArray, array arPrimesArray, array arErrorArray):
    cdef unsigned long long[:] arTerms = arTermsArray
    cdef char[:] arPrimes = arPrimesArray
    cdef float[:] arError = arErrorArray
    cdef double goldenNbr

    # Call the C function
    result = fibonacci_interop_c(fbStart, maxTerms, maxFibo, maxFactor, nbrOfLoops,
                                         &arTerms[0], &arPrimes[0], &arError[0], &goldenNbr)

    # Return the result and golden number
    return result, goldenNbr
