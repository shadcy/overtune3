<div align="center">

# ⚡ Filter Designer

**Next-Generation Digital Filter Design & Real-Time DSP Studio**

[![C++20](https://img.shields.io/badge/C%2B%2B-20-00599C?style=for-the-badge&logo=c%2B%2B&logoColor=white)](https://en.cppreference.com/w/cpp/20)
[![Qt](https://img.shields.io/badge/Qt-6.4+-41CD52?style=for-the-badge&logo=qt&logoColor=white)](https://www.qt.io/)
[![CMake](https://img.shields.io/badge/CMake-3.24+-064F8C?style=for-the-badge&logo=cmake&logoColor=white)](https://cmake.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey?style=for-the-badge)](#building)

A sleek, Apple-inspired DSP workstation combining a **pure C++20 filter engine** (zero external dependencies) with a reactive **Qt 6 QML** interface. Design IIR filters, drag cutoffs interactively in real time, analyze pole-zero placement, simulate audio playback, study DSP theory with rendered LaTeX equations, and export production-ready C, C++, Python, and JSON code.

[Quick Start](#-quick-start) • [Architecture](#-architecture) • [Features](#-key-features) • [Filter Matrix](#-filter-matrix) • [Exporting](#-code-export) • [Standalone DSP](#-standalone-dsp-library)

---

</div>

## 🚀 Quick Start

### One-Liner (Build & Run)

```bash
./build.sh && ./build/bin/FilterDesigner
```

### Clean Rebuild & Run

```bash
./build.sh --clean && ./build/bin/FilterDesigner
```

### Standard CMake Workflow

```bash
# 1. Configure
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release

# 2. Compile (uses all CPU cores)
cmake --build build --parallel

# 3. Launch
./build/bin/FilterDesigner
```

<details>
<summary><b>🛠️ Advanced Build Options & Platform Notes</b></summary>

#### Custom Qt Installation Path
```bash
# Using the convenience script
./build.sh --qt /opt/Qt/6.7.0/gcc_64 && ./build/bin/FilterDesigner

# Or with raw CMake
cmake -S . -B build -DCMAKE_PREFIX_PATH=/opt/Qt/6.7.0/gcc_64 -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
```

#### Debug Build
```bash
./build.sh --debug && ./build/bin/FilterDesigner
```

#### Windows (MSVC 2022)
```bat
cmake -S . -B build -DCMAKE_PREFIX_PATH=C:\Qt\6.7.0\msvc2019_64
cmake --build build --config Release
.\build\bin\FilterDesigner.exe
```

#### Prerequisites
- **Compiler**: C++20 compatible (GCC 12+, Clang 14+, Apple Clang 15+, MSVC 2022+)
- **CMake**: >= 3.24
- **Qt 6**: >= 6.4 (Modules: `Core`, `Gui`, `Qml`, `Quick`, `QuickControls2`, `Multimedia`)

</details>

---

## 🏛 Architecture

Filter Designer is strictly decoupled into two distinct tiers: an ultra-fast, zero-dependency C++20 DSP engine and a hardware-accelerated declarative QML UI.

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Filter Designer Application                      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
         ┌──────────────────────────┴──────────────────────────┐
         ▼                                                     ▼
┌──────────────────────────────────┐        ┌──────────────────────────────────┐
│      Qt 6 QML Presentation       │        │        dsp/ Engine Core          │
│  • Draggable Frequency Response  │        │  • Pure ISO C++20                │
│  • Interactive Pole-Zero Plot    │        │  • Zero external dependencies    │
│  • Audio Simulation & Waveforms  │◄──────►│  • Bilinear Transform (s → z)    │
│  • LaTeX Math & Tutorial Studio  │        │  • SOS Biquad Cascade (DF2T)     │
│  • Dark / Light Studio Theming   │        │  • Audio & WAV / CSV streaming   │
└──────────────────────────────────┘        └──────────────────────────────────┘
                                    ▲
                                    │
                         ┌──────────┴──────────┐
                         │ FilterEngine Bridge │
                         │  (Qt C++ Adapter)   │
                         └─────────────────────┘
```

> **Standalone Decoupling:** The `dsp/` library has **zero Qt dependencies**. You can extract the `dsp/` folder and drop it into embedded firmware, command-line tools, audio plugins (VST/AU), WebAssembly, or Python bindings via pybind11.

---

## ✨ Key Features

### 🎛️ Interactive Filter Design
- **Direct Graph Manipulation:** Drag cutoff frequencies ($f_c$) and passband edges directly on the interactive Bode plot with tactile visual response.
- **Continuous Recalculation:** Sub-millisecond filter coefficient generation and response recomputation upon every slider touch or mouse drag.
- **Topology Support:** Low Pass, High Pass, Band Pass, and Band Stop.
- **Arbitrary Orders:** Seamlessly cascade up to 20+ order filters partitioned into numerically stable Second-Order Sections (SOS).

### 🔬 Deep Signal & System Analysis
- **Magnitude & Phase:** Logarithmic-frequency Bode plots with exact $-3\text{ dB}$ reference indicators and configurable dB scaling.
- **Group Delay:** Exact phase derivative analysis highlighting transit distortion across critical frequency bands.
- **Complex Z-Plane Poles & Zeros:** Real-time root visualization showing distance relative to the unit circle with stability detection.
- **Impulse & Step Response:** Time-domain transient response simulations illustrating settling time and overshoot.

### 🧪 Live Audio & Signal Simulation
- **Multi-Format Ingestion:** Load WAV (8, 16, 24, 32-bit integer PCM & IEEE float) and CSV datasets.
- **Synthetic Signal Generator:** Built-in sine tone and linear frequency sweep (chirp) generators.
- **Direct A/B Comparison:** Dual-trace waveform overlay comparing raw input signals with filtered output signals.
- **Audio Output:** Audition raw vs. filtered audio directly through system audio output via Qt Multimedia.

### 📚 Integrated LaTeX Docs & Tutorial Studio
- **Mathematical Foundations:** Fully rendered in-app formulas for Laplace prototypes, bilinear pre-warping, and $z$-domain transfer functions.
- **Interactive Tutorials:** Guided walk-throughs covering audio anti-aliasing, DC blocking, notch filtering, and biomedical EEG/ECG filtering.
- **Technical Tables:** Quick reference guides for filter attenuation slopes, phase linearity comparison, and biquad numerical sensitivity.

---

## 📊 Filter Matrix

| Filter Response | Passband Ripple | Stopband Ripple | Transition Roll-Off | Phase Linearity | Best Suited For |
|:---|:---:|:---:|:---:|:---:|:---|
| **Butterworth** | Maximally Flat ($0\text{ dB}$) | Monotonic | Moderate ($6N\text{ dB/oct}$) | Good | General audio, clean crossover networks, measurement |
| **Chebyshev Type I** | Equiripple ($\varepsilon$) | Monotonic | Steep | Non-linear | High selectivity where passband ripple is tolerable |
| **Chebyshev Type II** | Maximally Flat | Equiripple ($R_s$) | Steep | Non-linear | Anti-aliasing, systems requiring zero passband distortion |
| **Elliptic (Cauer)** | Equiripple ($\varepsilon$) | Equiripple ($R_s$) | **Steepest** | Highly non-linear | Severe transition band constraints, steep brick-wall cutoffs |
| **Bessel** | Monotonic | Monotonic | Gentle | **Maximally Flat Group Delay** | Pulse shaping, communications, audio transient preservation |

---

## 💾 Code Export

Export verified, production-grade filter implementations in four industry-standard formats:

### 1. Embedded C (`Direct Form II Transposed`)
Single-header compatible, zero-allocation C routine ideal for microcontrollers (ARM Cortex-M, ESP32, STM32, PIC):
```c
/* Generated by Filter Designer */
void filter_process(const float* in, float* out, size_t count, BiquadState* state);
```

### 2. Modern C++ (`constexpr` Biquads)
Object-oriented C++20 header with `constexpr` coefficients and vectorized processing methods.

### 3. Python (SciPy / NumPy)
Self-contained Python script utilizing `scipy.signal.sosfilt` with automatic Matplotlib verification plots:
```python
import numpy as np
from scipy import signal
import matplotlib.pyplot as plt

sos = np.array([...])
filtered = signal.sosfilt(sos, data)
```

### 4. Machine-Readable JSON
Structured interchange format containing complete filter specifications, pole-zero coordinates, and SOS arrays for automated toolchains and test fixtures.

---

## 📦 Standalone DSP Library

You can integrate the pure C++20 DSP library into any CMake project without Qt:

```cmake
# In your project's CMakeLists.txt:
add_subdirectory(overtune3/dsp)
target_link_libraries(MyEmbeddedApp PRIVATE dsp)
```

### C++ Usage Example

```cpp
#include <dsp/FilterDesigner.h>
#include <dsp/FilterAnalysis.h>
#include <dsp/SignalProcessor.h>
#include <dsp/CodeExporter.h>

// 1. Define Filter Specification
dsp::FilterSpec spec{
    .type         = dsp::FilterType::LowPass,
    .response     = dsp::FilterResponse::Butterworth,
    .order        = 4,
    .sampleRate   = 48000.0,
    .cutoffFreq   = 2500.0,
    .ripplePass   = 1.0,  // dB (for Chebyshev I / Elliptic)
    .stopbandAttn = 40.0  // dB (for Chebyshev II / Elliptic)
};

// 2. Synthesize Filter
dsp::FilterCoefficients coeffs = dsp::designFilter(spec);

// 3. Compute Spectral Analysis
dsp::AnalysisResult analysis = dsp::FilterAnalysis::compute(coeffs, spec.sampleRate);

// 4. Process Samples in Real-Time
std::vector<float> inputSignal = /* ... */;
std::vector<float> outputSignal = dsp::SignalProcessor::process(coeffs, inputSignal);

// 5. Generate Standalone C Code
std::string cSource = dsp::CodeExporter::generate(coeffs, spec, dsp::ExportFormat::C);
```

---

## 📂 Project Directory Structure

```
overtune3/
├── CMakeLists.txt               # Master CMake configuration
├── build.sh                     # Automated build & configuration script
├── assets/                      # Application icons, fonts, and graphics
│
├── dsp/                         # 🧠 Pure C++20 DSP Library (Zero Qt dependency)
│   ├── CMakeLists.txt
│   ├── include/dsp/
│   │   ├── FilterSpec.h         # Specification and parameter structures
│   │   ├── FilterDesigner.h     # High-level synthesis factory
│   │   ├── FilterCoefficients.h # Second-Order Section (SOS) representations
│   │   ├── FilterAnalysis.h     # Bode, phase, group delay & z-plane analysis
│   │   ├── SignalProcessor.h    # Block and sample-by-sample processing
│   │   ├── CodeExporter.h       # C, C++, Python, JSON code generators
│   │   ├── WavReader.h          # Multi-format WAV audio decoder
│   │   └── CsvReader.h          # Time-series CSV importer
│   └── src/
│       ├── BilinearTransform.cpp# s-plane to z-plane bilinear mapping
│       ├── Butterworth.cpp      # Butterworth analog prototype
│       ├── Chebyshev.cpp        # Chebyshev Type I & II analog prototype
│       ├── Elliptic.cpp         # Jacobi elliptic function prototype
│       └── Bessel.cpp           # Bessel prototype polynomials
│
└── app/                         # 🎨 Qt 6 / QML Desktop Application
    ├── CMakeLists.txt
    ├── src/
    │   ├── main.cpp             # Application bootstrap & window management
    │   ├── FilterEngine.h/.cpp  # C++/QML bridge (reactive data pipeline)
    │   ├── SimulationModel.h/.cpp# Signal generator & audio playback controller
    │   ├── ExportModel.h/.cpp   # Real-time code preview provider
    │   └── ThemeManager.h/.cpp  # Dynamic theme switcher (Dark/Light/System)
    └── qml/
        ├── Main.qml             # Main layout, sidebar, and view stack
        ├── theme/Theme.qml      # Apple-inspired color tokens and typography
        ├── components/          # Reusable visual widgets
        │   ├── FrequencyPlot.qml# Draggable Bode response graph
        │   ├── PoleZeroPlot.qml # Complex z-plane unit-circle canvas
        │   ├── ImpulseStepPlot.qml# Transient response visualizer
        │   ├── SignalPlot.qml   # Time-domain waveform oscilloscope
        │   ├── LaTeXBlock.qml   # Formatted DSP mathematical equation block
        │   ├── CodeViewer.qml   # Syntax-colored code viewer with copy
        │   └── TutorialStudio.qml# Interactive step-by-step DSP guide
        └── pages/               # Primary application views
            ├── DesignPage.qml   # Synthesis workbench & interactive plot
            ├── AnalysisPage.qml # Detailed spectral & root analysis
            ├── SimulationPage.qml# Audio & signal generation studio
            ├── DocsPage.qml     # LaTeX theory guide & technical tables
            ├── ExportPage.qml   # Code export center (C, C++, Py, JSON)
            └── SettingsPage.qml # Theme and audio device preferences
```

---

## ⌨️ Navigation & Controls

| View | Description | Key Capabilities |
|:---|:---|:---|
| **Design** | Filter Synthesis | Drag cutoff line directly on graph, change order, ripple, & response type |
| **Analysis** | System Diagnostics | Inspect group delay, phase unwrapping, impulse/step response, and poles/zeros |
| **Simulation** | Real-Time Testing | Load WAV/CSV, generate sines/chirps, apply filter, and preview audio playback |
| **Docs & Theory** | Educational Suite | Read mathematical derivations, examine LaTeX formulas, run interactive tutorials |
| **Export** | Code Generator | Preview and copy C/C++/Python/JSON implementations with 1-click clipboard copy |
| **Settings** | Configuration | Toggle Dark / Light / System theme, customize plotting fidelity and grid styles |

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) — free for personal, academic, and commercial use.
