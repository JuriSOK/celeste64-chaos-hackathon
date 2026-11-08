@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launch-Celeste64-C.ps1" %*
if errorlevel 1 pause
