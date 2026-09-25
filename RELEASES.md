# Release Notes

## Versioning

Overtune3 follows Semantic Versioning. Releases are tagged as `v{MAJOR}.{MINOR}.{PATCH}` on GitHub.

---

## Version 1.0.0

**Status:** Stable  
**Release Date:** September 2026  
**Download:** [GitHub Releases](https://github.com/shadcy/overtune3/releases)

### Overview

Overtune3 is a professional digital filter design application for creating, analyzing, simulating, and exporting signal-processing filters. It combines a Qt 6 / QML interface with a pure C++20 DSP engine designed for portability, clarity, and accurate filtering workflows.

### Highlights

#### Filter Design Engine
- Filter types: Low Pass, High Pass, Band Pass, Band Stop
- Filter responses: Butterworth, Chebyshev Type I, Chebyshev Type II, Elliptic, Bessel
- Interactive frequency plotting with direct cutoff adjustment
- Real-time recalculation across all analysis views whenever parameters change

#### Analysis and Visualization
- Magnitude response in dB
- Phase response in degrees
- Group delay in samples
- Pole-zero plot in the z-plane
- Impulse response
- Step response
- Log-spaced frequency axis and -3 dB reference line

#### Simulation
- WAV file import for PCM and IEEE float audio
- CSV input import
- Signal generation: sine wave and linear chirp
- Apply current filter to generated or imported signals
- Overlay input and output signals for comparison

#### Export

| Format | Contents |
|--------|----------|
| C | `filter_process()` implementation using Direct Form II Transposed biquads |
| C++ Header | `constexpr` SOS arrays and a C++ `Filter` class |
| Python | NumPy/SciPy `sosfilt` code and matplotlib plotting support |
| JSON | Machine-readable SOS coefficients and design metadata |

#### User Interface
- Apple-inspired design language
- Dark mode, light mode, and system auto theme support
- Clean multi-page navigation for design, analysis, simulation, export, and settings
- Smooth interaction and visual transitions

### Technical Highlights

- Pure C++20 DSP engine with no Qt dependency for core signal processing
- Clean separation between the UI layer and the DSP library
- Cross-platform support for Linux, macOS, and Windows
- Extensible architecture designed for future filter types and export targets

### System Requirements

- CMake 3.24 or newer
- Qt 6.5+ with Core, Gui, Qml, Quick, QuickControls2, and Multimedia
- C++20 compatible compiler: GCC 12+, Clang 14+, or MSVC 2022+
- Supported operating systems: Linux, macOS, Windows

### Build Instructions

#### Linux and macOS

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

Or use the project convenience script:

```bash
./build.sh
```

For custom Qt installations:

```bash
./build.sh --qt /opt/Qt/6.7.0/gcc_64
```

#### Windows (MSVC)

```bat
cmake -S . -B build -DCMAKE_PREFIX_PATH=C:\Qt\6.7.0\msvc2019_64
cmake --build build --config Release
```

### Running the Application

```bash
./build/bin/FilterDesigner
```

### Known Limitations

- Large filter orders may reduce chart smoothness in some UI configurations
- Very large audio files may require more memory during simulation
- High-order pole-zero plots are optimized for readability rather than full rendering density

### Documentation

- Installation Guide: [Wiki](https://github.com/shadcy/overtune3/wiki/Installation-&-Setup)
- Architecture Overview: [Wiki](https://github.com/shadcy/overtune3/wiki/Architecture)
- Contributor Guide: [Wiki](https://github.com/shadcy/overtune3/wiki/Contributing)

---

## Planned Releases

### Version 1.1.0

Planned work includes:
- Additional filter design methods
- Improved batch export tools
- More advanced simulation workflows
- Continued UI and performance refinement

---

## Reporting Issues

Issues can be reported in the GitHub repository issue tracker. When filing a report, include:
1. Operating system and version
2. Qt version and build details
3. Steps to reproduce the issue
4. Expected behavior
5. Actual behavior
6. Relevant screenshots or sample files when applicable

---

## Contributing

Contributions are welcome. Please review the project documentation and follow the repository guidelines before submitting changes.
