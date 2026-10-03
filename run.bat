@echo off
setlocal
set "APP_EXE=%~dp0build\windows-release\bin\ot3.exe"
if not exist "%APP_EXE%" (
    echo Overtune is not built yet. Run build.bat first.
    exit /b 1
)
start "" "%APP_EXE%" %*
endlocal
