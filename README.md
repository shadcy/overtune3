# Filter Designer

A professional **digital filter design tool** built with **Qt 6 / QML** (Apple-style UI) and a **pure C++20 DSP engine** with no external dependencies.

---

## Architecture

```
                 Filter Designer
                       │
              ┌────────┴────────┐
              │                 │
          Qt 6 QML          dsp library
          Apple-style UI     Pure C++20
              │                 │
              └────────┬────────┘
                       │
                 FilterEngine (bridge)
```

The `dsp/` library compiles **without Qt**. It can be used standalone, wrapped in Python bindings, or compiled to WebAssembly.

---

## Features

### Filter Types
- Low Pass, High Pass, Band Pass, Band Stop

### Filter Responses
- Butterworth
- Chebyshev Type I & II
- Elliptic (Cauer) — using Jacobi elliptic functions
- Bessel (maximally flat group delay)

### Analysis
- Magnitude response (dB)
- Phase response (degrees)
- Group delay (samples)
- Pole-zero diagram (z-plane)
- Impulse response
- Step response

### Interactive Plot
- **Drag the cutoff frequency directly on the graph**
- Real-time DSP recalculation on every parameter change
- Log-spaced frequency axis, −3 dB reference line

### Simulation
- Load WAV files (8/16/24/32-bit PCM + IEEE float)
- Load CSV files
- Generate sine wave or linear chirp
- Apply current filter and overlay input/output

### Export
| Format | Contents |
|--------|----------|
| **C** | `filter_process()` function with Direct Form II Transposed biquad |
| **C++ Header** | `constexpr` SOS array + `Filter` class |
| **Python** | NumPy/SciPy `sosfilt` code + matplotlib plot |
| **JSON** | Machine-readable SOS + spec |

### UI
- Apple-inspired design language
- Dark mode default, light mode, system auto
- Smooth animations and color transitions
- Sidebar navigation: Design · Analysis · Simulation · Export · Settings

---

## Building

### Requirements
- **CMake** ≥ 3.24
- **Qt 6.5+** with components: Core, Gui, Qml, Quick, QuickControls2, Multimedia
- A C++20-capable compiler (GCC 12+, Clang 14+, MSVC 2022+)

### Quick build (Linux / macOS)

```bash
# If Qt is in a standard location
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel

# Or use the convenience script
./build.sh

# With a custom Qt installation
./build.sh --qt /opt/Qt/6.7.0/gcc_64
```

### Windows (MSVC)

```bat
cmake -S . -B build -DCMAKE_PREFIX_PATH=C:\Qt\6.7.0\msvc2019_64
cmake --build build --config Release
```

### Running

```bash
./build/bin/FilterDesigner
```

---

## Project Structure

```
overtune3/
├── CMakeLists.txt              # Root CMake
├── build.sh                    # Convenience build script
├── dsp/                        # Pure C++20 DSP library
│   ├── include/dsp/
│   │   ├── FilterSpec.h        # Filter specification struct
│   │   ├── FilterDesigner.h    # Factory function
│   │   ├── FilterCoefficients.h # SOS biquad coefficients
│   │   ├── FilterAnalysis.h    # Frequency response analysis
│   │   ├── SignalProcessor.h   # Real-time sample processing
│   │   ├── CodeExporter.h      # Code generation
│   │   ├── WavReader.h         # WAV file I/O
│   │   └── CsvReader.h         # CSV file I/O
│   └── src/
│       ├── BilinearTransform.cpp  # s→z domain transform
│       ├── Butterworth.cpp
│       ├── Chebyshev.cpp          # Type I & II
│       ├── Elliptic.cpp           # Jacobi elliptic functions
│       ├── Bessel.cpp             # Pre-computed poles
│       └── ...
└── app/                        # Qt 6 QML application
    ├── src/
    │   ├── main.cpp
    │   ├── FilterEngine.{h,cpp}    # C++/QML bridge
    │   ├── SimulationModel.{h,cpp}
    │   ├── ExportModel.{h,cpp}
    │   └── ThemeManager.{h,cpp}   # Dark/light theme
    └── qml/
        ├── Main.qml
        ├── components/
        │   ├── FrequencyPlot.qml  # Interactive draggable plot
        │   ├── PoleZeroPlot.qml
        │   ├── ImpulseStepPlot.qml
        │   └── ...
        └── pages/
            ├── DesignPage.qml
            ├── AnalysisPage.qml
            ├── SimulationPage.qml
            ├── ExportPage.qml
            └── SettingsPage.qml
```

---

## Extending

### Adding a new filter type
1. Add an entry to `dsp::FilterResponse` in `FilterSpec.h`
2. Create `dsp/src/MyFilter.{h,cpp}` computing the analog prototype poles/zeros
3. Call `bilinearTransform()` from `BilinearTransform.h`
4. Register it in `FilterDesigner.cpp`
5. Add a model entry in `DesignPage.qml`

### Using the DSP library without Qt

```cpp
#include <FilterDesignerDSP.h>

dsp::FilterSpec spec;
spec.type       = dsp::FilterType::LowPass;
spec.response   = dsp::FilterResponse::Butterworth;
spec.order      = 4;
spec.sampleRate = 48000;
spec.cutoffFreq = 1000;

auto coeff  = dsp::designFilter(spec);
auto result = dsp::FilterAnalysis::compute(coeff, spec.sampleRate);

// Process audio
auto output = dsp::SignalProcessor::process(coeff, input);

// Generate C code
auto code = dsp::CodeExporter::generate(coeff, spec, dsp::ExportFormat::C);
```
