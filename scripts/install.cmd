@echo off
REM Double-click friendly launcher (Windows)
chcp 65001 >nul
cd /d "%~dp0"
title Cursor Constitution installer
echo.
echo Cursor Constitution installer
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
echo.
pause
