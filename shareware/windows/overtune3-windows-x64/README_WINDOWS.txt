========================================================================
  Overtune 3 (ot3) — Windows Installation & Deployment Instructions
  Release 3.2.0 (x64) | Pure C++20 & Qt 6 Real-Time DSP Studio
========================================================================

1. SYSTEM REQUIREMENTS
----------------------
- Operating System: Windows 10 (64-bit, 1809+) or Windows 11 (x64)
- Runtime: Microsoft Visual C++ 2015-2022 Redistributable (x64)
- Display: 1280x800 minimum recommended resolution (HiDPI supported)
- Audio: Any standard DirectSound / WASAPI audio output device

2. PORTABLE EXECUTION (Zero Install)
------------------------------------
You can run Overtune 3 directly without installing or modifying system settings:
  a. Double-click "ot3.bat" or "run.bat" in the package folder.
  b. Or navigate to "bin\" and run:
         .\bin\ot3.exe
         (or .\bin\FilterDesigner.exe)

3. AUTOMATED NATIVE INSTALLATION (Recommended)
----------------------------------------------
To integrate Overtune 3 into your Windows system (Start Menu, Desktop, Apps list):
  a. Open PowerShell in this folder.
  b. Run:
         powershell -ExecutionPolicy Bypass -File .\install_windows.ps1

  Optional Parameters:
  - Custom directory: -InstallDir "C:\Tools\Overtune3"
  - Skip Desktop icon: -NoDesktop
  - Skip Start Menu:   -NoStartMenu

  What the installer does:
  - Deploys application binaries and complete Qt 6 runtime to:
        %LOCALAPPDATA%\Programs\Overtune3
  - Creates Desktop shortcut: "Overtune 3.lnk"
  - Creates Start Menu shortcut: "Programs\Overtune 3\Overtune 3.lnk"
  - Registers "Overtune 3 Studio" in Windows Settings / Installed Apps
  - Configures uninstaller scripts and atomic in-place updater

4. IN-APP UPDATES & CLI MODES
-----------------------------
- In-App: Click "Help" -> "Check for Updates..." or click the titlebar badge.
- CLI Installer Mode:  ot3.exe --install (launches built-in installer GUI)
- CLI Updater Mode:    ot3.exe --update  (checks remote patches)

5. UNINSTALLATION
-----------------
To remove Overtune 3 cleanly:
  a. Go to Windows Settings -> Apps -> Installed Apps -> "Overtune 3 Studio" -> Uninstall.
  b. Or run the uninstaller script directly:
         powershell -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\Programs\Overtune3\uninstall.ps1"
  c. Or run:
         "%LOCALAPPDATA%\Programs\Overtune3\uninstall.bat"

6. REBUILDING FROM SOURCE
-------------------------
From the repository root:
  - Full configure, build, & deploy:  build.bat
  - Quick launch:                     run.bat
  - Package distribution ZIP:         shareware\windows\package_windows.bat
========================================================================
