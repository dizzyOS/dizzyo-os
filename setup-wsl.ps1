# DizzyoOS WSL2 Setup Script
# Run this script in PowerShell as Administrator

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    DizzyoOS WSL2 Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Enable WSL feature
Write-Host "Enabling WSL feature..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine Platform
Write-Host "Enabling Virtual Machine Platform..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Download and install WSL2 Linux kernel update
Write-Host "Downloading WSL2 Linux kernel update..." -ForegroundColor Yellow
$kernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$kernelPath = "$env:TEMP\wsl_update_x64.msi"

try {
    Invoke-WebRequest -Uri $kernelUrl -OutFile $kernelPath
    Start-Process msiexec.exe -ArgumentList "/i $kernelPath /quiet" -Wait
    Write-Host "WSL2 kernel updated!" -ForegroundColor Green
} catch {
    Write-Host "Failed to download kernel update. Please download manually:" -ForegroundColor Red
    Write-Host "https://aka.ms/wsl2kernel" -ForegroundColor Cyan
}

# Set WSL2 as default version
Write-Host "Setting WSL2 as default..." -ForegroundColor Yellow
wsl --set-default-version 2

# Install Arch Linux from Microsoft Store
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Open Microsoft Store" -ForegroundColor Yellow
Write-Host "2. Search for 'Arch Linux'" -ForegroundColor Yellow
Write-Host "3. Click 'Install'" -ForegroundColor Yellow
Write-Host "4. Open Arch Linux from Start Menu" -ForegroundColor Yellow
Write-Host "5. Set up your username and password" -ForegroundColor Yellow
Write-Host ""

# Create build script for WSL
$wslScript = @'
#!/bin/bash
# DizzyoOS WSL Build Script

echo "========================================"
echo "    DizzyoOS WSL Build Setup"
echo "========================================"
echo ""

# Update system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install dependencies
echo "Installing build dependencies..."
sudo pacman -S --noconfirm archiso squashfs-tools git base-devel

# Get Windows username
WIN_USER=$(cmd.exe /C "echo %USERNAME%" 2>/dev/null | tr -d '\r')

# Navigate to project
echo "Navigating to project directory..."
cd /mnt/c/Users/$WIN_USER/Desktop/linuxdistro/dizzyo-os

# Make scripts executable
chmod +x create-iso.sh build.sh

echo ""
echo "Setup complete!"
echo ""
echo "To build the ISO, run:"
echo "sudo ./create-iso.sh"
echo ""
echo "Or use the Makefile:"
echo "sudo make iso"
echo ""
'@

# Save script to a temp file
$scriptPath = "$env:TEMP\dizzyo-build.sh"
$wslScript | Out-File -FilePath $scriptPath -Encoding UTF8

Write-Host "Build script created at: $scriptPath" -ForegroundColor Green
Write-Host ""
Write-Host "After installing Arch Linux, run this command in the Arch Linux terminal:" -ForegroundColor Cyan
Write-Host "bash $scriptPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "    Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
