# ============================================================================
# USER CUSTOMIZATION TEMPLATE
# ============================================================================
# This template provides examples for user-specific customizations.
# Copy this file to ~/.config/zsh/user/custom.zsh and modify as needed.
#
# File: ~/.config/zsh/user/custom.zsh
# ============================================================================

# ============================================================================
# PERSONAL INFORMATION
# ============================================================================

# Set your personal information (used by some functions and Git)
# export GIT_AUTHOR_NAME="Your Name"
# export GIT_AUTHOR_EMAIL="your.email@example.com"
# export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
# export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

# ============================================================================
# CUSTOM ENVIRONMENT VARIABLES
# ============================================================================

# Set custom paths
# export CUSTOM_TOOLS_PATH="$HOME/tools"
# export PATH="$CUSTOM_TOOLS_PATH/bin:$PATH"

# Set default applications
# export BROWSER="firefox"
# export TERMINAL="alacritty"

# Custom configuration directories
# export MY_CONFIG_DIR="$HOME/.config/myapp"

# ============================================================================
# CUSTOM ALIASES
# ============================================================================

# File and directory operations
# alias ll='ls -alF'
# alias la='ls -A'
# alias l='ls -CF'

# Navigation shortcuts
# alias ..='cd ..'
# alias ...='cd ../..'
# alias ....='cd ../../..'

# Git shortcuts (if not using the git module)
# alias gs='git status'
# alias ga='git add'
# alias gc='git commit'
# alias gp='git push'
# alias gl='git pull'

# Docker shortcuts
# alias d='docker'
# alias dc='docker-compose'
# alias dps='docker ps'
# alias di='docker images'

# Network utilities
# alias myip='curl -s https://ipinfo.io/ip'
# alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# System monitoring
# alias cpu='top -o cpu'
# alias mem='top -o rsize'

# Application shortcuts
# alias code='code-insiders'
# alias v='vim'
# alias nv='nvim'

# ============================================================================
# CUSTOM FUNCTIONS
# ============================================================================

# Example: Quick directory creation and navigation
# mkcd() {
#     mkdir -p "$1" && cd "$1"
# }

# Example: Extract various archive formats
# extract() {
#     if [[ -f "$1" ]]; then
#         case "$1" in
#             *.tar.bz2)   tar xjf "$1"     ;;
#             *.tar.gz)    tar xzf "$1"     ;;
#             *.bz2)       bunzip2 "$1"     ;;
#             *.rar)       unrar x "$1"     ;;
#             *.gz)        gunzip "$1"      ;;
#             *.tar)       tar xf "$1"      ;;
#             *.tbz2)      tar xjf "$1"     ;;
#             *.tgz)       tar xzf "$1"     ;;
#             *.zip)       unzip "$1"       ;;
#             *.Z)         uncompress "$1"  ;;
#             *.7z)        7z x "$1"        ;;
#             *)           echo "'$1' cannot be extracted via extract()" ;;
#         esac
#     else
#         echo "'$1' is not a valid file"
#     fi
# }

# Example: Find and replace in files
# find-replace() {
#     if [[ $# -ne 3 ]]; then
#         echo "Usage: find-replace <directory> <search> <replace>"
#         return 1
#     fi
#
#     local dir="$1"
#     local search="$2"
#     local replace="$3"
#
#     find "$dir" -type f -exec sed -i "s/$search/$replace/g" {} +
# }

# Example: Create a backup of a file
# backup() {
#     if [[ -f "$1" ]]; then
#         cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
#         echo "Backup created: $1.backup-$(date +%Y%m%d-%H%M%S)"
#     else
#         echo "File not found: $1"
#     fi
# }

# Example: Weather function
# weather() {
#     local city="${1:-}"
#     if [[ -n "$city" ]]; then
#         curl -s "wttr.in/$city"
#     else
#         curl -s "wttr.in"
#     fi
# }

# ============================================================================
# DEVELOPMENT SHORTCUTS
# ============================================================================

# Programming language version managers
# if command -v pyenv >/dev/null 2>&1; then
#     eval "$(pyenv init -)"
# fi

# if command -v rbenv >/dev/null 2>&1; then
#     eval "$(rbenv init -)"
# fi

# if command -v nvm >/dev/null 2>&1; then
#     source "$(nvm which nvm)"
# fi

# Project-specific shortcuts
# alias myproject='cd ~/Projects/myproject && code .'
# alias work='cd ~/Work'
# alias personal='cd ~/Personal'

# ============================================================================
# CUSTOM PROMPT MODIFICATIONS
# ============================================================================

# Override prompt colors (if using the prompt module)
# export PROMPT_USER_COLOR="cyan"
# export PROMPT_HOST_COLOR="green"
# export PROMPT_PATH_COLOR="blue"
# export PROMPT_GIT_COLOR="yellow"

# Simple custom prompt (uncomment to override the module prompt)
# PS1="%F{green}%n@%m%f:%F{blue}%~%f$ "

# ============================================================================
# OS-SPECIFIC CUSTOMIZATIONS
# ============================================================================

# macOS specific
# if [[ "$(uname)" == "Darwin" ]]; then
#     # Homebrew customizations
#     export HOMEBREW_NO_ANALYTICS=1
#
#     # macOS aliases
#     alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
#     alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
# fi

# Linux specific
# if [[ "$(uname)" == "Linux" ]]; then
#     # Linux aliases
#     alias open='xdg-open'
#
#     # Package manager shortcuts
#     if command -v apt >/dev/null 2>&1; then
#         alias install='sudo apt install'
#         alias update='sudo apt update && sudo apt upgrade'
#     fi
# fi

# FreeBSD/TrueNAS specific
# if [[ "$(uname)" == "FreeBSD" ]]; then
#     # FreeBSD aliases
#     alias pkg-update='sudo pkg update && sudo pkg upgrade'
#
#     # ZFS shortcuts (if not using the freebsd module)
#     alias zlist='zfs list'
#     alias zsnap='zfs snapshot'
# fi

# ============================================================================
# APPLICATION INTEGRATIONS
# ============================================================================

# Fuzzy finder (fzf) integration
# if command -v fzf >/dev/null 2>&1; then
#     source <(fzf --zsh)
#
#     # Custom fzf options
#     export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
#     export FZF_DEFAULT_COMMAND='find . -type f'
# fi

# Starship prompt (alternative to built-in prompt)
# if command -v starship >/dev/null 2>&1; then
#     eval "$(starship init zsh)"
# fi

# Zoxide (better cd) integration
# if command -v zoxide >/dev/null 2>&1; then
#     eval "$(zoxide init zsh)"
#     alias cd='z'
# fi

# ============================================================================
# CUSTOM COMPLETIONS
# ============================================================================

# Add custom completion directories
# fpath=(~/.local/share/zsh/completions $fpath)

# Custom completion for your tools
# _my_tool() {
#     local state
#     _arguments \
#         '1: :->commands' \
#         '*: :->args'
#
#     case $state in
#         commands)
#             _values 'commands' \
#                 'start[Start the service]' \
#                 'stop[Stop the service]' \
#                 'restart[Restart the service]'
#             ;;
#         args)
#             _files
#             ;;
#     esac
# }
# compdef _my_tool my_tool

# ============================================================================
# STARTUP COMMANDS
# ============================================================================

# Commands to run on shell startup
# echo "Welcome back, $(whoami)!"

# Display system information on startup
# if command -v neofetch >/dev/null 2>&1; then
#     neofetch
# fi

# Check for system updates (uncomment for your OS)
# macOS
# if [[ "$(uname)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
#     if [[ $(brew outdated | wc -l) -gt 0 ]]; then
#         echo "📦 $(brew outdated | wc -l) Homebrew packages can be updated"
#     fi
# fi

# Linux (apt)
# if command -v apt >/dev/null 2>&1; then
#     if [[ $(apt list --upgradable 2>/dev/null | wc -l) -gt 1 ]]; then
#         echo "📦 System packages can be updated (run 'apt update && apt upgrade')"
#     fi
# fi

# ============================================================================
# KEYBOARD SHORTCUTS
# ============================================================================

# Custom key bindings
# bindkey '^H' backward-kill-word                    # Ctrl+H
# bindkey '^[[3;5~' kill-word                       # Ctrl+Delete
# bindkey '^R' history-incremental-search-backward  # Ctrl+R

# Widget functions for custom key bindings
# my_widget() {
#     echo "Custom widget executed!"
#     zle accept-line
# }
# zle -N my_widget
# bindkey '^X^M' my_widget  # Ctrl+X, Ctrl+M

# ============================================================================
# DEBUGGING AND MAINTENANCE
# ============================================================================

# Debug function to show loaded customizations
# debug_custom() {
#     echo "=== Custom Configuration Debug ==="
#     echo "Custom aliases:"
#     alias | grep -v "^_" | head -10
#     echo -e "\nCustom functions:"
#     typeset -f | grep "^[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*(" | head -5
#     echo -e "\nCustom environment variables:"
#     env | grep -E "^(CUSTOM|MY)" | head -5
# }

# Maintenance function
# zsh_maintenance() {
#     echo "🧹 Running ZSH maintenance..."
#
#     # Clean up completion cache
#     rm -f ~/.config/zsh/cache/.zcompdump*
#
#     # Rebuild completions
#     autoload -U compinit && compinit
#
#     echo "✅ ZSH maintenance complete!"
# }

# ============================================================================
# NOTES
# ============================================================================

# This file is loaded last in the module loading sequence, so you can:
# 1. Override any settings from other modules
# 2. Add new functionality
# 3. Customize existing features
# 4. Set machine-specific configurations

# Remember to:
# - Test your changes in a new shell session
# - Use 'ZSH_DEBUG=true' to troubleshoot issues
# - Document your customizations
# - Keep backups of working configurations

# ============================================================================
# END OF CUSTOMIZATION TEMPLATE
# ============================================================================
