#include <cmath>
#include <string>

enum class fbReturn {
    OK, TMT, TB, PRM_ERR
};

bool isPrime(unsigned long long numberPrime, unsigned long long maxFactor) {
    int maxSearch = (numberPrime < maxFactor) ? numberPrime : maxFactor;
    for (unsigned long long i = 2; i < maxSearch; ++i) {
        if (numberPrime % i == 0)
            return false;
    }
    return true;
}

void factorization(unsigned long long* arTerms, bool* arPrimes, int baseIndex, unsigned long long maxFactor) {
    int position = 0;
    unsigned long long result = arTerms[baseIndex];
    unsigned long long testNbr = 2;

    while (result != 1) {
        if (result % testNbr == 0) {
            position += 1;
            arTerms[baseIndex + position] = testNbr;
            arPrimes[baseIndex + position] = isPrime(testNbr, maxFactor);
            result /= testNbr;
            if (position == 49)
                break;
            continue;
        }
        testNbr += 1;
        if (testNbr > maxFactor)
            break;
    }
}

extern "C" __attribute__((visibility("default"))) fbReturn fibonacci_interop_cpp(unsigned long long fbStart, unsigned char maxTerms, long long maxFibo, unsigned long long maxFactor, unsigned char nbrOfLoops,
                           unsigned long long* arTerms, bool* arPrimes, double* arError, double& goldenNbr) {

    if (fbStart < 1 || maxFibo < 1 || maxTerms < 3 || maxFactor < 2 || nbrOfLoops < 1)
        return fbReturn::PRM_ERR;

    if (maxTerms > 74)
        return fbReturn::TMT;

    if (maxFibo > 1304969544928657)
        return fbReturn::TB;

    goldenNbr = (1 + sqrt(5)) / 2;
    unsigned long long nextValue;

    for (int loop = 0; loop < nbrOfLoops; ++loop) {
        std::fill_n(arTerms, maxTerms * 50, 0);
        arTerms[0] = arTerms[50] = fbStart;
        std::fill_n(arPrimes, maxTerms * 50, false);
        std::fill_n(arError, maxTerms, 0.0);

        factorization(arTerms, arPrimes, 0, maxFactor);
        factorization(arTerms, arPrimes, 50, maxFactor);

        for (int currentTerm = 2; currentTerm < maxTerms; ++currentTerm) {
            int baseIndex = currentTerm * 50;
            nextValue = arTerms[baseIndex - 50] + arTerms[baseIndex - 100];

            if (nextValue > maxFibo)
                return fbReturn::OK;

            arTerms[baseIndex] = nextValue;
            arPrimes[baseIndex] = isPrime(arTerms[baseIndex], maxFactor);
            arError[currentTerm] = abs(goldenNbr - (arTerms[baseIndex]) / arTerms[baseIndex - 50]);
            factorization(arTerms, arPrimes, baseIndex, maxFactor);
        }
    }

    return fbReturn::OK;
}
