# Ultimate TrueNAS ZSH Configuration
# Place this in ~/.zshrc

# ============================================================================
# ALIASES & SHORTCUTS
# ============================================================================

# Your original aliases
alias h='history 25'
alias j='jobs -l'
alias c='clear' 
alias la='ls -aF --color=auto'
alias lf='ls -FA --color=auto'
alias ll='ls -lAF --color=auto'
alias freenas_dir='cd /mnt/PoolONE/FreeNAS'

# Enhanced ls aliases
alias l='ls -CF --color=auto'
alias lr='ls -R --color=auto'                    # recursive ls
alias lt='ls -ltrh --color=auto'                 # sort by date
alias lk='ls -lSrh --color=auto'                 # sort by size
alias lx='ls -lXBh --color=auto'                 # sort by extension
alias lc='ls -ltcrh --color=auto'                # sort by change time
alias lu='ls -lturh --color=auto'                # sort by access time

# Navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'                                # previous directory

# System aliases
alias df='df -h'                                 # human-readable sizes
alias du='du -h'                                 # human-readable sizes
alias free='free -h'                            # human-readable memory
alias ps='ps auxf'                              # full process list
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'  # search processes
alias mkdir='mkdir -pv'                         # create parent dirs
alias wget='wget -c'                            # continue downloads
alias histg='history | grep'                    # search history
alias myip="curl -s checkip.dyndns.org | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'"

# TrueNAS specific aliases
alias pools='zpool list'                        # list ZFS pools
alias datasets='zfs list'                       # list ZFS datasets
alias snapshots='zfs list -t snapshot'          # list snapshots
alias services='service -e'                     # list enabled services
alias jails='jls'                              # list jails
alias plugins='iocage list'                     # list plugins
alias logs='tail -f /var/log/messages'          # tail system logs
alias space='zpool list -o name,size,allocated,free,capacity,health'

# Safety aliases
alias rm='rm -i'                                # confirm removal
alias cp='cp -i'                                # confirm copy
alias mv='mv -i'                                # confirm move
alias ln='ln -i'                                # confirm link

# Quick editing
alias zshrc='$EDITOR ~/.zshrc && source ~/.zshrc'
alias vimrc='$EDITOR ~/.vimrc'
alias hosts='$EDITOR /etc/hosts'

# ============================================================================
# ENVIRONMENT SETUP
# ============================================================================

# A righteous umask
umask 022

# Path setup
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$HOME/bin:$HOME/.local/bin

# Environment variables
export EDITOR=nano
export PAGER=less
export IGNORE_OSVERSION=yes
export LESSOPEN="| /usr/bin/lesspipe %s"
export LESSCLOSE="/usr/bin/lesspipe %s %s"
export LESS='-F -g -i -M -R -S -w -X -z-4'
export GREP_COLOR='1;32'

# ============================================================================
# ZSH CONFIGURATION
# ============================================================================

# Enable colors
autoload -U colors && colors

# Prompt with git support and enhanced info
autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats ' (%F{yellow}%b%f)'
zstyle ':vcs_info:*' enable git

setopt PROMPT_SUBST

# Fancy prompt with load average and git
PROMPT='%F{cyan}┌─[%f%F{green}%n@%m%f%F{cyan}]─[%f%F{blue}%~%f%F{cyan}]${vcs_info_msg_0_}
└─%f%# '
RPROMPT='%F{magenta}[%D{%H:%M:%S}]%f'

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file
setopt HIST_VERIFY               # Do not execute immediately upon history expansion
setopt SHARE_HISTORY             # Share history between all sessions
setopt APPEND_HISTORY            # Append to history file
setopt INC_APPEND_HISTORY        # Write to history file immediately

# ============================================================================
# KEY BINDINGS
# ============================================================================

bindkey '^W' backward-kill-word
bindkey '^[[A' history-search-backward    # Up arrow
bindkey '^[[B' history-search-forward     # Down arrow
bindkey '^[[1;5C' forward-word            # Ctrl+Right
bindkey '^[[1;5D' backward-word           # Ctrl+Left
bindkey '^[[3~' delete-char               # Delete key
bindkey '^[[H' beginning-of-line          # Home key
bindkey '^[[F' end-of-line                # End key
bindkey '^R' history-incremental-search-backward  # Ctrl+R for history search

# ============================================================================
# COMPLETION SYSTEM
# ============================================================================

autoload -Uz compinit
compinit

# Advanced completion settings
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Completion for sudo
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# Completion for kill command
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# SSH/SCP hostname completion
h=()
if [[ -r ~/.ssh/config ]]; then
  h=($h ${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
fi
if [[ -r ~/.ssh/known_hosts ]]; then
  h=($h ${${${(f)"$(cat ~/.ssh/known_hosts{,2} || true)"}%%\ *}%%,*}) 2>/dev/null
fi
if [[ $#h -gt 0 ]]; then
  zstyle ':completion:*:ssh:*' hosts $h
  zstyle ':completion:*:slogin:*' hosts $h
fi

# ============================================================================
# ZSH OPTIONS
# ============================================================================

setopt AUTO_CD              # cd by typing directory name if it's not a command
setopt CORRECT              # Correct typos
setopt EXTENDED_GLOB        # Extended globbing
setopt NO_CASE_GLOB         # Case insensitive globbing
setopt NUMERIC_GLOB_SORT    # Sort filenames numerically when it makes sense
setopt GLOB_DOTS            # Include dotfiles in globbing
setopt AUTO_PUSHD           # Push the old directory onto the stack
setopt PUSHD_IGNORE_DUPS    # Don't push multiple copies of the same directory
setopt PUSHD_MINUS          # Exchange the meanings of '+' and '-'
setopt CD_ABLE_VARS         # Try to expand the expression as a variable
setopt AUTO_LIST            # Automatically list choices on an ambiguous completion
setopt AUTO_MENU            # Show completion menu on a successive tab press
setopt AUTO_PARAM_SLASH     # If completed parameter is a directory, add a trailing slash
setopt COMPLETE_IN_WORD     # Complete from both ends of a word
setopt ALWAYS_TO_END        # Move cursor to the end of a completed word
setopt PATH_DIRS            # Perform path search even on command names with slashes
setopt AUTO_REMOVE_SLASH    # Remove trailing slash if next character is a word delimiter

# ============================================================================
# FUNCTIONS
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find files by name
ff() {
    find . -type f -iname '*'"$*"'*' -ls
}

# Find files by content
ftext() {
    grep -r --include="$2" "$1" . 
}

# Quick backup function
backup() {
    cp "$1"{,.bak}
}

# Show directory size
dirsize() {
    du -sh "${1:-.}" | cut -f1
}

# Quick network test
nettest() {
    echo "Testing network connectivity..."
    ping -c 3 8.8.8.8 && echo "Internet: OK" || echo "Internet: Failed"
    ping -c 3 $(ip route | grep default | awk '{print $3}') && echo "Gateway: OK" || echo "Gateway: Failed"
}

# Show listening ports
ports() {
    netstat -tulanp
}

# ZFS health check
zhealth() {
    echo "=== ZFS Pool Status ==="
    zpool status
    echo -e "\n=== ZFS List ==="
    zfs list
    echo -e "\n=== Pool Space Usage ==="
    zpool list -o name,size,allocated,free,capacity,health
}

# System info
sysinfo() {
    echo "=== System Information ==="
    echo "Hostname: $(hostname)"
    echo "Uptime: $(uptime)"
    echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    echo "TrueNAS Version: $(freenas-version 2>/dev/null || echo "Unknown")"
}

# Show top processes by CPU
topcpu() {
    ps aux --sort=-%cpu | head -${1:-10}
}

# Show top processes by memory
topmem() {
    ps aux --sort=-%mem | head -${1:-10}
}

# ============================================================================
# DIRECTORY SHORTCUTS
# ============================================================================

# Directory hashes for quick navigation
hash -d freenas=/mnt/PoolONE/FreeNAS
hash -d pools=/mnt
hash -d logs=/var/log
hash -d etc=/etc
hash -d usr=/usr/local

# ============================================================================
# COMPLETION ENHANCEMENTS
# ============================================================================

# Load additional completions if available
if [ -d /usr/local/share/zsh/site-functions ]; then
    fpath=(/usr/local/share/zsh/site-functions $fpath)
fi

# Load bash completion compatibility
autoload -U +X bashcompinit && bashcompinit

# ============================================================================
# PLUGIN LOADING (if available)
# ============================================================================

# Syntax highlighting
if [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Autosuggestions
if [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
fi

# ============================================================================
# WELCOME MESSAGE
# ============================================================================

# Show system info on login (only for interactive shells)
if [[ $- == *i* ]]; then
    echo "Welcome to TrueNAS!"
    echo "Quick commands: pools, datasets, snapshots, services, sysinfo, zhealth"
    export MAIL=/var/mail/$USER
fi

# ============================================================================
# MISC ENHANCEMENTS
# ============================================================================

# Enable word deletion with Ctrl+Backspace
bindkey '^H' backward-kill-word

# Better job control
setopt LONG_LIST_JOBS
setopt AUTO_RESUME
setopt NOTIFY
setopt CHECK_JOBS
setopt HUP

# Spell correction
setopt CORRECT_ALL

# Don't beep
unsetopt BEEP
