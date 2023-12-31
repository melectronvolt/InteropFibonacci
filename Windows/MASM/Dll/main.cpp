// 03-MixingWithC.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <stdio.h>
#include <windows.h>

#include <iostream>
#include <stdlib.h>
#include <cmath>
#include <ctime>
#include <string>
#include <iomanip>

enum class fbReturn {
    OK, NOL, OF_P, OF, TMT, TB, PRM_ERR, ERR
};

typedef fbReturn (*LPFIBO)(int fbStart, int maxTerms,unsigned long long maxFibo, int maxFactor, int nbrOfLoops,
                           unsigned long long* arTerms, bool* arPrimes, float* arError, double& goldenNbr,unsigned long long& test);

int main()
{

    HINSTANCE hDll = LoadLibrary("FiboASMx64.dll");
    if (hDll == NULL) {
        printf("Failed to load DLL. Error Code: %lu\n", GetLastError());
        return 1;
    }

    LPFIBO fibonacci_interop_asm = (LPFIBO)GetProcAddress(hDll, "fibonacci_interop_asm");
    if (fibonacci_interop_asm == NULL) {
        printf("Failed to get function address\n");
        FreeLibrary(hDll);
        return 1;
    }

    int maxTerms = 74;
    double timeCount[5];

    unsigned long long* arTerms = new unsigned long long[maxTerms * 50];
    bool* arPrimes = new bool[maxTerms * 50];
    float* arError = new float[maxTerms];

    double goldenNbr = 0.5;
    unsigned long long test= 0;
    fbReturn fbRet = fibonacci_interop_asm(1, maxTerms, 1304969544928657, 4000000, 5, arTerms, arPrimes, arError, goldenNbr, test);

    std::cout << "Return: " << static_cast<int>(fbRet) << std::endl;
    std::cout << "Return: " << test << std::endl;
    std::cout << "Golden Number: " << std::setprecision(20) <<  goldenNbr << std::endl;


    delete[] arTerms;
    delete[] arPrimes;
    delete[] arError;

    return 0;
}
