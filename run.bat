@echo off
pushd "%~dp0build\bin\Release"
start "" "ot3.exe" %*
popd
