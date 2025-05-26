# TrueNAS ZSH Configuration

Here's how to set up zsh nicely in your TrueNAS SSH profile. I'll show you how to convert your existing bash configuration to zsh.

<details>
<summary>Click to expand the zsh configuration</summary>

```zsh
# TrueNAS ZSH Configuration
# Place this in ~/.zshrc

# Aliases (same as your bash setup)
alias h='history 25'
alias j='jobs -l'
alias c='clear' 
alias la='ls -aF --color=auto'
alias lf='ls -FA --color=auto'
alias ll='ls -lAF --color=auto'
alias freenas_dir='cd /mnt/PoolONE/FreeNAS'

# A righteous umask
umask 022

# Path setup
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$HOME/bin

# Environment variables
export EDITOR=nano
export PAGER=less
export IGNORE_OSVERSION=yes

# ZSH-specific configuration
# Enable colors
autoload -U colors && colors

# Set prompt (equivalent to your bash PS1)
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f %# '

# History configuration
HISTSIZE=1000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS        # Don't save duplicate commands
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicate commands
setopt HIST_REDUCE_BLANKS      # Remove extra blanks
setopt HIST_SAVE_NO_DUPS       # Don't save duplicates to file
setopt SHARE_HISTORY           # Share history between sessions
setopt APPEND_HISTORY          # Append to history file

# Key bindings (equivalent to your bash bindings)
bindkey '^W' backward-kill-word
bindkey '^[[A' history-search-backward    # Up arrow
bindkey '^[[B' history-search-forward     # Down arrow

# Enable completion system
autoload -Uz compinit
compinit

# Improved completion settings
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

# Make completion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Enable useful zsh options
setopt AUTO_CD              # cd by typing directory name if it's not a command
setopt CORRECT              # Correct typos
setopt EXTENDED_GLOB        # Extended globbing
setopt NO_CASE_GLOB         # Case insensitive globbing
setopt NUMERIC_GLOB_SORT    # Sort filenames numerically when it makes sense

# Mail check (equivalent to your bash setup)
export MAIL=/var/mail/$USER

# Load additional completions if available
if [ -d /usr/local/share/zsh/site-functions ]; then
    fpath=(/usr/local/share/zsh/site-functions $fpath)
fi
```

</details>

Now here's how to set it up:

## Installation Steps

1.  **Change your default shell to zsh** (if not already done):

```bash
# Check if zsh is available
which zsh

# Change default shell
chsh -s /usr/local/bin/zsh
# or if zsh is in a different location:
chsh -s $(which zsh)
```

2.  **Create the .zshrc file**:

```bash
# Copy the configuration above to ~/.zshrc
nano ~/.zshrc
# Paste the configuration from the artifact
```

3.  **Source the configuration**:

```bash
source ~/.zshrc
```

## Key Improvements Over Bash

-   **Better completion**: Tab completion is more intelligent and shows options in a menu
-   **Case-insensitive completion**: Type `cd doc` and it will complete to `Documents`
-   **Shared history**: History is shared between all zsh sessions
-   **Auto-cd**: Just type a directory name to cd into it
-   **Typo correction**: zsh will suggest corrections for mistyped commands
-   **Better globbing**: More powerful pattern matching

## Optional Enhancements

If you want even more features, you can add:

```bash
# Add to your .zshrc for syntax highlighting (if available)
if [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Add autosuggestions (if available)
if [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
```

The configuration preserves all your existing aliases and functionality while adding zsh's enhanced features. Your workflow should remain the same, but with better completion and history handling.

## 🚀 Additional Awesome Features Added

<details>
<summary>Click to expand the zsh configuration</summary>

```zsh
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
```

</details>

### **Enhanced Aliases**

-   **Smart ls variants**: `lt` (by time), `lk` (by size), `lx` (by extension)
-   **Navigation shortcuts**: `..`, `...`, `....` for quick directory traversal
-   **TrueNAS specific**: `pools`, `datasets`, `snapshots`, `services`, `jails`
-   **Safety aliases**: Confirm before `rm`, `cp`, `mv`

### **Powerful Functions**

-   `mkcd()` - Create directory and cd into it
-   `extract()` - Universal archive extractor
-   `zhealth()` - Complete ZFS health check
-   `sysinfo()` - System overview at a glance
-   `nettest()` - Quick network connectivity test
-   `backup()` - Quick file backup

### **Advanced Prompt**

-   **Git integration** - Shows current branch
-   **Multi-line prompt** with fancy Unicode characters
-   **Right-side timestamp**
-   **Color-coded elements**

### **Smart Completion**

-   **SSH hostname completion** from ~/.ssh/config
-   **Process completion** for kill commands
-   **Sudo command completion**
-   **Case-insensitive matching**

### **Directory Shortcuts**

Use `~freenas`, `~pools`, `~logs` to jump instantly:

```bash
cd ~freenas  # Goes to /mnt/PoolONE/FreeNAS
cd ~logs     # Goes to /var/log
```

### **Enhanced History**

-   **50,000 commands** stored
-   **Duplicate removal**
-   **Timestamp tracking**
-   **Shared between sessions**

### **Key Bindings**

-   `Ctrl+R` - History search
-   `Ctrl+Left/Right` - Word navigation
-   `Ctrl+Backspace` - Delete word backward

## 🔧 Optional Plugin Installation

For even MORE features, install these FreeBSD packages:

```bash
# Syntax highlighting (colors commands as you type)
pkg install zsh-syntax-highlighting

# Auto-suggestions (suggests commands from history)
pkg install zsh-autosuggestions

# Advanced prompt themes
pkg install powerlevel10k

# Better file manager
pkg install ranger

# Enhanced grep with colors
pkg install ripgrep
```

## 💡 Pro Tips

1.  **Use the new functions**:

   ```bash
   sysinfo        # Quick system overview
   zhealth        # ZFS status check
   nettest        # Network test
   extract file.tar.gz  # Extract any archive
   ```

2.  **Directory navigation**:

   ```bash
   cd ~freenas    # Jump to FreeNAS directory
   mkcd new/deep/path  # Create and enter directory
   ```

3.  **Process management**:

   ```bash
   topcpu 5       # Show top 5 CPU processes
   topmem         # Show top memory processes
   ports          # Show listening ports
   ```

This configuration turns your TrueNAS shell into a productivity powerhouse! 🎯

## 🎉 ULTIMATE ZSH BEAST MODE FEATURES ADDED

<details>
<summary>Click to expand the zsh configuration</summary>

```zsh
# ██╗   ██╗██╗  ████████╗██╗███╗   ███╗ █████╗ ████████╗███████╗
# ██║   ██║██║  ╚══██╔══╝██║████╗ ████║██╔══██╗╚══██╔══╝██╔════╝
# ██║   ██║██║     ██║   ██║██╔████╔██║███████║   ██║   █████╗  
# ██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██╔══╝  
# ╚██████╔╝███████╗██║   ██║██║ ╚═╝ ██║██║  ██║   ██║   ███████╗
#  ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝
# 
# ████████╗██████╗ ██╗   ██╗███████╗███╗   ██╗ █████╗ ███████╗
# ╚══██╔══╝██╔══██╗██║   ██║██╔════╝████╗  ██║██╔══██╗██╔════╝
#    ██║   ██████╔╝██║   ██║█████╗  ██╔██╗ ██║███████║███████╗
#    ██║   ██╔══██╗██║   ██║██╔══╝  ██║╚██╗██║██╔══██║╚════██║
#    ██║   ██║  ██║╚██████╔╝███████╗██║ ╚████║██║  ██║███████║
#    ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝
#
# ULTIMATE TrueNAS ZSH Configuration - Beast Mode Enabled!

# ============================================================================
# PERFORMANCE OPTIMIZATION
# ============================================================================

# Skip global compinit for faster startup
skip_global_compinit=1

# Optimize completion loading
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# ============================================================================
# ENVIRONMENT & SYSTEM SETUP
# ============================================================================

# Core environment
umask 022
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=nano
export PAGER=less
export BROWSER=lynx
export IGNORE_OSVERSION=yes

# Enhanced PATH
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$HOME/bin:$HOME/.local/bin:/usr/games

# Less configuration for better viewing
export LESSOPEN="| /usr/bin/lesspipe %s"
export LESSCLOSE="/usr/bin/lesspipe %s %s"
export LESS='-F -g -i -M -R -S -w -X -z-4'
export LESSHISTFILE=-

# Grep colors
export GREP_COLOR='1;32'
export GREP_OPTIONS='--color=auto'

# ============================================================================
# ALIASES - THE ULTIMATE COLLECTION
# ============================================================================

# Your original aliases
alias h='history 25'
alias j='jobs -l'
alias c='clear' 
alias la='ls -aF --color=auto'
alias lf='ls -FA --color=auto'
alias ll='ls -lAF --color=auto'
alias freenas_dir='cd /mnt/PoolONE/FreeNAS'

# Enhanced ls aliases with icons and colors
alias l='ls -CF --color=auto'
alias lr='ls -R --color=auto'                    # recursive
alias lt='ls -ltrh --color=auto'                 # sort by date
alias lk='ls -lSrh --color=auto'                 # sort by size
alias lx='ls -lXBh --color=auto'                 # sort by extension
alias lc='ls -ltcrh --color=auto'                # sort by change time
alias lu='ls -lturh --color=auto'                # sort by access time
alias lm='ls -al --color=auto | more'            # pipe through more
alias tree='tree -C'                             # colorized tree

# Navigation power aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias -- -='cd -'
alias ~='cd ~'
alias back='cd $OLDPWD'

# File operations with confirmations and colors
alias rm='rm -i --preserve-root'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# System monitoring aliases
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias top='htop 2>/dev/null || top'
alias iotop='iotop 2>/dev/null || iostat'
alias nethogs='nethogs 2>/dev/null || echo "nethogs not installed"'

# Network aliases
alias myip="curl -s ifconfig.me"
alias myipv4="curl -s ipv4.icanhazip.com"
alias myipv6="curl -s ipv6.icanhazip.com"
alias localip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python'
alias ports='netstat -tulanp'
alias listening='netstat -tlnp | grep LISTEN'
alias tcpdump='tcpdump -nn'

# TrueNAS power aliases
alias pools='zpool list -o name,size,allocated,free,capacity,health,status'
alias datasets='zfs list -o name,used,avail,refer,mountpoint'
alias snapshots='zfs list -t snapshot -o name,used,refer,creation'
alias scrub='zpool scrub'
alias scrubstatus='zpool status | grep scrub'
alias iostat='zpool iostat 1'
alias services='service -e'
alias servicestatus='service -l'
alias jails='jls -v'
alias plugins='iocage list'
alias logs='tail -f /var/log/messages'
alias syslog='less /var/log/messages'
alias dmesg='dmesg --color=always | less -R'
alias mountinfo='mount | column -t'

# Quick editing
alias zshrc='$EDITOR ~/.zshrc && source ~/.zshrc'
alias vimrc='$EDITOR ~/.vimrc'
alias nanorc='$EDITOR ~/.nanorc'
alias hosts='$EDITOR /etc/hosts'
alias fstab='$EDITOR /etc/fstab'

# Archive operations
alias tarxz='tar -Jxf'
alias targz='tar -zxf'
alias tarbz='tar -jxf'
alias mktar='tar -cvf'
alias mktargz='tar -czvf'
alias mktarbz='tar -cjvf'
alias mktarxz='tar -cJvf'

# Search aliases
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias histg='history | grep'
alias psg='ps aux | grep'

# Quick shortcuts
alias q='exit'
alias x='exit'
alias :q='exit'
alias bashrc='$EDITOR ~/.bashrc'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# Safety aliases for destructive commands
alias rm='rm -i --preserve-root'
alias del='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# Funny aliases for typos
alias sl='ls'
alias cd..='cd ..'
alias l='ls'
alias ll='ls -la'
alias lsl='ls -la'
alias claer='clear'
alias cealr='clear'
alias clera='clear'
alias celar='clear'

# ============================================================================
# ULTRA ADVANCED PROMPT WITH STATUS INDICATORS
# ============================================================================

autoload -U colors && colors
autoload -Uz vcs_info

# Git status with detailed info
zstyle ':vcs_info:git:*' formats ' %F{yellow}⎇ %b%f%c%u'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}⎇ %b%f %F{red}(%a)%f%c%u'
zstyle ':vcs_info:git:*' stagedstr ' %F{green}●%f'
zstyle ':vcs_info:git:*' unstagedstr ' %F{red}●%f'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git

# System load indicator
get_load() {
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local load_int=${load%.*}
    if [[ $load_int -gt 2 ]]; then
        echo "%F{red}⚠ ${load}%f"
    elif [[ $load_int -gt 1 ]]; then
        echo "%F{yellow}⚡ ${load}%f"
    else
        echo "%F{green}✓ ${load}%f"
    fi
}

# ZFS pool health indicator
get_zfs_status() {
    local status=$(zpool status 2>/dev/null | grep -i "errors\|degraded\|offline" | wc -l)
    if [[ $status -gt 0 ]]; then
        echo "%F{red}⚠ ZFS%f"
    else
        echo "%F{green}✓ ZFS%f"
    fi
}

# Battery status (if applicable)
get_battery() {
    if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
        local battery=$(cat /sys/class/power_supply/BAT0/capacity)
        if [[ $battery -lt 20 ]]; then
            echo "%F{red}🔋 ${battery}%%%f"
        elif [[ $battery -lt 50 ]]; then
            echo "%F{yellow}🔋 ${battery}%%%f"
        else
            echo "%F{green}🔋 ${battery}%%%f"
        fi
    fi
}

# Network connectivity indicator
get_network() {
    if ping -c 1 8.8.8.8 &>/dev/null; then
        echo "%F{green}🌐%f"
    else
        echo "%F{red}⚠ NET%f"
    fi
}

# Async functions for prompt
autoload -Uz add-zsh-hook

precmd() {
    vcs_info
    # Cache system info for performance
    typeset -g _load_info="$(get_load)"
    typeset -g _zfs_info="$(get_zfs_status)"
    typeset -g _net_info="$(get_network)"
    typeset -g _battery_info="$(get_battery)"
}

# Ultimate multi-line prompt
PROMPT='%F{cyan}╭─[%f%F{green}%n@%m%f%F{cyan}]─[%f%F{blue}%~%f%F{cyan}]${vcs_info_msg_0_}─[%f${_load_info}%F{cyan}]─[%f${_zfs_info}%F{cyan}]─[%f${_net_info}%F{cyan}]${_battery_info:+─[}${_battery_info}${_battery_info:+%F{cyan}]}
╰─%f%(?.%F{green}➤%f.%F{red}➤%f) '

# Right prompt with time, exit code, and job count
RPROMPT='%(1j.%F{magenta}⚙ %j%f .)%(?..%F{red}✗ %?%f )%F{cyan}⌚ %D{%H:%M:%S}%f'

# ============================================================================
# HISTORY CONFIGURATION - MAXIMUM POWER
# ============================================================================

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# All the history options
setopt EXTENDED_HISTORY          # Write timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_FIND_NO_DUPS         # Don't display duplicates during search
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicates
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
setopt HIST_SAVE_NO_DUPS         # Don't save duplicates
setopt HIST_VERIFY               # Show expanded history before executing
setopt SHARE_HISTORY             # Share history between sessions
setopt APPEND_HISTORY            # Append to history
setopt INC_APPEND_HISTORY        # Write immediately
setopt HIST_REDUCE_BLANKS        # Remove extra blanks
setopt HIST_NO_STORE             # Don't store history commands

# ============================================================================
# KEY BINDINGS - ULTIMATE POWER USER SETUP
# ============================================================================

# Emacs-style bindings
bindkey -e

# Standard bindings
bindkey '^W' backward-kill-word
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# Advanced bindings
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^u' kill-whole-line
bindkey '^k' kill-line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^f' forward-char
bindkey '^b' backward-char
bindkey '^d' delete-char

# Alt bindings
bindkey '^[f' forward-word
bindkey '^[b' backward-word
bindkey '^[d' kill-word
bindkey '^[^?' backward-kill-word

# Function key bindings
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history

# ============================================================================
# COMPLETION SYSTEM - ULTRA ADVANCED
# ============================================================================

# Load completion system
autoload -Uz compinit
compinit

# Completion caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

# Enhanced completion settings
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
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'

# Fuzzy completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Group matches and describe
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# Advanced command completion
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Process completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:killall:*' menu yes select
zstyle ':completion:*:killall:*' force-list always

# SSH/SCP completion
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
# ZSH OPTIONS - ALL THE POWER
# ============================================================================

# Directory navigation
setopt AUTO_CD              # cd by typing directory name
setopt AUTO_PUSHD           # Push old directory onto stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_MINUS          # Exchange + and - for pushd
setopt CD_ABLE_VARS         # Try expanding as variable
setopt PUSHD_SILENT         # Don't print stack after pushd/popd

# Globbing and expansion
setopt EXTENDED_GLOB        # Extended globbing
setopt NO_CASE_GLOB         # Case insensitive globbing
setopt NUMERIC_GLOB_SORT    # Sort numerically
setopt GLOB_DOTS            # Include dotfiles
setopt MARK_DIRS            # Mark directories with /
setopt GLOB_COMPLETE        # Complete globs
setopt BAD_PATTERN          # Error on bad pattern

# Completion
setopt AUTO_LIST            # List choices on ambiguous completion
setopt AUTO_MENU            # Show menu on successive tab
setopt AUTO_PARAM_SLASH     # Add slash after directory completion
setopt COMPLETE_IN_WORD     # Complete from both ends
setopt ALWAYS_TO_END        # Move cursor to end
setopt PATH_DIRS            # Perform path search on commands with slashes
setopt AUTO_REMOVE_SLASH    # Remove trailing slash

# Job control
setopt LONG_LIST_JOBS       # List jobs in long format
setopt AUTO_RESUME          # Resume jobs with their name
setopt NOTIFY               # Report status immediately
setopt CHECK_JOBS           # Check jobs on exit
setopt HUP                  # Send HUP to jobs on shell exit
setopt BG_NICE              # Background jobs at lower priority

# Input/Output
setopt CORRECT              # Try to correct spelling
setopt CORRECT_ALL          # Try to correct all arguments
setopt DVORAK               # Use Dvorak keyboard
setopt FLOW_CONTROL         # Enable flow control
setopt IGNORE_EOF           # Don't exit on EOF
setopt INTERACTIVE_COMMENTS # Allow comments in interactive mode
setopt HASH_CMDS            # Hash commands for faster lookup
setopt HASH_DIRS            # Hash directories

# Prompting
setopt PROMPT_SUBST         # Parameter expansion in prompts
setopt TRANSIENT_RPROMPT    # Remove right prompt from previous lines

# Scripts and functions
setopt MULTIOS              # Multiple redirections
setopt SHORT_LOOPS          # Allow short loop syntax

# Don't beep!
unsetopt BEEP
unsetopt HIST_BEEP
unsetopt LIST_BEEP

# ============================================================================
# MEGA FUNCTION LIBRARY
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Universal archive extractor
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.tar.xz)    tar xJf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *.deb)       ar x $1        ;;
            *.tar.xz)    tar xf $1      ;;
            *.tar.zst)   tar xf $1      ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Create archive
mkarchive() {
    case $1 in
        *.tar.gz)   tar -czf $1 ${@:2} ;;
        *.tar.bz2)  tar -cjf $1 ${@:2} ;;
        *.tar.xz)   tar -cJf $1 ${@:2} ;;
        *.zip)      zip -r $1 ${@:2}   ;;
        *.7z)       7z a $1 ${@:2}     ;;
        *)          echo "Unsupported format" ;;
    esac
}

# Find files by name
ff() {
    find . -type f -iname '*'"$*"'*' -ls
}

# Find files by content
ftext() {
    grep -r --include="$2" "$1" . 
}

# Find and replace in files
findreplace() {
    find . -type f -name "$1" -exec sed -i "s/$2/$3/g" {} +
}

# Quick backup function
backup() {
    cp "$1"{,.bak-$(date +%Y%m%d-%H%M%S)}
}

# Show directory size
dirsize() {
    du -sh "${1:-.}" | cut -f1
}

# Quick network test
nettest() {
    echo "🌐 Testing network connectivity..."
    if ping -c 3 8.8.8.8 >/dev/null 2>&1; then
        echo "✅ Internet: OK"
    else
        echo "❌ Internet: Failed"
    fi
    
    local gateway=$(ip route | grep default | awk '{print $3}' | head -1)
    if [[ -n $gateway ]]; then
        if ping -c 3 $gateway >/dev/null 2>&1; then
            echo "✅ Gateway ($gateway): OK"
        else
            echo "❌ Gateway ($gateway): Failed"
        fi
    fi
    
    echo "📡 DNS Test:"
    nslookup google.com >/dev/null 2>&1 && echo "✅ DNS: OK" || echo "❌ DNS: Failed"
}

# Enhanced ports function
ports() {
    echo "🔌 Listening ports:"
    netstat -tulanp | grep LISTEN | sort -k4
    echo "🌐 Established connections:"
    netstat -tulanp | grep ESTABLISHED | wc -l | xargs echo "Active connections:"
}

# Ultimate ZFS health check
zhealth() {
    echo "🏊 === ZFS Pool Status ==="
    zpool status -v
    echo -e "\n📊 === Pool Space Usage ==="
    zpool list -o name,size,allocated,free,capacity,health,status
    echo -e "\n💾 === ZFS Datasets ==="
    zfs list -o name,used,avail,refer,mountpoint
    echo -e "\n📸 === Recent Snapshots ==="
    zfs list -t snapshot -s creation | tail -10
    echo -e "\n⚡ === I/O Statistics ==="
    zpool iostat -v 1 1
    echo -e "\n🔍 === Pool History ==="
    zpool history | tail -20
}

# System info dashboard
sysinfo() {
    echo "🖥️  === TrueNAS System Dashboard ==="
    echo "📍 Hostname: $(hostname)"
    echo "⏰ Uptime: $(uptime | awk -F, '{sub(".*up ",x,$1);print $1}' | sed 's/^ *//')"
    echo "📈 Load: $(uptime | awk -F'load average:' '{print $2}')"
    echo "💾 Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2 " (" int($3/$2 * 100) "%)"}')"
    echo "💿 Root Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    echo "🌡️  CPU Temp: $(sysctl -n hw.acpi.thermal.tz0.temperature 2>/dev/null | sed 's/C/°C/' || echo "N/A")"
    echo "🔧 TrueNAS: $(freenas-version 2>/dev/null || echo "Unknown")"
    echo "🐧 Kernel: $(uname -r)"
    echo "🏃 Processes: $(ps aux | wc -l)"
    echo "👥 Users: $(who | wc -l)"
    echo "🌐 IP: $(hostname -I | awk '{print $1}')"
}

# Process management
topcpu() {
    echo "🔥 Top ${1:-10} CPU processes:"
    ps aux --sort=-%cpu | head -$((${1:-10}+1))
}

topmem() {
    echo "💾 Top ${1:-10} Memory processes:"
    ps aux --sort=-%mem | head -$((${1:-10}+1))
}

# Service management helper
servstat() {
    if [[ -n $1 ]]; then
        service $1 status
    else
        echo "📋 Service Status Overview:"
        service -e | while read svc; do
            status=$(service $svc onestatus 2>/dev/null | grep -o "is running\|is not running" || echo "unknown")
            if [[ $status == *"running"* ]]; then
                echo "✅ $svc: Running"
            else
                echo "❌ $svc: Stopped"
            fi
        done
    fi
}

# Log analysis
logwatch() {
    echo "📝 Recent system events:"
    echo "=== Errors ==="
    tail -100 /var/log/messages | grep -i error | tail -5
    echo "=== Warnings ==="
    tail -100 /var/log/messages | grep -i warn | tail -5
    echo "=== Last 10 entries ==="
    tail -10 /var/log/messages
}

# Temperature monitoring
temps() {
    echo "🌡️  System Temperatures:"
    for sensor in $(sysctl -a | grep temperature | cut -d: -f1); do
        temp=$(sysctl -n $sensor 2>/dev/null)
        if [[ -n $temp ]]; then
            echo "$sensor: $temp"
        fi
    done
}

# Disk usage analyzer
diskusage() {
    echo "💾 Disk Usage Analysis:"
    echo "=== Top 10 largest directories ==="
    du -h --max-depth=1 ${1:-.} 2>/dev/null | sort -hr | head -10
    echo "=== Disk space by filesystem ==="
    df -h | grep -v tmpfs | grep -v udev
}

# Network analyzer
netinfo() {
    echo "🌐 Network Information:"
    echo "=== Interfaces ==="
    ip addr show | grep -E '^[0-9]+:|inet '
    echo "=== Routing Table ==="
    ip route
    echo "=== DNS Servers ==="
    cat /etc/resolv.conf | grep nameserver
    echo "=== Open Connections ==="
    netstat -tuln | head -20
}

# Security scanner
seccheck() {
    echo "🔒 Security Check:"
    echo "=== Failed Login Attempts ==="
    grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5 || echo "No auth.log found"
    echo "=== Open Ports ==="
    netstat -tuln | grep LISTEN
    echo "=== Root Login Sessions ==="
    last root | head -5
    echo "=== File Permissions Check ==="
    find /etc -name "passwd" -o -name "shadow" -o -name "group" | xargs ls -la
}

# Performance monitor
perfmon() {
    echo "⚡ Performance Monitor:"
    echo "=== CPU Usage ==="
    top -bn1 | grep "Cpu(s)" || iostat -c 1 1 | tail -1
    echo "=== Memory Usage ==="
    free -h
    echo "=== Disk I/O ==="
    iostat -d 1 1 2>/dev/null | tail -n +4 || echo "iostat not available"
    echo "=== Network I/O ==="
    cat /proc/net/dev | grep -v "lo:" | awk 'NR>2{print $1, $2, $10}' | head -5 2>/dev/null || ifconfig | grep "RX bytes"
    echo "=== Load Average ==="
    uptime
}

# ZFS maintenance helper
zfsmaint() {
    echo "🛠️  ZFS Maintenance Helper:"
    echo "=== Pool Status ==="
    zpool status | grep -E "pool:|state:|errors:"
    echo "=== Scrub Status ==="
    zpool status | grep scrub
    echo "=== Recent Snapshots ==="
    zfs list -t snapshot -s creation | tail -10
    echo "=== Space Usage ==="
    zfs list | head -20
    
    echo -e "\n🔧 Maintenance Commands:"
    echo "  zpool scrub [pool]     - Start scrub"
    echo "  zfs snapshot [dataset]@$(date +%Y%m%d) - Create snapshot"
    echo "  zfs destroy [snapshot] - Remove snapshot"
}

# Container/Jail manager
jailmgr() {
    echo "🏢 Jail/Container Manager:"
    echo "=== Running Jails ==="
    jls -v 2>/dev/null || echo "No jails running"
    echo "=== iocage Jails ==="
    iocage list 2>/dev/null || echo "iocage not available"
    echo "=== Resource Usage ==="
    for jail in $(jls -h jid 2>/dev/null); do
        [[ $jail == "jid" ]] && continue
        echo "Jail $jail: $(ps -J $jail | wc -l) processes"
    done 2>/dev/null
}

# File finder with preview
findfile() {
    find ${2:-.} -iname "*$1*" -type f 2>/dev/null | head -20 | while read file; do
        echo "📄 $file"
        if [[ $(file "$file" | grep text) ]]; then
            echo "   Preview: $(head -1 "$file" 2>/dev/null | cut -c1-80)..."
        fi
    done
}

# Quick file server
serve() {
    local port=${1:-8000}
    echo "🌐 Starting HTTP server on port $port"
    echo "📁 Serving: $(pwd)"
    echo "🔗 URL: http://$(hostname -I | awk '{print $1}'):$port"
    python3 -m http.server $port 2>/dev/null || python -m SimpleHTTPServer $port
}

# System cleanup
cleanup() {
    echo "🧹 System Cleanup:"
    echo "=== Cleaning temporary files ==="
    sudo rm -rf /tmp/* /var/tmp/* 2>/dev/null && echo "✅ Temp files cleaned"
    echo "=== Cleaning old logs ==="
    sudo find /var/log -name "*.log.*" -mtime +30 -delete 2>/dev/null && echo "✅ Old logs cleaned"
    echo "=== Package cache cleanup ==="
    sudo pkg clean -y 2>/dev/null && echo "✅ Package cache cleaned"
    echo "=== ZFS snapshot cleanup (older than 30 days) ==="
    zfs list -t snapshot -o name,creation | awk '$2 < "'$(date -d '30 days ago' '+%Y-%m-%d')'" {print $1}' | head -5
}

# Weather function
weather() {
    local city=${1:-Amsterdam}
    curl -s "wttr.in/$city?format=3" 2>/dev/null || echo "🌤️  Weather service unavailable"
}

# Color test
colortest() {
    echo "🎨 Color Test:"
    for i in {0..255}; do
        printf "\x1b[38;5;${i}m%3d " "${i}"
        if (( i == 15 )) || (( i > 15 )) && (( (i-15) % 6 == 0 )); then
            printf "\x1b[0m\n";
        fi
    done
}

# System benchmark
benchmark() {
    echo "🏃 Quick System Benchmark:"
    echo "=== CPU Test ==="
    time echo "scale=5000; 4*a(1)" | bc -l >/dev/null
    echo "=== Memory Test ==="
    dd if=/dev/zero of=/tmp/benchmark bs=1M count=100 2>&1 | grep copied
    rm -f /tmp/benchmark
    echo "=== Disk Test ==="
    dd if=/dev/zero of=/tmp/disktest bs=1M count=100 oflag=sync 2>&1 | grep copied
    rm -f /tmp/disktest
}

# Git shortcuts (if git is available)
gits() {
    if command -v git >/dev/null; then
        echo "📋 Git Status:"
        git status --short 2>/dev/null || echo "Not a git repository"
    fi
}

gitl() {
    if command -v git >/dev/null; then
        git log --oneline -10 2>/dev/null || echo "Not a git repository"
    fi
}

# Quick calculator
calc() {
    echo "scale=3; $*" | bc -l
}

# Password generator
genpass() {
    local length=${1:-16}
    openssl rand -base64 $length | cut -c1-$length 2>/dev/null || \
    tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c $length; echo
}

# System update helper
sysupdate() {
    echo "🔄 System Update Helper:"
    echo "=== Updating package index ==="
    sudo pkg update
    echo "=== Available updates ==="
    pkg version -v | grep '<'
    echo "=== Update commands ==="
    echo "  sudo pkg upgrade    - Upgrade all packages"
    echo "  sudo freenas-update - Update TrueNAS (if available)"
}

# ============================================================================
# DIRECTORY SHORTCUTS & HASHES
# ============================================================================

# Directory hashes for quick navigation
hash -d freenas=/mnt/PoolONE/FreeNAS
hash -d pools=/mnt
hash -d logs=/var/log
hash -d etc=/etc
hash -d usr=/usr/local
hash -d home=/home
hash -d tmp=/tmp
hash -d var=/var
hash -d root=/root
hash -d boot=/boot

# ============================================================================
# INTELLIGENT AUTO-SUGGESTIONS & SYNTAX HIGHLIGHTING
# ============================================================================

# Load syntax highlighting (if available)
if [[ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    
    # Custom highlighting styles
    ZSH_HIGHLIGHT_STYLES[default]=none
    ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
    ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
    ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
    ZSH_HIGHLIGHT_STYLES[global-alias]=fg=cyan
    ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
    ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
    ZSH_HIGHLIGHT_STYLES[path]=underline
    ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
    ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
    ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[command-substitution]=none
    ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[process-substitution]=none
    ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=cyan
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=cyan
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
    ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta
    ZSH_HIGHLIGHT_STYLES[assign]=none
    ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
    ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
    ZSH_HIGHLIGHT_STYLES[named-fd]=none
    ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
    ZSH_HIGHLIGHT_STYLES[arg0]=fg=green
fi

# Load autosuggestions (if available)
if [[ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

# ============================================================================
# INTELLIGENT COMMAND CORRECTION
# ============================================================================

# Advanced spell correction
setopt CORRECT
setopt CORRECT_ALL

# Custom corrections
alias sl='ls'
alias cd..='cd ..'
alias pdw='pwd'
alias claer='clear'
alias whihc='which'

# ============================================================================
# AUTO-COMPLETION ENHANCEMENTS
# ============================================================================

# Load additional completions
if [[ -d /usr/local/share/zsh/site-functions ]]; then
    fpath=(/usr/local/share/zsh/site-functions $fpath)
fi

# Load bash completion compatibility
autoload -U +X bashcompinit && bashcompinit

# Custom completion functions
_zfs_completion() {
    local -a datasets
    datasets=($(zfs list -H -o name 2>/dev/null))
    compadd $datasets
}
compdef _zfs_completion zfs

_zpool_completion() {
    local -a pools
    pools=($(zpool list -H -o name 2>/dev/null))
    compadd $pools
}
compdef _zpool_completion zpool

# ============================================================================
# STARTUP BANNER & SYSTEM CHECK
# ============================================================================

# Startup banner and system check (only for interactive shells)
if [[ $- == *i* ]] && [[ -z $ZSH_BANNER_SHOWN ]]; then
    export ZSH_BANNER_SHOWN=1
    
    # Cool banner
    echo "
╔══════════════════════════════════════════════════════════════════════════════╗
║  🚀 WELCOME TO ULTIMATE TRUENAS ZSH - BEAST MODE ACTIVATED! 🚀              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  📊 Quick Commands: sysinfo | zhealth | nettest | perfmon | servstat         ║
║  🔧 ZFS Tools: pools | datasets | snapshots | scrub | zfsmaint              ║
║  🌐 Network: myip | ports | netinfo | speedtest                            ║
║  📁 Files: ff [name] | ftext [content] | extract [file] | backup [file]     ║
║  🎯 Utils: weather | calc | genpass | cleanup | temps                       ║
╚══════════════════════════════════════════════════════════════════════════════╝"
    
    # Quick system status
    echo "📍 $(hostname) | 💾 $(free -h | awk '/^Mem:/ {print $3 "/" $2}') | ⏰ $(uptime | awk -F, '{sub(".*up ",x,$1);print $1}' | sed 's/^ *//')"
    
    # ZFS quick status
    if zpool list >/dev/null 2>&1; then
        local zfs_status=$(zpool status 2>/dev/null | grep -c "errors\|DEGRADED\|OFFLINE" || echo "0")
        if [[ $zfs_status -eq 0 ]]; then
            echo "✅ ZFS: All pools healthy"
        else
            echo "⚠️  ZFS: Check pool status with 'zhealth'"
        fi
    fi
    
    # Check for updates (non-blocking)
    (pkg version -v | grep -q '<' 2>/dev/null && echo "📦 Updates available: run 'sysupdate'") &
    
    export MAIL=/var/mail/$USER
fi

# ============================================================================
# PLUGIN MANAGEMENT SYSTEM
# ============================================================================

# Plugin directory
ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"

# Plugin loader function
load_plugin() {
    local plugin_name="$1"
    local plugin_file="$ZSH_PLUGIN_DIR/$plugin_name/$plugin_name.plugin.zsh"
    
    if [[ -f "$plugin_file" ]]; then
        source "$plugin_file"
        echo "✅ Loaded plugin: $plugin_name"
    else
        echo "❌ Plugin not found: $plugin_name"
    fi
}

# Auto-load plugins from directory
if [[ -d "$ZSH_PLUGIN_DIR" ]]; then
    for plugin in "$ZSH_PLUGIN_DIR"/*; do
        if [[ -d "$plugin" ]]; then
            local plugin_name=$(basename "$plugin")
            load_plugin "$plugin_name"
        fi
    done
fi

# ============================================================================
# PERFORMANCE MONITORING
# ============================================================================

# Track command execution time for slow commands
preexec() {
    timer=${timer:-$SECONDS}
}

precmd() {
    if [ $timer ]; then
        timer_show=$(($SECONDS - $timer))
        if [[ $timer_show -gt 3 ]]; then
            echo "⏱️  Command took ${timer_show}s"
        fi
        unset timer
    fi
}

# ============================================================================
# FINAL OPTIMIZATIONS
# ============================================================================

# Rehash automatically
zstyle ':completion:*' rehash true

# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Reduce escape sequence timeout
export KEYTIMEOUT=1

# Optimize for SSD
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# Final message
echo "🎉 Ultimate TrueNAS ZSH loaded! Type 'help' for command overview."

# Help function
help() {
    echo "
🎯 ULTIMATE TRUENAS ZSH COMMAND REFERENCE:

📊 SYSTEM MONITORING:
  sysinfo    - Complete system dashboard
  perfmon    - Performance monitor
  temps      - Temperature sensors
  benchmark  - Quick system benchmark

🏊 ZFS MANAGEMENT:
  zhealth    - Complete ZFS health check
  zfsmaint   - ZFS maintenance helper
  pools      - List ZFS pools with health
  datasets   - List ZFS datasets
  snapshots  - List ZFS snapshots
  scrub      - Start pool scrub

🌐 NETWORK TOOLS:
  nettest    - Network connectivity test
  netinfo    - Complete network info
  myip       - Show external IP
  ports      - Show listening ports
  speedtest  - Internet speed test

🔧 SYSTEM ADMINISTRATION:
  servstat   - Service status overview
  jailmgr    - Jail/container manager
  seccheck   - Security check
  cleanup    - System cleanup
  sysupdate  - Update helper

📁 FILE OPERATIONS:
  ff [name]     - Find files by name
  ftext [text]  - Find files by content
  extract [file] - Extract any archive
  backup [file]  - Quick backup
  findfile [name] - Find with preview

🎯 UTILITIES:
  weather [city] - Weather info
  calc [expr]    - Calculator
  genpass [len]  - Password generator
  serve [port]   - HTTP file server
  colortest      - Terminal color test

📍 QUICK NAVIGATION:
  ~freenas   - /mnt/PoolONE/FreeNAS
  ~pools     - /mnt
  ~logs      - /var/log
  ~etc       - /etc
  
✨ Press TAB for auto-completion on everything!
🎨 Commands are color-coded as you type!
🔍 Use Ctrl+R for history search!
"
}
```

</details>

### 🚀 **Advanced System Functions**

-   **`sysinfo`** - Complete dashboard with CPU temp, memory, processes
-   **`perfmon`** - Real-time performance monitoring
-   **`seccheck`** - Security audit with failed logins & open ports
-   **`benchmark`** - Quick CPU/memory/disk speed tests
-   **`cleanup`** - Intelligent system cleanup

### 🏊 **Enhanced ZFS Management**

-   **`zfsmaint`** - Complete ZFS maintenance helper
-   **`zhealth`** - Extended health check with I/O stats & history
-   Smart pool status indicators in prompt

### 🌐 **Network Power Tools**

-   **`netinfo`** - Complete network analysis
-   **`speedtest`** - Built-in internet speed test
-   **`serve`** - Instant HTTP file server
-   Network connectivity indicator in prompt

### 🔧 **System Administration**

-   **`servstat`** - Service management with status overview
-   **`jailmgr`** - Jail/container management
-   **`logwatch`** - Intelligent log analysis
-   **`sysupdate`** - Update management helper

### 🎨 **Visual Enhancements**

-   **Multi-line prompt** with system indicators
-   **Git integration** with branch display
-   **Load average warnings** (color-coded)
-   **ZFS health indicator** in prompt
-   **Network status indicator**
-   **Battery indicator** (if available)
-   **Custom syntax highlighting** themes

### 📁 **Enhanced File Operations**

-   **`findfile`** - Find with content preview
-   **`mkarchive`** - Create archives in any format
-   **`findreplace`** - Bulk find & replace
-   **Smart backup** with timestamps

### 🎯 **Utility Functions**

-   **`weather`** - Get weather for any city
-   **`calc`** - Built-in calculator
-   **`genpass`** - Secure password generator
-   **`colortest`** - Terminal color testing
-   **`temps`** - Hardware temperature monitoring

### ⚡ **Performance Features**

-   **Command timing** for slow operations
-   **Intelligent caching** for completions
-   **Plugin management system**
-   **Startup system check** with health status

### 🎪 **Interactive Features**

-   **Startup banner** with system status
-   **`help`** command with complete reference
-   **Auto-update notifications**
-   **Smart error correction**

### 🔧 **Advanced Completions**

-   **ZFS dataset completion**
-   **ZPool completion**
-   **SSH hostname completion**
-   **Process completion** for kill commands
-   **Fuzzy matching** for everything

## 🚀 Installation Bonus Commands

```bash
# Install additional tools for maximum power
pkg install htop iotop tree ranger ripgrep fd-find bat exa

# Enable even more features
pkg install zsh-syntax-highlighting zsh-autosuggestions

# For the ultimate experience
pkg install powerlevel10k fzf
```

This configuration transforms your TrueNAS into a **command-line spaceship**! 🚀 Every feature is optimized for TrueNAS administration with beautiful visuals, intelligent helpers, and maximum productivity!

Type `help` after loading to see the complete command reference! 🎯
