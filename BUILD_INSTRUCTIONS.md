# DizzyoOS Build Instructions

## Overview

This document explains how to build DizzyoOS from source and create a bootable ISO image for testing.

## Prerequisites

### System Requirements
- **Operating System**: Arch Linux (recommended) or any Arch-based distro
- **Disk Space**: At least 20GB free
- **RAM**: 4GB minimum, 8GB recommended
- **Internet**: Active connection for package downloads

### Required Packages

```bash
# Install build dependencies
sudo pacman -S archiso squashfs-tools git base-devel
```

## Building the ISO

### Method 1: Using the Build Script (Recommended)

```bash
# Navigate to the project directory
cd dizzyo-os

# Make scripts executable
chmod +x build.sh create-iso.sh

# Build everything (requires root)
sudo ./build.sh all

# OR use the ISO creator
sudo ./create-iso.sh
```

### Method 2: Using Make

```bash
# Navigate to the project directory
cd dizzyo-os

# Build everything
sudo make build

# OR build just the ISO
sudo make iso
```

### Method 3: Manual Build

```bash
# Navigate to the project directory
cd dizzyo-os

# Create directory structure
mkdir -p iso/arch/x86_64
mkdir -p iso/arch/boot/x86_64
mkdir -p iso/airootfs/etc
mkdir -p iso/airootfs/root
mkdir -p iso/airootfs/usr/bin

# Copy kernel and initramfs
cp /boot/vmlinuz-linux iso/arch/boot/x86_64/
cp /boot/initramfs-linux.img iso/arch/boot/x86_64/
cp /boot/initramfs-linux-fallback.img iso/arch/boot/x86_64/

# Create package list
# (copy packages.x86_64 to iso/arch/x86_64/packages)

# Build ISO
sudo mkarchiso -v -w work -o output iso
```

## Output

After a successful build, you'll find:
- **ISO file**: `./output/dizzyo-os-*.iso`
- **Build logs**: `./work/`
- **Packages**: `./packages/*/pkg/`

## Testing the ISO

### Using QEMU (Recommended)

```bash
# Install QEMU
sudo pacman -S qemu-full

# Create a virtual disk
qemu-img create -f qcow2 dizzyo.qcow2 50G

# Boot the ISO
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 4 \
  -cpu host \
  -drive file=dizzyo.qcow2,format=qcow2 \
  -cdrom ./output/dizzyo-os-*.iso \
  -boot d \
  -vga virtio \
  -display gtk

# OR use Make
sudo make test
```

### Using VirtualBox

1. Open VirtualBox
2. Click "New"
3. Name: "DizzyoOS"
4. Type: "Linux"
5. Version: "Arch Linux (64-bit)"
6. Memory: 4096 MB
7. Create virtual hard disk (50GB)
8. Go to Settings -> Storage
9. Mount the ISO file
10. Start the VM

### Using VMware

1. Create New Virtual Machine
2. Select "Installer disc image file (iso)"
3. Browse to the ISO file
4. Select Linux -> Other Linux 5.x or later kernel
5. Allocate 4GB RAM, 2 processors
6. Create 50GB virtual disk
7. Customize hardware if needed
8. Finish and start

## Installation

1. Boot from the ISO
2. Select "DizzyoOS Live"
3. Run the installer from the desktop
4. Follow the installation wizard

## Troubleshooting

### Build fails with "permission denied"
```bash
# Make sure you're running as root
sudo ./create-iso.sh
```

### Build fails with "package not found"
```bash
# Update system first
sudo pacman -Syu

# Then try building again
sudo ./create-iso.sh
```

### ISO boots but no graphics
```bash
# Try the NVIDIA option in GRUB
# Or boot with: nomodeset
```

### QEMU fails to start
```bash
# Make sure KVM is enabled
lsmod | grep kvm

# If not loaded, load the modules
sudo modprobe kvm
sudo modprobe kvm_intel  # For Intel
sudo modprobe kvm_amd    # For AMD

# Add your user to the kvm group
sudo usermod -aG kvm $USER
```

## Advanced Build Options

### Custom Kernel

To build with a custom kernel:

```bash
# Edit the kernel configuration
nano packages/kernel/config

# Build kernel package
cd packages/kernel
makepkg -s

# Then build ISO
sudo ./create-iso.sh
```

### Custom Packages

To add custom packages:

1. Add package to `archiso/packages.x86_64`
2. Rebuild ISO

### Custom Desktop Environment

To add a new DE:

1. Edit `installer/calamares/config.conf`
2. Add DE configuration to the desktops section
3. Rebuild ISO

## Build Statistics

- **Build time**: 30-60 minutes (depending on hardware)
- **ISO size**: ~2-3 GB
- **Installed size**: ~10-15 GB

## Support

- **Documentation**: https://wiki.dizzyo-os.org
- **Forum**: https://forum.dizzyo-os.org
- **GitHub Issues**: https://github.com/dizzyo-os/issues

## Next Steps

After testing the ISO:

1. Report any bugs on GitHub
2. Suggest new features
3. Contribute to the project
4. Share your experience with the community
