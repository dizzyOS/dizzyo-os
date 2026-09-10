@echo off
title DizzyoOS Quick Start
color 0A

echo ========================================
echo    DizzyoOS Quick Start for Windows
echo ========================================
echo.
echo This script will help you build DizzyoOS on Windows.
echo.
echo Options:
echo 1. Setup WSL2 (Recommended)
echo 2. View build instructions
echo 3. Open project folder
echo 4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto setup_wsl
if "%choice%"=="2" goto view_instructions
if "%choice%"=="3" goto open_folder
if "%choice%"=="4" goto exit

echo Invalid choice!
pause
goto start

:setup_wsl
echo.
echo Setting up WSL2...
echo.
echo Please follow these steps:
echo.
echo 1. Open PowerShell as Administrator
echo 2. Run: wsl --install
echo 3. Restart your computer
echo 4. Open Arch Linux from Start Menu
echo 5. Create username and password
echo.
echo After that, run these commands in Arch Linux:
echo.
echo sudo pacman -Syu
echo sudo pacman -S archiso squashfs-tools git base-devel
echo cd /mnt/c/Users/fifi/Desktop/linuxdistro/dizzyo-os
echo chmod +x create-iso.sh
echo sudo ./create-iso.sh
echo.
echo Press any key to open PowerShell as Administrator...
pause >nul
echo.
echo Right-click PowerShell and select "Run as administrator"
echo Then run: wsl --install
start powershell
pause
goto start

:view_instructions
echo.
echo Opening build instructions...
start notepad "%~dp0README_WINDOWS.md"
pause
goto start

:open_folder
echo.
echo Opening project folder...
explorer "%~dp0"
pause
goto start

:exit
echo.
echo Goodbye!
pause
exit /b 0
