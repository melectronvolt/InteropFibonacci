// 03-MixingWithC.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <stdlib.h>
#include <cmath>
#include <ctime>
#include <string>
#include <iomanip>

enum class fbReturn {
    OK, NOL, OF_P, OF, TMT, TB, PRM_ERR, ERR
};

extern "C" fbReturn fibonacci_interop_asm(unsigned long long fbStart, unsigned char maxTerms,unsigned long long maxFibo, unsigned long long maxFactor, unsigned char nbrOfLoops,
                                      unsigned long long* arTerms, bool* arPrimes, double* arError, double& goldenNbr,unsigned long long& test);

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
    unsigned char maxTerms = 74;
    double timeCount[5];

    unsigned long long* arTerms = new unsigned long long[maxTerms * 50];

   //  Fill the arTerms array with the value 12
    for (int i = 0; i < maxTerms * 50; ++i) {
        arTerms[i] = 12;
    }

    bool* arPrimes = new bool[maxTerms * 50];

    for (int i = 0; i < maxTerms * 50; ++i) {
        arPrimes[i] = true;
    }

    double* arError = new double[maxTerms];

    for (int i = 0; i < maxTerms; ++i) {
        arError[i] = 9.87654321;
    }

    double goldenNbr = 0.5;
    unsigned long long test= 0;
    fbReturn fbRet = fibonacci_interop_asm(1, maxTerms, 1304969544928657, 400000, 1, arTerms, arPrimes, arError, goldenNbr, test);


    for (int i = 0; i < maxTerms*50; ++i) {
        std::cout << arTerms[i] << std::endl;
    }

    for (int i = 0; i < maxTerms*50; ++i) {
        std::cout << arPrimes[i] << std::endl;
    }

//    for (int i = 0; i < maxTerms; ++i) {
//        std::cout << arError[i] << std::endl;
//    }



    std::cout << "Return: " << static_cast<int>(fbRet) << std::endl;
    std::cout << "Test : " << test << std::endl;
    std::cout << "Golden Number: " << std::setprecision(20) <<  goldenNbr << std::endl;

    /*  for (int i = 0; i < 5; ++i) {
          clock_t start_time = clock();
   // fbReturn fbRet = fibonacci_interop(1, maxTerms, 1304969544928657, 4000000, 5, arTerms, arPrimes, arError, goldenNbr);
          clock_t end_time = clock();
          timeCount[i] = static_cast<double>(end_time - start_time) / CLOCKS_PER_SEC;
      }*/

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

//      std::cout << "Golden Number: " << goldenNbr << std::endl;
//      std::cout << "---------------------------------" << std::endl;
//      std::cout << "Average Duration: " << mean(timeCount, 5) << std::endl;
//      std::cout << "Standard Deviation: " << standard_deviation(timeCount, 5) << std::endl;

      delete[] arTerms;
      delete[] arPrimes;
      delete[] arError;

    return 0;
}
