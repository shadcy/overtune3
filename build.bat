@echo off
setlocal
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "BUILD_DIR=%ROOT%\build\windows-release"
set "QT_ROOT=C:\Qt\6.7.2\msvc2019_64"
set "CMAKE=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
set "VS_DEVCMD=%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat"
if not exist "%CMAKE%" (
    where cmake >nul 2>nul
    if not errorlevel 1 set "CMAKE=cmake"
)
if not exist "%CMAKE%" if /i not "%CMAKE%"=="cmake" (
    echo CMake was not found. Install CMake or Visual Studio Build Tools.
    exit /b 1
)

where cl >nul 2>nul
if errorlevel 1 if exist "%VS_DEVCMD%" call "%VS_DEVCMD%" -arch=amd64
where cl >nul 2>nul
if errorlevel 1 (
    echo MSVC was not found. Install Visual Studio Build Tools with the C++ workload.
    exit /b 1
)

echo [1/3] Configure Windows x64 Release...
"%CMAKE%" -S "%ROOT%" -B "%BUILD_DIR%" -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_AUTOGEN_PARALLEL=1
if errorlevel 1 exit /b %errorlevel%

echo [2/3] Build application and tests...
"%CMAKE%" --build "%BUILD_DIR%"
if errorlevel 1 exit /b %errorlevel%

echo [3/3] Deploy Qt runtime...
set "APP_DIR=%BUILD_DIR%\bin"
if not exist "%APP_DIR%\ot3.exe" (
    echo Build did not produce %APP_DIR%\ot3.exe
    exit /b 1
)
if exist "%QT_ROOT%\bin\windeployqt.exe" (
    "%QT_ROOT%\bin\windeployqt.exe" "%APP_DIR%\ot3.exe" --qmldir "%ROOT%\app\qml" --multimedia --compiler-runtime
    if errorlevel 1 exit /b %errorlevel%
) else (
    echo Qt deployment tool was not found at "%QT_ROOT%\bin\windeployqt.exe".
    echo The executable is built, but the portable runtime was not deployed.
    exit /b 1
)

copy /y "%APP_DIR%\ot3.exe" "%APP_DIR%\FilterDesigner.exe" >nul
copy /y "%ROOT%\assets\logo.ico" "%APP_DIR%\logo.ico" >nul
copy /y "%ROOT%\assets\logo.png" "%APP_DIR%\logo.png" >nul

echo Build ready: %APP_DIR%\ot3.exe
echo Run the app with run.bat. Package it with scripts\package_windows.bat.
endlocal
