using System;
using DllFibonacci;

class Program
{
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

    static void Main(string[] args)
    {
        int maxTerms = 74;
        double[] timeCount = new double[5];

        ulong[] arTerms = new ulong[maxTerms * 50];
        bool[] arPrimes = new bool[maxTerms * 50];
        float[] arError = new float[maxTerms];
        double goldenNbr = 0;
        MyFiboClass.FibonacciResult fbRet = new MyFiboClass.FibonacciResult(); // or 'null' if your logic allows

        for (int i = 0; i < 5; ++i)
        {
            var start_time = DateTime.Now;
            fbRet = MyFiboClass.FibonacciInterop(1, maxTerms, 1304969544928657, 4000000, 5, arTerms, arPrimes, arError);
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

        Console.WriteLine($"Golden Number: {fbRet.GoldenNumber}");
        Console.WriteLine("---------------------------------");
        Console.WriteLine($"Average Duration: {Mean(timeCount)}");
        Console.WriteLine($"Standard Deviation: {StandardDeviation(timeCount)}");
    }
}