@echo off
setlocal
set "QT_PATH=C:\Qt\6.7.2\msvc2019_64"
set "CMAKE_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"

echo [1/3] Configuring CMake...
"%CMAKE_PATH%" -G "Visual Studio 17 2022" -A x64 -S "%~dp0." -B "%~dp0build" -DCMAKE_PREFIX_PATH="%QT_PATH%"
if errorlevel 1 exit /b %errorlevel%

echo [2/3] Compiling Release build...
"%CMAKE_PATH%" --build "%~dp0build" --config Release --parallel
if errorlevel 1 exit /b %errorlevel%

echo [3/3] Deploying Qt runtime libraries...
"%QT_PATH%\bin\windeployqt.exe" "%~dp0build\bin\Release\ot3.exe" --qmldir "%~dp0app\qml" --multimedia
copy /y "%~dp0build\bin\Release\ot3.exe" "%~dp0build\bin\Release\FilterDesigner.exe" >nul

echo Build complete! Run run.bat or .\build\bin\Release\ot3.exe
endlocal
