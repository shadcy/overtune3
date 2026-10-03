# Overtune 3 (`ot3`) — Shareware Distribution Package
**Release 3.3.5 (x64) | C++20 & Qt 6 DSP Workstation**

Welcome to the **Overtune 3** standalone distribution and shareware package. This directory provides self-contained, ready-to-run, and native-install distributions for **Windows** and **Linux**, complete with compiled high-resolution LaTeX manuals, DSP theoretical guides, and automation scripts.

---

## Package Contents

```
shareware/
├── Installation_Guide.pdf               <-- Full compiled Release 3.3.5 LaTeX manual
├── docs/                                <-- Full suite of DSP documentation & guides
│   ├── Installation_Guide.pdf           <-- System installation & deployment manual
│   ├── Overtune3_Installation_Guide.pdf <-- Release mirror
│   ├── installation_guide.tex           <-- LaTeX source
│   ├── theory_and_math.pdf              <-- Filter synthesis & bilinear mapping theory
│   ├── tutorials_and_guides.pdf         <-- Step-by-step DSP implementation guide
│   └── contributors_and_wiki.pdf        <-- Architectural & developer references
├── linux/
│   ├── overtune3-linux-x86_64.tar.gz    <-- Compressed standalone Linux package
│   └── overtune3-linux-x86_64/          <-- Unpacked portable directory
│       ├── bin/ot3                      <-- Compiled executable
│       ├── ot3.sh                       <-- Portable one-click launcher
│       ├── install_linux.sh             <-- Native desktop installer
│       ├── Installation_Guide.pdf
│       └── README.md
├── windows/
│   ├── overtune3-windows-x64.zip        <-- Complete self-contained Windows archive
│   ├── overtune3-windows-x64/           <-- Unpacked portable distribution
│   │   ├── bin/                         <-- Binaries & deployed Qt 6.7 runtime
│   │   │   ├── ot3.exe                  <-- Primary executable (v3.3.5)
│   │   │   ├── FilterDesigner.exe       <-- Filter Designer alias
│   │   │   ├── ot3-installer.exe        <-- Standalone native setup wizard
│   │   │   ├── Qt6*.dll                 <-- Core, Gui, Qml, Quick, Multimedia, Network
│   │   │   └── platforms/               <-- qwindows.dll
│   │   ├── ot3.bat                      <-- Portable launcher
│   │   ├── run.bat                      <-- Portable launcher alias
│   │   ├── ot3-installer.exe            <-- One-click setup launcher
│   │   ├── install_windows.ps1          <-- Native PowerShell installer
│   │   ├── Installation_Guide.pdf       <-- Bundled installation manual
│   │   ├── docs/                        <-- Bundled documentation & AI integration guide
│   │   │   ├── Installation_Guide.pdf
│   │   │   ├── theory_and_math.pdf
│   │   │   ├── tutorials_and_guides.pdf
│   │   │   ├── contributors_and_wiki.pdf
│   │   │   └── ai-integration.md
│   │   ├── CHANGELOG.md
│   │   └── README_WINDOWS.txt
│   ├── install_windows.ps1              <-- Standalone automated PowerShell setup
│   ├── installer_windows.nsi            <-- NSIS installer script definition
│   ├── package_windows.bat              <-- Windows distribution packaging utility
│   ├── CHANGELOG.md                     <-- Complete version release notes
│   ├── README_WINDOWS.txt               <-- Windows quick reference notes
│   └── assets/                          <-- Branding icons and high-DPI graphics
└── SHA256SUMS.txt                       <-- Cryptographic verification checksums
```

---

## Quick Start: Windows

### Method 1: One-Click Graphical Setup (`ot3-installer.exe`)
From `windows\overtune3-windows-x64`:
- Double-click **`ot3-installer.exe`**.
- Choose your preferred installation directory (defaults to `%LOCALAPPDATA%\Programs\Overtune3`, zero administrator privileges required).
- Automatically registers shortcuts in Start Menu, Desktop, and Windows **Installed Apps**.

### Method 2: Portable Execution (Zero Install)
Extract `windows\overtune3-windows-x64.zip` (or open `windows\overtune3-windows-x64`):
```cmd
ot3.bat
```
*(Or double-click `ot3.bat`, `run.bat`, or `bin\ot3.exe`).*

### Method 3: Automated PowerShell Setup (Unattended / CI)
Run PowerShell as standard user or administrator:
```powershell
powershell -ExecutionPolicy Bypass -File .\windows\install_windows.ps1
```
Supported switches:
- `-InstallDir "C:\CustomPath"`: Custom installation directory.
- `-NoDesktop`: Omit Desktop shortcut creation.
- `-NoStartMenu`: Omit Start Menu shortcut creation.

### Method 4: Build from Source (`build.bat`)
From the repository root:
```cmd
build.bat
run.bat
```

---

## Quick Start: Linux

### Method 1: Portable Execution (Zero Install)
```bash
cd linux/overtune3-linux-x86_64
./ot3.sh
```

### Method 2: System Installation (Desktop Menu & PATH)
```bash
# User-level (Installs to ~/.local/share/overtune3 and links ~/.local/bin/ot3)
./linux/overtune3-linux-x86_64/install_linux.sh

# Or system-wide:
sudo ./linux/overtune3-linux-x86_64/install_linux.sh
```

---

## In-App Features & Updates

- **In-App Auto-Updater**: Select **Settings $\to$ Updates $\to$ Check for Updates** or click the titlebar badge. On Windows, updates swap atomically without executable locking via `overtune_update.bat`.
- **AI DSP Assistant (Shadcy)**: Built-in OpenRouter LLM copilot for filter mathematics, C++ / MATLAB coefficient synthesis, and live chat assistance. API keys are encrypted at rest with Windows DPAPI.
- **Clean Uninstallation**: Seamlessly remove Overtune 3 via **Settings $\to$ Resources & Maintenance $\to$ Uninstall Overtune 3**, Windows Settings (*Apps $\to$ Installed apps*), or `%LOCALAPPDATA%\Programs\Overtune3\uninstall.bat`.

---

## Documentation

Open [Installation_Guide.pdf](Installation_Guide.pdf) in the package root or open the in-app documentation browser via the **Docs** tab (`Ctrl + 5`). Full mathematical notes and tutorials are also included in `docs/`.
