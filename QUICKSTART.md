# DizzyoOS Quick Start Guide

## Building the ISO

### Prerequisites

You need a Linux system (Arch Linux recommended) with:
- `archiso` package installed
- `squashfs-tools` package installed
- Root access (sudo)
- At least 20GB free disk space

### Build Steps

```bash
# 1. Navigate to the project directory
cd dizzyo-os

# 2. Make build scripts executable
chmod +x build.sh create-iso.sh

# 3. Build the ISO (requires root)
sudo ./create-iso.sh

# OR use the build script
sudo ./build.sh all
```

The ISO will be created in the `./output/` directory.

## Testing in Virtual Machine

### Option 1: QEMU (Recommended)

```bash
# Install QEMU
sudo pacman -S qemu-full

# Run the ISO
qemu-system-x86_64 \
  -enable-kvm \
  -m 4G \
  -smp 4 \
  -cpu host \
  -drive file=dizzyo-os.qcow2,format=qcow2 \
  -cdrom ./output/dizzyo-os-*.iso \
  -boot d \
  -vga virtio \
  -display gtk

# Create a virtual disk first
qemu-img create -f qcow2 dizzyo-os.qcow2 50G
```

### Option 2: VirtualBox

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

### Option 3: VMware

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
4. Follow the installation wizard:
   - Select language
   - Select keyboard layout
   - Select desktop environment
   - Select init system (dinit recommended)
   - Select filesystem (Btrfs recommended)
   - Select bootloader (Limine recommended)
   - Create partitions
   - Set username and password
   - Optional: Enable gaming meta
   - Install

## First Boot

After installation, you'll see the DizzyoOS login screen.

### Initial Setup

```bash
# Update system
sudo pacman -Syu

# Install additional packages
sudo pacman -S git base-devel

# Install AUR helper
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Configure gaming (optional)
dizzyo-gaming-optimize

# Run TUI manager
dizzyo-tui

# Run AI assistant
dizzyo-ai "system info"
```

## Quick Commands

| Command | Description |
|---------|-------------|
| `dizzyo-tui` | Open TUI manager |
| `dizzyo-ai "query"` | AI assistant |
| `dizzyo-welcome` | Welcome application |
| `dizzyo-gaming-optimize` | Enable gaming optimizations |

## Troubleshooting

### Boot fails
- Try the "Fallback" option in GRUB
- Check if your hardware is supported
- Verify ISO integrity

### No graphics
- Try "NVIDIA" option if you have NVIDIA GPU
- Install appropriate drivers

### Network issues
- Check NetworkManager status
- Restart network: `sudo systemctl restart NetworkManager`

### Sound issues
- Check PipeWire: `systemctl --user status pipewire`
- Restart PipeWire: `systemctl --user restart pipewire`

## Getting Help

- Wiki: https://wiki.dizzyo-os.org
- Forum: https://forum.dizzyo-os.org
- Discord: https://discord.gg/dizzyo-os
- GitHub Issues: https://github.com/dizzyo-os/issues
