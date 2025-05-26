# ============================================================================
# MODULE: ALIASES
# ============================================================================
# Comprehensive alias collection including system, navigation, and TrueNAS-specific aliases.

# Core system aliases (from original configuration)
alias h='history 25'
alias j='jobs -l'
alias c='clear'
alias la='ls -aF --color=auto'
alias lf='ls -FA --color=auto'
alias ll='ls -lAF --color=auto'
alias freenas_dir='cd /mnt/PoolONE/FreeNAS'

# Enhanced ls aliases with colors and sorting
alias l='ls -CF --color=auto'
alias lr='ls -R --color=auto'         # recursive ls
alias lt='ls -ltrh --color=auto'      # sort by date
alias lk='ls -lSrh --color=auto'      # sort by size
alias lx='ls -lXBh --color=auto'      # sort by extension
alias lc='ls -ltcrh --color=auto'     # sort by change time
alias lu='ls -lturh --color=auto'     # sort by access time
alias lm='ls -al --color=auto | more' # pipe through more
alias tree='tree -C'                  # colorized tree

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
alias del='rm -i'

# Funny aliases for typos
alias sl='ls'
alias cd..='cd ..'
alias lsl='ls -la'
alias claer='clear'
alias cealr='clear'
alias clera='clear'
alias celar='clear'
alias pdw='pwd'
alias whihc='which'

# Git shortcuts (if git is available)
if command -v git >/dev/null; then
    alias gits='git status --short'
    alias gitl='git log --oneline -10'
    alias gita='git add'
    alias gitc='git commit'
    alias gitp='git push'
    alias gitd='git diff'
fi

# Package management (FreeBSD/TrueNAS specific)
if [[ "$OSTYPE" == "freebsd"* ]]; then
    alias pkginfo='pkg info'
    alias pkgsearch='pkg search'
    alias pkginstall='sudo pkg install'
    alias pkgupdate='sudo pkg update && sudo pkg upgrade'
    alias pkgclean='sudo pkg clean'
    alias pkgaudit='pkg audit -F'
fi

# Create directory hashes for quick navigation
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

# Module loaded successfully
[[ "$ZSH_DEBUG" == "true" ]] && echo "🔗 Aliases loaded ($(alias | wc -l) aliases)"
