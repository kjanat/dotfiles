# ============================================================================
# MACOS SPECIFIC CONFIGURATION
# ============================================================================
# macOS-specific ZSH configuration including Homebrew, macOS system tools,
# and Apple-specific utilities.
#
# This module provides:
# - Homebrew package management
# - macOS system management functions
# - Apple-specific development tools
# - macOS-specific utilities and shortcuts
# ============================================================================

# Only load on macOS systems
[[ "$(uname)" != "Darwin" ]] && return 0

# ============================================================================
# MACOS ENVIRONMENT
# ============================================================================

# Set macOS-specific environment variables
export MACOS_VERSION="$(sw_vers -productVersion 2>/dev/null || echo "unknown")"
export MACOS_BUILD="$(sw_vers -buildVersion 2>/dev/null || echo "unknown")"

# ============================================================================
# HOMEBREW INTEGRATION
# ============================================================================

# Homebrew path detection
HOMEBREW_PATHS=(
    "/opt/homebrew/bin/brew"              # Apple Silicon Macs
    "/usr/local/bin/brew"                 # Intel Macs
    "/home/linuxbrew/.linuxbrew/bin/brew" # Linux brew (just in case)
)

for brew_path in "${HOMEBREW_PATHS[@]}"; do
    if [[ -x "$brew_path" ]]; then
        # Initialize Homebrew environment
        eval "$("$brew_path" shellenv)"
        break
    fi
done

# Homebrew aliases and functions
if command -v brew >/dev/null 2>&1; then
    alias bi='brew install'
    alias br='brew remove'
    alias bu='brew update && brew upgrade'
    alias bs='brew search'
    alias binfo='brew info'
    alias blist='brew list'
    alias bout='brew outdated'
    alias bclean='brew cleanup'
    alias bdoctor='brew doctor'
    alias bservices='brew services list'
    alias bstart='brew services start'
    alias bstop='brew services stop'
    alias brestart='brew services restart'

    # Cask operations
    alias cask='brew install --cask'
    alias cask-remove='brew remove --cask'
    alias cask-list='brew list --cask'
    alias cask-outdated='brew outdated --cask'
    alias cask-upgrade='brew upgrade --cask'

    # Homebrew maintenance function
    brew-maintenance() {
        echo "🍺 Running Homebrew maintenance..."
        brew update
        brew upgrade
        brew cleanup
        brew doctor
        echo "✅ Homebrew maintenance complete!"
    }
fi

# ============================================================================
# MACOS SYSTEM MANAGEMENT
# ============================================================================

# System information
sysinfo() {
    echo "=== macOS System Information ==="
    echo "Version: $MACOS_VERSION (Build: $MACOS_BUILD)"
    echo "Hardware: $(sysctl -n hw.model 2>/dev/null || echo "unknown")"
    echo "Architecture: $(uname -m)"

    if command -v system_profiler >/dev/null 2>&1; then
        echo -e "\n=== Hardware Overview ==="
        system_profiler SPHardwareDataType | grep -E "(Chip|Memory|Serial Number)"
    fi

    echo -e "\n=== Memory Usage ==="
    vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+):\s+(\d+)/ and printf("%-16s % 16.2f MB\n", "$1:", $2 * $size / 1048576);'

    echo -e "\n=== Disk Usage ==="
    df -h | grep -E '^/dev/'
}

# macOS-specific aliases
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
alias showdesktop='defaults write com.apple.finder CreateDesktop true; killall Finder'
alias hidedesktop='defaults write com.apple.finder CreateDesktop false; killall Finder'
alias spotlight-off='sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist'
alias spotlight-on='sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist'

# Quick Look aliases
alias ql='qlmanage -p'
alias quicklook='qlmanage -p'

# ============================================================================
# MACOS DEVELOPMENT TOOLS
# ============================================================================

# Xcode and development tools
if command -v xcode-select >/dev/null 2>&1; then
    alias xcode-path='xcode-select -p'
    alias xcode-install='xcode-select --install'

    # Function to switch Xcode versions
    xcode-switch() {
        if [[ -z "$1" ]]; then
            echo "Usage: xcode-switch <path-to-xcode>"
            echo "Example: xcode-switch /Applications/Xcode.app"
            return 1
        fi
        sudo xcode-select -s "$1"
        echo "Switched to Xcode at: $1"
    }
fi

# iOS Simulator
if [[ -d "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" ]]; then
    alias simulator='open -a Simulator'
fi

# ============================================================================
# MACOS PACKAGE MANAGERS
# ============================================================================

# MacPorts (if installed)
if command -v port >/dev/null 2>&1; then
    alias port-install='sudo port install'
    alias port-update='sudo port selfupdate && sudo port upgrade outdated'
    alias port-search='port search'
    alias port-info='port info'
    alias port-list='port installed'
    alias port-clean='sudo port clean --all installed'
fi

# ============================================================================
# MACOS UTILITIES
# ============================================================================

# File operations
alias cpwd='pwd | pbcopy' # Copy current directory to clipboard
alias copy='pbcopy'       # Copy to clipboard
alias paste='pbpaste'     # Paste from clipboard

# Network utilities
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias localip='ipconfig getifaddr en0'
alias publicip='curl -s https://checkip.amazonaws.com'

# System maintenance
alias cleanup='sudo rm -rf /private/var/log/asl/*.asl; sudo rm -rf /private/var/tmp/*; sudo rm -rf ~/Library/Caches/*'
alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl'

# Application management
alias killall-dock='killall Dock'
alias killall-finder='killall Finder'
alias killall-safari='killall Safari'
alias restart-audio='sudo killall coreaudiod'

# ============================================================================
# MACOS SERVICES AND LAUNCHD
# ============================================================================

# LaunchAgent/LaunchDaemon management
alias launchctl-list='launchctl list'
alias launchctl-user='launchctl list | grep -v com.apple'

# Function to manage launch agents
launchctl-toggle() {
    local service="$1"
    local action="$2"

    if [[ -z "$service" || -z "$action" ]]; then
        echo "Usage: launchctl-toggle <service> <load|unload>"
        return 1
    fi

    case "$action" in
    load)
        launchctl load -w "$service"
        echo "Loaded: $service"
        ;;
    unload)
        launchctl unload -w "$service"
        echo "Unloaded: $service"
        ;;
    *)
        echo "Action must be 'load' or 'unload'"
        return 1
        ;;
    esac
}

# ============================================================================
# MACOS SECURITY AND PRIVACY
# ============================================================================

# Keychain utilities
alias keychain-list='security list-keychains'
alias keychain-info='security show-keychain-info'

# Privacy and security
alias gatekeeper-status='spctl --status'
alias gatekeeper-enable='sudo spctl --master-enable'
alias gatekeeper-disable='sudo spctl --master-disable'

# SIP (System Integrity Protection) status
alias sip-status='csrutil status'

# ============================================================================
# MACOS HARDWARE UTILITIES
# ============================================================================

# Battery information (for laptops)
if command -v pmset >/dev/null 2>&1; then
    alias battery='pmset -g batt'
    alias energy='pmset -g'
    alias sleep-info='pmset -g assertions'

    # Caffeine-like function to prevent sleep
    caffeinate-session() {
        local duration="${1:-3600}" # Default 1 hour
        echo "☕ Preventing sleep for $duration seconds..."
        caffeinate -d -t "$duration"
    }
fi

# Temperature monitoring (if available)
if command -v powermetrics >/dev/null 2>&1; then
    alias temp='sudo powermetrics --samplers smc -n 1 -i 1 | grep -i temp'
fi

# ============================================================================
# MACOS APPLICATION SHORTCUTS
# ============================================================================

# Common applications
alias safari='open -a Safari'
alias chrome='open -a "Google Chrome"'
alias firefox='open -a Firefox'
alias vscode='open -a "Visual Studio Code"'
alias finder='open -a Finder'
alias terminal='open -a Terminal'
alias textedit='open -a TextEdit'
alias preview='open -a Preview'

# Function to open current directory in Finder
finder-here() {
    open -a Finder "${1:-.}"
}

# Function to open current directory in VS Code
code-here() {
    code "${1:-.}"
}

# ============================================================================
# MACOS FILE SYSTEM
# ============================================================================

# Extended attributes
alias xattr-list='xattr -l'
alias xattr-clear='xattr -c'
alias xattr-remove='xattr -d'

# HFS+ specific
alias hfs-check='diskutil verifyVolume'
alias hfs-repair='diskutil repairVolume'

# APFS specific
if command -v diskutil >/dev/null 2>&1; then
    alias apfs-list='diskutil apfs list'
    alias apfs-info='diskutil info'
fi

# ============================================================================
# MACOS NETWORK CONFIGURATION
# ============================================================================

# Network interface management
alias wifi-scan='airport -s'
alias wifi-info='airport -I'
alias wifi-cycle='networksetup -setairportpower en0 off && sleep 2 && networksetup -setairportpower en0 on'

# DNS configuration
alias dns-get='networksetup -getdnsservers Wi-Fi'
alias dns-flush='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

# ============================================================================
# MACOS DEFAULTS AND PREFERENCES
# ============================================================================

# Function to backup and modify system defaults
macos-defaults() {
    local action="$1"

    case "$action" in
    backup)
        defaults read >~/Desktop/macos-defaults-backup-$(date +%Y%m%d-%H%M%S).plist
        echo "✅ Defaults backed up to Desktop"
        ;;
    restore)
        local backup_file="$2"
        if [[ -f "$backup_file" ]]; then
            defaults import "$backup_file"
            echo "✅ Defaults restored from $backup_file"
        else
            echo "❌ Backup file not found: $backup_file"
        fi
        ;;
    *)
        echo "Usage: macos-defaults <backup|restore> [backup-file]"
        ;;
    esac
}

# ============================================================================
# MACOS COMPLETION ENHANCEMENTS
# ============================================================================

# Add macOS-specific completions
if [[ -d /usr/local/share/zsh-completions ]]; then
    fpath=(/usr/local/share/zsh-completions $fpath)
fi

if [[ -d /opt/homebrew/share/zsh-completions ]]; then
    fpath=(/opt/homebrew/share/zsh-completions $fpath)
fi

# ============================================================================
# MACOS INITIALIZATION
# ============================================================================

# Display macOS-specific information on startup
if [[ "$ZSH_DEBUG" == "true" ]]; then
    echo "🍎 macOS configuration loaded"
    echo "   Version: $MACOS_VERSION ($MACOS_BUILD)"
    echo "   Hardware: $(sysctl -n hw.model 2>/dev/null || echo "unknown")"
    echo "   Homebrew: $(command -v brew >/dev/null 2>&1 && echo "✅" || echo "❌")"
fi
