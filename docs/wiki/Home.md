# Overtune3 Wiki

Welcome to the Overtune3 wiki. This project is a digital filter design tool built with Qt 6 and QML, backed by a pure C++20 DSP engine.

Overtune3 helps users design filters, inspect frequency behavior, validate performance with simulation, and export implementation-ready code.

## What Overtune3 does

Overtune3 is designed for engineers, researchers, and developers working with digital signal processing. It supports:

- Filter synthesis for common analog-inspired digital filter families
- Frequency-domain and time-domain analysis
- Signal simulation with generated or imported data
- Export of filter implementations to C, C++, Python, and JSON

## Core workflow

1. Choose a filter type and response
2. Set design parameters such as cutoff, order, sampling rate, and ripple
3. Inspect magnitude, phase, and time responses
4. Test the filter with generated or real data
5. Export the final design for use in code or analysis pipelines

## Quick links

- [Installation guide](Installation)
- [Architecture overview](Architecture)
- [Features and capabilities](Features)
- [Frequently asked questions](FAQ)
- [Release notes](../RELEASES.md)

## Project structure

```text
overtune3/
├── app/                  # Qt/QML application
├── dsp/                  # Core DSP library
├── docs/                 # Documentation and wiki content
├── CMakeLists.txt        # Build configuration
├── build.sh              # Convenience build script
├── README.md             # Project overview
├── RELEASES.md           # Release notes
└── ...
```

## Why this project exists

The goal of Overtune3 is to combine a clean visual workflow with a reusable DSP engine. The interface is designed to be approachable, while the core library remains computationally independent, portable, and suitable for further extension.

## Recommended reading order

- [Installation guide](Installation)
- [Architecture overview](Architecture)
- [Features and capabilities](Features)
- [Frequently asked questions](FAQ)

## Community and maintenance

Overtune3 is intended to remain understandable, modular, and usable as a practical DSP design environment. The project focuses on correctness, maintainability, and a clear separation between UI behavior and mathematical processing.
