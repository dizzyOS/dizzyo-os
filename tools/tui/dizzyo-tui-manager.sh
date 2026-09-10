#!/bin/bash
#
# DizzyoOS TUI Manager
# Terminal User Interface for system management
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Main menu
show_main_menu() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    DizzyoOS TUI Manager               ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    echo -e "${GREEN}1.${NC} System Information"
    echo -e "${GREEN}2.${NC} Process Manager"
    echo -e "${GREEN}3.${NC} Service Manager"
    echo -e "${GREEN}4.${NC} Package Manager"
    echo -e "${GREEN}5.${NC} Disk Analyzer"
    echo -e "${GREEN}6.${NC} Network Monitor"
    echo -e "${GREEN}7.${NC} Security Audit"
    echo -e "${GREEN}8.${NC} Snapshot Manager"
    echo -e "${GREEN}9.${NC} Hardware Info"
    echo -e "${GREEN}10.${NC} Power Manager"
    echo -e "${GREEN}11.${NC} AI Assistant"
    echo -e "${GREEN}0.${NC} Exit"
    echo
    echo -e "${YELLOW}Enter your choice: ${NC}"
}

# System information
show_system_info() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    System Information                   ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    # CPU info
    echo -e "${CYAN}CPU:${NC}"
    grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs
    echo -e "${CYAN}Cores:${NC} $(nproc)"
    echo
    
    # Memory info
    echo -e "${CYAN}Memory:${NC}"
    free -h
    echo
    
    # Disk info
    echo -e "${CYAN}Disk Usage:${NC}"
    df -h /
    echo
    
    # Uptime
    echo -e "${CYAN}Uptime:${NC}"
    uptime -p
    echo
    
    # Load average
    echo -e "${CYAN}Load Average:${NC}"
    cat /proc/loadavg
    echo
    
    read -p "Press Enter to continue..."
}

# Process manager
show_process_manager() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    Process Manager                      ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${CYAN}Top processes by CPU:${NC}"
    ps aux --sort=-%cpu | head -20
    echo
    
    echo -e "${CYAN}Top processes by Memory:${NC}"
    ps aux --sort=-%mem | head -20
    echo
    
    read -p "Press Enter to continue..."
}

# Service manager
show_service_manager() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    Service Manager                      ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${CYAN}Running services:${NC}"
    dinitctl list
    echo
    
    echo -e "${YELLOW}Options:${NC}"
    echo "1. Start a service"
    echo "2. Stop a service"
    echo "3. Restart a service"
    echo "4. View service status"
    echo "5. Back to main menu"
    echo
    
    read -p "Enter your choice: " choice
    
    case $choice in
        1)
            read -p "Enter service name: " service
            sudo dinitctl start "$service"
            ;;
        2)
            read -p "Enter service name: " service
            sudo dinitctl stop "$service"
            ;;
        3)
            read -p "Enter service name: " service
            sudo dinitctl restart "$service"
            ;;
        4)
            read -p "Enter service name: " service
            dinitctl status "$service"
            ;;
        5)
            return
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Package manager
show_package_manager() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    Package Manager                      ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${YELLOW}Options:${NC}"
    echo "1. Update system"
    echo "2. Install package"
    echo "3. Remove package"
    echo "4. Search packages"
    echo "5. View installed packages"
    echo "6. Back to main menu"
    echo
    
    read -p "Enter your choice: " choice
    
    case $choice in
        1)
            sudo pacman -Syu
            ;;
        2)
            read -p "Enter package name: " package
            sudo pacman -S "$package"
            ;;
        3)
            read -p "Enter package name: " package
            sudo pacman -R "$package"
            ;;
        4)
            read -p "Enter search term: " term
            pacman -Ss "$term"
            ;;
        5)
            pacman -Q | less
            ;;
        6)
            return
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Disk analyzer
show_disk_analyzer() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    Disk Analyzer                        ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${CYAN}Disk Usage:${NC}"
    df -h
    echo
    
    echo -e "${CYAN}Largest directories in /:${NC}"
    du -h --max-depth=1 / 2>/dev/null | sort -hr | head -20
    echo
    
    read -p "Press Enter to continue..."
}

# Network monitor
show_network_monitor() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    Network Monitor                      ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${CYAN}Network interfaces:${NC}"
    ip addr
    echo
    
    echo -e "${CYAN}Active connections:${NC}"
    ss -tuln
    echo
    
    read -p "Press Enter to continue..."
}

# Security audit
show_security_audit() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    Security Audit                       ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${CYAN}SUID files:${NC}"
    find / -type f -perm -4000 2>/dev/null | head -20
    echo
    
    echo -e "${CYAN}Failed login attempts:${NC}"
    lastb | head -20
    echo
    
    read -p "Press Enter to continue..."
}

# Snapshot manager
show_snapshot_manager() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    Snapshot Manager                     ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${CYAN}Btrfs snapshots:${NC}"
    sudo btrfs subvolume list /
    echo
    
    echo -e "${YELLOW}Options:${NC}"
    echo "1. Create snapshot"
    echo "2. Delete snapshot"
    echo "3. Back to main menu"
    echo
    
    read -p "Enter your choice: " choice
    
    case $choice in
        1)
            read -p "Enter snapshot name: " name
            sudo btrfs subvolume snapshot / "/snapshots/$name"
            ;;
        2)
            read -p "Enter snapshot name: " name
            sudo btrfs subvolume delete "/snapshots/$name"
            ;;
        3)
            return
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

# Hardware info
show_hardware_info() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    Hardware Info                        ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${CYAN}CPU:${NC}"
    lscpu
    echo
    
    echo -e "${CYAN}Memory:${NC}"
    free -h
    echo
    
    echo -e "${CYAN}PCI devices:${NC}"
    lspci
    echo
    
    read -p "Press Enter to continue..."
}

# Power manager
show_power_manager() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    Power Manager                        ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${CYAN}Battery status:${NC}"
    if [[ -f /sys/class/power_supply/BAT0/status ]]; then
        cat /sys/class/power_supply/BAT0/status
        cat /sys/class/power_supply/BAT0/capacity
    else
        echo "No battery detected"
    fi
    echo
    
    echo -e "${CYAN}CPU frequency:${NC}"
    cat /proc/cpuinfo | grep "cpu MHz" | head -1
    echo
    
    echo -e "${YELLOW}Options:${NC}"
    echo "1. Set performance mode"
    echo "2. Set powersave mode"
    echo "3. Back to main menu"
    echo
    
    read -p "Enter your choice: " choice
    
    case $choice in
        1)
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                echo performance | sudo tee "$cpu" > /dev/null
            done
            echo "Performance mode enabled"
            ;;
        2)
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                echo powersave | sudo tee "$cpu" > /dev/null
            done
            echo "Powersave mode enabled"
            ;;
        3)
            return
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

# AI assistant
show_ai_assistant() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    AI Assistant                         ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
    
    echo -e "${CYAN}Enter your query (or 'help' for commands):${NC}"
    read -r query
    
    /usr/bin/dizzyo-ai "$query"
    
    read -p "Press Enter to continue..."
}

# Main function
main() {
    while true; do
        show_main_menu
        read -p "" choice
        
        case $choice in
            1) show_system_info ;;
            2) show_process_manager ;;
            3) show_service_manager ;;
            4) show_package_manager ;;
            5) show_disk_analyzer ;;
            6) show_network_monitor ;;
            7) show_security_audit ;;
            8) show_snapshot_manager ;;
            9) show_hardware_info ;;
            10) show_power_manager ;;
            11) show_ai_assistant ;;
            0) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid choice"; sleep 1 ;;
        esac
    done
}

# Run main function
main "$@"
