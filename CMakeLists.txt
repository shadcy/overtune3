cmake_minimum_required(VERSION 3.24)
project(FilterDesigner VERSION 3.2.1 LANGUAGES CXX)

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

find_package(Qt6 6.4 COMPONENTS Core Gui Qml Quick QuickControls2 Multimedia Network REQUIRED)

message(STATUS "Found Qt ${Qt6_VERSION}")

# ── Sub-projects ───────────────────────────────────────────────────────────────
add_subdirectory(dsp)   # Pure C++20 DSP library (no Qt)
add_subdirectory(app)   # Qt 6 QML application

# ── CPack Packaging & Installer Generation ─────────────────────────────────────
set(CPACK_PACKAGE_NAME "Overtune3")
set(CPACK_PACKAGE_VENDOR "Overtune DSP")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "High-Precision Digital Filter Design & Live Audio Lab")
set(CPACK_PACKAGE_VERSION "3.2.1")
set(CPACK_PACKAGE_CONTACT "support@overtune.audio")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

if(WIN32)
    set(CPACK_GENERATOR "NSIS;ZIP")
    set(CPACK_NSIS_DISPLAY_NAME "Overtune 3 Studio")
    set(CPACK_NSIS_PACKAGE_NAME "Overtune 3")
    set(CPACK_NSIS_HELP_LINK "https://overtune.audio")
    set(CPACK_NSIS_URL_INFO_ABOUT "https://overtune.audio")
    set(CPACK_NSIS_MODIFY_PATH ON)
else()
    set(CPACK_GENERATOR "TGZ;DEB")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Overtune DSP Team")
    set(CPACK_DEBIAN_PACKAGE_SECTION "sound")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libqt6core6, libqt6gui6, libqt6qml6, libqt6quick6, libqt6multimedia6, libqt6network6")
endif()

include(CPack)

