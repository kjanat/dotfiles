#!/bin/bash
# ~/.bashrc - Comprehensive Bash Configuration
# Author: kjanat
# Compatible with: Linux, macOS, FreeBSD, WSL
# Last updated: May 2025

# ============================================================================
# PERFORMANCE OPTIMIZATION
# ============================================================================

# Early exit for non-interactive shells
[[ $- != *i* ]] && return

# Disable terminal flow control (Ctrl-S/Ctrl-Q)
stty -ixon 2>/dev/null

# ============================================================================
# ENVIRONMENT DETECTION
# ============================================================================

# Detect operating system
detect_os() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        case "$ID" in
            debian|ubuntu|linuxmint|pop) echo "debian" ;;
            rhel|fedora|centos|rocky|alma|ol) echo "redhat" ;;
            alpine) echo "alpine" ;;
            arch|manjaro) echo "arch" ;;
            opensuse*|sles) echo "suse" ;;
            *) echo "linux" ;;
        esac
    elif [[ "$(uname)" == "FreeBSD" ]]; then
        echo "freebsd"
    elif [[ "$(uname)" == "OpenBSD" ]]; then
        echo "openbsd"
    elif [[ "$(uname)" == "NetBSD" ]]; then
        echo "netbsd"
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "macos"
    elif [[ -n "$WSL_DISTRO_NAME" ]] || [[ -n "$WSLENV" ]]; then
        echo "wsl"
    else
        echo "unknown"
    fi
}

# Set OS variable
export OS_TYPE="$(detect_os)"

# ============================================================================
# PATH MANAGEMENT
# ============================================================================

# Function to safely add to PATH
add_to_path() {
    local dir="$1"
    [[ -d "$dir" ]] && [[ ":$PATH:" != *":$dir:"* ]] && PATH="$dir:$PATH"
}

# Add common directories to PATH
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/bin"
add_to_path "/usr/local/bin"
add_to_path "/opt/homebrew/bin"  # macOS Homebrew (Apple Silicon)
add_to_path "/usr/local/sbin"
add_to_path "/opt/local/bin"     # MacPorts

export PATH

# ============================================================================
# SHELL OPTIONS
# ============================================================================

# Shell behavior
shopt -s autocd         # Change to directory without cd
shopt -s cdspell        # Correct minor spelling errors in cd
shopt -s dirspell       # Correct directory spelling errors
shopt -s checkwinsize   # Check window size after commands
shopt -s expand_aliases # Expand aliases
shopt -s extglob        # Extended globbing
shopt -s globstar       # ** recursive globbing
shopt -s histappend     # Append to history file
shopt -s no_empty_cmd_completion  # No completion on empty line

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================

# History settings
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:la:cd:pwd:exit:clear:history:bg:fg:jobs"
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

# Save history immediately
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

# Default editor
if command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export VISUAL="nvim"
elif command -v vim >/dev/null 2>&1; then
    export EDITOR="vim"
    export VISUAL="vim"
else
    export EDITOR="nano"
    export VISUAL="nano"
fi

# Pager
export PAGER="less"
export LESS="-R -i -F -X"

# Language and locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Colors for ls and grep
export CLICOLOR=1
export LSCOLORS="ExFxCxDxBxegedabagacad"
export LS_COLORS="di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=1;34;46:cd=1;34;43:su=1;30;41:sg=1;30;46:tw=1;30;42:ow=1;30;43"

# Less colors for man pages
export LESS_TERMCAP_mb=$'\e[1;32m'      # begin bold
export LESS_TERMCAP_md=$'\e[1;32m'      # begin blink
export LESS_TERMCAP_me=$'\e[0m'         # reset bold/blink
export LESS_TERMCAP_so=$'\e[01;33m'     # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'         # reset reverse video
export LESS_TERMCAP_us=$'\e[1;4;31m'    # begin underline
export LESS_TERMCAP_ue=$'\e[0m'         # reset underline

# ============================================================================
# COMPLETION
# ============================================================================

# Enable bash completion
if [[ -f /etc/bash_completion ]]; then
    # shellcheck source=/dev/null
    . /etc/bash_completion
elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
    # shellcheck source=/dev/null
    . /usr/share/bash-completion/bash_completion
elif [[ -f /usr/local/etc/bash_completion ]]; then
    # shellcheck source=/dev/null
    . /usr/local/etc/bash_completion
fi

# Homebrew bash completion (macOS)
if [[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]]; then
    # shellcheck source=/dev/null
    . "/opt/homebrew/etc/profile.d/bash_completion.sh"
fi

# Git completion
for git_completion in \
    /usr/share/bash-completion/completions/git \
    /usr/local/etc/bash_completion.d/git-completion.bash \
    /opt/homebrew/etc/bash_completion.d/git-completion.bash; do
    [[ -f "$git_completion" ]] && . "$git_completion" && break
done

# ============================================================================
# ALIASES
# ============================================================================

# Core aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias c='clear'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# ls aliases with color support
if ls --color=auto >/dev/null 2>&1; then
    # GNU ls
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -A --color=auto'
    alias l='ls -CF --color=auto'
    alias lt='ls -altr --color=auto'
    alias lh='ls -alh --color=auto'
else
    # BSD ls (macOS, FreeBSD)
    alias ls='ls -G'
    alias ll='ls -alFG'
    alias la='ls -AG'
    alias l='ls -CFG'
    alias lt='ls -altrG'
    alias lh='ls -alhG'
fi

# Directory operations
alias md='mkdir -p'
alias rd='rmdir'

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ln='ln -i'

# Search and find
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias rg='rg --color=auto'

# Process management
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias myps='ps -f'
alias jobs='jobs -l'

# Network
alias ping='ping -c 5'
alias fastping='ping -c 100 -s 2'
alias ports='netstat -tulanp'

# Archives
alias tarls="tar -tvf"
alias untar="tar -xf"

# Text processing
alias count='wc -l'
alias head='head -n 20'
alias tail='tail -n 20'

# Git aliases (if git is available)
if command -v git >/dev/null 2>&1; then
    alias g='git'
    alias ga='git add'
    alias gaa='git add --all'
    alias gb='git branch'
    alias gba='git branch -a'
    alias gc='git commit -v'
    alias gcm='git commit -m'
    alias gco='git checkout'
    alias gd='git diff'
    alias gf='git fetch'
    alias gl='git pull'
    alias glog='git log --oneline --decorate --graph'
    alias gp='git push'
    alias gst='git status'
    alias gsta='git stash'
    alias gsw='git switch'
fi

# OS-specific aliases
case "$OS_TYPE" in
    macos)
        alias flush='dscacheutil -flushcache && killall -HUP mDNSResponder'
        alias lscleanup='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder'
        alias ql='qlmanage -p'
        alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
        alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
        ;;
    freebsd)
        alias pkg-update='sudo pkg update && sudo pkg upgrade'
        alias pkg-search='pkg search'
        alias pkg-info='pkg info'
        ;;
    debian)
        alias apt-update='sudo apt update && sudo apt upgrade'
        alias apt-search='apt search'
        alias apt-show='apt show'
        alias install='sudo apt install'
        ;;
    redhat)
        alias yum-update='sudo yum update'
        alias dnf-update='sudo dnf update'
        ;;
    wsl)
        alias open='explorer.exe'
        alias pbcopy='clip.exe'
        ;;
esac

# ============================================================================
# FUNCTIONS
# ============================================================================

# Create directory and change into it
mkcd() {
    mkdir -p "$1" && cd "$1" || return 1
}

# Extract various archive formats
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find file containing text
findtext() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: findtext <search_term> [directory]"
        return 1
    fi
    local search_term="$1"
    local directory="${2:-.}"
    find "$directory" -type f -exec grep -l "$search_term" {} \;
}

# Quick backup function
backup() {
    if [[ -z "$1" ]]; then
        echo "Usage: backup <file>"
        return 1
    fi
    cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"
}

# System information function
sysinfo() {
    echo "🖥️  System Information"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "OS: $(uname -s) $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "User: $(whoami)"
    echo "Shell: $BASH_VERSION"
    echo "Terminal: $TERM"
    echo "Date: $(date)"
    echo "Uptime: $(uptime)"
    echo "Load: $(uptime | awk '{print $NF}')"
    if command -v free >/dev/null 2>&1; then
        echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    fi
}

# Weather function (requires curl)
weather() {
    local location="${1:-$(curl -s ipinfo.io/city 2>/dev/null || echo "New York")}"
    curl -s "wttr.in/$location?format=3" 2>/dev/null || echo "Weather info unavailable"
}

# Port check function
portcheck() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: portcheck <host> <port>"
        return 1
    fi
    local host="$1"
    local port="$2"
    timeout 3 bash -c "</dev/tcp/$host/$port" && echo "Port $port is open on $host" || echo "Port $port is closed on $host"
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    if command -v python3 >/dev/null 2>&1; then
        python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        python -m SimpleHTTPServer "$port"
    else
        echo "Python not found"
        return 1
    fi
}

# ============================================================================
# SERVICE STATUS FUNCTION (from servstat.sh)
# ============================================================================

# Universal Service Status Function for Unix Systems
servstat() {
    local filter=""
    local show_disabled=false
    local show_details=false
    local sort_output=false
    local output_format="table"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        -a | --all)
            show_disabled=true
            shift
            ;;
        -d | --details)
            show_details=true
            shift
            ;;
        -s | --sort)
            sort_output=true
            shift
            ;;
        -j | --json)
            output_format="json"
            shift
            ;;
        -r | --running)
            filter="running"
            shift
            ;;
        -x | --stopped)
            filter="stopped"
            shift
            ;;
        -h | --help)
            echo "Usage: servstat [OPTIONS] [SERVICE_NAME]"
            echo ""
            echo "Options:"
            echo "  -a, --all        Show all services (including disabled)"
            echo "  -d, --details    Show detailed service information"
            echo "  -s, --sort       Sort services alphabetically"
            echo "  -j, --json       Output in JSON format"
            echo "  -r, --running    Show only running services"
            echo "  -x, --stopped    Show only stopped services"
            echo "  -h, --help       Show this help message"
            return 0
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Use 'servstat --help' for usage information"
            return 1
            ;;
        *)
            # Single service query
            _servstat_single_service "$1" "$show_details"
            return $?
            ;;
        esac
    done

    # Main service overview
    _servstat_overview "$filter" "$show_disabled" "$show_details" "$sort_output" "$output_format"
}

# Helper functions for servstat (abbreviated for space)
_detect_system() {
    local os_type=""
    local service_manager=""

    # Detect OS
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        case "$ID" in
        debian | ubuntu | linuxmint | pop) os_type="debian" ;;
        rhel | fedora | centos | rocky | alma | ol) os_type="redhat" ;;
        alpine) os_type="alpine" ;;
        arch | manjaro) os_type="arch" ;;
        opensuse* | sles) os_type="suse" ;;
        freebsd) os_type="freebsd" ;;
        esac
    elif [[ "$(uname)" == "FreeBSD" ]]; then
        os_type="freebsd"
    elif [[ "$(uname)" == "OpenBSD" ]]; then
        os_type="openbsd"
    elif [[ "$(uname)" == "NetBSD" ]]; then
        os_type="netbsd"
    elif [[ "$(uname)" == "Darwin" ]]; then
        os_type="macos"
    else
        os_type="unknown"
    fi

    # Detect service manager
    if command -v systemctl >/dev/null 2>&1 && [[ -d /etc/systemd ]]; then
        service_manager="systemd"
    elif command -v service >/dev/null 2>&1 && [[ "$os_type" =~ ^(freebsd|openbsd|netbsd)$ ]]; then
        service_manager="bsd_rc"
    elif command -v rc-service >/dev/null 2>&1; then
        service_manager="openrc"
    elif command -v launchctl >/dev/null 2>&1 && [[ "$os_type" == "macos" ]]; then
        service_manager="launchd"
    elif [[ -d /etc/init.d ]] && command -v service >/dev/null 2>&1; then
        service_manager="sysv"
    else
        service_manager="unknown"
    fi

    echo "$os_type|$service_manager"
}

_servstat_single_service() {
    local service_name="$1"
    local show_details="$2"
    
    if [[ -z "$service_name" ]]; then
        return 1
    fi

    echo "🔍 Service: $service_name"
    echo "🖥️  System: $OS_TYPE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Basic service status check
    if command -v systemctl >/dev/null 2>&1; then
        systemctl status "$service_name" 2>/dev/null | head -10
    elif command -v service >/dev/null 2>&1; then
        service "$service_name" status 2>/dev/null
    else
        echo "Service management not available on this system"
    fi
}

_servstat_overview() {
    echo "📋 System Services Overview"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if command -v systemctl >/dev/null 2>&1; then
        systemctl list-units --type=service --no-legend --no-pager | head -20
    elif command -v service >/dev/null 2>&1; then
        service -e 2>/dev/null | head -20
    else
        echo "Service management not available on this system"
    fi
}

# ============================================================================
# PROMPT CONFIGURATION
# ============================================================================

# Colors for prompt
if [[ $COLORTERM == gnome-* && $TERM == xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
    export TERM='gnome-256color'
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM='xterm-256color'
fi

# Define colors
if tput setaf 1 &> /dev/null; then
    tput sgr0
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
    BLACK=$(tput setaf 0)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    WHITE=$(tput setaf 7)
else
    BOLD='\033[1m'
    RESET='\033[0m'
    BLACK='\033[0;30m'
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[0;37m'
fi

# Git prompt function
git_prompt() {
    local git_status=""
    local branch=""
    
    if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        
        if [[ -n "$branch" ]]; then
            local status_flags=""
            
            # Check for unstaged changes
            if ! git diff-files --quiet; then
                status_flags+="*"
            fi
            
            # Check for staged changes
            if ! git diff-index --quiet --cached HEAD 2>/dev/null; then
                status_flags+="+"
            fi
            
            # Check for untracked files
            if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]]; then
                status_flags+="?"
            fi
            
            git_status=" ${MAGENTA}git:(${branch}${status_flags})${RESET}"
        fi
    fi
    
    echo "$git_status"
}

# Set prompt
set_prompt() {
    local exit_code=$?
    local prompt_symbol="$"
    local exit_status=""
    
    # Show exit code if non-zero
    if [[ $exit_code -ne 0 ]]; then
        exit_status=" ${RED}[$exit_code]${RESET}"
    fi
    
    # Root user gets # symbol
    if [[ $EUID -eq 0 ]]; then
        prompt_symbol="#"
    fi
    
    # Build prompt
    PS1="${BOLD}${GREEN}\u${RESET}${WHITE}@${RESET}${BOLD}${BLUE}\h${RESET}${WHITE}:${RESET}${BOLD}${YELLOW}\w${RESET}$(git_prompt)${exit_status}\n${BOLD}${prompt_symbol}${RESET} "
}

# Set the prompt command
PROMPT_COMMAND="set_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ============================================================================
# STARTUP ACTIONS
# ============================================================================

# Display welcome message
if [[ $- == *i* ]]; then
    echo -e "${BOLD}${GREEN}Welcome to Bash on $OS_TYPE!${RESET}"
    echo -e "${CYAN}Shell: $BASH_VERSION${RESET}"
    echo -e "${CYAN}Today is: $(date)${RESET}"
    
    # Show system load on login
    if command -v uptime >/dev/null 2>&1; then
        echo -e "${YELLOW}System load: $(uptime | awk '{print $NF}')${RESET}"
    fi
    echo ""
fi

# ============================================================================
# LOCAL CUSTOMIZATIONS
# ============================================================================

# Source local bashrc if it exists
[[ -f ~/.bashrc.local ]] && . ~/.bashrc.local

# Source work-specific configurations
[[ -f ~/.bashrc.work ]] && . ~/.bashrc.work

# ============================================================================
# TOOL INTEGRATIONS
# ============================================================================

# Load SSH agent
if [[ -z "$SSH_AUTH_SOCK" ]] && command -v ssh-agent >/dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null 2>&1
fi

# Load direnv if available
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook bash)"
fi

# Load fzf if available
if [[ -f ~/.fzf.bash ]]; then
    # shellcheck source=/dev/null
    . ~/.fzf.bash
fi

# Load Node Version Manager
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
fi

# Load Ruby Version Manager
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
    # shellcheck source=/dev/null
    . "$HOME/.rvm/scripts/rvm"
fi

# ============================================================================
# END OF BASHRC
# ============================================================================

# vim: ft=bash ts=4 sw=4 et
