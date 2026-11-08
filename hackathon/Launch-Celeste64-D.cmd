@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launch-Celeste64-D.ps1" %*
if errorlevel 1 pause
