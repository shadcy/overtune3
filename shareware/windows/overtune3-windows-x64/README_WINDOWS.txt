========================================================================
  Overtune 3 (ot3) — Windows Installation & Deployment Instructions
  Release 3.3.5 (x64) | C++20 & Qt 6 DSP Studio
========================================================================

1. SYSTEM REQUIREMENTS
----------------------
- Operating System: Windows 10 (64-bit, 1809+) or Windows 11 (x64)
- Runtime: Microsoft Visual C++ 2015-2022 Redistributable (x64)
- Display: 1280x800 minimum recommended resolution (HiDPI supported)
- Audio: Any standard DirectSound / WASAPI audio output device

2. ONE-CLICK GUI INSTALLATION (Recommended)
--------------------------------------------
You can install Overtune 3 with a single click:
  a. Double-click "ot3-installer.exe" in this folder.
  b. The native installation dialog will launch automatically with full custom
     options: customize destination folder, desktop shortcut, and Start menu.
  c. Click "Install Overtune 3" to complete deployment.

3. PORTABLE EXECUTION (Zero Install)
------------------------------------
You can run Overtune 3 directly without installing or modifying system settings:
  a. Double-click "ot3.bat" or "run.bat" in the package folder.
  b. Or navigate to "bin\" and run:
         .\bin\ot3.exe
         (or .\bin\FilterDesigner.exe)

4. AUTOMATED POWERSHELL INSTALLATION
------------------------------------
To integrate Overtune 3 via script or headless CI:
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

5. IN-APP UPDATES & CLI MODES
-----------------------------
- In-App: Click "Help" -> "Check for Updates..." or click the titlebar badge.
- Native Installer:   Double-click "ot3-installer.exe" (or ot3.exe --install)
- Native Updater:     ot3.exe --update

6. UNINSTALLATION
-----------------
To remove Overtune 3 cleanly:
  a. In-App Uninstallation:
     Open Overtune 3 -> Go to Settings (gear icon in sidebar) -> "System Integration & Uninstall"
     -> Click "Uninstall Overtune 3". It will cleanly remove shortcuts, registry entries,
     and self-delete the application directory before exiting.
  b. Windows Settings:
     Go to Windows Settings -> Apps -> Installed Apps -> "Overtune 3 Studio" -> Uninstall.
  c. Or run the uninstaller script directly:
         powershell -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\Programs\Overtune3\uninstall.ps1"
  d. Or run:
         "%LOCALAPPDATA%\Programs\Overtune3\uninstall.bat"

6. REBUILDING FROM SOURCE
-------------------------
From the repository root:
  - Full configure, build, & deploy:  build.bat
  - Quick launch:                     run.bat
  - Package distribution ZIP:         shareware\windows\package_windows.bat
========================================================================
