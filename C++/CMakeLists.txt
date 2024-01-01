cmake_minimum_required(VERSION 3.27)
project(InteropFibonacciWinCPP)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /O2 /arch:AVX2")

add_library(InteropFibonacciWinCPP SHARED library.cpp)
