#!/bin/bash
#
# DizzyoOS Build Script
# Builds the DizzyoOS ISO image
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
ISO_DIR="${SCRIPT_DIR}/iso"
WORK_DIR="${SCRIPT_DIR}/work"
ARCHISO_DIR="${SCRIPT_DIR}/archiso"
PKG_DIR="${SCRIPT_DIR}/packages"
OUT_DIR="${SCRIPT_DIR}/output"

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
        error "This script must be run as root"
    fi
}

# Check dependencies
check_deps() {
    local deps=("archiso" "mkarchiso" "squashfs-tools" "mksquashfs")
    
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
    rm -rf "${ISO_DIR}" "${WORK_DIR}" "${OUT_DIR}"
    mkdir -p "${ISO_DIR}" "${WORK_DIR}" "${OUT_DIR}"
}

# Build packages
build_packages() {
    info "Building custom packages..."
    
    # Build kernel package
    if [[ -d "${PKG_DIR}/kernel" ]]; then
        info "Building kernel package..."
        cd "${PKG_DIR}/kernel"
        makepkg -s --noconfirm
        cp *.pkg.tar.zst "${OUT_DIR}/"
        cd "${SCRIPT_DIR}"
    fi
    
    # Build other packages
    for pkg_dir in "${PKG_DIR}"/*/; do
        if [[ -d "${pkg_dir}" ]] && [[ -f "${pkg_dir}/PKGBUILD" ]]; then
            info "Building package: $(basename "${pkg_dir}")"
            cd "${pkg_dir}"
            makepkg -s --noconfirm --skipchecksums
            cp *.pkg.tar.zst "${OUT_DIR}/" 2>/dev/null || true
            cd "${SCRIPT_DIR}"
        fi
    done
}

# Create custom repository
create_repo() {
    info "Creating custom repository..."
    
    # Create repository directory structure
    mkdir -p "${ISO_DIR}/customrepo/x86_64"
    mkdir -p "${ISO_DIR}/customrepo/any"
    
    # Copy packages to repository
    cp "${OUT_DIR}"/*.pkg.tar.zst "${ISO_DIR}/customrepo/x86_64/" 2>/dev/null || true
    
    # Create repository database
    cd "${ISO_DIR}/customrepo/x86_64"
    repo-add -s -n -R dizzyo.db.tar.gz *.pkg.tar.zst 2>/dev/null || true
    cd "${SCRIPT_DIR}"
}

# Prepare airootfs
prepare_airootfs() {
    info "Preparing airootfs..."
    
    # Copy archiso airootfs
    cp -r "${ARCHISO_DIR}/airootfs" "${ISO_DIR}/"
    
    # Copy custom packages to live environment
    mkdir -p "${ISO_DIR}/airootfs/var/cache/pacman/custom"
    cp "${OUT_DIR}"/*.pkg.tar.zst "${ISO_DIR}/airootfs/var/cache/pacman/custom/" 2>/dev/null || true
    
    # Copy dinit service files
    mkdir -p "${ISO_DIR}/airootfs/etc/dinit.d"
    cp "${ARCHISO_DIR}/dinit/"*.conf "${ISO_DIR}/airootfs/etc/dinit.d/" 2>/dev/null || true
    
    # Set permissions
    chmod -R 755 "${ISO_DIR}/airootfs/etc/dinit.d/"
}

# Build ISO
build_iso() {
    info "Building DizzyoOS ISO..."
    
    # Create output directory
    mkdir -p "${OUT_DIR}"
    
    # Run mkarchiso
    mkarchiso -v -w "${WORK_DIR}" -o "${OUT_DIR}" "${ISO_DIR}"
    
    success "ISO built successfully!"
}

# Create GRUB configuration
create_grub_config() {
    info "Creating GRUB configuration..."
    
    mkdir -p "${ISO_DIR}/grub"
    
    cat > "${ISO_DIR}/grub/grub.cfg" << 'EOF'
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
    
    mkdir -p "${ISO_DIR}/limine"
    
    cat > "${ISO_DIR}/limine/limine.conf" << 'EOF'
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

# Main function
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    DizzyoOS Build System               ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    # Parse arguments
    case "${1:-build}" in
        clean)
            clean_build
            success "Build cleaned"
            ;;
        packages)
            build_packages
            ;;
        repo)
            create_repo
            ;;
        iso)
            build_iso
            ;;
        grub)
            create_grub_config
            ;;
        limine)
            create_limine_config
            ;;
        all)
            check_root
            check_deps
            clean_build
            build_packages
            create_repo
            prepare_airootfs
            create_grub_config
            create_limine_config
            build_iso
            ;;
        *)
            echo "Usage: $0 {clean|packages|repo|iso|grub|limine|all}"
            exit 1
            ;;
    esac
}

main "$@"
