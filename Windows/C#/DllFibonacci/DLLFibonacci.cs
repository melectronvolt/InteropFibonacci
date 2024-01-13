// -----------------------------------------------------------------------
// Author: Rémi MEVAERE
// Copyright: Copyright (c) 2024 Rémi MEVAERE
// License: MIT License
// Version: 1.0.0
// Maintainer: Rémi MEVAERE
// Email: github@volt.melectron.fr
// Website: spnet.fr
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
        PRM_ERR
    }

    /// <summary>Checks if a number is prime.</summary>
    /// <param name="number">The number to check for primality.</param>
    /// <param name="maxFactor">The maximum factor to consider.</param>
    /// <returns>True if the number is prime, otherwise false.</returns>
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

    /// <summary>
    /// Performs factorization of a given number and populates arrays with the factors and their primality.
    /// </summary>
    /// <param name="arTerms">An array to store the factors.</param>
    /// <param name="arPrimes">An array to store the primality of factors.</param>
    /// <param name="baseIndex">The base index in the arrays to start storing factors.</param>
    /// <param name="maxFactor">The maximum factor to consider during factorization.</param>

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

    /// <summary>
    /// Calculates Fibonacci sequences with additional information.
    /// </summary>
    /// <param name="fbStart">The starting value for the Fibonacci sequence.</param>
    /// <param name="maxTerms">The maximum number of terms in the Fibonacci sequence.</param>
    /// <param name="maxFibo">The maximum Fibonacci value allowed.</param>
    /// <param name="maxFactor">The maximum factor to consider during factorization.</param>
    /// <param name="nbrOfLoops">The number of loops to run the calculation.</param>
    /// <param name="arTerms">An array to store the terms of the Fibonacci sequence.</param>
    /// <param name="arPrimes">An array to store the primality of terms.</param>
    /// <param name="arError">An array to store error values.</param>
    /// <returns>A <see cref="FibonacciResult"/> object containing the result and the golden number.</returns>

    public static FibonacciResult fibonacci_interop_cs(ulong fbStart, byte maxTerms, ulong maxFibo, ulong maxFactor, byte nbrOfLoops,
        ulong[] arTerms, bool[] arPrimes, double[] arError)
    {
        double goldenNbr = 0;

        if (fbStart < 1 || maxFibo < 1 || maxTerms < 3 || maxFactor < 2 || nbrOfLoops < 1)
            return new FibonacciResult { Result = FbReturn.PRM_ERR, GoldenNumber = goldenNbr };

        if (maxTerms > 93)
            return new FibonacciResult { Result = FbReturn.TMT, GoldenNumber = goldenNbr };

        if (maxFibo > 18446744073709551615 || maxFactor > 18446744073709551615)
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