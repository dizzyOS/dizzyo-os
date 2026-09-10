# DizzyoOS - Docker Build for Windows

No WSL needed! Use Docker to build DizzyoOS directly on Windows.

## Option 1: Docker Desktop (Recommended)

### Step 1: Install Docker Desktop

1. Download Docker Desktop: https://www.docker.com/products/docker-desktop/
2. Install and restart
3. Make sure Docker is running (check system tray)

### Step 2: Build the ISO

Open PowerShell and run:

```powershell
cd C:\Users\fifi\Desktop\linuxdistro\dizzyo-os

# Build the Docker image
docker build -t dizzyo-builder .

# Run the builder
docker run -v "${PWD}:/build" dizzyo-builder
```

### Step 3: Find Your ISO

The ISO will be in: `C:\Users\fifi\Desktop\linuxdistro\dizzyo-os\output\`

---

## Option 2: GitHub Actions (Free, No Install)

Build in the cloud - no software needed on your PC!

### Step 1: Install Git

Download: https://git-scm.com/download/win

### Step 2: Create GitHub Repository

1. Go to https://github.com
2. Sign up / Sign in
3. Click "New repository"
4. Name: `dizzyo-os`
5. Make it Public
6. Click "Create repository"

### Step 3: Upload Files

Open Git Bash and run:

```bash
cd /c/Users/fifi/Desktop/linuxdistro/dizzyo-os

# Initialize git
git init
git add .
git commit -m "Initial commit"

# Connect to GitHub (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/dizzyo-os.git
git branch -M main
git push -u origin main
```

### Step 4: Create Build Workflow

Create file `.github/workflows/build.yml` with this content:

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
      uses: actions/checkout@v4
    
    - name: Install dependencies
      run: |
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm archiso squashfs-tools
    
    - name: Build ISO
      run: |
        chmod +x create-iso.sh
        sudo ./create-iso.sh
    
    - name: Upload ISO
      uses: actions/upload-artifact@v4
      with:
        name: dizzyo-os-iso
        path: output/*.iso
```

### Step 5: Download ISO

1. Go to your repo on GitHub
2. Click "Actions" tab
3. Click on the build
4. Download the ISO from "Artifacts"

---

## Option 3: VirtualBox (Full Control)

Run Arch Linux in a virtual machine to build.

### Step 1: Download VirtualBox

https://www.virtualbox.org/

### Step 2: Download Arch Linux ISO

https://archlinux.org/download/

### Step 3: Create VM

1. Open VirtualBox
2. Click "New"
3. Name: ArchBuilder
4. Type: Linux
5. Version: Arch Linux (64-bit)
6. Memory: 4096 MB
7. Create virtual hard disk: 50 GB

### Step 4: Install Arch Linux

1. Mount Arch Linux ISO in VM
2. Start VM
3. Follow installation: https://wiki.archlinux.org/title/Installation_guide

### Step 5: Build DizzyoOS in VM

```bash
# Install dependencies
sudo pacman -Syu
sudo pacman -S archiso squashfs-tools git base-devel

# Share folder: VM Settings -> Shared Folders -> Add
# Map to: C:\Users\fifi\Desktop\linuxdistro\dizzyo-os

# Navigate to shared folder
cd /mnt/shared/dizzyo-os

# Build
sudo ./create-iso.sh
```

---

## Quick Comparison

| Method | Difficulty | Time | Requirements |
|--------|-----------|------|--------------|
| Docker Desktop | Easy | 1 hour | Docker Desktop |
| GitHub Actions | Easy | 30 min | GitHub account |
| VirtualBox | Medium | 2+ hours | VirtualBox |

---

## Need Help?

- Docker: https://docs.docker.com/desktop/install/windows-install/
- GitHub: https://docs.github.com/en/get-started
- VirtualBox: https://www.virtualbox.org/manual/
