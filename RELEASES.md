# Releases

Official downloads are published on [GitHub Releases](https://github.com/shadcy/overtune3/releases). Each Windows release should include:

- `Overtune3-Setup-x64.exe`: interactive installer with target-folder selection, Start Menu and desktop shortcuts, Windows Installed Apps registration, and launch on completion.
- `overtune3-windows-x64.zip`: portable distribution. Extract the complete archive and run `bin/ot3.exe`.
- `SHA256SUMS.txt`: SHA-256 checksums for the downloadable files.

The packaging script writes working distribution artifacts to `dist/` and copies release-ready files to `dist/release/`.

## Current Version: 3.3.0

Supported platforms: Windows 10 (64-bit, version 1809 or later) and Windows 11, x64.

This release adds linear-phase FIR filter design with an IIR | FIR selector on the Design page, corrects Bessel filter accuracy and several design and export bugs, and makes plots smooth during live edits. See [CHANGELOG.md](CHANGELOG.md) for details.

## Publishing

1. Build the Windows Release configuration and ensure the Qt runtime is deployed beside `ot3.exe`.
2. Install NSIS and ensure `makensis` is available on `PATH`.
3. Run `scripts/package_windows.bat`.
4. Create a GitHub release tagged `v3.3.0` and attach the setup executable and portable archive from `dist/release/`. Include `SHA256SUMS.txt`.

Developed and maintained by [@/shadcy](https://github.com/shadcy).
