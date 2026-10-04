@echo off
setlocal
title PNG to High-DPI TIFF

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0png-to-high-dpi-tiff.ps1" %*
set "exit_code=%errorlevel%"

if not "%exit_code%"=="0" pause
exit /b %exit_code%
