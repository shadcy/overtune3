========================================================================
  Overtune 3 (ot3) — Windows Installation & Deployment Instructions
========================================================================

1. AUTOMATED INSTALLATION (Recommended)
---------------------------------------
Right-click on PowerShell -> "Run as administrator" (or standard user):
    powershell -ExecutionPolicy Bypass -File .\install_windows.ps1

What this does:
  - Copies ot3.exe and assets into %LOCALAPPDATA%\Programs\Overtune3
  - Creates Desktop shortcut: "Overtune 3.lnk"
  - Creates Start Menu shortcut: "Programs\Overtune 3\Overtune 3.lnk"
  - Adds uninstaller to Windows Settings / Control Panel
  - Configures the background in-place updater (overtune_update.bat)

2. NSIS INSTALLER GENERATION
----------------------------
To generate a standalone graphical setup wizard (Overtune3-Setup-x64.exe):
  - Install NSIS (Nullsoft Scriptable Install System)
  - Run: makensis installer_windows.nsi
  - Outputs to: ..\dist\Overtune3-Setup-x64.exe

3. PORTABLE EXECUTION
---------------------
To run without installing, simply copy ot3.exe and launch:
    .\ot3.exe

4. UNINSTALLATION
-----------------
Open Windows Settings -> Apps -> Installed Apps -> "Overtune 3 Studio" -> Uninstall
Or execute:
    powershell -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\Programs\Overtune3\uninstall.ps1"
========================================================================
