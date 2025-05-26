# ============================================================================
# LINUX SPECIFIC CONFIGURATION
# ============================================================================
# Linux-specific ZSH configuration including package managers, desktop
# environments, and Linux-specific utilities.
#
# This module provides:
# - Package manager aliases (apt, yum, dnf, pacman, etc.)
# - Linux system management functions
# - Desktop environment specific configurations
# - Linux-specific tools and utilities
# ============================================================================

# Only load on Linux systems
[[ "$(uname)" != "Linux" ]] && return 0

# ============================================================================
# LINUX ENVIRONMENT
# ============================================================================

# Set Linux-specific environment variables
export LINUX_DISTRO=""
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    export LINUX_DISTRO="$ID"
fi

# ============================================================================
# PACKAGE MANAGER DETECTION AND ALIASES
# ============================================================================

# Detect package manager
detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    elif command -v apk >/dev/null 2>&1; then
        echo "apk"
    else
        echo "unknown"
    fi
}

PKG_MANAGER="$(detect_package_manager)"

# Universal package management aliases
case "$PKG_MANAGER" in
apt)
    alias install='sudo apt install'
    alias update='sudo apt update && sudo apt upgrade'
    alias search='apt search'
    alias remove='sudo apt remove'
    alias purge='sudo apt purge'
    alias autoremove='sudo apt autoremove'
    alias show='apt show'
    alias list-installed='apt list --installed'
    ;;
yum)
    alias install='sudo yum install'
    alias update='sudo yum update'
    alias search='yum search'
    alias remove='sudo yum remove'
    alias show='yum info'
    alias list-installed='yum list installed'
    ;;
dnf)
    alias install='sudo dnf install'
    alias update='sudo dnf update'
    alias search='dnf search'
    alias remove='sudo dnf remove'
    alias show='dnf info'
    alias list-installed='dnf list installed'
    ;;
pacman)
    alias install='sudo pacman -S'
    alias update='sudo pacman -Syu'
    alias search='pacman -Ss'
    alias remove='sudo pacman -R'
    alias show='pacman -Si'
    alias list-installed='pacman -Q'
    ;;
zypper)
    alias install='sudo zypper install'
    alias update='sudo zypper update'
    alias search='zypper search'
    alias remove='sudo zypper remove'
    alias show='zypper info'
    ;;
apk)
    alias install='sudo apk add'
    alias update='sudo apk update && sudo apk upgrade'
    alias search='apk search'
    alias remove='sudo apk del'
    alias show='apk info'
    ;;
esac

# ============================================================================
# LINUX SYSTEM MANAGEMENT FUNCTIONS
# ============================================================================

# System information
sysinfo() {
    echo "=== Linux System Information ==="
    echo "Distribution: $LINUX_DISTRO"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Package Manager: $PKG_MANAGER"

    if command -v free >/dev/null 2>&1; then
        echo -e "\n=== Memory Usage ==="
        free -h
    fi

    if command -v df >/dev/null 2>&1; then
        echo -e "\n=== Disk Usage ==="
        df -h | grep -E '^/dev/'
    fi

    if command -v lscpu >/dev/null 2>&1; then
        echo -e "\n=== CPU Information ==="
        lscpu | grep -E '^(Architecture|CPU\(s\)|Model name|CPU MHz)'
    fi
}

# Service management (systemd)
if command -v systemctl >/dev/null 2>&1; then
    alias start='sudo systemctl start'
    alias stop='sudo systemctl stop'
    alias restart='sudo systemctl restart'
    alias status='systemctl status'
    alias enable='sudo systemctl enable'
    alias disable='sudo systemctl disable'
    alias reload='sudo systemctl reload'
    alias list-services='systemctl list-unit-files --type=service'
    alias failed='systemctl --failed'
fi

# Process management
alias psg='ps aux | grep -v grep | grep -i -E'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Network management
if command -v ip >/dev/null 2>&1; then
    alias ipa='ip addr show'
    alias ipr='ip route show'
fi

if command -v ss >/dev/null 2>&1; then
    alias ports='ss -tuln'
    alias connections='ss -tupln'
fi

# ============================================================================
# DESKTOP ENVIRONMENT INTEGRATION
# ============================================================================

# GNOME specific
if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" ]]; then
    alias gnome-settings='gnome-control-center'
    alias gnome-extensions='gnome-shell-extension-prefs'
fi

# KDE specific
if [[ "$XDG_CURRENT_DESKTOP" == "KDE" ]]; then
    alias kde-settings='systemsettings5'
fi

# XFCE specific
if [[ "$XDG_CURRENT_DESKTOP" == "XFCE" ]]; then
    alias xfce-settings='xfce4-settings-manager'
fi

# ============================================================================
# LINUX-SPECIFIC UTILITIES
# ============================================================================

# File system utilities
if command -v lsblk >/dev/null 2>&1; then
    alias disks='lsblk'
    alias drives='lsblk -f'
fi

if command -v findmnt >/dev/null 2>&1; then
    alias mounts='findmnt'
fi

# Hardware information
if command -v lshw >/dev/null 2>&1; then
    alias hardware='sudo lshw -short'
fi

if command -v lsusb >/dev/null 2>&1; then
    alias usb='lsusb'
fi

if command -v lspci >/dev/null 2>&1; then
    alias pci='lspci'
fi

# Log viewing
if command -v journalctl >/dev/null 2>&1; then
    alias logs='sudo journalctl -xe'
    alias logs-follow='sudo journalctl -f'
    alias logs-boot='sudo journalctl -b'
fi

# Performance monitoring
if command -v htop >/dev/null 2>&1; then
    alias top='htop'
fi

if command -v iotop >/dev/null 2>&1; then
    alias iotop='sudo iotop'
fi

# ============================================================================
# LINUX DEVELOPMENT TOOLS
# ============================================================================

# Build tools
if command -v make >/dev/null 2>&1; then
    alias make-clean='make clean'
    alias make-install='sudo make install'
fi

# Docker (if available)
if command -v docker >/dev/null 2>&1; then
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dex='docker exec -it'
    alias dlogs='docker logs'
    alias dstop='docker stop $(docker ps -q)'
    alias drm='docker rm $(docker ps -aq)'
    alias drmi='docker rmi $(docker images -q)'
fi

# ============================================================================
# LINUX SECURITY UTILITIES
# ============================================================================

# Firewall management (ufw)
if command -v ufw >/dev/null 2>&1; then
    alias fw-status='sudo ufw status'
    alias fw-enable='sudo ufw enable'
    alias fw-disable='sudo ufw disable'
fi

# SELinux (if available)
if command -v getenforce >/dev/null 2>&1; then
    alias selinux-status='getenforce'
    alias selinux-permissive='sudo setenforce 0'
    alias selinux-enforcing='sudo setenforce 1'
fi

# ============================================================================
# DISTRO-SPECIFIC CONFIGURATIONS
# ============================================================================

case "$LINUX_DISTRO" in
ubuntu | debian)
    # Ubuntu/Debian specific
    alias apt-update='sudo apt update && sudo apt upgrade'
    alias apt-clean='sudo apt autoremove && sudo apt autoclean'
    ;;
fedora | rhel | centos)
    # Red Hat family specific
    if command -v dnf >/dev/null 2>&1; then
        alias dnf-update='sudo dnf update'
        alias dnf-clean='sudo dnf autoremove'
    fi
    ;;
arch | manjaro)
    # Arch family specific
    alias pac-update='sudo pacman -Syu'
    alias pac-clean='sudo pacman -Rns $(pacman -Qtdq)'
    if command -v yay >/dev/null 2>&1; then
        alias yay-update='yay -Syu'
    fi
    ;;
esac

# ============================================================================
# LINUX COMPLETION ENHANCEMENTS
# ============================================================================

# Add Linux-specific completions
if [[ -d /usr/share/bash-completion/completions ]]; then
    for completion in /usr/share/bash-completion/completions/*; do
        [[ -f "$completion" ]] && source "$completion" 2>/dev/null
    done
fi

# ============================================================================
# LINUX INITIALIZATION
# ============================================================================

# Display Linux-specific information on startup
if [[ "$ZSH_DEBUG" == "true" ]]; then
    echo "📧 Linux configuration loaded"
    echo "   Distribution: $LINUX_DISTRO"
    echo "   Package Manager: $PKG_MANAGER"
    echo "   Desktop: ${XDG_CURRENT_DESKTOP:-None}"
fi
