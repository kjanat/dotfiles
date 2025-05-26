# ============================================================================
# MODULE: FUNCTIONS
# ============================================================================
# Comprehensive utility function library for system administration and productivity.

# Create directory and cd into it
mkcd() {
    [[ $# -eq 0 ]] && {
        echo "Usage: mkcd <directory>"
        return 1
    }
    mkdir -p "$1" && cd "$1"
}

# Universal archive extractor
extract() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: extract <archive_file>"
        echo "Supported formats: tar.bz2, tar.gz, tar.xz, bz2, rar, gz, tar, tbz2, tgz, zip, Z, 7z"
        return 1
    fi

    if [[ ! -f "$1" ]]; then
        echo "Error: '$1' is not a valid file"
        return 1
    fi

    case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "Error: '$1' cannot be extracted via extract()" ;;
    esac
}

# Create archive from files/directories
mkarchive() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: mkarchive <archive_name> <file1> [file2] [...]"
        echo "Archive format determined by extension"
        return 1
    fi

    local archive="$1"
    shift

    case "$archive" in
    *.tar.gz | *.tgz) tar czf "$archive" "$@" ;;
    *.tar.bz2 | *.tbz) tar cjf "$archive" "$@" ;;
    *.tar.xz) tar cJf "$archive" "$@" ;;
    *.tar) tar cf "$archive" "$@" ;;
    *.zip) zip -r "$archive" "$@" ;;
    *.7z) 7z a "$archive" "$@" ;;
    *) echo "Unsupported format: $archive" ;;
    esac
}

# Find files by name with preview
findfile() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: findfile <pattern> [directory]"
        return 1
    fi

    local pattern="$1"
    local search_dir="${2:-.}"

    echo "🔍 Searching for files matching '*$pattern*' in $search_dir"
    find "$search_dir" -iname "*$pattern*" -type f 2>/dev/null | head -20 | while read -r file; do
        echo "📄 $file"
        if file "$file" | grep -q text; then
            echo "   Preview: $(head -1 "$file" 2>/dev/null | cut -c1-80)"
        fi
        echo
    done
}

# Find files by content
ftext() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: ftext <text> [file_pattern]"
        return 1
    fi

    local text="$1"
    local pattern="${2:-*}"

    echo "🔍 Searching for '$text' in files matching '$pattern'"
    grep -r --include="$pattern" --color=always "$text" . 2>/dev/null
}

# Find and replace in files
findreplace() {
    if [[ $# -ne 3 ]]; then
        echo "Usage: findreplace <file_pattern> <search> <replace>"
        echo "Example: findreplace '*.txt' 'old_text' 'new_text'"
        return 1
    fi

    local pattern="$1"
    local search="$2"
    local replace="$3"

    echo "🔄 Replacing '$search' with '$replace' in files matching '$pattern'"
    find . -type f -name "$pattern" -exec sed -i "s/$search/$replace/g" {} + 2>/dev/null
    echo "✅ Replacement complete"
}

# Quick backup with timestamp
backup() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: backup <file_or_directory>"
        return 1
    fi

    local item="$1"
    local backup_name="${item}.bak-$(date +%Y%m%d-%H%M%S)"

    if [[ -e "$item" ]]; then
        cp -r "$item" "$backup_name"
        echo "✅ Backup created: $backup_name"
    else
        echo "❌ Error: '$item' does not exist"
        return 1
    fi
}

# Show directory size
dirsize() {
    local target="${1:-.}"
    echo "📁 Directory size for: $target"
    du -sh "$target" 2>/dev/null | cut -f1
}

# Enhanced directory listing with size
dirinfo() {
    local target="${1:-.}"
    echo "📂 Directory information for: $target"
    echo "Total size: $(du -sh "$target" 2>/dev/null | cut -f1)"
    echo "File count: $(find "$target" -type f 2>/dev/null | wc -l)"
    echo "Directory count: $(find "$target" -type d 2>/dev/null | wc -l)"
    echo "Largest files:"
    find "$target" -type f -exec ls -lh {} + 2>/dev/null | sort -k5 -hr | head -5
}

# Quick network connectivity test
nettest() {
    echo "🌐 Testing network connectivity..."

    # Test internet connectivity
    if ping -c 3 -W 3 8.8.8.8 >/dev/null 2>&1; then
        echo "✅ Internet connectivity: OK"
    else
        echo "❌ Internet connectivity: Failed"
    fi

    # Test DNS resolution
    if nslookup google.com >/dev/null 2>&1; then
        echo "✅ DNS resolution: OK"
    else
        echo "❌ DNS resolution: Failed"
    fi

    # Test gateway connectivity
    local gateway=$(ip route 2>/dev/null | grep default | awk '{print $3}' | head -1)
    if [[ -n "$gateway" ]]; then
        if ping -c 3 -W 3 "$gateway" >/dev/null 2>&1; then
            echo "✅ Gateway ($gateway): OK"
        else
            echo "❌ Gateway ($gateway): Failed"
        fi
    fi
}

# Comprehensive system information
sysinfo() {
    echo "🖥️  System Information"
    echo "===================="

    # Basic system info
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s -r)"
    [[ -f /etc/version ]] && echo "Version: $(cat /etc/version | head -1)"

    # Uptime and load
    echo "Uptime: $(uptime | sed 's/.*up //' | sed 's/,.*user.*//')"
    echo "Load: $(uptime | sed 's/.*load average: //')"

    # Memory info
    if command -v free >/dev/null; then
        echo "Memory:"
        free -h | grep -E "Mem|Swap"
    fi

    # Disk usage
    echo "Disk Usage:"
    df -h | grep -vE '^Filesystem|tmpfs|cdrom'

    # Network interfaces
    echo "Network Interfaces:"
    ip addr show 2>/dev/null | grep -E "inet |UP," | head -10

    # Running services (if available)
    if command -v service >/dev/null; then
        echo "Key Services:"
        service -e 2>/dev/null | head -5
    fi
}

# ZFS health check and status
zhealth() {
    if ! command -v zpool >/dev/null; then
        echo "❌ ZFS not available on this system"
        return 1
    fi

    echo "💾 ZFS Health Check"
    echo "=================="

    echo "=== Pool Status ==="
    zpool status

    echo -e "\n=== Pool List ==="
    zpool list -o name,size,allocated,free,capacity,health,status

    echo -e "\n=== Dataset List ==="
    zfs list -o name,used,avail,refer,mountpoint | head -20

    echo -e "\n=== Recent Snapshots ==="
    zfs list -t snapshot -o name,used,refer,creation | tail -10

    echo -e "\n=== Pool I/O Statistics ==="
    zpool iostat -v | head -20

    # Check for errors
    local errors=$(zpool status | grep -c "DEGRADED\|FAULTED\|OFFLINE\|UNAVAIL")
    if [[ $errors -gt 0 ]]; then
        echo -e "\n⚠️  WARNING: Found $errors pools with issues!"
    else
        echo -e "\n✅ All pools healthy"
    fi
}

# Process management helpers
topcpu() {
    local count="${1:-10}"
    echo "🔥 Top $count CPU processes:"
    ps aux --sort=-%cpu | head -$((count + 1))
}

topmem() {
    local count="${1:-10}"
    echo "🧠 Top $count memory processes:"
    ps aux --sort=-%mem | head -$((count + 1))
}

# Service management helper
servstat() {
    echo "🔧 Service Status Overview"
    echo "========================"

    if command -v systemctl >/dev/null; then
        # systemd systems
        echo "Failed services:"
        systemctl --failed --no-legend | head -10
        echo -e "\nActive services:"
        systemctl list-units --type=service --state=active --no-legend | head -10
    elif command -v service >/dev/null; then
        # FreeBSD/TrueNAS
        echo "Enabled services:"
        service -e | head -10
        echo -e "\nService list:"
        service -l | head -10
    else
        echo "No supported service manager found"
    fi
}

# Security check
seccheck() {
    echo "🔒 Basic Security Check"
    echo "====================="

    echo "=== Failed Login Attempts ==="
    if [[ -f /var/log/auth.log ]]; then
        grep "Failed password" /var/log/auth.log 2>/dev/null | tail -5
    elif [[ -f /var/log/messages ]]; then
        grep -i "failed.*login\|authentication.*failure" /var/log/messages 2>/dev/null | tail -5
    else
        echo "No authentication logs found"
    fi

    echo -e "\n=== Open Ports ==="
    netstat -tuln | grep LISTEN | head -10

    echo -e "\n=== Root Login Sessions ==="
    last root 2>/dev/null | head -5

    echo -e "\n=== File Permissions Check ==="
    find /etc -perm -002 -type f 2>/dev/null | head -5 | while read -r file; do
        echo "World-writable: $file"
    done
}

# System cleanup helper
cleanup() {
    echo "🧹 System Cleanup"
    echo "================"

    echo "=== Temporary files cleanup ==="
    sudo find /tmp -type f -atime +7 -delete 2>/dev/null && echo "✅ Old temp files cleaned"

    echo "=== Log files cleanup ==="
    sudo find /var/log -name "*.log.*" -mtime +30 -delete 2>/dev/null && echo "✅ Old logs cleaned"

    if command -v pkg >/dev/null; then
        echo "=== Package cache cleanup ==="
        sudo pkg clean -y 2>/dev/null && echo "✅ Package cache cleaned"
    fi

    if command -v zfs >/dev/null; then
        echo "=== ZFS snapshot cleanup (older than 30 days) ==="
        local old_snapshots=$(zfs list -t snapshot -o name,creation | awk '$2 < "'$(date -d '30 days ago' '+%Y-%m-%d')'" {print $1}' | head -5)
        if [[ -n "$old_snapshots" ]]; then
            echo "Old snapshots found (showing first 5):"
            echo "$old_snapshots"
        else
            echo "No old snapshots found"
        fi
    fi
}

# Weather function
weather() {
    local city="${1:-Amsterdam}"
    echo "🌤️  Weather for $city:"
    curl -s "wttr.in/$city?format=3" 2>/dev/null || echo "Weather service unavailable"
}

# Calculator function
calc() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: calc <expression>"
        echo "Example: calc '2 + 2 * 3'"
        return 1
    fi

    if command -v bc >/dev/null; then
        echo "scale=3; $*" | bc -l
    else
        # Fallback to basic arithmetic
        echo $(($*)) 2>/dev/null || echo "Error: Invalid expression"
    fi
}

# Password generator
genpass() {
    local length="${1:-16}"
    if command -v openssl >/dev/null; then
        openssl rand -base64 "$length" | cut -c1-"$length"
    else
        tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c "$length"
        echo
    fi
}

# Simple HTTP file server
serve() {
    local port="${1:-8000}"
    echo "🌐 Starting HTTP server on port $port"
    echo "Access at: http://localhost:$port"

    if command -v python3 >/dev/null; then
        python3 -m http.server "$port"
    elif command -v python >/dev/null; then
        python -m SimpleHTTPServer "$port"
    else
        echo "❌ Python not available for HTTP server"
        return 1
    fi
}

# Color test function
colortest() {
    echo "🎨 Terminal Color Test:"
    for i in {0..255}; do
        printf "\e[38;5;%dm%3d\e[0m " "$i" "$i"
        (((i + 1) % 16 == 0)) && printf "\n"
    done
    echo
}

# Temperature monitoring
temps() {
    echo "🌡️  System Temperatures:"

    # Linux thermal zones
    if [[ -d /sys/class/thermal ]]; then
        for zone in /sys/class/thermal/thermal_zone*; do
            if [[ -f "$zone/temp" ]]; then
                local temp=$(($(cat "$zone/temp") / 1000))
                local type=$(cat "$zone/type" 2>/dev/null || echo "unknown")
                echo "$type: ${temp}°C"
            fi
        done
    fi

    # FreeBSD thermal info
    if command -v sysctl >/dev/null; then
        sysctl -a 2>/dev/null | grep -i temp | head -10
    fi

    # CPU info if available
    if [[ -f /proc/cpuinfo ]]; then
        echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
    fi
}

# System update helper
sysupdate() {
    echo "🔄 System Update Helper"
    echo "====================="

    if command -v pkg >/dev/null; then
        echo "=== Updating package index ==="
        sudo pkg update

        echo -e "\n=== Available updates ==="
        pkg version -v | grep '<' | head -10

        echo -e "\n=== Update commands ==="
        echo "  sudo pkg upgrade    - Upgrade all packages"
        echo "  sudo freenas-update - Update TrueNAS (if available)"
    elif command -v apt >/dev/null; then
        echo "=== Updating package lists ==="
        sudo apt update

        echo -e "\n=== Available upgrades ==="
        apt list --upgradable 2>/dev/null | head -10
    elif command -v yum >/dev/null; then
        echo "=== Checking for updates ==="
        yum check-update | head -10
    else
        echo "No supported package manager found"
    fi
}

# Help function to show available commands
help() {
    echo "
🎯 ZSH Configuration Help
========================

📁 FILE OPERATIONS:
  mkcd <dir>          - Create directory and cd into it
  extract <archive>   - Extract any archive format
  mkarchive <name>    - Create archive from files
  findfile <pattern>  - Find files by name with preview
  ftext <text>        - Find files by content
  findreplace         - Find and replace in files
  backup <file>       - Quick backup with timestamp
  dirsize [dir]       - Show directory size
  dirinfo [dir]       - Detailed directory information

🖥️  SYSTEM INFO:
  sysinfo            - Complete system overview
  topcpu [n]         - Top CPU processes
  topmem [n]         - Top memory processes
  servstat           - Service status overview
  seccheck           - Basic security check
  cleanup            - System cleanup helper
  temps              - Temperature monitoring
  sysupdate          - Update helper

💾 ZFS TOOLS:
  zhealth            - Complete ZFS health check
  pools              - List ZFS pools
  datasets           - List ZFS datasets
  snapshots          - List ZFS snapshots

🌐 NETWORK TOOLS:
  nettest            - Network connectivity test
  myip               - Show external IP
  localip            - Show local IP addresses
  ports              - Show listening ports
  speedtest          - Internet speed test

🔧 UTILITIES:
  calc <expr>        - Calculator
  genpass [len]      - Password generator
  weather [city]     - Weather information
  serve [port]       - HTTP file server
  colortest          - Terminal color test

📍 NAVIGATION:
  ~freenas           - Quick jump to FreeNAS directory
  ~pools             - Quick jump to /mnt
  ~logs              - Quick jump to /var/log
  ~etc               - Quick jump to /etc

✨ Press TAB for auto-completion on everything!
🎨 Commands are color-coded as you type!
🔍 Use Ctrl+R for history search!
"
}

# Module loaded successfully
[[ "$ZSH_DEBUG" == "true" ]] && echo "⚡ Functions loaded ($(declare -f | grep -c '^[a-zA-Z_][a-zA-Z0-9_]* ()') functions)"
