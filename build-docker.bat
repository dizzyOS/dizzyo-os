@echo off
title DizzyoOS Docker Builder
color 0A

echo ========================================
echo    DizzyoOS Docker Builder
echo ========================================
echo.
echo This script builds DizzyoOS using Docker.
echo.
echo Prerequisites:
echo - Docker Desktop must be installed and running
echo.
echo Press any key to check Docker status...
pause >nul

REM Check if Docker is installed
docker --version 2>nul
if %errorlevel% neq 0 (
    echo.
    echo Docker is NOT installed!
    echo.
    echo Please install Docker Desktop:
    echo https://www.docker.com/products/docker-desktop/
    echo.
    echo After installing, restart your computer and run this script again.
    echo.
    start https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo.
echo Docker is installed!
echo.

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo Docker is NOT running!
    echo.
    echo Please start Docker Desktop and wait for it to be ready.
    echo Look for the Docker icon in your system tray.
    echo.
    pause
    exit /b 1
)

echo.
echo Docker is running!
echo.
echo Building DizzyoOS ISO...
echo This will take 30-60 minutes.
echo.

REM Get current directory
set "CURRENT_DIR=%~dp0"

REM Build Docker image
echo Building Docker image...
docker build -t dizzyo-builder "%CURRENT_DIR%"
if %errorlevel% neq 0 (
    echo.
    echo Docker build failed!
    echo.
    pause
    exit /b 1
)

echo.
echo Docker image built successfully!
echo.

REM Run the builder
echo Starting ISO build...
echo This may take a while...
echo.
docker run -v "%CURRENT_DIR%:/build" dizzyo-builder
if %errorlevel% neq 0 (
    echo.
    echo Build failed!
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo    Build Complete!
echo ========================================
echo.
echo Your ISO is in the output folder:
echo %CURRENT_DIR%output\
echo.
echo Next steps:
echo 1. Install VirtualBox: https://www.virtualbox.org/
echo 2. Create new VM (Linux, Arch Linux 64-bit)
echo 3. Mount the ISO file
echo 4. Start VM and test DizzyoOS
echo.
echo Press any key to open output folder...
pause >nul
explorer "%CURRENT_DIR%output"
