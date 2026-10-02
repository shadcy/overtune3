@echo off
rem package_windows.bat — Package Overtune 3 for Windows distribution
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%.."
set "ROOT_DIR=%CD%"
popd

set "DIST_DIR=%ROOT_DIR%\dist"
set "PKG_NAME=overtune3-windows-x64"
set "STAGE_DIR=%ROOT_DIR%\shareware\windows\%PKG_NAME%"

echo ========================================================
echo   Packaging Overtune 3 for Windows x64 (Shareware)
echo ========================================================
echo Root directory: %ROOT_DIR%

set "BIN_SRC="
if exist "%ROOT_DIR%\build\bin\Release\ot3.exe" (
    set "BIN_SRC=%ROOT_DIR%\build\bin\Release"
) else if exist "%ROOT_DIR%\build\bin\ot3.exe" (
    set "BIN_SRC=%ROOT_DIR%\build\bin"
)

if "%BIN_SRC%"=="" (
    echo [ERROR] Could not find built binary ot3.exe.
    echo Please build the project first using build.bat.
    exit /b 1
)

echo Source binary path: %BIN_SRC%

if exist "%STAGE_DIR%" rmdir /s /q "%STAGE_DIR%"
mkdir "%STAGE_DIR%"
mkdir "%STAGE_DIR%\bin"
mkdir "%STAGE_DIR%\assets"

echo [1/4] Copying binary and deployed Qt runtime...
xcopy /s /e /y /q "%BIN_SRC%\*" "%STAGE_DIR%\bin\" >nul

if not exist "%STAGE_DIR%\bin\FilterDesigner.exe" (
    copy /y "%STAGE_DIR%\bin\ot3.exe" "%STAGE_DIR%\bin\FilterDesigner.exe" >nul
)
if exist "%STAGE_DIR%\bin\ot3-installer.exe" (
    copy /y "%STAGE_DIR%\bin\ot3-installer.exe" "%STAGE_DIR%\ot3-installer.exe" >nul
)

echo [2/4] Adding documentation and assets...
if exist "%ROOT_DIR%\assets\logo.png" (
    copy /y "%ROOT_DIR%\assets\logo.png" "%STAGE_DIR%\assets\" >nul
    copy /y "%ROOT_DIR%\assets\logo.png" "%STAGE_DIR%\" >nul
)
if exist "%ROOT_DIR%\assets\logo.ico" (
    copy /y "%ROOT_DIR%\assets\logo.ico" "%STAGE_DIR%\assets\" >nul
    copy /y "%ROOT_DIR%\assets\logo.ico" "%STAGE_DIR%\" >nul
)
if exist "%ROOT_DIR%\shareware\windows\README_WINDOWS.txt" (
    copy /y "%ROOT_DIR%\shareware\windows\README_WINDOWS.txt" "%STAGE_DIR%\" >nul
)
if exist "%ROOT_DIR%\README.md" (
    copy /y "%ROOT_DIR%\README.md" "%STAGE_DIR%\" >nul
)

echo [3/4] Adding Windows launcher and installer scripts...
copy /y "%SCRIPT_DIR%install_windows.ps1" "%STAGE_DIR%\" >nul

(
    echo @echo off
    echo pushd "%%~dp0bin"
    echo start "" "ot3.exe" %%*
    echo popd
) > "%STAGE_DIR%\ot3.bat"

(
    echo @echo off
    echo pushd "%%~dp0bin"
    echo start "" "ot3.exe" %%*
    echo popd
) > "%STAGE_DIR%\run.bat"

echo [4/4] Creating zip archives...
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

powershell -NoProfile -Command "Compress-Archive -Path '%STAGE_DIR%' -DestinationPath '%ROOT_DIR%\shareware\windows\%PKG_NAME%.zip' -Force"
copy /y "%ROOT_DIR%\shareware\windows\%PKG_NAME%.zip" "%DIST_DIR%\%PKG_NAME%.zip" >nul

echo.
echo [OK] Windows shareware package created successfully:
echo   - Folder:  %STAGE_DIR%
echo   - Archive: %ROOT_DIR%\shareware\windows\%PKG_NAME%.zip
echo   - Dist:    %DIST_DIR%\%PKG_NAME%.zip
echo.
endlocal
