enum fbReturn {
    OK = 0,
    NOL = 1,
    OF_P = 2,
    OF = 3,
    TMT = 4,
    TB = 5,
    PRM_ERR = 6,
    ERR = 7
}

function isPrime(numberPrime: number, maxFactor: number): boolean {
    let maxSearch: number = numberPrime < maxFactor ? numberPrime : maxFactor;
    for (let i: number = 2; i < maxSearch; i++) {
        if (numberPrime % i === 0) {
            return false;
        }
    }
    return true;
}

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

function fibonacci_interop(fbStart: number, maxTerms: number = 74, maxFibo: number = 1304969544928657, maxFactor: number = 5000, nbrOfLoops: number = 1): [fbReturn, number[] | null, boolean[] | null, number[] | null, number | null] {
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

    const goldenConst: number = (1 + Math.sqrt(5)) / 2;

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
            arTerms[baseIndex] = arTerms[baseIndex - 50] + arTerms[baseIndex - 100];
            arPrimes[baseIndex] = isPrime(arTerms[baseIndex], maxFactor);
            arError[currentTerm] = Math.abs(goldenConst - (arTerms[baseIndex] / arTerms[baseIndex - 50]));
            factorization(baseIndex, arTerms, arPrimes, maxFactor);
        }
    }

    let goldenNbr: number = arTerms[(maxTerms - 1) * 50] / arTerms[(maxTerms - 2) * 50];
    return [fbReturn.OK, arTerms, arPrimes, arError, goldenNbr];
}

function mean(lst: number[]): number {
    return lst.reduce((a, b) => a + b, 0) / lst.length;
}

function standardDeviation(lst: number[]): number {
    const meanValue: number = mean(lst);
    const variance: number = lst.reduce((total, num) => total + Math.pow(num - meanValue, 2), 0) / lst.length;
    return Math.sqrt(variance);
}

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
