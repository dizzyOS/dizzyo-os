# DizzyoOS - Windows Build Guide

## Quick Start (5 Minutes)

### Step 1: Install WSL2

Open PowerShell as Administrator and run:

```powershell
wsl --install
```

**Restart your computer** after installation.

### Step 2: Install Arch Linux

1. Open **Microsoft Store**
2. Search for **"Arch Linux"**
3. Click **Install**
4. Open Arch Linux from Start Menu
5. Create a username and password when prompted

### Step 3: Build DizzyoOS

Open Arch Linux and run these commands:

```bash
# Update system
sudo pacman -Syu

# Install build tools
sudo pacman -S archiso squashfs-tools git base-devel

# Navigate to your project
cd /mnt/c/Users/fifi/Desktop/linuxdistro/dizzyo-os

# Make build script executable
chmod +x create-iso.sh

# Build the ISO (takes 30-60 minutes)
sudo ./create-iso.sh
```

### Step 4: Find Your ISO

The ISO file will be in:
```
C:\Users\fifi\Desktop\linuxdistro\dizzyo-os\output\
```

### Step 5: Test in VirtualBox

1. Download VirtualBox: https://www.virtualbox.org/
2. Create new VM:
   - Name: DizzyoOS
   - Type: Linux
   - Version: Arch Linux (64-bit)
   - RAM: 4096 MB
   - Disk: 50 GB
3. Go to **Settings** → **Storage** → Mount the ISO
4. Start the VM

---

## Alternative: Use the Helper Script

Double-click `build-windows.bat` and follow the instructions.

---

## Files You Need

| File | Purpose |
|------|---------|
| `create-iso.sh` | Main build script |
| `build.sh` | Alternative build script |
| `Makefile` | Build automation |
| `archiso/` | ISO configuration |
| `packages/` | Custom packages |
| `installer/` | Installer config |

---

## Troubleshooting

### "wsl is not recognized"
- Make sure you ran PowerShell as Administrator
- Restart your computer after installing WSL

### "permission denied"
- Make sure you're using `sudo`
- Run `chmod +x create-iso.sh` first

### Build fails
- Make sure you have internet connection
- Try updating first: `sudo pacman -Syu`
- Check disk space: `df -h`

### Can't find the ISO
- Check the `output/` folder
- The ISO filename starts with `dizzyo-os-`

---

## Need Help?

- Open Arch Linux terminal
- Run: `cd /mnt/c/Users/fifi/Desktop/linuxdistro/dizzyo-os`
- Check: `ls -la output/`

---

## What's Next?

After building the ISO:

1. **Test in VirtualBox** (see Step 5 above)
2. **Report issues** on GitHub
3. **Customize** the distribution
4. **Share** with the community!

---

## Quick Reference

```bash
# Build ISO
sudo ./create-iso.sh

# Clean build
sudo ./build.sh clean

# Build packages only
sudo ./build.sh packages

# Test in QEMU (if installed)
sudo make test
```

---

## Video Tutorial

Coming soon! Check our YouTube channel for video guides.
