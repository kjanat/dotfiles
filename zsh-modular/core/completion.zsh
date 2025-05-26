# ============================================================================
# CORE: COMPLETION SYSTEM
# ============================================================================
# Advanced ZSH completion system with SSH host completion and extensive configuration.

# Load completion system
autoload -Uz compinit
compinit

# Completion caching
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${ZSH_CACHE_DIR:-$HOME/.zsh/cache}"

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

# SSH/SCP hostname completion function
_setup_ssh_completion() {
    typeset -a h
    h=()

    # Parse SSH config file
    if [[ -r ~/.ssh/config ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*[Hh]ost[[:space:]]+(.+)$ ]]; then
                local host_entry="${match[1]}"
                if [[ "$host_entry" != *"*"* ]] && [[ "$host_entry" != *"?"* ]]; then
                    local -a hosts_on_line
                    hosts_on_line=(${=host_entry})
                    local host
                    for host in "${hosts_on_line[@]}"; do
                        if [[ -n "$host" ]] && [[ "$host" != *"*"* ]] && [[ "$host" != *"?"* ]]; then
                            h+=("$host")
                        fi
                    done
                fi
            fi
        done < ~/.ssh/config
    fi

    # Parse known_hosts files
    local known_hosts_file
    for known_hosts_file in ~/.ssh/known_hosts ~/.ssh/known_hosts2; do
        if [[ -r "$known_hosts_file" ]]; then
            while IFS= read -r line; do
                [[ -z "$line" || "$line" == "#"* ]] && continue
                local host_field="${line%% *}"
                host_field="${host_field%%,*}"
                if [[ "$host_field" == "["*"]:"* ]]; then
                    host_field="${host_field#[}"
                    host_field="${host_field%]:*}"
                fi
                host_field="${host_field%:22}"
                if [[ "$host_field" != *"*"* ]] && [[ "$host_field" != *"?"* ]] && [[ -n "$host_field" ]]; then
                    h+=("$host_field")
                fi
            done < "$known_hosts_file"
        fi
    done

    # Remove duplicates and set up completion
    if [[ ${#h[@]} -gt 0 ]]; then
        typeset -A seen
        typeset -a unique_hosts
        local host
        for host in "${h[@]}"; do
            if [[ -z "${seen[$host]}" ]]; then
                seen[$host]=1
                unique_hosts+=("$host")
            fi
        done

        # Sort the hosts
        h=("${(@o)unique_hosts}")

        # Set up completion styles
        zstyle ':completion:*:ssh:*' hosts "${h[@]}"
        zstyle ':completion:*:slogin:*' hosts "${h[@]}"
        zstyle ':completion:*:scp:*' hosts "${h[@]}"
        zstyle ':completion:*:rsync:*' hosts "${h[@]}"
        zstyle ':completion:*:sftp:*' hosts "${h[@]}"

        # Additional SSH-related completions
        zstyle ':completion:*:(ssh|scp|rsync|slogin|sftp):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
        zstyle ':completion:*:(ssh|scp|rsync|slogin|sftp):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
        zstyle ':completion:*:(ssh|scp|rsync|slogin|sftp):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
        zstyle ':completion:*:(ssh|scp|rsync|slogin|sftp):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

        [[ "$ZSH_DEBUG" == "true" ]] && echo "✅ SSH completion loaded ${#h[@]} hosts"
    fi
}

# SSH completion management functions
ssh_completion_debug() {
    local hosts
    zstyle -a ':completion:*:ssh:*' hosts hosts
    if [[ ${#hosts[@]} -gt 0 ]]; then
        echo "SSH completion has ${#hosts[@]} hosts:"
        printf '%s\n' "${hosts[@]}" | sort | column -c 80 2>/dev/null || printf '%s\n' "${hosts[@]}" | sort
    else
        echo "No SSH hosts configured for completion"
    fi
}

ssh_completion_reload() {
    echo "Reloading SSH completion..."
    _setup_ssh_completion
}

# Set up SSH completion
_setup_ssh_completion

# Load bash completion compatibility
autoload -U +X bashcompinit && bashcompinit

# Load additional completions if available
if [[ -d /usr/local/share/zsh/site-functions ]]; then
    fpath=(/usr/local/share/zsh/site-functions $fpath)
fi

# Module loaded successfully
[[ "$ZSH_DEBUG" == "true" ]] && echo "🔧 Completion system loaded"
