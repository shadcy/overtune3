# Overtune 3 (`ot3`) — Shareware Distribution Package

Welcome to the **Overtune 3** standalone distribution and shareware package. This folder contains ready-to-run and ready-to-install distributions for both **Linux** and **Windows**, complete with full documentation and installation guides.

---

## Package Contents

```
shareware/
├── Installation_Guide.pdf               <-- Full compiled LaTeX guide
├── linux/
│   ├── overtune3-linux-x86_64.tar.gz    <-- Compressed standalone Linux package
│   └── overtune3-linux-x86_64/          <-- Unpacked portable directory
│       ├── bin/ot3                      <-- Compiled executable
│       ├── ot3.sh                       <-- Portable one-click launcher
│       ├── install_linux.sh             <-- Native desktop installer
│       └── README.md
├── windows/
│   ├── overtune3-windows-x64.zip        <-- Compressed standalone Windows package
│   ├── overtune3-windows-x64/           <-- Unpacked portable directory
│   │   ├── bin/                         <-- Binaries & bundled Qt 6 runtime
│   │   │   ├── ot3.exe
│   │   │   ├── FilterDesigner.exe
│   │   │   ├── Qt6*.dll
│   │   │   └── platforms/
│   │   ├── ot3.bat                      <-- Portable one-click launcher
│   │   ├── run.bat                      <-- Portable launcher alias
│   │   ├── install_windows.ps1          <-- Native Windows installer
│   │   └── README_WINDOWS.txt
│   ├── install_windows.ps1              <-- Native PowerShell installer
│   ├── installer_windows.nsi            <-- NSIS setup compiler script
│   ├── package_windows.bat              <-- Windows packaging utility
│   ├── assets/logo.png
│   └── README_WINDOWS.txt
├── docs/
│   ├── Overtune3_Installation_Guide.pdf
│   └── installation_guide.tex           <-- LaTeX source
└── SHA256SUMS.txt                       <-- Cryptographic verification checksums
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

## Quick Start: Windows

### Method 1: Portable Execution (Zero Install)
Extract `windows\overtune3-windows-x64.zip` (or open `windows\overtune3-windows-x64`):
```cmd
ot3.bat
```
*(Or double-click `ot3.bat` / `run.bat` in File Explorer).*

### Method 2: Automated PowerShell Setup (Desktop & Start Menu)
Open PowerShell and execute:
```powershell
powershell -ExecutionPolicy Bypass -File .\windows\install_windows.ps1
```
This automatically:
- Copies `ot3.exe`, all Qt 6 runtime DLLs, and QML plugins to `%LOCALAPPDATA%\Programs\Overtune3`
- Creates **Desktop** shortcut (`Overtune 3.lnk`)
- Creates **Start Menu** shortcut (`Programs\Overtune 3\Overtune 3.lnk`)
- Adds **Add/Remove Programs** entry in Windows Settings
- Prepares the background atomic updater (`overtune_update.bat`)

### Method 3: Build from Source (`build.bat`)
From the repository root:
```cmd
build.bat
run.bat
```
Configures CMake, compiles with MSVC 2022 in Release mode, and runs `windeployqt` to bundle all runtime dependencies.

---

## In-App Auto-Updater

Overtune 3 includes a built-in background update manager matching the OLED design:
- Navigate to **Help $\rightarrow$ Check for Updates...** or click the **Installer / Update Ready** titlebar badge.
- **Linux:** In-place atomic patch swapping via POSIX `unlink`/`rename`.
- **Windows:** Detached runner (`overtune_update.bat`) that avoids file locks and restarts into the updated build.
- **Cryptographic Audit:** Automatically verifies package SHA-256 signatures before updating.

---

## Documentation

Open `Installation_Guide.pdf` or view the in-app DSP theory documents in the **Docs** tab.
