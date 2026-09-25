# Installation

This guide explains how to install and build Overtune3 on supported operating systems.

## Requirements

Before building the project, ensure the following are installed:

- CMake 3.24 or newer
- Qt 6.5 or newer
- C++20-compatible compiler
- Git

### Required Qt components

The project uses the following Qt modules:

- Core
- Gui
- Qml
- Quick
- QuickControls2
- Multimedia

## Clone the repository

```bash
git clone https://github.com/shadcy/overtune3.git
cd overtune3
```

## Configure the project

### Linux and macOS

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
```

### Windows with MSVC

```bat
cmake -S . -B build -DCMAKE_PREFIX_PATH=C:\Qt\6.7.0\msvc2019_64
```

## Build the project

### Linux and macOS

```bash
cmake --build build --parallel
```

Or use the provided script:

```bash
./build.sh
```

If your Qt installation is not in a standard location:

```bash
./build.sh --qt /opt/Qt/6.7.0/gcc_64
```

### Windows

```bat
cmake --build build --config Release
```

## Run the application

After the build completes, run the executable from the build output directory:

```bash
./build/bin/FilterDesigner
```

On Windows, launch the generated executable from the build output folder.

## Troubleshooting

### Qt is not found

If CMake cannot find Qt, specify the Qt installation path explicitly:

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.x.x/gcc_64
```

### Compiler compatibility issues

Make sure your compiler supports C++20. Recommended toolchains include:

- GCC 12+
- Clang 14+
- MSVC 2022+

### Build script errors

Check the following:

- Qt is installed
- The Qt path is correct
- Build tools are available on your system
- The repository was cloned successfully

## Recommended workflow

1. Clone the repository
2. Configure with CMake
3. Build in Release mode
4. Run the app
5. Design a filter
6. Evaluate the response
7. Simulate the signal
8. Export the result

## Related pages

- [Architecture](Architecture)
- [Features](Features)
- [FAQ](FAQ)
