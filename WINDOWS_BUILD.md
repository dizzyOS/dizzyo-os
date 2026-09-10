# DizzyoOS - Windows Build Guide

Since you're on Windows, here are your options to build DizzyoOS:

## Option 1: WSL2 (Recommended)

WSL2 lets you run Linux directly on Windows. This is the best option.

### Step 1: Install WSL2

Open PowerShell as Administrator and run:

```powershell
wsl --install
```

Restart your computer after installation.

### Step 2: Install Arch Linux on WSL2

After restart, open "Arch Linux" from Start Menu and run:

```bash
# Update system
pacman -Syu

# Install base packages
pacman -S base-devel git

# Create a non-root user
useradd -m -G wheel -s /bin/bash yourusername
passwd yourusername

# Edit sudoers
EDITOR=nano visudo
# Uncomment: %wheel ALL=(ALL:ALL) ALL
```

### Step 3: Install Build Dependencies

```bash
sudo pacman -S archiso squashfs-tools git base-devel
```

### Step 4: Build the ISO

```bash
# Navigate to your Windows folder from WSL
cd /mnt/c/Users/fifi/Desktop/linuxdistro/dizzyo-os

# Make scripts executable
chmod +x create-iso.sh build.sh

# Build the ISO (requires root in WSL)
sudo ./create-iso.sh
```

The ISO will be created in `./output/` folder, accessible from Windows.

---

## Option 2: Docker (Easier)

If you don't want to install WSL2, use Docker.

### Step 1: Install Docker Desktop

Download and install Docker Desktop for Windows:
https://www.docker.com/products/docker-desktop/

### Step 2: Create Dockerfile

Create a file called `Dockerfile` in the dizzyo-os folder:

```dockerfile
FROM archlinux:latest

# Install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm archiso squashfs-tools git base-devel

# Set working directory
WORKDIR /build

# Copy build scripts
COPY . .

# Make scripts executable
RUN chmod +x create-iso.sh build.sh

# Default command
CMD ["./create-iso.sh"]
```

### Step 3: Build with Docker

Open Docker Desktop, then open PowerShell and run:

```powershell
cd C:\Users\fifi\Desktop\linuxdistro\dizzyo-os

# Build Docker image
docker build -t dizzyo-builder .

# Run builder
docker run -v "${PWD}:/build" dizzyo-builder
```

---

## Option 3: GitHub Actions (Free)

Use GitHub Actions to build the ISO in the cloud.

### Step 1: Create GitHub Repository

1. Go to https://github.com
2. Create new repository: `dizzyo-os`
3. Upload all files from `dizzyo-os/` folder

### Step 2: Create GitHub Actions Workflow

Create file `.github/workflows/build.yml`:

```yaml
name: Build DizzyoOS ISO

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y archiso squashfs-tools
    
    - name: Build ISO
      run: |
        chmod +x create-iso.sh
        sudo ./create-iso.sh
    
    - name: Upload ISO
      uses: actions/upload-artifact@v3
      with:
        name: dizzyo-os-iso
        path: output/*.iso
```

### Step 3: Trigger Build

Push any change to trigger the build. Download the ISO from Actions > Artifacts.

---

## Option 4: Virtual Machine (Most Compatible)

Run Arch Linux in a VM to build.

### Step 1: Download Arch Linux ISO

Download from: https://archlinux.org/download/

### Step 2: Create VM

Use VirtualBox or VMware:
- Name: ArchBuilder
- RAM: 4GB
- Disk: 50GB
- Mount Arch Linux ISO

### Step 3: Install Arch Linux

Follow the Arch Linux installation guide.

### Step 4: Build in VM

```bash
# Install dependencies
sudo pacman -S archiso squashfs-tools git base-devel

# Copy files to VM (use shared folder or SCP)

# Build
sudo ./create-iso.sh
```

---

## Testing the ISO

Once you have the ISO, test it:

### VirtualBox (Free)

1. Install VirtualBox: https://www.virtualbox.org/
2. Create new VM:
   - Name: DizzyoOS
   - Type: Linux
   - Version: Arch Linux (64-bit)
   - RAM: 4096 MB
   - Disk: 50 GB
3. Settings -> Storage -> Mount ISO
4. Start VM

### VMware Workstation Player (Free)

1. Download: https://www.vmware.com/products/workstation-player.html
2. Create new VM
3. Select ISO
4. Start VM

### QEMU (Command Line)

If you have QEMU installed:

```bash
qemu-img create -f qcow2 dizzyo.qcow2 50G
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 4 \
  -cdrom output/dizzyo-os-*.iso \
  -boot d \
  -drive file=dizzyo.qcow2,format=qcow2
```

---

## Quick Start (Easiest Path)

If you just want to test quickly:

1. **Install WSL2**: Run `wsl --install` in PowerShell (Admin)
2. **Restart computer**
3. **Open Arch Linux** from Start Menu
4. **Run these commands**:

```bash
sudo pacman -Syu
sudo pacman -S archiso squashfs-tools git base-devel
cd /mnt/c/Users/fifi/Desktop/linuxdistro/dizzyo-os
chmod +x create-iso.sh
sudo ./create-iso.sh
```

5. **Wait for build** (30-60 minutes)
6. **Find ISO** in `./output/` folder
7. **Test in VirtualBox**

---

## Need Help?

- WSL2 Issues: https://github.com/microsoft/WSL/issues
- Arch Linux Wiki: https://wiki.archlinux.org/
- DizzyoOS GitHub: https://github.com/dizzyo-os
