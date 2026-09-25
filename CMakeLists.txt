cmake_minimum_required(VERSION 3.24)
project(FilterDesigner VERSION 1.0.0 LANGUAGES CXX)

# ── C++20 ─────────────────────────────────────────────────────────────────────
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ── Output directories ─────────────────────────────────────────────────────────
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# ── CMake modules ──────────────────────────────────────────────────────────────
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# ── Qt 6 ──────────────────────────────────────────────────────────────────────
# Try to find an existing Qt 6 installation first.
# Set QT_ROOT or CMAKE_PREFIX_PATH if Qt is in a non-standard location, e.g.:
#   cmake -DQT_ROOT=/opt/Qt/6.7.0/gcc_64 ..
if(DEFINED QT_ROOT)
    list(PREPEND CMAKE_PREFIX_PATH "${QT_ROOT}")
endif()

find_package(Qt6 6.4 COMPONENTS Core Gui Qml Quick QuickControls2 Multimedia REQUIRED)

message(STATUS "Found Qt ${Qt6_VERSION}")

# ── Sub-projects ───────────────────────────────────────────────────────────────
add_subdirectory(dsp)   # Pure C++20 DSP library (no Qt)
add_subdirectory(app)   # Qt 6 QML application
