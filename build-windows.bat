@echo off
REM DizzyoOS Windows Build Helper
REM This script helps you build DizzyoOS on Windows

echo ========================================
echo    DizzyoOS Windows Build Helper
echo ========================================
echo.

REM Check if WSL is installed
wsl --list --verbose 2>nul
if %errorlevel% neq 0 (
    echo WSL is not installed.
    echo.
    echo To install WSL2, run this command in PowerShell as Administrator:
    echo wsl --install
    echo.
    echo Then restart your computer and run this script again.
    echo.
    pause
    exit /b 1
)

echo WSL is installed!
echo.

REM Check if Arch Linux is available
wsl -l -v | findstr /i "arch" >nul
if %errorlevel% neq 0 (
    echo Arch Linux is not installed in WSL.
    echo.
    echo Please install Arch Linux from Microsoft Store:
    echo https://apps.microsoft.com/store/detail/arch-linux/9P5LQ96HN7KP
    echo.
    pause
    exit /b 1
)

echo Arch Linux is available!
echo.

REM Build options
echo Choose build method:
echo 1. WSL2 (Recommended)
echo 2. Docker
echo 3. GitHub Actions (Cloud)
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto wsl_build
if "%choice%"=="2" goto docker_build
if "%choice%"=="3" goto github_build

echo Invalid choice!
pause
exit /b 1

:wsl_build
echo.
echo Building with WSL2...
echo.

REM Get current directory
set "CURRENT_DIR=%~dp0"

REM Convert Windows path to WSL path
set "WSL_PATH=%CURRENT_DIR:\=/%"
set "WSL_PATH=/mnt/%WSL_PATH:~0,1%%WSL_PATH:~2%"

echo Opening Arch Linux terminal...
echo Please run these commands:
echo.
echo 1. sudo pacman -Syu
echo 2. sudo pacman -S archiso squashfs-tools git base-devel
echo 3. cd %WSL_PATH%
echo 4. chmod +x create-iso.sh
echo 5. sudo ./create-iso.sh
echo.

REM Open WSL with Arch Linux
wsl -d ArchLinux

pause
exit /b 0

:docker_build
echo.
echo Building with Docker...
echo.

REM Check if Docker is installed
docker --version 2>nul
if %errorlevel% neq 0 (
    echo Docker is not installed.
    echo.
    echo Please install Docker Desktop:
    echo https://www.docker.com/products/docker-desktop/
    echo.
    pause
    exit /b 1
)

echo Docker is installed!
echo.

REM Get current directory
set "CURRENT_DIR=%~dp0"

echo Building Docker image...
docker build -t dizzyo-builder "%CURRENT_DIR%"

echo Running builder...
docker run -v "%CURRENT_DIR%:/build" dizzyo-builder

echo.
echo Build complete! Check the output folder for the ISO.
pause
exit /b 0

:github_build
echo.
echo Building with GitHub Actions...
echo.
echo Please follow these steps:
echo 1. Create a GitHub account (if you don't have one)
echo 2. Go to https://github.com
echo 3. Create new repository: dizzyo-os
echo 4. Upload all files from this folder
echo 5. Create .github/workflows/build.yml (see WINDOWS_BUILD.md)
echo 6. Push any change to trigger the build
echo 7. Download ISO from Actions - Artifacts
echo.
echo See WINDOWS_BUILD.md for detailed instructions.
pause
exit /b 0
