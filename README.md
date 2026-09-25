<div align="center">

# ⚡ Filter Designer (Overtune 3)

**Next-Generation Digital Filter Design & Real-Time DSP Studio**

[![C++20](https://img.shields.io/badge/C%2B%2B-20-0A84FF?style=for-the-badge&logo=c%2B%2B&logoColor=white)](https://en.cppreference.com/w/cpp/20)
[![Qt](https://img.shields.io/badge/Qt-6.4+-0A84FF?style=for-the-badge&logo=qt&logoColor=white)](https://www.qt.io/)
[![CMake](https://img.shields.io/badge/CMake-3.24+-0A84FF?style=for-the-badge&logo=cmake&logoColor=white)](https://cmake.org/)
[![License](https://img.shields.io/badge/License-MIT-0A84FF?style=for-the-badge)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-shadcy%2Fovertune3-0A84FF?style=for-the-badge&logo=github&logoColor=white)](https://github.com/shadcy/overtune3)
[![Issues](https://img.shields.io/badge/Issues-Report-0A84FF?style=for-the-badge&logo=github&logoColor=white)](https://github.com/shadcy/overtune3/issues)

A professional DSP workstation combining a pure C++20 filter engine with zero external dependencies and a reactive Qt 6 QML interface. Design IIR filters, drag cutoffs interactively in real time, analyze pole-zero placement on the unit circle, simulate audio playback, study DSP theory with rendered equations, and export production-ready C, C++, Python, and JSON code.

[Quick Start](#-quick-start) • [Architecture](#-architecture) • [Features](#-key-features) • [Filter Theory & Wiki](#-filter-approximations--wiki-articles) • [Exporting](#-code-export) • [Contributors](#-contributors--community)

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

# 2. Compile (uses all available CPU cores)
cmake --build build --parallel

# 3. Launch
./build/bin/FilterDesigner
```

### Advanced Options
- **Debug build:** `./build.sh --debug && ./build/bin/FilterDesigner`
- **Custom Qt prefix:** `./build.sh --qt /opt/Qt/6.7.0/gcc_64 && ./build/bin/FilterDesigner`
- **Windows (MSVC 2022):** `cmake -S . -B build -DCMAKE_PREFIX_PATH=C:\Qt\6.7.0\msvc2019_64 && cmake --build build --config Release && .\build\bin\FilterDesigner.exe`

---

## 🏛 Architecture

Filter Designer is strictly decoupled into two tiers: an ultra-fast, zero-dependency C++20 DSP engine and a hardware-accelerated declarative QML UI.

```
                   Filter Designer Application
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
   Qt 6 QML Presentation                 dsp/ Engine Core
   • Draggable Frequency Response        • Pure ISO C++20
   • Interactive Pole-Zero Plot          • Zero external dependencies
   • Audio Simulation & Waveforms        • Bilinear Transform (s → z)
   • LaTeX Math & Tutorial Studio        • SOS Biquad Cascade (DF2T)
   • Dark / Light Studio Theming         • Audio & WAV / CSV streaming
            ▲                                     ▲
            └──────────────────┬──────────────────┘
                               │
                      FilterEngine Bridge
                       (Qt C++ Adapter)
```

The `dsp/` library has **zero Qt dependencies**. It can be extracted into embedded firmware, command-line utilities, VST audio plugins, WebAssembly, or Python bindings.

---

## ✨ Key Features

### Interactive Filter Synthesis
- **Direct Graph Manipulation:** Drag cutoff frequencies ($f_c$) and passband boundaries directly on the interactive Bode plot with tactile visual response.
- **Continuous Recalculation:** Sub-millisecond filter coefficient generation and response recomputation upon every slider touch or mouse drag.
- **Topology Support:** Low Pass, High Pass, Band Pass, and Band Stop.
- **Arbitrary Orders:** Seamlessly cascade up to 20+ order filters partitioned into numerically stable Second-Order Sections (SOS).

### Signal & System Diagnostics
- **Magnitude & Phase:** Logarithmic-frequency Bode plots with exact $-3\text{ dB}$ reference indicators and configurable dB scaling.
- **Group Delay:** Exact phase derivative analysis highlighting transit distortion across critical frequency bands.
- **Complex Z-Plane Poles & Zeros:** Real-time root visualization showing distance relative to the unit circle with stability detection.
- **Impulse & Step Response:** Time-domain transient response simulations illustrating settling time and overshoot.

### Live Audio & Signal Simulation
- **Multi-Format Ingestion:** Load WAV (8, 16, 24, 32-bit integer PCM & IEEE float) and CSV datasets.
- **Synthetic Signal Generator:** Built-in sine tone and linear frequency sweep (chirp) generators.
- **Direct A/B Comparison:** Dual-trace waveform overlay comparing raw input signals with filtered output signals.
- **Audio Output:** Audition raw vs. filtered audio directly through system audio output via Qt Multimedia.

### Integrated Documentation & Tutorial Studio
- **Mathematical Foundations:** Fully rendered in-app formulas for Laplace prototypes, bilinear pre-warping, and $z$-domain transfer functions.
- **Interactive Tutorials:** Guided walk-throughs covering audio anti-aliasing, DC blocking, notch filtering, and biomedical EEG/ECG filtering.
- **Theory & Guides:** Quick reference guides for filter attenuation slopes, phase linearity, and biquad numerical sensitivity.

---

## 📖 Filter Approximations & Wiki Articles

Explore the theoretical foundations and mathematical derivations behind each supported filter approximation:

- **[Butterworth Filter](https://en.wikipedia.org/wiki/Butterworth_filter)**
  - *Passband:* Maximally flat ($0\text{ dB}$ ripple)
  - *Stopband:* Monotonic roll-off ($6N\text{ dB/octave}$)
  - *Phase Response:* Moderate phase linearity
  - *Best Suited For:* High-fidelity audio crossovers, general-purpose filtering, and measurement systems where passband ripple cannot be tolerated.

- **[Chebyshev Type I Filter](https://en.wikipedia.org/wiki/Chebyshev_filter)**
  - *Passband:* Equiripple behavior controlled by user ripple tolerance $\varepsilon$
  - *Stopband:* Monotonic roll-off with steeper transition than Butterworth
  - *Phase Response:* Non-linear near the cutoff frequency
  - *Best Suited For:* Channelization and high-selectivity applications where passband ripple is acceptable.

- **[Chebyshev Type II Filter (Inverse Chebyshev)](https://en.wikipedia.org/wiki/Chebyshev_filter#Type_II_Chebyshev_filters)**
  - *Passband:* Maximally flat passband with zero ripple
  - *Stopband:* Equiripple attenuation reaching specified stopband dB
  - *Phase Response:* Non-linear in transition region
  - *Best Suited For:* Anti-aliasing and ADC front-ends requiring pristine passbands with sharp cutoff.

- **[Elliptic Filter (Cauer Filter)](https://en.wikipedia.org/wiki/Elliptic_filter)**
  - *Passband:* Equiripple passband
  - *Stopband:* Equiripple stopband with transmission zeros
  - *Transition Band:* **Steepest possible roll-off** for a given filter order
  - *Phase Response:* Highly non-linear
  - *Best Suited For:* Severe transition band constraints, steep brick-wall cutoffs, and bandwidth-limited communication channels.

- **[Bessel Filter (Thomson Filter)](https://en.wikipedia.org/wiki/Bessel_filter)**
  - *Group Delay:* **Maximally flat group delay** across passband
  - *Phase Response:* Linear phase with virtually zero phase distortion
  - *Transition Band:* Gentle, monotonic roll-off
  - *Best Suited For:* Audio transient preservation, pulse shaping, radar, and square wave filtering without ringing or overshoot.

### Core Mathematical Concepts
- **[Bilinear Transform](https://en.wikipedia.org/wiki/Bilinear_transform)**: Conformal mapping transforming the continuous $s$-plane into the discrete $z$-plane via trapezoidal integration with frequency pre-warping.
- **[Digital Biquad Filter](https://en.wikipedia.org/wiki/Digital_biquad_filter)**: Second-Order Section (SOS) Direct Form II Transposed implementation ensuring robust numerical stability.
- **[Group Delay & Phase Delay](https://en.wikipedia.org/wiki/Group_delay_and_phase_delay)**: Time delay of amplitude envelopes across frequencies, computed via phase derivatives.
- **[Z-Transform & Unit Circle Stability](https://en.wikipedia.org/wiki/Z-transform)**: Root constellation criteria for Bounded-Input Bounded-Output (BIBO) stability.

---

## 💾 Code Export

Export verified, production-grade filter implementations in four industry-standard formats:

- **Embedded C (`Direct Form II Transposed`)**
  Single-header compatible, zero-allocation C routine ideal for microcontrollers (ARM Cortex-M, ESP32, STM32):
  ```c
  /* Generated by Filter Designer */
  void filter_process(const float* in, float* out, size_t count, BiquadState* state);
  ```

- **Modern C++ (`constexpr` Biquads)**
  Object-oriented C++20 header with `constexpr` coefficient arrays and vectorized sample processing.

- **Python (SciPy / NumPy)**
  Self-contained Python script utilizing `scipy.signal.sosfilt` with automatic Matplotlib verification plots.

- **Machine-Readable JSON**
  Structured interchange schema containing complete filter specifications, pole-zero coordinates, and SOS arrays for automated toolchains and test fixtures.

---

## 📦 Standalone DSP Library

You can integrate the pure C++20 DSP library into any CMake project without Qt:

```cmake
# In your project's CMakeLists.txt:
add_subdirectory(overtune3/dsp)
target_link_libraries(MyEmbeddedApp PRIVATE dsp)
```

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
    .ripplePass   = 1.0,
    .stopbandAttn = 40.0
};

// 2. Synthesize Filter
dsp::FilterCoefficients coeffs = dsp::designFilter(spec);

// 3. Compute Spectral Analysis
dsp::AnalysisResult analysis = dsp::FilterAnalysis::compute(coeffs, spec.sampleRate);

// 4. Process Samples in Real-Time
std::vector<float> input = /* ... */;
std::vector<float> output = dsp::SignalProcessor::process(coeffs, input);

// 5. Generate Standalone C Code
std::string cCode = dsp::CodeExporter::generate(coeffs, spec, dsp::ExportFormat::C);
```

---

## 🤝 Contributors & Community

Filter Designer is an open-source project hosted on GitHub. Community contributions, bug reports, and filter algorithm proposals are welcome!

- **Main Repository:** [https://github.com/shadcy/overtune3](https://github.com/shadcy/overtune3)
- **Issue Tracker & Feature Requests:** [https://github.com/shadcy/overtune3/issues](https://github.com/shadcy/overtune3/issues)

### How to Contribute
1. **Report Bugs & Suggest Features:** Submit an issue on the [Issue Tracker](https://github.com/shadcy/overtune3/issues) describing the behavior, sample rate, filter specifications, and environment.
2. **Implement DSP Algorithms:** Extend `dsp/src/` with new prototype synthesis routines (e.g. Papoulis Optimum L, Legendre, Gaussian, or FIR Parks-McClellan).
3. **Enhance User Experience:** Contribute QML improvements, interactive tutorials, or responsive layout polish in `app/qml/`.
4. **Submit Pull Requests:**
   - Fork the repository: [https://github.com/shadcy/overtune3](https://github.com/shadcy/overtune3)
   - Create your feature branch (`git checkout -b feature/my-dsp-filter`)
   - Commit your changes (`git commit -m "feat: add Gaussian filter prototype"`)
   - Push to your branch (`git push origin feature/my-dsp-filter`)
   - Open a Pull Request on GitHub

### Project Maintainers
- **shadcy** — Project creator & lead maintainer ([GitHub @shadcy](https://github.com/shadcy))
- All open-source contributors who have submitted issues, benchmarks, and pull requests!

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) — free for personal, academic, and commercial use.
