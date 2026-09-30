# install_windows.ps1 — Native Windows Installer for Overtune 3 DSP Filter Designer
# Usage:
#   powershell -ExecutionPolicy Bypass -File install_windows.ps1 [-InstallDir <path>] [-NoDesktop] [-NoStartMenu]

param (
    [string]$InstallDir = "$env:LOCALAPPDATA\Programs\Overtune3",
    [switch]$NoDesktop = $false,
    [switch]$NoStartMenu = $false
)

$ErrorActionPreference = "Stop"

$AppName = "Overtune 3"
$AppId = "Overtune3"
$ExeName = "ot3.exe"
$Version = "3.0.0"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "         Overtune 3 — Windows Native Installer            " -ForegroundColor White
Write-Host "         Version: $Version (x64)                          " -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

# Locate binary
$SourceBin = ""
if (Test-Path "$RootDir\build\bin\$ExeName") {
    $SourceBin = "$RootDir\build\bin\$ExeName"
} elseif (Test-Path "$RootDir\build\bin\FilterDesigner.exe") {
    $SourceBin = "$RootDir\build\bin\FilterDesigner.exe"
} elseif (Test-Path "$ScriptDir\$ExeName") {
    $SourceBin = "$ScriptDir\$ExeName"
} elseif (Test-Path "$ScriptDir\bin\$ExeName") {
    $SourceBin = "$ScriptDir\bin\$ExeName"
} elseif (Test-Path "$ScriptDir\FilterDesigner.exe") {
    $SourceBin = "$ScriptDir\FilterDesigner.exe"
} else {
    Write-Warning "Could not find $ExeName in standard build paths."
    Write-Host "Please build the project first with cmake/visual studio or place $ExeName alongside this script."
}

Write-Host "Target Installation Directory: $InstallDir" -ForegroundColor Yellow

if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

$DestExe = Join-Path $InstallDir $ExeName

# Copy binary if available
if ($SourceBin -and (Test-Path $SourceBin)) {
    Write-Host "  -> Copying application executable..." -ForegroundColor Green
    Copy-Item -Path $SourceBin -Destination $DestExe -Force
}

# Copy icons & resources
$IconSrc = "$RootDir\assets\logo.png"
$DestIcon = Join-Path $InstallDir "logo.png"
if (Test-Path $IconSrc) {
    Copy-Item -Path $IconSrc -Destination $DestIcon -Force
}

# Self-updater batch file for Windows in-place atomic updates
$UpdaterBat = Join-Path $InstallDir "overtune_update.bat"
@"
@echo off
echo Updating Overtune 3...
timeout /t 1 /nobreak >nul
if exist "%~dp0ot3.exe.new" (
    copy /y "%~dp0ot3.exe.new" "%~dp0ot3.exe" >nul
    del "%~dp0ot3.exe.new" >nul
)
start "" "%~dp0ot3.exe"
exit
"@ | Out-File -FilePath $UpdaterBat -Encoding ASCII -Force

# Create Shortcuts via WScript.Shell
$WshShell = New-Object -ComObject WScript.Shell

if (!$NoDesktop) {
    Write-Host "  -> Creating Desktop shortcut..." -ForegroundColor Green
    $DesktopPath = [System.Environment]::GetFolderPath('Desktop')
    $DesktopShortcut = Join-Path $DesktopPath "Overtune 3.lnk"
    $Shortcut = $WshShell.CreateShortcut($DesktopShortcut)
    $Shortcut.TargetPath = $DestExe
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "Overtune 3 — DSP Filter Designer & Live Audio Lab"
    $Shortcut.Save()
}

if (!$NoStartMenu) {
    Write-Host "  -> Creating Start Menu shortcut..." -ForegroundColor Green
    $ProgramsPath = [System.Environment]::GetFolderPath('Programs')
    $MenuFolder = Join-Path $ProgramsPath "Overtune 3"
    if (!(Test-Path $MenuFolder)) {
        New-Item -ItemType Directory -Path $MenuFolder -Force | Out-Null
    }
    $StartShortcut = Join-Path $MenuFolder "Overtune 3.lnk"
    $Shortcut = $WshShell.CreateShortcut($StartShortcut)
    $Shortcut.TargetPath = $DestExe
    $Shortcut.WorkingDirectory = $InstallDir
    $Shortcut.Description = "Overtune 3 — DSP Filter Designer & Live Audio Lab"
    $Shortcut.Save()
}

# Register in Windows Add/Remove Programs (Registry HKCU)
Write-Host "  -> Registering in Windows Add/Remove Programs..." -ForegroundColor Green
$UninstallKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$AppId"
if (!(Test-Path $UninstallKey)) {
    New-Item -Path $UninstallKey -Force | Out-Null
}

Set-ItemProperty -Path $UninstallKey -Name "DisplayName" -Value "Overtune 3 Studio"
Set-ItemProperty -Path $UninstallKey -Name "DisplayVersion" -Value $Version
Set-ItemProperty -Path $UninstallKey -Name "Publisher" -Value "Overtune DSP"
Set-ItemProperty -Path $UninstallKey -Name "InstallLocation" -Value $InstallDir
Set-ItemProperty -Path $UninstallKey -Name "DisplayIcon" -Value "$DestExe,0"
Set-ItemProperty -Path $UninstallKey -Name "UninstallString" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$InstallDir\uninstall.ps1`""

# Create uninstaller script
$UninstallScript = Join-Path $InstallDir "uninstall.ps1"
@"
`$ErrorActionPreference = 'SilentlyContinue'
Write-Host 'Uninstalling Overtune 3...' -ForegroundColor Yellow
`$DesktopPath = [System.Environment]::GetFolderPath('Desktop')
Remove-Item -Path (Join-Path `$DesktopPath 'Overtune 3.lnk') -Force -ErrorAction SilentlyContinue
`$ProgramsPath = [System.Environment]::GetFolderPath('Programs')
Remove-Item -Path (Join-Path `$ProgramsPath 'Overtune 3') -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Overtune3' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path '$InstallDir' -Recurse -Force -ErrorAction SilentlyContinue
Write-Host 'Overtune 3 has been uninstalled successfully.' -ForegroundColor Green
"@ | Out-File -FilePath $UninstallScript -Encoding UTF8 -Force

Write-Host ""
Write-Host "[OK] Installation completed successfully!" -ForegroundColor Green
Write-Host "Installed in: $InstallDir"
Write-Host "You can now run Overtune 3 from the Start Menu or Desktop."
