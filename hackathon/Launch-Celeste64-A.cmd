@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launch-Celeste64-A.ps1" %*
if errorlevel 1 pause
