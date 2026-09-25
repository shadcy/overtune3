# FAQ

## What is Overtune3?

Overtune3 is a digital filter design and analysis application. It combines a Qt 6 interface with a pure C++20 DSP engine to let users design filters, inspect their behavior, and export them for implementation.

## What kinds of filters does it support?

The project supports several standard filter responses and topologies, including:

- Low Pass
- High Pass
- Band Pass
- Band Stop
- Butterworth
- Chebyshev Type I
- Chebyshev Type II
- Elliptic
- Bessel

## Does it require Qt at runtime?

The application UI is built with Qt, but the DSP core is intentionally written to avoid a hard dependency on Qt so the core logic remains portable and reusable.

## Can I use it for audio processing?

Yes. The application supports WAV import and signal processing workflows for evaluating filter behavior on audio-style data.

## Can I export the results?

Yes. The export system supports C, C++, Python, and JSON outputs.

## Why is the architecture split between UI and DSP engine?

This separation keeps the interface easier to maintain and lets the DSP logic be reused independently. It also makes the project more extensible for future features and integrations.

## Is it intended for embedded use?

The DSP engine is designed to be modular and reusable, which makes it suitable for embedded or custom implementation workflows, especially when paired with code export.

## How do I build it?

Follow the instructions in the [Installation](Installation) page.

## Where do I start?

Start with:

1. [Installation](Installation)
2. [Architecture](Architecture)
3. [Features](Features)

## How do I report issues?

Use the project issue tracker in GitHub and include the operating system, Qt version, steps to reproduce, and observed behavior.

## Related pages

- [Installation](Installation)
- [Architecture](Architecture)
- [Features](Features)
