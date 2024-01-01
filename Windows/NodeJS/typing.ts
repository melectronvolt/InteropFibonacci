
enum fbReturn {
    OK = 0,
    TMT = 1,
    TB = 2,
    PRM_ERR = 3
}

/**
 * Determines if a given number is prime, up to a specified maximum factor.
 *
 * This function checks if 'numberPrime' is divisible by any number from 2
 * up to 'maxFactor' or 'numberPrime', whichever is smaller. If 'numberPrime'
 * is found to be divisible by any of these numbers, it is not a prime number.
 * Otherwise, it is considered prime.
 *
 * @param {number} numberPrime - The number to check for primality.
 * @param {number} maxFactor - The maximum factor to check up to.
 * @returns {boolean} - True if 'numberPrime' is prime up to 'maxFactor',
 *                      false otherwise.
 */
function isPrime(numberPrime: number, maxFactor: number): boolean {
    let maxSearch: number = numberPrime < maxFactor ? numberPrime : maxFactor;
    for (let i: number = 2; i < maxSearch; i++) {
        if (numberPrime % i === 0) {
            return false;
        }
    }
    return true;
}

/**
 * Performs the factorization of a given number and stores the factors and their primality status.
 *
 * The function starts with 'baseIndex' in 'arTerms' array, then repeatedly divides 'result'
 * (initialized as the value at 'arTerms[baseIndex]') by the smallest factor starting from 2.
 * Each factor found is stored in 'arTerms', and its primality (determined using 'isPrime')
 * is stored in 'arPrimes'. The process stops when 'result' becomes 1,
 * when 50 factors are found, or when the smallest factor exceeds 'maxFactor'.
 *
 * @param {number} baseIndex - The starting index in 'arTerms' for storing factors.
 * @param {number[]} arTerms - An array to store the factors of the number.
 * @param {boolean[]} arPrimes - An array to store the primality status of the factors.
 * @param {number} maxFactor - The maximum factor to consider for factorization.
 *
 * @note This function does not return any value. It modifies 'arTerms' and 'arPrimes' directly.
 * @note It assumes 'isPrime' function is defined and accessible for checking primality.
 * @note The function has a limit of storing up to 49 factors (including repetitions).
 */
function factorization(baseIndex: number, arTerms: number[], arPrimes: boolean[], maxFactor: number): void {
    let position: number = 0;
    let result: number = arTerms[baseIndex];
    let testNbr: number = 2;

    while (result !== 1) {
        if (result % testNbr === 0) {
            position++;
            arTerms[baseIndex + position] = testNbr;
            arPrimes[baseIndex + position] = isPrime(testNbr, maxFactor);
            result /= testNbr;
            if (position === 49) {
                break;
            }
            continue;
        }
        testNbr++;
        if (testNbr > maxFactor) {
            break;
        }
    }
}

/**
 * Generates Fibonacci numbers starting from a specified value, performs factorization on each, and evaluates their approximation to the golden ratio.
 *
 * This function generates a Fibonacci sequence beginning with 'fbStart', continuing for 'maxTerms' terms or until a term exceeds 'maxFibo'.
 * Each term is factorized and checked for primality, and the error relative to the golden ratio is calculated.
 * The function operates for 'nbrOfLoops' iterations and returns an array containing the terms, their primality, error values, and the last golden ratio approximation.
 *
 * @param {number} fbStart - The starting value of the Fibonacci sequence.
 * @param {number} [maxTerms=74] - The maximum number of terms to generate.
 * @param {number} [maxFibo=1304969544928657] - The maximum value a Fibonacci term can have.
 * @param {number} [maxFactor=5000] - The maximum factor for the factorization process.
 * @param {number} [nbrOfLoops=1] - The number of iterations to run the algorithm.
 * @returns {Array} - An array containing the results: Fibonacci terms, their primality status, error values, and last golden ratio approximation.
 *
 * @note 'fbReturn' is assumed to be an enumeration representing different error or success states.
 */
function fibonacci_interop(fbStart: number, maxTerms: number = 74, maxFibo: number, maxFactor: number, nbrOfLoops: number): [fbReturn, number[] | null, boolean[] | null, number[] | null, number | null] {
    let arTerms: number[] = [];
    let arPrimes: boolean[] = [];
    let arError: number[] = [];

    if (fbStart < 1 || maxFibo < 1 || maxTerms < 3 || maxFactor < 2 || nbrOfLoops < 1) {
        return [fbReturn.PRM_ERR, null, null, null, null];
    }

    if (maxTerms > 74) {
        return [fbReturn.TMT, null, null, null, null];
    }

    if (maxFibo > 1304969544928657) {
        return [fbReturn.TB, null, null, null, null];
    }

    let goldenNbr: number = (1 + Math.sqrt(5)) / 2;

    for (let _ = 0; _ < nbrOfLoops; _++) {
        arTerms = new Array(maxTerms * 50).fill(0);
        arPrimes = new Array(maxTerms * 50).fill(false);
        arError = new Array(maxTerms).fill(0);
        arTerms[0] = fbStart;
        arTerms[50] = fbStart;

        factorization(0, arTerms, arPrimes, maxFactor);
        factorization(50, arTerms, arPrimes, maxFactor);

        for (let currentTerm = 2; currentTerm < maxTerms; currentTerm++) {
            let baseIndex = currentTerm * 50;
            let nextValue:number = arTerms[baseIndex - 50] + arTerms[baseIndex - 100];

            if (nextValue > maxFibo) {
                return [fbReturn.OK, arTerms, arPrimes, arError, goldenNbr];
            }

            arTerms[baseIndex] = nextValue;
            arPrimes[baseIndex] = isPrime(arTerms[baseIndex], maxFactor);
            arError[currentTerm] = Math.abs(goldenNbr - (arTerms[baseIndex] / arTerms[baseIndex - 50]));
            factorization(baseIndex, arTerms, arPrimes, maxFactor);
        }
    }
    return [fbReturn.OK, arTerms, arPrimes, arError, goldenNbr];
}

/**
 * Calculates the mean (average) of the values in an array.
 *
 * The function sums up all the numbers in the array 'lst' and divides the total by the length of the array, returning the mean value.
 *
 * @param {number[]} lst - An array of numbers for which the mean is to be calculated.
 * @returns {number} - The mean of the values in the array.
 *
 */
function mean(lst: number[]): number {
    return lst.reduce((a, b) => a + b, 0) / lst.length;
}

/**
 * Calculates the standard deviation of the values in an array.
 *
 * The function first calculates the mean of the array. Then, it computes the variance by summing the squares of the difference
 * between each value and the mean, dividing by the length of the array. Finally, it returns the square root of the variance,
 * which is the standard deviation.
 *
 * @param {number[]} lst - An array of numbers for which the standard deviation is to be calculated.
 * @returns {number} - The standard deviation of the values in the array.
 */
function standardDeviation(lst: number[]): number {
    const meanValue: number = mean(lst);
    const variance: number = lst.reduce((total, num) => total + Math.pow(num - meanValue, 2), 0) / lst.length;
    return Math.sqrt(variance);
}

/**
 * Main function that executes the Fibonacci sequence generation and factorization process multiple times, and logs the results.
 *
 * The function runs the 'fibonacci_interop' function 20 times with predefined parameters, measuring the execution time for each run.
 * It then logs each term of the Fibonacci sequence, its factorization (highlighting prime factors), and calculates the average
 * and standard deviation of the execution times. Finally, it logs the golden ratio approximation and the average and standard
 * deviation of execution times.
 *
 * @note This function assumes the existence of 'fibonacci_interop', 'mean', and 'standardDeviation' functions.
 * @note The 'fibonacci_interop' function is called with fixed values for 'maxTerms', 'maxFibo', and 'maxFactor',
 *       and runs for 7 iterations.
 * @note The function does not return any value; it logs results to the console.
 */
function main(): void {
    const maxTerms: number = 74;
    let timeCount: number[] = [];
    let fbRet: fbReturn;
    let arTerms: number[] | null = null;
    let arPrimes: boolean[] | null = null;
    let arError: number[] | null = null;
    let goldenNbr: number | null = null;

    for (let i = 0; i < 20; i++) {
        let startTime: number = Date.now();
        [fbRet, arTerms, arPrimes, arError, goldenNbr] = fibonacci_interop(1, maxTerms, 1304969544928657, 4000000, 7);
        let endTime: number = Date.now();
        timeCount.push(endTime - startTime);
    }


    if (arTerms && arPrimes && arError && goldenNbr !== null) {
        for (let i = 0; i < maxTerms; i++) {
            let line: string = '';
            let baseIndex: number = i * 50;
            if (arTerms[baseIndex] !== undefined) {
                line += arPrimes[baseIndex] ? `${i} - [${arTerms[baseIndex]}] : ` : `${i} - ${arTerms[baseIndex]} : `;
                let addValue: boolean = false;
                for (let position = 1; position < 50; position++) {
                    let index: number = baseIndex + position;
                    // Skip if the term is 0
                    if (arTerms[index] !== undefined && arTerms[index] !== 0) {
                        line += arPrimes[index] ? `[${arTerms[index]}] x ` : `${arTerms[index]} x `;
                        addValue = true;
                    }
                }
                // Remove the trailing ' x ' if addValue is true
                line = addValue ? line.slice(0, -3) : line + "Factor not found";
                console.log(line);
            }
        }

    }

    console.log("Golden Number: ", goldenNbr);
    console.log("---------------------------------");
    console.log("Average Duration: " + mean(timeCount) / 1000);
    console.log("Standard Deviation: " + standardDeviation(timeCount) / 1000);
}

main();
