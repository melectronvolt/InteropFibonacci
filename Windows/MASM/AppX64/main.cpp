// 03-MixingWithC.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <iostream>
#include <stdlib.h>

extern "C" void Reverser(int* y, const int* x, int n);

int main()
{
    const int n = 10;
    int x[n], y[n];


    for (int i = 0; i < n; i++)
    {
        x[i] = i;
    }
    Reverser(y, x, n);

    printf("\n---------Array Reverser---------\n");
    for (int i = 0; i < n; i++)
    {
        printf("i:     %5d      y:     %5d      x:     %5d\n", i, y[i], x[i]);
    }

    return 0;
}
