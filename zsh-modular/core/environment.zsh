# ============================================================================
# CORE: ENVIRONMENT SETUP
# ============================================================================
# Basic environment configuration that works across all Unix-like systems.

# Core environment
umask 022                 # Set default permissions to 755 for directories and 644 for files
export LANG=en_US.UTF-8   # Set default locale to UTF-8
export LC_ALL=en_US.UTF-8 # Set all locale categories to UTF-8
export EDITOR=nano        # Set default text editor
export PAGER=less         # Set default pager
export BROWSER=lynx       # Set default web browser

# Enhanced PATH (will be augmented by OS-specific modules)
typeset -U path # Keep PATH entries unique
path=(
    /sbin
    /bin
    /usr/sbin
    /usr/bin
    /usr/local/sbin
    /usr/local/bin
    $HOME/bin
    $HOME/.local/bin
    $path
)

# Less configuration for better viewing
export LESSOPEN="| /usr/bin/lesspipe %s 2>/dev/null"   # Use lesspipe for automatic file type detection
export LESSCLOSE="/usr/bin/lesspipe %s %s 2>/dev/null" # Close lesspipe after viewing
export LESS='-F -g -i -M -R -S -w -X -z-4'             # Less options for better usability
export LESSHISTFILE=-                                  # Disable less history file

# Grep colors
export GREP_COLOR='1;32'           # Set default grep color to bright green
export GREP_OPTIONS='--color=auto' # Enable color output for grep

# Mail configuration
export MAIL="${MAIL:-/var/mail/$USER}"

# Module loaded successfully
[[ "$ZSH_DEBUG" == "true" ]] && echo "🌍 Environment setup loaded"
