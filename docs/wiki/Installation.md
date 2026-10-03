# Installation Guide

This guide covers installing, running, and building **Overtune 3 (ot3)** on Windows (x64) and other supported operating systems.

---

## Windows Installation Methods

There are three ways to install and run Overtune 3 on Windows:

### Method 1: Standalone Native Installer (Recommended)

The standalone native installer (`ot3-installer.exe` or `Overtune3-Setup-x64.exe`) provides a modern GUI setup wizard:

1. Download `ot3-installer.exe` (or `Overtune3-Setup-x64.exe`) from the [GitHub Releases](https://github.com/shadcy/overtune3/releases) or the `dist/` folder.
2. Double-click the installer to launch the setup wizard.
3. Choose your desired options:
   - **Installation Directory**: Default is `%LOCALAPPDATA%\Programs\Overtune3` (no admin rights required), or browse to any custom folder.
   - **Shortcuts**: Create Desktop and Start Menu shortcuts.
4. Click **Install Overtune 3**.
5. Once complete, click **Launch Overtune 3**.

> **Note**: The application is registered in Windows **Settings > Apps > Installed apps** for seamless management.

---

### Method 2: Portable Distribution (Zero Installation)

If you prefer a standalone portable version that doesn't modify the registry:

1. Download `overtune3-windows-x64.zip`.
2. Extract the archive to any folder (e.g. `C:\Tools\Overtune3` or your Desktop).
3. Run the application:
   - Double-click `run.bat` or `ot3.bat` in the root folder, **or**
   - Navigate to `bin\` and double-click `ot3.exe`.

All required Qt 6 runtime libraries, QML plugins, audio codecs, and fonts are self-contained.

---

### Method 3: Automated PowerShell Installation

For silent deployments, scripted installations, or CI/CD pipelines:

1. Open PowerShell in the unzipped folder.
2. Run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install_windows.ps1
   ```

**Optional Parameters**:
- Custom target directory:
  ```powershell
  .\install_windows.ps1 -InstallDir "C:\Overtune3"
  ```
- Omit Desktop shortcut:
  ```powershell
  .\install_windows.ps1 -NoDesktop
  ```
- Omit Start Menu shortcut:
  ```powershell
  .\install_windows.ps1 -NoStartMenu
  ```

---

## Building from Source on Windows

### Prerequisites

- **Operating System**: Windows 10 (64-bit, 1809+) or Windows 11 (x64)
- **Compiler**: Visual Studio 2022 (MSVC v143+) or Visual Studio 2022 Build Tools with **C++20** support
- **CMake**: Version 3.24 or newer
- **Qt 6**: Version 6.4 or newer (6.7.2 MSVC 2019/2022 64-bit recommended) with:
  - `Core`, `Gui`, `Qml`, `Quick`, `QuickControls2`, `Multimedia`, `Network`

### Build Instructions

1. **Clone the repository**:
   ```bat
   git clone https://github.com/shadcy/overtune3.git
   cd overtune3
   ```

2. **Quick Build via script**:
   ```bat
   build.bat
   ```
   *This automatically configures CMake, compiles all DSP and GUI modules in Release mode, runs `windeployqt`, and copies required assets.*

3. **Or build with CMake directly**:
   ```bat
   cmake -G "Visual Studio 17 2022" -A x64 -S . -B build\windows-release -DCMAKE_PREFIX_PATH="C:\Qt\6.7.2\msvc2019_64"
   cmake --build build\windows-release --config Release --parallel
   ```

4. **Deploy Qt Runtime**:
   ```bat
   C:\Qt\6.7.2\msvc2019_64\bin\windeployqt.exe build\windows-release\bin\ot3.exe --qmldir app\qml --multimedia
   ```

5. **Run the application**:
   ```bat
   run.bat
   ```
   *Or launch `.\build\windows-release\bin\ot3.exe`.*

6. **Create Distribution Packages**:
   ```bat
   scripts\package_windows.bat
   ```
   *Creates the portable archive `dist/overtune3-windows-x64.zip` and checksum manifest `dist/release/SHA256SUMS.txt`.*

---

## In-App Updates & Maintenance

- **Checking for Updates**: In Overtune 3, open **Settings** (gear icon) > **Updates** and click **Check**.
- **AI DSP Assistant**: Configure your OpenRouter model and key in **Settings > AI Assistant**. Keys on Windows are secured via Windows DPAPI.
- **Uninstallation**:
  - Open **Settings > Resources & Maintenance** and click **Uninstall**, **or**
  - Go to Windows **Settings > Apps > Installed apps > Overtune 3 > Uninstall**, **or**
  - Run `%LOCALAPPDATA%\Programs\Overtune3\uninstall.bat`.

---

## Troubleshooting

### `VCRUNTIME140.dll` or `MSVCP140.dll` missing
Install the official [Microsoft Visual C++ 2015–2022 Redistributable (x64)](https://aka.ms/vs/17/release/vc_redist.x64.exe).

### CMake cannot locate Qt 6
Specify the Qt installation path when configuring:
```bat
cmake -S . -B build -DCMAKE_PREFIX_PATH="C:\Qt\6.7.2\msvc2019_64"
```
*(The build system also includes an automatic fallback for `C:\Qt\6.7.2\msvc2019_64` on Windows).*

### Audio playback device not detected
Ensure WASAPI or DirectSound audio drivers are active in Windows Sound Settings.

---

## Related Documentation

- [Architecture Overview](Architecture)
- [DSP Features & Filter Models](Features)
- [DSP Chat AI Integration](../ai-integration.md)
- [Frequently Asked Questions](FAQ)

