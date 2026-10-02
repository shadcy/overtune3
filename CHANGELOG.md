# Changelog

All notable changes to **Overtune 3 (ot3)** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [3.2.1] - 2026-10-02

### Added
- **One-Click Native Executable Installer (`ot3-installer.exe`)**:
  - Running `ot3-installer.exe` (or `ot3.exe --install`) automatically launches the integrated GUI installation wizard.
  - Fully customizable installation parameters: user-selected target directory, optional Desktop shortcut, and optional Start Menu shortcut.
  - Bundled directly inside distribution packages with zero external dependencies (no third-party setup prerequisites).
- **In-App Full System Uninstallation**:
  - Direct uninstallation button embedded in both the **Settings** page (*System Integration & Uninstall*) and the **Installer & Updater** modal.
  - Performs surgical cleanup: removes Windows Desktop `.lnk` shortcuts, Start Menu folder and shortcut, removes `HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Overtune3` registry registration, and safely triggers a self-deleting deferred cleanup script (`ot3_cleaner.bat`) followed by graceful application shutdown.
- **Symmetric Squircle Application Icon Suite**:
  - Master $1024 \times 1024$ continuous-curvature squircle icon with 4-fold rotational symmetry and centered DSP constellation core.
  - Multi-resolution Windows icon (`.ico`) containing all 7 standard mipmap sizes: 16x16, 24x24, 32x32, 48x48, 64x64, 128x128, and 256x256 RGBA.
  - Synchronized across application resources (`app/icons/logo.png`, `app/icons/logo.ico`, `assets/logo.png`, `assets/logo.ico`, and `resources.qrc`).

### Fixed
- **Sidebar & Configuration Panel Overflow UI**:
  - Eliminated the stark white unstyled Windows default scrollbar track in Qt Quick Controls. Replaced with a sleek 6px translucent OLED dark-themed rounded scrollbar (`radius: 3`, accent highlight on interaction).
  - Raised sidebar panel minimum width to 280px (`Math.min(360, Math.max(280, width * 0.28))`) with 14px lateral margin padding (`width: configFlick.width - 28`), preventing control elements and sliders from clipping against the scrollbar.
  - Added text elision (`Text.ElideLeft` / `Text.ElideRight`) and max-width boundaries to `FlatRow` items in the **Filter Inspector**, preventing long labels (e.g., "Butterworth", center frequencies, bandwidths) from clipping or breaking row layout.
  - Removed double squircle border wrappers around sidebar logo presentation.
- **Taskbar & Titlebar Icon Display**:
  - Corrected Windows AppUserModelID initialization to `"Overtune.FilterDesigner.3.2.1"` to ensure proper taskbar grouping and crisp icon rendering on Windows 10 and Windows 11.
- **Documentation**:
  - Updated LaTeX `installation_guide.tex` and recompiled `Installation_Guide.pdf` to reflect v3.2.1 deployment options and uninstallation workflows.
  - Updated `README_WINDOWS.txt` with clear step-by-step instructions for `ot3-installer.exe`, portable execution, and uninstallation.

---

## [3.2.0] - 2026-10-01

### Added
- **Stage 2 Verification Suite**:
  - Dedicated compliance verifier modal evaluating mathematical filter integrity, pole-zero stability margins, passband ripple, and stopband attenuation against sub-millidecibel tolerances.
- **What's New Modal Window**:
  - Interactive OLED modal highlighting recent DSP features, SIMD acceleration upgrades, and UI refinements.
- **Windows Shareware & Deployment Infrastructure**:
  - Full portable bundle structure with `ot3.bat`, `run.bat`, and `shareware/windows/install_windows.ps1`.
  - Windows registry registration for system *Installed Apps* list.
  - Compiled LaTeX PDF installation manual.

### Changed
- Refactored build scripts (`build.bat`, `package_windows.bat`) to support automated Qt runtime deployment via `windeployqt`.

---

## [3.1.0] - 2026-09-15

### Added
- Real-time interactive audio sweep generator and live DSP filter listening lab.
- Pole-Zero interactive plot with pole frequency mapping and stability indicators.
- High-precision export formats: C++ header (`BiquadCoefficients.h`), MATLAB / Octave script, Python NumPy/SciPy script, and raw JSON filter graph.

### Changed
- Switched biquad cascade calculation to AVX2/SSE4 SIMD vectorization.

---

## [3.0.0] - 2026-08-01

### Added
- Initial release of Overtune 3 Digital Filter Designer.
- Pure C++20 DSP synthesis engine: Butterworth, Chebyshev I & II, Elliptic, and Bessel approximations.
- QML 6 / Qt Quick OLED Dark interface with hardware-accelerated charting.
