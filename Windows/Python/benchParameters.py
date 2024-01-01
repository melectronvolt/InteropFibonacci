__author__ = "Rémi MEVAERE"
__copyright__ = "Copyright (c) 2024 Rémi MEVAERE"
__license__ = "MIT License"
__version__ = "1.0.0"
__maintainer__ = "Rémi MEVAERE"
__email__ = "your.email@example.com"
__status__ = "Development"
__date__ = "2024-01-01"

# Parameters for the benchmarks

class parameters:
    fiboMaxTerms: int = 74  # 74 is the maximum number of terms that can be calculated, it must fit in int64
    numberRun: int = 20  # Number of times the test is performed
    fiboStart: int = 1  # The first term of the fibonacci sequence
    fiboMaxValue: int = 1304969544928657  # The maximum value of the fibonacci sequence, it must fit in int64
    fiboMaxFactor: int = 4000000  # The maximum value of the factorization
    fiboNbrOfLoops: int = 1  # The number of times the test is performed
    showResult: bool = False  # Hide the result of the test