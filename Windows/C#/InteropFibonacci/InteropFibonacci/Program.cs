using System;

class Program
{
    enum FbReturn
    {
        OK, TMT, TB, PRM_ERR, ERR
    }

    static bool IsPrime(int numberPrime, int maxFactor)
    {
        int maxSearch = (numberPrime < maxFactor) ? numberPrime : maxFactor;
        for (int i = 2; i < maxSearch; ++i)
        {
            if (numberPrime % i == 0)
                return false;
        }
        return true;
    }

    static void Factorization(ulong[] arTerms, bool[] arPrimes, int baseIndex, int maxFactor)
    {
        int position = 0;
        ulong result = arTerms[baseIndex];
        int testNbr = 2;

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

    static FbReturn FibonacciInterop(int fbStart, int maxTerms, long maxFibo, int maxFactor, int nbrOfLoops,
                                     ulong[] arTerms, bool[] arPrimes, float[] arError, out double goldenNbr)
    {
        goldenNbr = 0;

        if (fbStart < 1 || maxFibo < 1 || maxTerms < 3 || maxFactor < 2 || nbrOfLoops < 1)
            return FbReturn.PRM_ERR;

        if (maxTerms > 74)
            return FbReturn.TMT;

        if (maxFibo > 1304969544928657)
            return FbReturn.TB;

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
                arTerms[baseIndex] = arTerms[baseIndex - 50] + arTerms[baseIndex - 100];
                arPrimes[baseIndex] = IsPrime((int)arTerms[baseIndex], maxFactor);
                arError[currentTerm] = Math.Abs((float)(goldenConst - ((double)arTerms[baseIndex] / arTerms[baseIndex - 50])));
                Factorization(arTerms, arPrimes, baseIndex, maxFactor);
            }
            goldenNbr = (double)arTerms[(maxTerms - 1) * 50] / arTerms[(maxTerms - 2) * 50];
        }

        return FbReturn.OK;
    }

    static double Mean(double[] lst)
    {
        double sum = 0;
        foreach (double val in lst)
            sum += val;
        return sum / lst.Length;
    }

    static double StandardDeviation(double[] lst)
    {
        double meanVal = Mean(lst);
        double variance = 0;
        foreach (double val in lst)
            variance += (val - meanVal) * (val - meanVal);
        return Math.Sqrt(variance / lst.Length);
    }

    static void Main()
    {
        int maxTerms = 74;
        double[] timeCount = new double[5];

        ulong[] arTerms = new ulong[maxTerms * 50];
        bool[] arPrimes = new bool[maxTerms * 50];
        float[] arError = new float[maxTerms];
        double goldenNbr = 0;

        for (int i = 0; i < 5; ++i)
        {
            var start_time = DateTime.Now;
            var fbRet = FibonacciInterop(1, maxTerms, 1304969544928657, 4000000, 5, arTerms, arPrimes, arError, out goldenNbr);
            var end_time = DateTime.Now;
            timeCount[i] = (end_time - start_time).TotalSeconds;
        }

        for (int i = 0; i < maxTerms; ++i)
        {
            string line = "";
            int baseIndex = i * 50;
            if (arTerms[baseIndex] != 0)
            {
                line += arPrimes[baseIndex] ? $"{i} - [{arTerms[baseIndex]}] : " :
                                              $"{i} - {arTerms[baseIndex]} : ";
                bool addValue = false;
                for (int position = 1; position < 50; ++position)
                {
                    int index = baseIndex + position;
                    if (arTerms[index] != 0)
                    {
                        line += arPrimes[index] ? $"[{arTerms[index]}] x " : $"{arTerms[index]} x ";
                        addValue = true;
                    }
                }
                if (addValue)
                    line = line.Remove(line.Length - 3);
                else
                    line += "Factor not found";
            }
            Console.WriteLine(line);
        }

        Console.WriteLine($"Golden Number: {goldenNbr}");
        Console.WriteLine("---------------------------------");
        Console.WriteLine($"Average Duration: {Mean(timeCount)}");
        Console.WriteLine($"Standard Deviation: {StandardDeviation(timeCount)}");
    }
}
