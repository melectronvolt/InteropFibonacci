const fbReturn = {
    OK: 0,
    NOL: 1,
    OF_P: 2,
    OF: 3,
    TMT: 4,
    TB: 5,
    PRM_ERR: 6,
    ERR: 7
};

function isPrime(numberPrime, maxFactor) {
    let maxSearch = numberPrime < maxFactor ? numberPrime : maxFactor;
    for (let i = 2; i < maxSearch; i++) {
        if (numberPrime % i === 0) {
            return false;
        }
    }
    return true;
}

function factorization(baseIndex, arTerms, arPrimes, maxFactor) {
    let position = 0;
    let result = arTerms[baseIndex];
    let testNbr = 2;

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


function fibonacci_interop(fbStart, maxTerms = 74, maxFibo = 1304969544928657, maxFactor = 5000, nbrOfLoops = 1) {
    let arTerms = [];
    let arPrimes = [];
    let arError = [];

    if (fbStart < 1 || maxFibo < 1 || maxTerms < 3 || maxFactor < 2 || nbrOfLoops < 1) {
        return [fbReturn.PRM_ERR, null, null, null];
    }

    if (maxTerms > 74) {
        return [fbReturn.TMT, null, null, null];
    }

    if (maxFibo > 1304969544928657) {
        return [fbReturn.TB, null, null, null];
    }

    const goldenConst = (1 + Math.sqrt(5)) / 2;

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
            arPrimes[baseIndex] = isPrime(arTerms[baseIndex]);
            arError[currentTerm] = Math.abs(goldenConst - (arTerms[baseIndex] / arTerms[baseIndex - 50]));
            factorization(baseIndex, arTerms, arPrimes, maxFactor);
        }
    }

    let goldenNbr = arTerms[(maxTerms - 1) * 50] / arTerms[(maxTerms - 2) * 50];
    return [fbReturn.OK, arTerms, arPrimes, arError, goldenNbr];
}

function mean(lst) {
    return lst.reduce((a, b) => a + b, 0) / lst.length;
}

function standardDeviation(lst) {
    const meanValue = mean(lst);
    const variance = lst.reduce((total, num) => total + Math.pow(num - meanValue, 2), 0) / lst.length;
    return Math.sqrt(variance);
}

function main() {

    const maxTerms = 74
    let timeCount = [];
    let fbRet, arTerms, arPrimes, arError, goldenNbr

    for (let i = 0; i < 20; i++) {
        let startTime = Date.now();
        [fbRet, arTerms, arPrimes, arError, goldenNbr] = fibonacci_interop(1, maxTerms, 1304969544928657, 4000000, 7);
        let endTime = Date.now();
        timeCount.push(endTime - startTime);
    }

    for (let i = 0; i < maxTerms; i++) {
        let line = '';
        let baseIndex = i * 50;
        if (arTerms[baseIndex]) {
            line += arPrimes[baseIndex] ? `${i} - [${arTerms[baseIndex]}] : ` : `${i} - ${arTerms[baseIndex]} : `;
            let addValue = false;
            for (let position = 1; position < 50; position++) {
                let index = baseIndex + position;
                if (arTerms[index]) {
                    line += arPrimes[index] ? `[${arTerms[index]}] x ` : `${arTerms[index]} x `;
                    addValue = true;
                }
            }
            line = addValue ? line.slice(0, -3) : line + "Factor not found";
            console.log(line);
        }
    }

    console.log("Golden Number: ", goldenNbr);
    console.log("---------------------------------");
    console.log("Average Duration: " + mean(timeCount)/ 1000);
    console.log("Standard Deviation: " + standardDeviation(timeCount)/ 1000);

}

main();
