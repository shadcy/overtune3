@echo off
rem package_windows.bat — Package Overtune 3 for Windows distribution
setlocal

set SCRIPT_DIR=%~dp0
set ROOT_DIR=%SCRIPT_DIR%..
set DIST_DIR=%ROOT_DIR%\dist
set PKG_NAME=overtune3-windows-x64
set STAGE_DIR=%DIST_DIR%\%PKG_NAME%

echo Packaging Overtune 3 for Windows x64...
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"
if exist "%STAGE_DIR%" rmdir /s /q "%STAGE_DIR%"
mkdir "%STAGE_DIR%"
mkdir "%STAGE_DIR%\bin"

if exist "%ROOT_DIR%\build\bin\ot3.exe" (
    copy /y "%ROOT_DIR%\build\bin\ot3.exe" "%STAGE_DIR%\bin\"
) else (
    copy /y "%ROOT_DIR%\build\bin\FilterDesigner.exe" "%STAGE_DIR%\bin\ot3.exe"
)
copy /y "%ROOT_DIR%\assets\logo.png" "%STAGE_DIR%\"
copy /y "%SCRIPT_DIR%install_windows.ps1" "%STAGE_DIR%\"
copy /y "%ROOT_DIR%\README.md" "%STAGE_DIR%\"

powershell -Command "Compress-Archive -Path '%STAGE_DIR%' -DestinationPath '%DIST_DIR%\%PKG_NAME%.zip' -Force"
echo Package created at %DIST_DIR%\%PKG_NAME%.zip
