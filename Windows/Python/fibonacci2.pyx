# fibonacci.pyx
from libc.math cimport sqrt
from cpython.array cimport array, clone
from libc.stdlib cimport malloc, free
from libc.stdio cimport printf
from libc.time cimport clock, CLOCKS_PER_SEC

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

cdef void print_results(unsigned long long* arTerms, char* arPrimes, int maxTerms):
    cdef int i, position, baseIndex
    cdef char addValue
    for i in range(0, maxTerms):
        baseIndex = i * 50
        if arTerms[baseIndex]:
            if arPrimes[baseIndex]:
                printf("%d - [%llu] : ", i, arTerms[baseIndex])
            else:
                printf("%d - %llu : ", i, arTerms[baseIndex])
            addValue = 0
            for position in range(1, 50):
                index = baseIndex + position
                if arTerms[index]:
                    if arPrimes[index]:
                        printf("[%llu] x ", arTerms[index])
                    else:
                        printf("%llu x ", arTerms[index])
                    addValue = 1
            if addValue:
                printf("\b\b\b   \n")  # Erase last " x " and add newline
            else:
                printf("Factor not found\n")

cdef double compute_mean(double *timeArray, int size):
    cdef int i
    cdef double total = 0
    for i in range(size):
        total += timeArray[i]
    return total / size

cdef double compute_std_deviation(double *timeArray, int size, double mean):
    cdef int i
    cdef double variance = 0
    for i in range(size):
        variance += (timeArray[i] - mean) ** 2
    variance /= size
    return sqrt(variance)

cpdef void fibonacci_fullinterop(int fbStart, int maxTerms=74, long long maxFibo=1304969544928657, int maxFactor=5000, int nbrOfLoops=1):
    cdef unsigned long long* arTerms
    cdef char* arPrimes
    cdef float* arError
    cdef double* timeArray
    cdef double goldenNbr
    cdef int array_size

    # Dynamically allocate memory
    array_size = maxTerms * 50
    arTerms = <unsigned long long*>malloc(array_size * sizeof(unsigned long long))
    arPrimes = <char*>malloc(array_size * sizeof(char))
    arError = <float*>malloc(maxTerms * sizeof(float))
    timeArray = <double*>malloc(nbrOfLoops * sizeof(double))

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


    free(arTerms)
    free(arPrimes)
    free(arError)
    free(timeArray)

    # Print results
    print_results(arTerms, arPrimes, maxTerms)
    printf("Golden Number : %lf\n", goldenNbr)
    printf("CYTHON FULL ---------------------------------\n")
    cdef double meanTime = compute_mean(timeArray, nbrOfLoops)
    printf("Average Duration : %lf\n", meanTime)
    printf("Standard Deviation : %lf\n", compute_std_deviation(timeArray, nbrOfLoops, meanTime))