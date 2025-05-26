# ============================================================================
# CORE: TERMINAL COMPATIBILITY FIXES
# ============================================================================
# Fixes for various terminal compatibility issues, especially paste mode.

# Fix bracketed paste mode issues (prevents ~, 201~ etc. when pasting)
# This comprehensive fix addresses terminal paste mode issues that can cause
# unwanted characters like ~ or 201~ to appear when pasting via right-click

# 1. Disable ZSH bracketed paste variables
unset zle_bracketed_paste 2>/dev/null
unset BRACKETED_PASTE 2>/dev/null

# 2. Disable terminal bracketed paste mode entirely
printf '\e[?2004l' 2>/dev/null

# 3. Set ZSH options to handle paste properly
setopt NO_BEEP              # Disable beep on paste errors
setopt IGNORE_EOF           # Don't exit on Ctrl+D during paste
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell

# 4. Configure ZSH line editor to handle paste better
if [[ -n "$ZLE_VERSION" ]]; then
    # Disable bracketed paste in ZLE
    zstyle ':bracketed-paste-magic' active-widgets '.false.'
    # Handle paste as regular input
    zstyle ':completion:*' menu select=0
fi

# 5. Additional terminal compatibility settings
stty -ixon 2>/dev/null # Disable XON/XOFF flow control
# DO NOT DISABLE CTRL+Z (susp) or CTRL+C (intr) for proper keyboard functionality

# 6. Function to force disable bracketed paste
disable_bracketed_paste() {
    printf '\e[?2004l' 2>/dev/null
    # Restore default terminal control behavior
    stty intr '^C' 2>/dev/null # Restore Ctrl+C functionality
    stty susp '^Z' 2>/dev/null # Restore Ctrl+Z functionality
    stty eof '^D' 2>/dev/null  # Restore Ctrl+D functionality
}

# 7. Ensure paste mode stays disabled but preserve keyboard functionality
trap disable_bracketed_paste EXIT
# Don't trap INT (Ctrl+C) or it will break keyboard functionality
trap disable_bracketed_paste TERM

# 8. Re-disable on prompt display (for persistent terminals)
precmd_disable_paste() {
    printf '\e[?2004l' 2>/dev/null
    # Make sure terminal keyboard controls are properly restored
    stty intr '^C' 2>/dev/null # Ensure Ctrl+C works
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd precmd_disable_paste

# Terminal initialization function - Ensures keyboard shortcuts work properly
init_terminal() {
    # Reset terminal control settings
    stty sane 2>/dev/null

    # Ensure critical keyboard shortcuts work
    stty intr '^C' 2>/dev/null  # Ctrl+C for interrupt
    stty susp '^Z' 2>/dev/null  # Ctrl+Z for suspend
    stty eof '^D' 2>/dev/null   # Ctrl+D for EOF
    stty start '^Q' 2>/dev/null # Ctrl+Q for XON
    stty stop '^S' 2>/dev/null  # Ctrl+S for XOFF

    # Disable bracketed paste mode
    printf '\e[?2004l' 2>/dev/null

    # Ensure proper text display
    printf '\e[0m' 2>/dev/null # Reset text attributes

    # Set UTF-8 support (if terminal supports it)
    printf '\e%%G' 2>/dev/null
}

# Run terminal initialization
init_terminal

# Module loaded successfully
[[ "$ZSH_DEBUG" == "true" ]] && echo "🖥️  Terminal fixes loaded"
