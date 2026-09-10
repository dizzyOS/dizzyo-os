@echo off
title DizzyoOS - GitHub Actions Build
color 0B

echo ========================================
echo    Build DizzyoOS with GitHub Actions
echo ========================================
echo.
echo This is the EASIEST way to build DizzyoOS!
echo No software to install - builds in the cloud!
echo.
echo Steps:
echo 1. Install Git
echo 2. Create GitHub account
echo 3. Upload files
echo 4. Download ISO
echo.
echo Press any key to start...
pause >nul

echo.
echo Step 1: Installing Git...
echo.
echo Download Git from: https://git-scm.com/download/win
echo.
echo After installing Git, press any key to continue...
start https://git-scm.com/download/win
pause >nul

echo.
echo Step 2: Create GitHub Account
echo.
echo Go to: https://github.com
echo Click "Sign up" and create an account
echo.
echo After creating account, press any key to continue...
start https://github.com
pause >nul

echo.
echo Step 3: Create Repository
echo.
echo 1. Click "New repository" (green button)
echo 2. Name it: dizzyo-os
echo 3. Make it Public
echo 4. Click "Create repository"
echo.
echo After creating repository, press any key to continue...
pause >nul

echo.
echo Step 4: Upload Files
echo.
echo Open Git Bash (installed with Git) and run:
echo.
echo cd /c/Users/fifi/Desktop/linuxdistro/dizzyo-os
echo git init
echo git add .
echo git commit -m "Initial commit"
echo.
echo REPLACE YOUR_USERNAME with your GitHub username:
echo git remote add origin https://github.com/YOUR_USERNAME/dizzyo-os.git
echo git branch -M main
echo git push -u origin main
echo.
echo After uploading, press any key to continue...
pause >nul

echo.
echo Step 5: Build ISO
echo.
echo 1. Go to your repository on GitHub
echo 2. Click "Actions" tab
echo 3. Click "Build DizzyoOS ISO"
echo 4. Click "Run workflow"
echo 5. Wait 30-60 minutes
echo 6. Download ISO from "Artifacts"
echo.
echo After build completes, press any key to finish...
pause >nul

echo.
echo ========================================
echo    Build Complete!
echo ========================================
echo.
echo Your ISO will be in your GitHub Artifacts
echo.
echo Next: Test in VirtualBox
echo.
echo Press any key to exit...
pause >nul
exit /b 0
