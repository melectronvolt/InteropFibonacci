#include <iostream>
#include <cmath>
#include <ctime>
#include <string>

enum class fbReturn {
    OK, NOL, OF_P, OF, TMT, TB, PRM_ERR, ERR
};

bool isPrime(int numberPrime, int maxFactor) {
    int maxSearch = (numberPrime < maxFactor) ? numberPrime : maxFactor;
    for (int i = 2; i < maxSearch; ++i) {
        if (numberPrime % i == 0)
            return false;
    }
    return true;
}

void factorization(unsigned long long* arTerms, bool* arPrimes, int baseIndex, int maxFactor) {
    int position = 0;
    int result = arTerms[baseIndex];
    int testNbr = 2;

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

extern "C" __declspec(dllexport) fbReturn fibonacci_interop(int fbStart, int maxTerms, long long maxFibo, int maxFactor, int nbrOfLoops,
                           unsigned long long* arTerms, bool* arPrimes, float* arError, double& goldenNbr) {

    if (fbStart < 1 || maxFibo < 1 || maxTerms < 3 || maxFactor < 2 || nbrOfLoops < 1)
        return fbReturn::PRM_ERR;

    if (maxTerms > 74)
        return fbReturn::TMT;

    if (maxFibo > 1304969544928657)
        return fbReturn::TB;

    double goldenConst = (1 + sqrt(5)) / 2;

    for (int loop = 0; loop < nbrOfLoops; ++loop) {
        std::fill_n(arTerms, maxTerms * 50, 0);
        arTerms[0] = arTerms[50] = fbStart;
        std::fill_n(arPrimes, maxTerms * 50, false);
        std::fill_n(arError, maxTerms, 0.0f);

        factorization(arTerms, arPrimes, 0, maxFactor);
        factorization(arTerms, arPrimes, 50, maxFactor);

        for (int currentTerm = 2; currentTerm < maxTerms; ++currentTerm) {
            int baseIndex = currentTerm * 50;
            arTerms[baseIndex] = arTerms[baseIndex - 50] + arTerms[baseIndex - 100];
            arPrimes[baseIndex] = isPrime(arTerms[baseIndex], maxFactor);
            arError[currentTerm] = abs(goldenConst - (static_cast<double>(arTerms[baseIndex]) / arTerms[baseIndex - 50]));
            factorization(arTerms, arPrimes, baseIndex, maxFactor);
        }
        goldenNbr = static_cast<double>(arTerms[(maxTerms - 1) * 50]) / arTerms[(maxTerms - 2) * 50];
    }

    return fbReturn::OK;
}

double mean(const double* lst, int size) {
    double sum = 0;
    for (int i = 0; i < size; ++i)
        sum += lst[i];
    return sum / size;
}

double standard_deviation(const double* lst, int size) {
    double meanVal = mean(lst, size);
    double variance = 0;
    for (int i = 0; i < size; ++i)
        variance += (lst[i] - meanVal) * (lst[i] - meanVal);
    return sqrt(variance / size);
}

int main() {
    int maxTerms = 74;
    double timeCount[5];

    unsigned long long* arTerms = new unsigned long long[maxTerms * 50];
    bool* arPrimes = new bool[maxTerms * 50];
    float* arError = new float[maxTerms];
    double goldenNbr = 0;

    for (int i = 0; i < 5; ++i) {
        clock_t start_time = clock();
        fbReturn fbRet = fibonacci_interop(1, maxTerms, 1304969544928657, 4000000, 5, arTerms, arPrimes, arError, goldenNbr);
        clock_t end_time = clock();
        timeCount[i] = static_cast<double>(end_time - start_time) / CLOCKS_PER_SEC;
    }

    for (int i = 0; i < maxTerms; ++i) {
        std::string line;
        int baseIndex = i * 50;
        if (arTerms[baseIndex]) {
            line += (arPrimes[baseIndex]) ? std::to_string(i) + " - [" + std::to_string(arTerms[baseIndex]) + "] : " :
                    std::to_string(i) + " - " + std::to_string(arTerms[baseIndex]) + " : ";
            bool addValue = false;
            for (int position = 1; position < 50; ++position) {
                int index = baseIndex + position;
                if (arTerms[index]) {
                    line += (arPrimes[index]) ? "[" + std::to_string(arTerms[index]) + "] x " : std::to_string(arTerms[index]) + " x ";
                    addValue = true;
                }
            }
            if (addValue)
                line = line.substr(0, line.size() - 3);
            else
                line += "Factor not found";
        }
        std::cout << line << std::endl;
    }

    std::cout << "Golden Number: " << goldenNbr << std::endl;
    std::cout << "---------------------------------" << std::endl;
    std::cout << "Average Duration: " << mean(timeCount, 5) << std::endl;
    std::cout << "Standard Deviation: " << standard_deviation(timeCount, 5) << std::endl;

    delete[] arTerms;
    delete[] arPrimes;
    delete[] arError;

    return 0;
}
