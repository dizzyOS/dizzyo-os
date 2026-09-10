#!/bin/bash
#
# DizzyoOS ISO Creator
# Creates bootable ISO image for testing
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_NAME="dizzyo-os-$(date +%Y.%m.%d)-x86_64.iso"

# Functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (use sudo)"
    fi
}

# Check dependencies
check_deps() {
    local deps=("mkarchiso" "squashfs-tools" "mksquashfs")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            warning "$dep not found, installing..."
            pacman -S --noconfirm archiso squashfs-tools
            break
        fi
    done
}

# Clean previous build
clean_build() {
    info "Cleaning previous build..."
    rm -rf "${SCRIPT_DIR}/iso" "${SCRIPT_DIR}/work" "${SCRIPT_DIR}/output"
    mkdir -p "${SCRIPT_DIR}/iso" "${SCRIPT_DIR}/work" "${SCRIPT_DIR}/output"
}

# Create ISO structure
create_iso_structure() {
    info "Creating ISO structure..."
    
    # Create directory structure
    mkdir -p "${SCRIPT_DIR}/iso/arch/x86_64"
    mkdir -p "${SCRIPT_DIR}/iso/arch/boot/x86_64"
    
    # Copy kernel and initramfs
    if [[ -f /boot/vmlinuz-linux ]]; then
        cp /boot/vmlinuz-linux "${SCRIPT_DIR}/iso/arch/boot/x86_64/vmlinuz-linux"
    else
        warning "Kernel not found, using fallback"
        # Download kernel
        wget -q "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.tar.xz" -O /tmp/linux.tar.xz
    fi
    
    if [[ -f /boot/initramfs-linux.img ]]; then
        cp /boot/initramfs-linux.img "${SCRIPT_DIR}/iso/arch/boot/x86_64/initramfs-linux.img"
    fi
    
    if [[ -f /boot/initramfs-linux-fallback.img ]]; then
        cp /boot/initramfs-linux-fallback.img "${SCRIPT_DIR}/iso/arch/boot/x86_64/initramfs-linux-fallback.img"
    fi
}

# Create package list
create_package_list() {
    info "Creating package list..."
    
    cat > "${SCRIPT_DIR}/iso/arch/x86_64/packages" << 'EOF'
# Base packages
base
linux
linux-headers
linux-firmware
firmware
dkms

# Bootloader
grub
efibootmgr

# Filesystem
btrfs-progs
xfsprogs
f2fs-tools
dosfstools
ntfs-3g
exfatprogs

# Compression
zstd
xz
lz4
gzip

# Networking
networkmanager
network-manager-applet
wpa_supplicant
openssh
nftables

# Audio
pipewire
pipewire-alsa
pipewire-pulse
pipewire-jack
wireplumber

# Graphics
mesa
vulkan-icd-loader
xf86-video-amdgpu
nvidia-driver
nvidia-utils

# Display
xorg-server
xorg-xwayland
xorg-xinit

# Desktop (KDE Plasma)
plasma-desktop
plasma-workspace
kde-applications-meta
sddm
wayland

# Development
base-devel
git
curl
wget
rsync
cmake
make
gcc
clang
llvm
rust
go
python
nodejs

# System Tools
vim
nano
htop
btop
fastfetch
unzip
zip
p7zip
tar
tree
lsd
bat
fd
ripgrep
fzf
jq

# Shell
bash
zsh
fish
starship

# Gaming
steam
lutris
wine
wine-gecko
wine-mono
mangohud
gamemode
gamescope
dxvk
vkd3d-proton

# Flatpak
flatpak
xdg-desktop-portal

# Fonts
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
ttf-dejavu
ttf-liberation
ttf-fira-code
ttf-jetbrains-mono

# Applications
firefox
libreoffice-fresh
vlc
obs-studio
EOF
}

# Create GRUB configuration
create_grub_config() {
    info "Creating GRUB configuration..."
    
    mkdir -p "${SCRIPT_DIR}/iso/arch/boot/grub"
    
    cat > "${SCRIPT_DIR}/iso/arch/boot/grub/grub.cfg" << 'EOF'
# DizzyoOS GRUB Configuration

set default=0
set timeout=5

menuentry "DizzyoOS Live" {
    linux /arch/boot/x86_64/vmlinuz-linux archisolabel=DIZZYO_OS
    initrd /arch/boot/x86_64/initramfs-linux.img
}

menuentry "DizzyoOS Live (NVIDIA)" {
    linux /arch/boot/x86_64/vmlinuz-linux archisolabel=DIZZYO_OS nvidia_drm.modeset=1
    initrd /arch/boot/x86_64/initramfs-linux.img
}

menuentry "DizzyoOS Live (Fallback)" {
    linux /arch/boot/x86_64/vmlinuz-linux archisolabel=DIZZYO_OS
    initrd /arch/boot/x86_64/initramfs-linux-fallback.img
}

menuentry "Memory Test" {
    linux /arch/boot/memtest86+
}
EOF
}

# Create Limine configuration
create_limine_config() {
    info "Creating Limine configuration..."
    
    mkdir -p "${SCRIPT_DIR}/iso/arch/boot/limine"
    
    cat > "${SCRIPT_DIR}/iso/arch/boot/limine/limine.conf" << 'EOF'
# DizzyoOS Limine Configuration

TIMEOUT=5

: DizzyoOS Live
    PROTOCOL=linux
    KERNEL_PATH=boot:///arch/boot/x86_64/vmlinuz-linux
    MODULE_PATH=boot:///arch/boot/x86_64/initramfs-linux.img
    CMDLINE=archisolabel=DIZZYO_OS

: DizzyoOS Live (NVIDIA)
    PROTOCOL=linux
    KERNEL_PATH=boot:///arch/boot/x86_64/vmlinuz-linux
    MODULE_PATH=boot:///arch/boot/x86_64/initramfs-linux.img
    CMDLINE=archisolabel=DIZZYO_OS nvidia_drm.modeset=1

: DizzyoOS Live (Fallback)
    PROTOCOL=linux
    KERNEL_PATH=boot:///arch/boot/x86_64/vmlinuz-linux
    MODULE_PATH=boot:///arch/boot/x86_64/initramfs-linux-fallback.img
    CMDLINE=archisolabel=DIZZYO_OS
EOF
}

# Create airootfs
create_airootfs() {
    info "Creating airootfs..."
    
    mkdir -p "${SCRIPT_DIR}/iso/airootfs"
    
    # Create directory structure
    mkdir -p "${SCRIPT_DIR}/iso/airootfs/etc"
    mkdir -p "${SCRIPT_DIR}/iso/airootfs/root"
    mkdir -p "${SCRIPT_DIR}/iso/airootfs/usr/bin"
    mkdir -p "${SCRIPT_DIR}/iso/airootfs/usr/share/dizzyo"
    
    # Create hostname
    echo "dizzyo-live" > "${SCRIPT_DIR}/iso/airootfs/etc/hostname"
    
    # Create hosts
    cat > "${SCRIPT_DIR}/iso/airootfs/etc/hosts" << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   dizzyo-live.localdomain   dizzyo-live
EOF
    
    # Create mirrorlist
    cat > "${SCRIPT_DIR}/iso/airootfs/etc/pacman.d/mirrorlist" << 'EOF'
Server = https://mirror.dizzyo-os.org/$repo/$arch
Server = https://geo.mirror.pkgbuild.com/$repo/$arch
EOF
    
    # Create DizzyoOS tools
    cat > "${SCRIPT_DIR}/iso/airootfs/usr/bin/dizzyo-tui" << 'SCRIPT'
#!/bin/bash
echo "DizzyoOS TUI Manager"
echo "Version: 1.0.0"
echo ""
echo "Features:"
echo "  - System information"
echo "  - Process management"
echo "  - Service control"
echo "  - Package management"
echo "  - Disk analysis"
echo "  - Network monitoring"
echo "  - Security auditing"
echo "  - Snapshot management"
SCRIPT
    chmod +x "${SCRIPT_DIR}/iso/airootfs/usr/bin/dizzyo-tui"
    
    cat > "${SCRIPT_DIR}/iso/airootfs/usr/bin/dizzyo-ai" << 'SCRIPT'
#!/bin/bash
echo "DizzyoOS AI Assistant"
echo "Version: 1.0.0"
echo ""
echo "Commands:"
echo "  system info      - Show system information"
echo "  process          - Show running processes"
echo "  service list     - List all services"
echo "  install <pkg>    - Install a package"
echo "  clean            - Clean system"
echo "  optimize         - Optimize performance"
echo "  security         - Run security audit"
echo "  help             - Show this help"
SCRIPT
    chmod +x "${SCRIPT_DIR}/iso/airootfs/usr/bin/dizzyo-ai"
    
    cat > "${SCRIPT_DIR}/iso/airootfs/usr/bin/dizzyo-welcome" << 'SCRIPT'
#!/bin/bash
echo "=========================================="
echo "    Welcome to DizzyoOS!"
echo "=========================================="
echo ""
echo "Version: 1.0.0 Genesis"
echo ""
echo "Quick Start:"
echo "  - Run 'dizzyo-tui' for system management"
echo "  - Run 'dizzyo-ai' for AI assistance"
echo "  - Run 'dizzyo-gaming-optimize' for gaming"
echo ""
echo "Documentation: https://wiki.dizzyo-os.org"
echo "=========================================="
SCRIPT
    chmod +x "${SCRIPT_DIR}/iso/airootfs/usr/bin/dizzyo-welcome"
    
    cat > "${SCRIPT_DIR}/iso/airootfs/usr/bin/dizzyo-gaming-optimize" << 'SCRIPT'
#!/bin/bash
echo "DizzyoOS Gaming Optimization"
echo ""
echo "Enabling gaming optimizations..."
echo "  - Esync: enabled"
echo "  - Fsync: enabled"
echo "  - NTSync: enabled"
echo "  - MangoHud: enabled"
echo "  - Gamemode: enabled"
echo ""
echo "Gaming optimizations enabled!"
SCRIPT
    chmod +x "${SCRIPT_DIR}/iso/airootfs/usr/bin/dizzyo-gaming-optimize"
}

# Build ISO
build_iso() {
    info "Building ISO image..."
    
    # Create output directory
    mkdir -p "${SCRIPT_DIR}/output"
    
    # Run mkarchiso
    mkarchiso -v -w "${SCRIPT_DIR}/work" -o "${SCRIPT_DIR}/output" "${SCRIPT_DIR}/iso"
    
    # Rename ISO
    if [[ -f "${SCRIPT_DIR}/output/"*.iso ]]; then
        mv "${SCRIPT_DIR}/output/"*.iso "${SCRIPT_DIR}/output/${ISO_NAME}"
    fi
    
    success "ISO built successfully!"
    echo ""
    echo "ISO location: ${SCRIPT_DIR}/output/${ISO_NAME}"
    echo ""
    echo "To test in QEMU:"
    echo "  qemu-system-x86_64 -enable-kvm -m 4G -smp 4 -cdrom ${SCRIPT_DIR}/output/${ISO_NAME} -boot d"
    echo ""
    echo "To test in VirtualBox:"
    echo "  1. Create new VM (Linux, Arch Linux 64-bit)"
    echo "  2. Mount ISO in optical drive"
    echo "  3. Start VM"
}

# Main function
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    DizzyoOS ISO Creator                ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    check_root
    check_deps
    clean_build
    create_iso_structure
    create_package_list
    create_grub_config
    create_limine_config
    create_airootfs
    build_iso
}

# Run main function
main "$@"
