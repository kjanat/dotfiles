# ============================================================================
# CORE: PERFORMANCE OPTIMIZATIONS
# ============================================================================
# This module contains performance optimizations for ZSH startup and runtime.
# It should be loaded first to ensure optimal performance.

# Skip global compinit for faster startup
skip_global_compinit=1

# Optimize completion loading
autoload -Uz compinit

# Simple completion check - rebuild daily or if missing
zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -f "$zcompdump" ]] || [[ $(find "$zcompdump" -mtime +1 2>/dev/null | wc -l) -gt 0 ]]; then
    compinit
else
    compinit -C
fi

# Track command execution time for slow commands
preexec() {
    timer=${timer:-$SECONDS}
}

precmd_performance() {
    if [ "$timer" ]; then
        timer_show=$(($SECONDS - $timer))
        if [[ $timer_show -gt 3 ]]; then
            echo "⏱️  Command took ${timer_show}s"
        fi
        unset timer
    fi
}

# Add to precmd hooks
autoload -Uz add-zsh-hook
add-zsh-hook precmd precmd_performance

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR:-$HOME/.zsh/cache}"

# Rehash automatically for new commands
zstyle ':completion:*' rehash true

# Reduce escape sequence timeout
export KEYTIMEOUT=1

# Optimize for SSD
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Module loaded successfully
[[ "$ZSH_DEBUG" == "true" ]] && echo "⚡ Performance optimizations loaded"
