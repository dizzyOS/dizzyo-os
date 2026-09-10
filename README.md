# DizzyoOS

A performance-first Linux distribution with the best Windows emulation support, 20+ desktop environments, and AI-powered system management.

## Quick Start

### Build ISO on Windows (Easiest)

**Option 1: GitHub Actions (Recommended)**
1. Create GitHub account at https://github.com
2. Create new repository named `dizzyo-os`
3. Upload all files from this folder
4. Go to Actions tab → Click "Run workflow"
5. Wait 30-60 minutes, then download ISO from Artifacts

**Option 2: Docker**
1. Install Docker Desktop: https://www.docker.com/products/docker-desktop/
2. Open PowerShell and run:
```powershell
cd C:\Users\fifi\Desktop\linuxdistro\dizzyo-os
docker build -t dizzyo-builder .
docker run -v "${PWD}:/build" dizzyo-builder
```

**Option 3: VirtualBox**
1. Install VirtualBox: https://www.virtualbox.org/
2. Download Arch Linux ISO: https://archlinux.org/download/
3. Create VM, install Arch Linux
4. Build DizzyoOS inside the VM

See `WINDOWS_BUILD.md` for detailed instructions.

### Build ISO on Linux

```bash
# Install dependencies (Arch Linux)
sudo pacman -S archiso squashfs-tools git base-devel

# Build the ISO
sudo ./create-iso.sh

# OR use Make
sudo make iso
```

## Features

- **Custom Kernel**: NTSYNC, BBR3, MGLRU, SCHED_EXT
- **20+ Desktop Environments**: KDE, GNOME, COSMIC, Hyprland, Sway, niri, and more
- **Full Windows Emulation**: Wine, Proton, DXVK, VKD3D, Lutris, Heroic
- **Dual Package Management**: pacman + Flatpak
- **AI Assistant**: Natural language system management
- **TUI Manager**: Complete terminal-based system tools
- **Security Hardening**: AppArmor, Firejail, kernel hardening

## Desktop Environments

### Mainstream
KDE Plasma 6, GNOME 47, COSMIC, XFCE 4, Cinnamon, MATE, Budgie, LXQt

### Tiling WMs (Wayland)
Hyprland, Sway, niri, river, fenriz, carrot, stilch, ashwc, margo

### Tiling WMs (X11)
i3, dwm, xmonad, bspwm, awesome

### Niche/Unknown
Orbitiny, eDEX-DE, Nuroneko, Nidara, tuiui, fluxland, zde

## Gaming Stack

- Steam with Proton
- Lutris, Heroic Games Launcher
- Wine + DXVK + VKD3D-Proton
- MangoHud, Gamemode, Gamescope
- Controller support (Xbox, PlayStation, Switch)

## System Tools

- **TUI Manager**: System info, processes, services, packages, disk, network, security
- **AI Assistant**: Natural language queries and automation
- **Gaming Optimizer**: One-click gaming setup

## Project Structure

```
dizzyo-os/
├── archiso/           # ISO configuration
├── packages/          # Custom packages (kernel, etc.)
├── dinit/             # Init system services
├── installer/         # Installer configuration
├── tools/             # System management tools
├── .github/workflows/ # GitHub Actions build
├── Dockerfile         # Docker build
├── create-iso.sh      # Main build script
└── README.md          # This file
```

## Documentation

- [Windows Build Guide](WINDOWS_BUILD.md)
- [Docker Build Guide](DOCKER_BUILD.md)
- [Quick Start](QUICKSTART.md)
- [Build Instructions](BUILD_INSTRUCTIONS.md)

## Support

- GitHub: https://github.com/dizzyo-os
- Issues: https://github.com/dizzyo-os/issues

## License

GPL-3.0
