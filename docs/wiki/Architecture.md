# Architecture

Overtune3 is built as a layered system with a clean separation between the graphical interface and the signal-processing engine.

## High-level structure

```text
Overtune3
├── Qt 6 / QML application
│   ├── Design controls
│   ├── Plotting and visualization
│   ├── Simulation tools
│   ├── Export workflows
│   └── Settings and preferences
│
├── DSP engine
│   ├── Filter specification
│   ├── Coefficient generation
│   ├── Frequency analysis
│   ├── Signal processing
│   └── Code export
│
└── Data flow between UI and engine
```

## The UI layer

The Qt 6 and QML interface is responsible for:

- presenting filter parameters
- rendering interaction plots
- managing pages for design, analysis, simulation, and export
- loading audio or CSV data
- displaying analysis results
- exporting design output

This layer is focused on interaction, presentation, and workflow management.

## The DSP layer

The DSP layer is the mathematical core of the application. It handles:

- filter specification creation
- coefficient synthesis
- transfer-function analysis
- response evaluation
- signal filtering
- export generation

This layer is designed to be independent from the UI so it can be reused outside the application environment, such as in custom tools, embedded systems, or future bindings.

## Filter design pipeline

The normal design process follows this sequence:

1. The user chooses a filter type and response
2. Parameters such as order, cutoff, sampling rate, and ripple are set
3. The DSP engine creates a filter specification
4. Filter coefficients are calculated
5. Analysis is performed on the resulting network
6. Simulation applies the filter to generated or imported signals
7. Export generates implementation-ready code

## Analysis engine

The analysis layer computes:

- magnitude response
- phase response
- group delay
- pole-zero locations
- impulse response
- step response

These values are then visualized so the user can evaluate stability, behavior, and passband or stopband characteristics.

## Simulation engine

Simulation verifies filter performance with real or synthetic inputs:

- WAV import for audio signals
- CSV import for custom data
- internally generated sine waves and chirps
- comparison between input and filtered output

This makes it easier to validate a filter against realistic use cases before exporting it.

## Export engine

The export engine turns the designed filter into reusable code or data. Supported formats include:

- C
- C++ header
- Python
- JSON

This allows the generated filter to move from design validation into real implementation workflows.

## Design principles

Overtune3 is organized around a few core principles:

- clear separation between interface and math
- real-time feedback during design
- practical, readable output for implementation
- extensibility for new filter types and export features

## Why this architecture matters

This structure helps the project remain maintainable and adaptable. The UI can evolve without changing the filter logic, and the DSP engine can be extended or reused independently of the application layer.

## Related pages

- [Installation](Installation)
- [Features](Features)
- [FAQ](FAQ)
