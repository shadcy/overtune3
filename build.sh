#!/usr/bin/env bash
# build.sh — Convenience build script for Filter Designer
# Usage:
#   ./build.sh                        # Release build in ./build/
#   ./build.sh --debug                # Debug build
#   ./build.sh --qt /path/to/Qt/6.x   # Specify Qt prefix

set -euo pipefail

BUILD_TYPE="Release"
QT_PREFIX=""
BUILD_DIR="build"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --debug)   BUILD_TYPE="Debug" ;;
        --qt)      shift; QT_PREFIX="$1" ;;
        --clean)   rm -rf "${BUILD_DIR}"; echo "Cleaned build dir." ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

CMAKE_ARGS=(-DCMAKE_BUILD_TYPE="${BUILD_TYPE}")
if [[ -n "${QT_PREFIX}" ]]; then
    CMAKE_ARGS+=(-DCMAKE_PREFIX_PATH="${QT_PREFIX}")
fi

echo "──────────────────────────────────────────"
echo "  Filter Designer  —  ${BUILD_TYPE} Build"
echo "──────────────────────────────────────────"
echo

# Configure
cmake -S . -B "${BUILD_DIR}" "${CMAKE_ARGS[@]}"

# Build (parallel)
cmake --build "${BUILD_DIR}" --parallel "$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 4)"

echo
echo "✓ Build complete. Binary: ${BUILD_DIR}/bin/FilterDesigner"
