# DSP Library CMakeLists.txt
# Pure C++20 — no Qt dependency

cmake_minimum_required(VERSION 3.24)

add_library(dsp STATIC
    src/FilterSpec.cpp
    src/BilinearTransform.cpp
    src/Butterworth.cpp
    src/Chebyshev.cpp
    src/Elliptic.cpp
    src/Bessel.cpp
    src/FilterCoefficients.cpp
    src/FilterDesigner.cpp
    src/FilterAnalysis.cpp
    src/SignalProcessor.cpp
    src/CodeExporter.cpp
    src/WavReader.cpp
    src/CsvReader.cpp
)

target_include_directories(dsp
    PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_features(dsp PUBLIC cxx_std_20)

if(MSVC)
    target_compile_options(dsp PRIVATE /W4 /WX)
else()
    target_compile_options(dsp PRIVATE -Wall -Wextra -Wpedantic)
endif()
