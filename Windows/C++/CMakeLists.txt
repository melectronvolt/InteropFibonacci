cmake_minimum_required(VERSION 3.27)
project(InteropFibonacciWin)

set(CMAKE_CXX_STANDARD 17)

#add_library(InteropFibonacciWin SHARED library.cpp)
add_executable(InteropFibonacciWinTest library.cpp)