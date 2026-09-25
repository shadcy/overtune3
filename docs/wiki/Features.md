# Features

Overtune3 is a digital filter design tool with analysis and export capabilities. The application is built to support both practical engineering work and visual experimentation.

## Filter types

The application supports these primary filter topologies:

- Low Pass
- High Pass
- Band Pass
- Band Stop

## Filter responses

Overtune3 supports common digital filter response families:

- Butterworth
- Chebyshev Type I
- Chebyshev Type II
- Elliptic (Cauer)
- Bessel

## Analysis views

The project includes several analysis modes:

### Frequency response
- Magnitude response in dB
- Phase response in degrees
- Group delay
- Log frequency scaling
- -3 dB reference line

### Time-domain response
- Impulse response
- Step response

### Pole-zero view
- z-plane representation
- visualization of filter behavior in the complex plane

## Simulation features

Users can validate filter designs with practical signals:

- Load WAV files
- Load CSV files
- Generate sine waves
- Generate chirps
- Compare input and output signals visually

This allows the filtering behavior to be checked against real-world or generated signals.

## Export options

The system supports generating implementation-ready output in multiple formats:

| Format | Purpose |
|--------|---------|
| C | Embedded and DSP implementation |
| C++ Header | C++ integration with SOS structures |
| Python | Research and prototyping workflows |
| JSON | Machine-readable filter data |

## User interface

The interface is designed to be simple and modern:

- Apple-inspired visual style
- dark mode and light mode options
- clean multi-page navigation
- real-time interaction while editing filter parameters

## Extensibility

Overtune3 is organized to allow additional filter types and export modes in future versions. The DSP engine is separated from the application layer, which makes future additions easier to manage without rewriting the entire interface.

## Typical usage

A typical user workflow is:

1. Choose a filter topology and response
2. Adjust filter parameters
3. Inspect magnitude, phase, and time responses
4. Test using simulation
5. Export the final filter to code or metadata

## Related pages

- [Architecture](Architecture)
- [Installation](Installation)
- [FAQ](FAQ)
