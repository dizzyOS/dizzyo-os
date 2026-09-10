#!/bin/bash
# DizzyoOS AI Assistant Service

# Create the AI assistant service
cat > /etc/dinit.d/dizzyo-ai << 'EOF'
type = process
description = "DizzyoOS AI Assistant"
command = /usr/bin/dizzyo-ai
restart = true
restart_delay = 10
EOF

# Create the AI assistant wrapper script
cat > /usr/bin/dizzyo-ai << 'SCRIPT'
#!/bin/bash
#
# DizzyoOS AI Assistant
# Provides system management via natural language
#

set -euo pipefail

# Configuration
AI_CONFIG_DIR="${HOME}/.config/dizzyo-ai"
AI_LOG_FILE="${AI_CONFIG_DIR}/ai.log"
AI_CACHE_DIR="${AI_CONFIG_DIR}/cache"

# Create directories
mkdir -p "${AI_CONFIG_DIR}" "${AI_CACHE_DIR}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${AI_LOG_FILE}"
}

info() {
    echo -e "${BLUE}[AI]${NC} $1"
}

success() {
    echo -e "${GREEN}[AI]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[AI]${NC} $1"
}

error() {
    echo -e "${RED}[AI]${NC} $1"
}

# System information gathering
get_system_info() {
    local info=""
    
    # CPU info
    info+="CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)\n"
    info+="Cores: $(nproc)\n"
    
    # Memory info
    local mem_total=$(free -h | grep Mem | awk '{print $2}')
    local mem_used=$(free -h | grep Mem | awk '{print $3}')
    info+="Memory: ${mem_used}/${mem_total}\n"
    
    # Disk info
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}')
    info+="Disk Usage: ${disk_usage}\n"
    
    # Uptime
    info+="Uptime: $(uptime -p)\n"
    
    # Load average
    info+="Load: $(cat /proc/loadavg)\n"
    
    echo -e "${info}"
}

# Process analysis
analyze_processes() {
    local query="${1:-}"
    
    if [[ -z "${query}" ]]; then
        ps aux --sort=-%cpu | head -20
    else
        ps aux | grep "${query}" | grep -v grep
    fi
}

# Service management
manage_service() {
    local action="${1:-}"
    local service="${2:-}"
    
    case "${action}" in
        start)
            sudo dinitctl start "${service}"
            ;;
        stop)
            sudo dinitctl stop "${service}"
            ;;
        restart)
            sudo dinitctl restart "${service}"
            ;;
        status)
            dinitctl status "${service}"
            ;;
        list)
            dinitctl list
            ;;
        *)
            echo "Usage: dizzyo-ai service {start|stop|restart|status|list} [service]"
            ;;
    esac
}

# Package management
manage_packages() {
    local action="${1:-}"
    local package="${2:-}"
    
    case "${action}" in
        install)
            sudo pacman -S --noconfirm "${package}"
            ;;
        remove)
            sudo pacman -R --noconfirm "${package}"
            ;;
        update)
            sudo pacman -Syu --noconfirm
            ;;
        search)
            pacman -Ss "${package}"
            ;;
        info)
            pacman -Si "${package}"
            ;;
        list)
            pacman -Q
            ;;
        *)
            echo "Usage: dizzyo-ai pkg {install|remove|update|search|info|list} [package]"
            ;;
    esac
}

# System cleanup
cleanup_system() {
    info "Cleaning system..."
    
    # Clean pacman cache
    sudo pacman -Sc --noconfirm
    
    # Clean package cache
    sudo pacman -Scc --noconfirm
    
    # Clean journal logs
    sudo journalctl --vacuum-time=7d
    
    # Clean tmp
    sudo find /tmp -type f -atime +7 -delete
    
    success "System cleaned!"
}

# Performance optimization
optimize_performance() {
    info "Optimizing system performance..."
    
    # Enable ZRAM
    sudo modprobe zram
    echo lz4 | sudo tee /sys/block/zram0/comp_algorithm
    sudo mkswap /dev/zram0
    sudo swapon -p 100 /dev/zram0
    
    # Set CPU governor
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance | sudo tee "${cpu}" > /dev/null
    done
    
    # Optimize network
    sudo sysctl -w net.core.rmem_max=16777216
    sudo sysctl -w net.core.wmem_max=16777216
    
    success "Performance optimized!"
}

# Security audit
security_audit() {
    info "Running security audit..."
    
    # Check for SUID files
    echo "SUID files:"
    find / -type f -perm -4000 2>/dev/null | head -20
    
    # Check for world-writable files
    echo -e "\nWorld-writable files:"
    find / -type f -perm -0002 2>/dev/null | head -20
    
    # Check for failed login attempts
    echo -e "\nFailed login attempts:"
    lastb | head -20
    
    # Check open ports
    echo -e "\nOpen ports:"
    ss -tuln
    
    success "Security audit completed!"
}

# Main AI processing function
process_query() {
    local query="${1:-}"
    
    # Convert to lowercase for easier matching
    query_lower=$(echo "${query}" | tr '[:upper:]' '[:lower:]')
    
    # System info queries
    if [[ "${query_lower}" == *"system info"* ]] || [[ "${query_lower}" == *"system status"* ]]; then
        get_system_info
        return
    fi
    
    # Process queries
    if [[ "${query_lower}" == *"process"* ]] || [[ "${query_lower}" == *"running"* ]]; then
        analyze_processes
        return
    fi
    
    # Service management
    if [[ "${query_lower}" == *"service"* ]]; then
        local action=""
        local service=""
        
        if [[ "${query_lower}" == *"start"* ]]; then
            action="start"
            service=$(echo "${query}" | grep -oP 'service \K\S+')
        elif [[ "${query_lower}" == *"stop"* ]]; then
            action="stop"
            service=$(echo "${query}" | grep -oP 'service \K\S+')
        elif [[ "${query_lower}" == *"restart"* ]]; then
            action="restart"
            service=$(echo "${query}" | grep -oP 'service \K\S+')
        elif [[ "${query_lower}" == *"status"* ]]; then
            action="status"
            service=$(echo "${query}" | grep -oP 'service \K\S+')
        elif [[ "${query_lower}" == *"list"* ]]; then
            action="list"
        fi
        
        manage_service "${action}" "${service}"
        return
    fi
    
    # Package management
    if [[ "${query_lower}" == *"install"* ]] || [[ "${query_lower}" == *"package"* ]]; then
        local action=""
        local package=""
        
        if [[ "${query_lower}" == *"install"* ]]; then
            action="install"
            package=$(echo "${query}" | grep -oP '(install|package) \K\S+')
        elif [[ "${query_lower}" == *"remove"* ]] || [[ "${query_lower}" == *"uninstall"* ]]; then
            action="remove"
            package=$(echo "${query}" | grep -oP '(remove|uninstall) \K\S+')
        elif [[ "${query_lower}" == *"update"* ]]; then
            action="update"
        elif [[ "${query_lower}" == *"search"* ]]; then
            action="search"
            package=$(echo "${query}" | grep -oP 'search \K\S+')
        fi
        
        manage_packages "${action}" "${package}"
        return
    fi
    
    # System cleanup
    if [[ "${query_lower}" == *"clean"* ]] || [[ "${query_lower}" == *"cleanup"* ]]; then
        cleanup_system
        return
    fi
    
    # Performance optimization
    if [[ "${query_lower}" == *"optimize"* ]] || [[ "${query_lower}" == *"performance"* ]]; then
        optimize_performance
        return
    fi
    
    # Security audit
    if [[ "${query_lower}" == *"security"* ]] || [[ "${query_lower}" == *"audit"* ]]; then
        security_audit
        return
    fi
    
    # Help
    if [[ "${query_lower}" == *"help"* ]] || [[ "${query_lower}" == *"?"* ]]; then
        echo "DizzyoOS AI Assistant Commands:"
        echo "  system info          - Show system information"
        echo "  process              - Show running processes"
        echo "  service start <name> - Start a service"
        echo "  service stop <name>  - Stop a service"
        echo "  service restart <name> - Restart a service"
        echo "  service status <name> - Show service status"
        echo "  service list         - List all services"
        echo "  install <package>    - Install a package"
        echo "  remove <package>     - Remove a package"
        echo "  update               - Update system"
        echo "  search <package>     - Search for a package"
        echo "  clean                - Clean system"
        echo "  optimize             - Optimize performance"
        echo "  security             - Run security audit"
        echo "  help                 - Show this help"
        return
    fi
    
    # Default response
    echo "I don't understand that command. Type 'help' for available commands."
}

# Main function
main() {
    if [[ $# -eq 0 ]]; then
        echo "DizzyoOS AI Assistant"
        echo "Type 'help' for available commands"
        echo "Query: "
        read -r query
        process_query "${query}"
    else
        process_query "$*"
    fi
}

# Run main function
main "$@"
SCRIPT

chmod +x /usr/bin/dizzyo-ai

echo "DizzyoOS AI Assistant installed successfully!"
