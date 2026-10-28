@echo off
setlocal DisableDelayedExpansion
title SCOM Setup 1.0.1
if not exist "%~dp0Install-SCOM.ps1" goto incomplete
if not exist "%~dp0Installer.Core.ps1" goto incomplete
if not exist "%~dp0manifest.json" goto incomplete
if not exist "%~dp0payload\" goto incomplete
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-SCOM.ps1"
set "installerExit=%ERRORLEVEL%"
echo.
pause
exit /b %installerExit%
:incomplete
echo Extract all files from ScomInstaller.zip, then run "Install SCOM.cmd" from that folder.
pause
exit /b 1
