#!/bin/bash
#
# DizzyoOS Post-Installation Script
# Configures system after installation
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
INSTALL_ROOT="${1:-/mnt}"
DIZZYO_CONFIG="${INSTALL_ROOT}/etc/dizzyo"

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

# Configure dinit services
configure_dinit() {
    info "Configuring dinit services..."
    
    # Create dinit service directory
    mkdir -p "${INSTALL_ROOT}/etc/dinit.d"
    
    # Create elogind service
    cat > "${INSTALL_ROOT}/etc/dinit.d/elogind" << 'EOF'
type = process
description = "elogind Login Manager"
command = /usr/lib/elogind/elogind-daemon
restart = true
restart_delay = 5
EOF
    
    # Create dbus service
    cat > "${INSTALL_ROOT}/etc/dinit.d/dbus" << 'EOF'
type = process
description = "D-Bus System Message Bus"
command = /usr/bin/dbus-daemon --system --nofork
socket_type = stream
socket_path = /run/dbus/system_bus_socket
restart = true
restart_delay = 5
EOF
    
    # Create networkmanager service
    cat > "${INSTALL_ROOT}/etc/dinit.d/networkmanager" << 'EOF'
type = process
description = "NetworkManager"
command = /usr/bin/NetworkManager --no-daemon
restart = true
restart_delay = 5
EOF
    
    # Create pipewire service
    cat > "${INSTALL_ROOT}/etc/dinit.d/pipewire" << 'EOF'
type = process
description = "PipeWire Multimedia Server"
command = /usr/bin/pipewire
restart = true
restart_delay = 5
EOF
    
    # Create wireplumber service
    cat > "${INSTALL_ROOT}/etc/dinit.d/wireplumber" << 'EOF'
type = process
description = "WirePlumber Session Manager"
command = /usr/bin/wireplumber
restart = true
restart_delay = 5
EOF
    
    # Create sddm service
    cat > "${INSTALL_ROOT}/etc/dinit.d/sddm" << 'EOF'
type = process
description = "SDDM Display Manager"
command = /usr/bin/sddm
restart = true
restart_delay = 5
EOF
    
    # Enable services
    systemctl enable elogind
    systemctl enable dbus
    systemctl enable NetworkManager
    systemctl enable pipewire
    systemctl enable wireplumber
    systemctl enable sddm
    
    success "Dinit services configured!"
}

# Configure gaming
configure_gaming() {
    info "Configuring gaming..."
    
    # Create gaming configuration
    mkdir -p "${INSTALL_ROOT}/etc/dizzyo/gaming"
    
    # Create gaming profile
    cat > "${INSTALL_ROOT}/etc/dizzyo/gaming/profile.conf" << 'EOF'
# DizzyoOS Gaming Profile

# Enable Esync
ESYNC=1

# Enable Fsync
FSYNC=1

# Enable NTSync
NTSYNC=1

# MangoHud
MANGOHUD=1
MANGOHUD_CONFIG="cpu_temp,gpu_temp,ram,vram,fps,frametime"

# Gamemode
GAMEMODE=1

# Gamescope
GAMESCOPE=1
GAMESCOPE_ARGS="-w 1920 -h 1080 -r 60"

# DXVK
DXVK_ASYNC=1

# VKD3D
VKD3D=1
EOF
    
    # Create gaming optimization script
    cat > "${INSTALL_ROOT}/usr/bin/dizzyo-gaming-optimize" << 'SCRIPT'
#!/bin/bash
#
# DizzyoOS Gaming Optimization Script
#

set -euo pipefail

# Enable Esync
echo 1 > /proc/sys/fs/inotify/max_user_watches

# Enable Fsync
modprobe ntsync

# Set CPU governor to performance
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo performance > "$cpu" 2>/dev/null || true
done

# Enable MangoHud
export MANGOHUD=1

# Enable Gamemode
gamemoded -d

echo "Gaming optimizations enabled!"
SCRIPT
    
    chmod +x "${INSTALL_ROOT}/usr/bin/dizzyo-gaming-optimize"
    
    success "Gaming configured!"
}

# Configure security
configure_security() {
    info "Configuring security..."
    
    # Create security configuration
    mkdir -p "${INSTALL_ROOT}/etc/dizzyo/security"
    
    # Create AppArmor profile
    cat > "${INSTALL_ROOT}/etc/dizzyo/security/apparmor.conf" << 'EOF'
# DizzyoOS AppArmor Configuration

# Enable AppArmor
apparmor=1 security=apparmor

# Load default profiles
aa-enforce /etc/apparmor.d/*
EOF
    
    # Create firewall rules
    cat > "${INSTALL_ROOT}/etc/nftables.dizzyo.conf" << 'EOF'
#!/usr/sbin/nft -f

# DizzyoOS Firewall Rules

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Allow loopback
        iif "lo" accept
        
        # Allow established connections
        ct state established,related accept
        
        # Allow ICMP
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept
        
        # Allow SSH
        tcp dport 22 accept
        
        # Allow HTTP/HTTPS
        tcp dport { 80, 443 } accept
        
        # Allow DNS
        udp dport 53 accept
        tcp dport 53 accept
        
        # Allow DHCP
        udp dport { 67, 68 } accept
        
        # Log and drop everything else
        log prefix "DIZZYO-DROP: " drop
    }
    
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF
    
    # Enable firewall
    systemctl enable nftables
    
    # Configure ClamAV
    if [[ -d "${INSTALL_ROOT}/usr/bin/clamscan" ]]; then
        systemctl enable clamav-freshclam
        systemctl enable clamav-daemon
    fi
    
    # Configure rkhunter
    if [[ -d "${INSTALL_ROOT}/usr/bin/rkhunter" ]]; then
        rkhunter --update
    fi
    
    success "Security configured!"
}

# Configure performance
configure_performance() {
    info "Configuring performance..."
    
    # Create performance configuration
    mkdir -p "${INSTALL_ROOT}/etc/dizzyo/performance"
    
    # Create sysctl configuration
    cat > "${INSTALL_ROOT}/etc/sysctl.d/99-dizzyo-performance.conf" << 'EOF'
# DizzyoOS Performance Optimizations

# Network optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1

# Memory optimizations
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.vfs_cache_pressure = 50
vm.min_free_kbytes = 65536
vm.zone_reclaim_mode = 0

# Kernel optimizations
kernel.pid_max = 4194304
kernel.threads-max = 4194304
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 8192
EOF
    
    # Create ZRAM configuration
    cat > "${INSTALL_ROOT}/etc/dizzyo/performance/zram.conf" << 'EOF'
# DizzyoOS ZRAM Configuration

# Load ZRAM module
zram

# Set up ZRAM
echo lz4 > /sys/block/zram0/comp_algorithm
echo 4G > /sys/block/zram0/disksize
mkswap /dev/zram0
swapon -p 100 /dev/zram0
EOF
    
    # Create power management configuration
    cat > "${INSTALL_ROOT}/etc/dizzyo/performance/power.conf" << 'EOF'
# DizzyoOS Power Management

# CPU Governor
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo powersave > "$cpu" 2>/dev/null || true
done

# Enable power management
echo 1 > /sys/module/snd_hda_intel/parameters/power_save
echo 1 > /sys/module/snd_hda_intel/parameters/power_save_controller
EOF
    
    success "Performance configured!"
}

# Install DizzyoOS tools
install_tools() {
    info "Installing DizzyoOS tools..."
    
    # Create tools directory
    mkdir -p "${INSTALL_ROOT}/usr/bin"
    mkdir -p "${INSTALL_ROOT}/usr/share/dizzyo"
    
    # Install TUI manager
    cat > "${INSTALL_ROOT}/usr/bin/dizzyo-tui" << 'SCRIPT'
#!/bin/bash
# DizzyoOS TUI Manager launcher
exec /usr/share/dizzyo/dizzyo-tui-manager.sh "$@"
SCRIPT
    chmod +x "${INSTALL_ROOT}/usr/bin/dizzyo-tui"
    
    # Install AI assistant
    cat > "${INSTALL_ROOT}/usr/bin/dizzyo-ai" << 'SCRIPT'
#!/bin/bash
# DizzyoOS AI Assistant launcher
exec /usr/share/dizzyo/dizzyo-ai.sh "$@"
SCRIPT
    chmod +x "${INSTALL_ROOT}/usr/bin/dizzyo-ai"
    
    # Install welcome application
    cat > "${INSTALL_ROOT}/usr/bin/dizzyo-welcome" << 'SCRIPT'
#!/bin/bash
# DizzyoOS Welcome Application
echo "Welcome to DizzyoOS!"
echo "Version: 1.0.0 Genesis"
echo ""
echo "Quick Start:"
echo "  - Run 'dizzyo-tui' for system management"
echo "  - Run 'dizzyo-ai' for AI assistance"
echo "  - Run 'dizzyo-gaming-optimize' for gaming"
echo ""
echo "Documentation: https://wiki.dizzyo-os.org"
SCRIPT
    chmod +x "${INSTALL_ROOT}/usr/bin/dizzyo-welcome"
    
    # Create DizzyoOS branding
    cat > "${INSTALL_ROOT}/usr/share/dizzyo/branding" << 'EOF'
DIZZYO_OS_NAME="DizzyoOS"
DIZZYO_OS_VERSION="1.0.0"
DIZZYO_OS_CODENAME="Genesis"
DIZZYO_OS_WEBSITE="https://dizzyo-os.org"
DIZZYO_OS_WIKI="https://wiki.dizzyo-os.org"
DIZZYO_OS_FORUM="https://forum.dizzyo-os.org"
DIZZYO_OS_GITHUB="https://github.com/dizzyo-os"
EOF
    
    success "DizzyoOS tools installed!"
}

# Main function
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    DizzyoOS Post-Installation          ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    # Parse arguments
    case "${1:-all}" in
        dinit)
            configure_dinit
            ;;
        gaming)
            configure_gaming
            ;;
        security)
            configure_security
            ;;
        performance)
            configure_performance
            ;;
        tools)
            install_tools
            ;;
        all)
            configure_dinit
            configure_gaming
            configure_security
            configure_performance
            install_tools
            ;;
        *)
            echo "Usage: $0 {dinit|gaming|security|performance|tools|all}"
            exit 1
            ;;
    esac
    
    success "Post-installation completed!"
}

# Run main function
main "$@"
