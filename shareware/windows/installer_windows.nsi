; installer_windows.nsi — Modern NSIS Setup Script for Overtune 3 DSP Filter Designer
!include "MUI2.nsh"
!include "FileFunc.nsh"

; General Definitions
Name "Overtune 3"
OutFile "..\dist\Overtune3-Setup-x64.exe"
Unicode True
RequestExecutionLevel user
InstallDir "$LOCALAPPDATA\Programs\Overtune3"
InstallDirRegKey HKCU "Software\Overtune3" "InstallDir"

; Interface Settings
!define MUI_ABORTWARNING
!define MUI_ICON "..\assets\logo.ico"
!define MUI_UNICON "..\assets\logo.ico"

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

Section "Overtune 3 Core (Required)" SecCore
    SetOutPath "$INSTDIR"

    ; Core application files
    File /r "..\build\bin\*.*"
    File "..\assets\logo.png"

    ; Store installation folder in registry
    WriteRegStr HKCU "Software\Overtune3" "InstallDir" $INSTDIR

    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Registry keys for Add/Remove Programs
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Overtune3" "DisplayName" "Overtune 3 Studio"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Overtune3" "DisplayVersion" "3.0.0"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Overtune3" "Publisher" "Overtune DSP"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Overtune3" "DisplayIcon" "$INSTDIR\ot3.exe,0"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Overtune3" "UninstallString" "$INSTDIR\Uninstall.exe"

    ; Create Shortcuts
    CreateDirectory "$SMPROGRAMS\Overtune 3"
    CreateShortcut "$SMPROGRAMS\Overtune 3\Overtune 3.lnk" "$INSTDIR\ot3.exe" "" "$INSTDIR\ot3.exe" 0
    CreateShortcut "$SMPROGRAMS\Overtune 3\Uninstall Overtune 3.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
    CreateShortcut "$DESKTOP\Overtune 3.lnk" "$INSTDIR\ot3.exe" "" "$INSTDIR\ot3.exe" 0

    ; In-place updater helper script
    FileOpen $0 "$INSTDIR\overtune_update.bat" w
    FileWrite $0 "@echo off$\r$\n"
    FileWrite $0 "timeout /t 1 /nobreak >nul$\r$\n"
    FileWrite $0 "if exist $\"%~dp0ot3.exe.new$\" ($\r$\n"
    FileWrite $0 "    copy /y $\"%~dp0ot3.exe.new$\" $\"%~dp0ot3.exe$\"$\r$\n"
    FileWrite $0 "    del $\"%~dp0ot3.exe.new$\"$\r$\n"
    FileWrite $0 ")$\r$\n"
    FileWrite $0 "start $\"$\" $\"%~dp0ot3.exe$\"$\r$\n"
    FileWrite $0 "exit$\r$\n"
    FileClose $0
SectionEnd

Section "Uninstall"
    Delete "$DESKTOP\Overtune 3.lnk"
    Delete "$SMPROGRAMS\Overtune 3\Overtune 3.lnk"
    Delete "$SMPROGRAMS\Overtune 3\Uninstall Overtune 3.lnk"
    RMDir "$SMPROGRAMS\Overtune 3"

    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\Overtune3"
    DeleteRegKey HKCU "Software\Overtune3"

    RMDir /r "$INSTDIR"
SectionEnd
