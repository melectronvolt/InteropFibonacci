// -----------------------------------------------------------------------
// File Information
// -----------------------------------------------------------------------
// Author: Rémi MEVAERE
// Copyright: Copyright (c) 2024 Rémi MEVAERE
// License: MIT License
// Version: 1.0.0
// Maintainer: Rémi MEVAERE
// Email: your.email@example.com
// Status: Development
// Date: 2024-01-01
// -----------------------------------------------------------------------

namespace DllFibonacci;

using System;

public class MyFiboClass
{

    public class FibonacciResult
    {
        public FbReturn Result { get; set; }
        public double GoldenNumber { get; set; }
    }

    public enum FbReturn
    {
        OK,
        TMT,
        TB,
        PRM_ERR,
        ERR
    }

    static bool IsPrime(ulong numberPrime, ulong maxFactor)
    {
        ulong maxSearch = (numberPrime < maxFactor) ? numberPrime : maxFactor;
        for (ulong i = 2; i < maxSearch; ++i)
        {
            if (numberPrime % i == 0)
                return false;
        }
        return true;
    }

    static void Factorization(ulong[] arTerms, bool[] arPrimes, int baseIndex, ulong maxFactor)
    {
        int position = 0;
        ulong result = arTerms[baseIndex];
        ulong testNbr = 2;

        while (result != 1)
        {
            if (result % (ulong)testNbr == 0)
            {
                position += 1;
                arTerms[baseIndex + position] = (ulong)testNbr;
                arPrimes[baseIndex + position] = IsPrime(testNbr, maxFactor);
                result /= (ulong)testNbr;
                if (position == 49)
                    break;
            }
            else
            {
                testNbr += 1;
                if (testNbr > maxFactor)
                    break;
            }
        }
    }

    public static FibonacciResult FibonacciInterop(ulong fbStart, byte maxTerms, ulong maxFibo, ulong maxFactor, byte nbrOfLoops,
        ulong[] arTerms, bool[] arPrimes, double[] arError)
    {
        double goldenNbr = 0;

        if (fbStart < 1 || maxFibo < 1 || maxTerms < 3 || maxFactor < 2 || nbrOfLoops < 1)
            return new FibonacciResult { Result = FbReturn.PRM_ERR, GoldenNumber = goldenNbr };

        if (maxTerms > 74)
            return new FibonacciResult { Result = FbReturn.TMT, GoldenNumber = goldenNbr };

        if (maxFibo > 1304969544928657)
            return new FibonacciResult { Result = FbReturn.TB, GoldenNumber = goldenNbr };

        double goldenConst = (1 + Math.Sqrt(5)) / 2;

        for (int loop = 0; loop < nbrOfLoops; ++loop)
        {
            Array.Fill(arTerms, 0UL);
            arTerms[0] = arTerms[50] = (ulong)fbStart;
            Array.Fill(arPrimes, false);
            Array.Fill(arError, 0.0f);

            Factorization(arTerms, arPrimes, 0, maxFactor);
            Factorization(arTerms, arPrimes, 50, maxFactor);

            for (int currentTerm = 2; currentTerm < maxTerms; ++currentTerm)
            {
                int baseIndex = currentTerm * 50;
                ulong nextValue = arTerms[baseIndex - 50] + arTerms[baseIndex - 100];

                if (nextValue > (ulong)maxFibo)
                    return new FibonacciResult { Result = FbReturn.TB, GoldenNumber = goldenNbr };

                arTerms[baseIndex] = nextValue;
                arPrimes[baseIndex] = IsPrime(arTerms[baseIndex], maxFactor);
                arError[currentTerm] =
                    Math.Abs((float)(goldenConst - ((double)arTerms[baseIndex] / arTerms[baseIndex - 50])));
                Factorization(arTerms, arPrimes, baseIndex, maxFactor);
            }

            goldenNbr = (double)arTerms[(maxTerms - 1) * 50] / arTerms[(maxTerms - 2) * 50];
        }

        return new FibonacciResult { Result = FbReturn.OK, GoldenNumber = goldenNbr };
    }
}