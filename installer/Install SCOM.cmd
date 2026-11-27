@echo off
setlocal DisableDelayedExpansion
title SCOM Setup 1.5.1
if not exist "%~dp0Install-SCOM.ps1" goto incomplete
if not exist "%~dp0Installer.Core.ps1" goto incomplete
if not exist "%~dp0manifest.json" goto incomplete
if not exist "%~dp0payload\" goto incomplete
if /i "%~1"=="/check" goto check
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-SCOM.ps1"
set "installerExit=%ERRORLEVEL%"
echo.
pause
exit /b %installerExit%
:check
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0Install-SCOM.ps1" -CheckOnly
exit /b %ERRORLEVEL%
:incomplete
echo Extract all files from ScomInstaller.zip, then run "Install SCOM.cmd" from that folder.
if /i "%~1"=="/check" exit /b 1
pause
exit /b 1
