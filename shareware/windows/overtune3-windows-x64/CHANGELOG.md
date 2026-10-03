# Changelog

All notable changes to **Overtune 3 (ot3)** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [3.3.5] - 2026-10-03

### Fixed & Refined
- **Navigation & Layout Architecture**:
  - Moved the main navigation menu bar (`WindowMenuBar`) directly into the main window column (`sidebar.right`), eliminating awkward overlap across the sidebar.
  - Positioned the `Sidebar` activity bar full height from window top to bottom on the left edge with a crisp 1px separation border.
  - Removed duplicate brand icon box from the menu bar to resolve double-logo visual clutter with the Windows native titlebar.
  - Added direct access to DSP Window Function Studio in the View menu and exposed global windowing studio caller.

## [3.3.4] - 2026-10-03

### Fixed & Refined
- **Navigation Bar & Sidebar Alignment**:
  - Added a dedicated 48px brand icon box on the top menu bar aligning vertically with the 48px sidebar activity bar.
  - Aligned top menu items (`File`, `Edit`, `Selection`, `View`...) to start directly above the main page content area.
  - Eliminated redundant 44px duplicate logo and extra spacing in the design page configuration panel for a clean layout.
- **DSP Window Function Studio**:
  - Recompiled all 26 LaTeX formula images with tight mathematical bounding box cropping, eliminating wide margins and clipping.
  - Configured formula view container to scale with proper aspect-fit, left-alignment, and auto-adjusted height.
  - Removed cluttery secondary property pills and description text under the formula card.

## [3.3.3] - 2026-10-03

### Added & Improved
- **Global Custom Tooltips**:
  - Replaced all default OS/Qt controls tooltips with a custom `CustomToolTip` component styled identically to the Sidebar.
  - Implemented sleek dark/light container styling (`#222225` / `#FFFFFF`), 6px border radius, smooth opacity & scale transitions, and custom typography.
  - Added dedicated shortcut badge pills for hotkeys (`Ctrl+0`, `Ctrl+T`, `+`, `−`).
  - Extended custom tooltips across sliders, navigation cluster, plot toolbars, and page headers.
- **DSP Window Function Studio LaTeX Formulas & Dual-Domain Analysis**:
  - Integrated high-resolution LaTeX-compiled mathematical formulas with one-click LaTeX source copy and TeX toggle.
  - Removed redundant close button and cluttery secondary subtitles for a clean, focused UI.
  - Added dual-domain visualization (Time Domain $w[n]$ and Frequency Spectrum $|W(\omega)|$ in dB) with interactive cursor inspection.

## [3.3.2] - 2026-10-03

### Fixed & Improved
- **DSP Window Function Studio**:
  - Fixed coefficient computation and data pipeline to ensure curves and metrics render reliably.
  - Redesigned the Window Function Studio modal with responsive layout filling, custom time-domain plot with smooth gradient shading and grid lines, and 6 dedicated metric cards.
  - Fixed the window dropdown selector to display all 13 standard windows cleanly without blank selections.
- **Navigation Bar & Menus**:
  - Enhanced top menu bar with clean, symmetric horizontal and vertical spacing (36px bar height, 28px centered items).
  - Balanced left menu items and right utility cluster (What's New, Auto-Scale, Theme toggle) with matching heights and radii.
  - Overhauled dropdown menus with 5px padding, 260px width, 28px items, clean checkmark slots, and responsive styling.

## [3.3.0] - 2026-10-03

### Added
- Added a Window Function Studio with rectangular, Bartlett, Hann, Hamming, Blackman, Blackman-Harris, Nuttall, flat-top, Kaiser, Tukey, Gaussian, Bohman, and Lanczos windows.
- Added symmetric and periodic sampling, peak/coherent-gain/energy normalization, and validated Kaiser beta, Tukey alpha, Gaussian sigma, and window length controls.
- Added animated coefficient visualization and coherent gain, RMS, energy, coefficient sum, and equivalent noise bandwidth readouts.
- Improved the responsive menu bar and added adaptive Omi prompt budgeting with automatic context recovery.

### Version
- Promoted the release version from 3.2.8 to 3.3.0 for the new DSP analysis feature.

## [3.2.8] - 2026-10-02

### Added & Improved
- **Chat Assistant Renamed to Omi**:
  - Rebranded the AI DSP assistant from Shadcy to **Omi** across the application header, sidebar, menus, system prompt, and workspace titles.
- **Fixed Chat Artifact Layout & Clutter**:
  - Eliminated text overlapping in `SegmentedButton` by enforcing explicit cell bounds, clipping (`clip: true`), and text eliding (`Text.ElideRight`).
  - Added sleek card framing (`radius: 12`, border, surface background) to `ChatPlot` with responsive tab sizing.
- **Fixed Unwanted Filter Comparisons**:
  - Resolved bug where requesting a specific filter family (e.g., elliptic) automatically injected the current Butterworth filter into the artifact display.
  - Now only single variants are shown unless the user explicitly asks to compare responses or models multiple designs.
- **Cleaned Chat Hardcoded Placeholders**:
  - Removed fictitious model references ("6 Luna High") and hardcoded filter comparisons ("Compare Butterworth vs Chebyshev I").
  - Provided genuine OpenRouter model choices (`google/gemini-2.0-flash-001`, `anthropic/claude-3.5-sonnet`, `openai/gpt-4o`, `deepseek/deepseek-chat`) and generalized DSP exploration shortcuts.

## [3.2.7] - 2026-10-02

### Improved
- **Unified Settings UI**:
  - Restructured the lower half of the Settings page (Updates, AI Assistant, About, Resources & Maintenance) into standardized cards (`radius: 12`, surface color, border, 16px bold section headers) matching the Appearance, Plots, and DSP & Export sections.
  - Replaced unstyled controls and raw buttons with consistent `StyledButton`, themed `TextInput` fields, and clean hairline separators across all cards.
  - Consolidated documentation access and uninstall action into a cohesive Resources & Maintenance card.

## [3.2.6] - 2026-10-02

### Added & Improved
- **Modern Chat Assistant Interface**:
  - Redesigned Chat prompt container with sleek floating card (`radius: 18`), multiline auto-sizing input field (`TextArea`), and bottom control bar matching modern design standards.
  - Added attachment context menu (`+`), mode approval selector (`Approve for me`), model selector dropdown (`6 Luna High`, `Claude 3.5 Sonnet`, `Gemini 2.0 Flash`, `GPT-4o`, `DeepSeek`), microphone button, and interactive blue circular send/stop action button.
  - Implemented request cancellation in C++ `ChatController` via blue stop button.
- **Fixed Shadcy Theme Logos**:
  - Reverted/swapped Shadcy assistant icon mappings so white icon is used on dark backgrounds (`theme.isDark`) and black icon is used on light backgrounds (`!theme.isDark`).

## [3.2.5] - 2026-10-02

### Fixed
- Corrected filter specification normalization and strengthened numerical verification across supported families and topologies.
- Improved frequency, phase, group-delay, pole-zero, and impulse-response analysis around critical poles and zeros.
- Synchronized Windows application and installer version metadata.

## [3.2.4] - 2026-10-02

### Fixed
- Windows setup now installs the executable and deployed Qt runtime in the paths used by shortcuts and the installer launcher.
- Installer and update status now reports file-copy and system-integration failures instead of claiming success.
- Installer, updater, and What's New windows follow the app's selected appearance and use the bundled banner.
- Windows Installed Apps and app version labels use the release version.

### Improved
- Windows setup opens the installed app from its finish page and keeps custom install-directory support.
- Installer/update copy and plot-label spacing have been refined.

## [3.2.3] - 2026-10-02

### Added
- **Native Installation Directory Browser**:
  - Setup wizard and installer allow browsing and selecting custom installation targets via native system folder picker.
- **Solid Black Plot Badges & Zero Number Overlap**:
  - All axis labels (`FrequencyPlot`, `PoleZeroPlot`, `ImpulseStepPlot`, `SignalPlot`) feature solid black (`#000000`) squircle backgrounds with clear margins preventing any overlap with grid tick numbers.
- **Complete Authentic Codicon Mapping**:
  - Integrated full 461-glyph Codicon icon font dictionary, eliminating all missing glyph fallbacks across Settings, Updater, and Navigation.
- **Adaptive Dark / Light Theming**:
  - Standalone modals and installers dynamically adapt backgrounds, surfaces, and borders to the application's dark/light settings.
- **Clean Apple-Grade UI Polish**:
  - Version transition display (`v3.2.2 → v3.2.3`), dynamic button width auto-scaling, and clean minimal copywriting.

---

## [3.2.2] - 2026-10-02

### Added
- **Solid Squircle Plot Axis Badges**:
  - Implemented solid squircle badge containers (`#12151E` in dark mode, `#FFFFFF` in light mode, with `radius: 6`, 1px borders, and balanced padding) behind all primary and secondary axis labels across the DSP workstation:
    - **Frequency Plot**: Rotated Y-axis badge and bottom X-axis badge.
    - **Pole-Zero Plot**: Solid squircle badges for $\text{Re}\{z\}$, $\text{Im}\{z\}$, and the $|z| = 1.0$ unit circle indicator, preventing line intersections and occlusions.
    - **Impulse & Step Response Plot**: Crisp squircle badges for $h[n]/s[n]$ and discrete time sample index $n$.
    - **Live Signal Simulation Plot**: Dedicated squircle badges for signal amplitudes $x[n], y[n]$ and sample index $n$.
- **LaTeX-Compiled Mathematical Typography**:
  - Embedded high-DPI transparent LaTeX formula renderings with solid, medium mathematical typography for $|H(e^{j\omega})|$ (Magnitude in dB and Linear $|H(e^{j\omega})|$), $\angle H(e^{j\omega})$ (Phase), $\tau_g(\omega)$ (Group Delay), $f\text{ [Hz]}$, $\omega\text{ [rad/sample]}$, $\text{Re}\{z\}$, $\text{Im}\{z\}$, $|z| = 1.0$, $h[n]$, $s[n]$, and $x[n], y[n]$.
  - Combined with clean medium typography in unified QML badges for maximum readability and scientific publication elegance.

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
