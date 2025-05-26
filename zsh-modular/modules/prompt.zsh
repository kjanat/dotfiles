# ============================================================================
# MODULE: PROMPT
# ============================================================================
# Advanced multi-line prompt with system status indicators, git integration, and visual enhancements.

# Load version control info
autoload -Uz vcs_info
autoload -U colors && colors

# Configure git information display
precmd() {
    vcs_info
    # Cache system info for performance
    typeset -g _load_info="$(get_load)"
    typeset -g _zfs_info="$(get_zfs_status)"
    typeset -g _net_info="$(get_network)"
    typeset -g _battery_info="$(get_battery)"
}

# Git status with detailed info
zstyle ':vcs_info:git:*' formats ' %F{yellow}⎇ %b%f%c%u'
zstyle ':vcs_info:git:*' actionformats ' %F{yellow}⎇ %b%f %F{red}(%a)%f%c%u'
zstyle ':vcs_info:git:*' stagedstr ' %F{green}●%f'
zstyle ':vcs_info:git:*' unstagedstr ' %F{red}●%f'
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:*' enable git

# Load average function with color coding
get_load() {
    if [[ -f /proc/loadavg ]]; then
        local load=$(cat /proc/loadavg | awk '{print $1}')
        local load_int=${load%.*}
        if [[ $load_int -gt 4 ]]; then
            echo "%F{red}🔥 $load%f"
        elif [[ $load_int -gt 2 ]]; then
            echo "%F{yellow}⚡ $load%f"
        else
            echo "%F{green}✅ $load%f"
        fi
    elif command -v uptime >/dev/null; then
        local load=$(uptime | sed 's/.*load average: //' | awk '{print $1}' | sed 's/,//')
        echo "%F{cyan}📊 $load%f"
    else
        echo ""
    fi
}

# ZFS health indicator
get_zfs_status() {
    if command -v zpool >/dev/null; then
        local degraded=$(zpool status | grep -c "DEGRADED\|FAULTED\|OFFLINE\|UNAVAIL" 2>/dev/null)
        if [[ $degraded -gt 0 ]]; then
            echo "%F{red}💥 ZFS%f"
        else
            local healthy=$(zpool list -H 2>/dev/null | wc -l)
            if [[ $healthy -gt 0 ]]; then
                echo "%F{green}💾 ZFS%f"
            fi
        fi
    fi
}

# Battery status (if available)
get_battery() {
    if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
        local battery=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
        local status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
        if [[ -n "$battery" ]]; then
            if [[ "$status" == "Charging" ]]; then
                echo "%F{green}🔌 ${battery}%%%f"
            elif [[ $battery -lt 20 ]]; then
                echo "%F{red}🔋 ${battery}%%%f"
            elif [[ $battery -lt 50 ]]; then
                echo "%F{yellow}🔋 ${battery}%%%f"
            else
                echo "%F{green}🔋 ${battery}%%%f"
            fi
        fi
    fi
}

# Network connectivity indicator
get_network() {
    if ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
        echo "%F{green}🌐%f"
    else
        echo "%F{red}⚠ NET%f"
    fi
}

# Memory usage indicator
get_memory() {
    if [[ -f /proc/meminfo ]]; then
        local total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        local used=$((total - available))
        local percent=$((used * 100 / total))

        if [[ $percent -gt 90 ]]; then
            echo "%F{red}🧠 ${percent}%%%f"
        elif [[ $percent -gt 70 ]]; then
            echo "%F{yellow}🧠 ${percent}%%%f"
        else
            echo "%F{green}🧠 ${percent}%%%f"
        fi
    elif command -v free >/dev/null; then
        local mem_info=$(free | grep Mem:)
        if [[ -n "$mem_info" ]]; then
            local total=$(echo $mem_info | awk '{print $2}')
            local used=$(echo $mem_info | awk '{print $3}')
            local percent=$((used * 100 / total))
            echo "%F{cyan}🧠 ${percent}%%%f"
        fi
    fi
}

# Disk usage for root filesystem
get_disk_usage() {
    local usage=$(df -h / 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ -n "$usage" ]]; then
        if [[ $usage -gt 90 ]]; then
            echo "%F{red}💿 ${usage}%%%f"
        elif [[ $usage -gt 80 ]]; then
            echo "%F{yellow}💿 ${usage}%%%f"
        else
            echo "%F{green}💿 ${usage}%%%f"
        fi
    fi
}

# Temperature indicator (if available)
get_temperature() {
    local temp=""
    if [[ -f /sys/class/thermal/thermal_zone0/temp ]]; then
        local temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
        if [[ -n "$temp_raw" ]]; then
            temp=$((temp_raw / 1000))
        fi
    elif command -v sysctl >/dev/null; then
        # FreeBSD temperature
        temp=$(sysctl -n hw.acpi.thermal.tz0.temperature 2>/dev/null | sed 's/C//')
    fi

    if [[ -n "$temp" ]] && [[ "$temp" =~ ^[0-9]+$ ]]; then
        if [[ $temp -gt 80 ]]; then
            echo "%F{red}🌡️  ${temp}°C%f"
        elif [[ $temp -gt 60 ]]; then
            echo "%F{yellow}🌡️  ${temp}°C%f"
        else
            echo "%F{green}🌡️  ${temp}°C%f"
        fi
    fi
}

# System uptime
get_uptime() {
    if command -v uptime >/dev/null; then
        local up=$(uptime | sed 's/.*up //' | sed 's/,.*user.*//' | sed 's/  / /')
        echo "%F{blue}⏱️  $up%f"
    fi
}

# Current user color based on privileges
get_user_color() {
    if [[ $EUID -eq 0 ]]; then
        echo "%F{red}%n%f" # Root in red
    elif [[ -n "$SUDO_USER" ]]; then
        echo "%F{yellow}%n%f" # Sudo user in yellow
    else
        echo "%F{green}%n%f" # Regular user in green
    fi
}

# Hostname color based on system type
get_host_color() {
    if [[ -f /etc/version ]] && grep -q "TrueNAS" /etc/version 2>/dev/null; then
        echo "%F{cyan}%m%f" # TrueNAS in cyan
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        echo "%F{blue}%m%f" # FreeBSD in blue
    else
        echo "%F{magenta}%m%f" # Other systems in magenta
    fi
}

# Build status line with system indicators
build_status_line() {
    local status_parts=()

    # Add each indicator if it returns content
    local load_info=$(get_load)
    [[ -n "$load_info" ]] && status_parts+=("$load_info")

    local mem_info=$(get_memory)
    [[ -n "$mem_info" ]] && status_parts+=("$mem_info")

    local disk_info=$(get_disk_usage)
    [[ -n "$disk_info" ]] && status_parts+=("$disk_info")

    local temp_info=$(get_temperature)
    [[ -n "$temp_info" ]] && status_parts+=("$temp_info")

    local zfs_info=$(get_zfs_status)
    [[ -n "$zfs_info" ]] && status_parts+=("$zfs_info")

    local net_info=$(get_network)
    [[ -n "$net_info" ]] && status_parts+=("$net_info")

    local battery_info=$(get_battery)
    [[ -n "$battery_info" ]] && status_parts+=("$battery_info")

    # Join status parts with separators
    if [[ ${#status_parts[@]} -gt 0 ]]; then
        local IFS=" %F{white}|%f "
        echo "[${status_parts[*]}]"
    fi
}

# Enable parameter expansion in prompts
setopt PROMPT_SUBST

# Multi-line prompt with system status indicators
if [[ -n "$SSH_CONNECTION" ]]; then
    # SSH session - show more info
    PROMPT='%F{cyan}╭─%f$(build_status_line) %F{cyan}[%f$(get_user_color)@$(get_host_color)%F{cyan}]%f %F{blue}%~%f${vcs_info_msg_0_}
%F{cyan}╰─%f%# '
else
    # Local session - simpler prompt
    PROMPT='%F{cyan}┌─%f$(build_status_line) %F{cyan}[%f$(get_user_color)@$(get_host_color)%F{cyan}]%f %F{blue}%~%f${vcs_info_msg_0_}
%F{cyan}└─%f%# '
fi

# Right-side prompt with timestamp and uptime
RPROMPT='%F{magenta}[%D{%H:%M:%S}]%f $(get_uptime)'

# Alternative simple prompt (uncomment to use)
# PROMPT='%F{cyan}[%f%F{green}%n@%m%f%F{cyan}]%f %F{blue}%~%f${vcs_info_msg_0_} %# '

# Alternative minimal prompt for slow systems (uncomment to use)
# PROMPT='%F{green}%n@%m%f:%F{blue}%~%f %# '

# Module loaded successfully
[[ "$ZSH_DEBUG" == "true" ]] && echo "🎨 Advanced prompt loaded"
