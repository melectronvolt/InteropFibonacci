
from pythonnet import load
load("coreclr")
import clr  # Import CLR from Python.NET
import os

def main_dotnet():
    # Load the DLL (provide the full path if it's not in the same directory)
    clr.AddReference('System')
    current_directory = os.getcwd()
    clr.AddReference(os.path.join(current_directory, 'DllFibonacci.dll'))
    # Import the namespace
    from DllFibonacci import MyFiboClass
    from System import Array
    from System import UInt64, Boolean, Single, Double
    from System.Runtime.InteropServices import GCHandle, GCHandleType

    # Prepare parameters
    fbStart = 1
    maxTerms = 74
    maxFibo = 1304969544928657
    maxFactor = 4000000
    nbrOfLoops = 7

    # Since arrays in C# are different from Python lists, we need to create them in a compatible way
    timeCount = []

    for _ in range(20):
        start_time = time.time()  # Start the timer
        # Correctly create the arrays using .NET types
        arTerms = Array[UInt64](range(maxTerms * 50))
        arPrimes = Array[Boolean]([False] * (maxTerms * 50))
        arError = Array[Single]([0.0] * maxTerms)

        # Call the method
        # Initialize the out parameter as a reference
        goldenNbr = Array[Double]([0.0])

        fibonacciResult = MyFiboClass.FibonacciInterop(fbStart, maxTerms, maxFibo, maxFactor, nbrOfLoops, arTerms, arPrimes, arError)

        result = fibonacciResult.Result
        goldenNumberValue = fibonacciResult.GoldenNumber
        end_time = time.time()  # End the timer
        timeCount.append(end_time - start_time)

    # Check the result and process the output
    for i in range(0, maxTerms):
        ligne = ''
        baseIndex = i * 50
        if arTerms[baseIndex]:
            if arPrimes[baseIndex]:
                ligne += f"{i} - [{arTerms[baseIndex]}] : "
            else:
                ligne += f"{i} - {arTerms[baseIndex]} : "
            addValue = False
            for position in range(1, 50):
                index = baseIndex + position
                if arTerms[index]:
                    if arPrimes[index]:
                        ligne += f"[{arTerms[index]}] x "
                    else:
                        ligne += f"{arTerms[index]} x "
                    addValue = True

            if addValue:
                ligne = ligne[:- 3]
            else:
                ligne += "Factor not found"
        print(ligne)

    print("Golden Number : ", goldenNumberValue)

    print("DOTNET C# ---------------------------------")
    print("Durée moyenne : " + str(mean(timeCount)))
    print("Standard Deviation : " + str(standard_deviation(timeCount)))
