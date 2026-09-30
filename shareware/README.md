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

### Method 1: Automated PowerShell Setup
Open PowerShell and run:
```powershell
powershell -ExecutionPolicy Bypass -File .\windows\install_windows.ps1
```
This automatically:
- Installs `ot3.exe` to `%LOCALAPPDATA%\Programs\Overtune3`
- Creates **Desktop** and **Start Menu** shortcuts
- Adds **Add/Remove Programs** entry in Windows Settings
- Prepares the background atomic updater script

### Method 2: Portable Direct Launch
If you have `ot3.exe`, place it in `bin\` and launch directly:
```cmd
bin\ot3.exe
```

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
