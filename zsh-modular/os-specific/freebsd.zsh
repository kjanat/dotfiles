# ============================================================================
# OS-SPECIFIC: FreeBSD/TrueNAS CONFIGURATION
# ============================================================================
# FreeBSD and TrueNAS specific functionality and compatibility.

# FreeBSD-specific environment variables
export IGNORE_OSVERSION=yes # Ignore OS version checks

# Add FreeBSD-specific paths
typeset -U path
path=(
    /usr/games
    $path
)

# FreeBSD-compatible memory info function
freebsd_meminfo() {
    local total_bytes page_size free_pages inactive_pages cache_pages

    total_bytes=$(sysctl -n hw.physmem)
    page_size=$(sysctl -n vm.stats.vm.v_page_size)
    free_pages=$(sysctl -n vm.stats.vm.v_free_count)
    inactive_pages=$(sysctl -n vm.stats.vm.v_inactive_count)
    cache_pages=$(sysctl -n vm.stats.vm.v_cache_count 2>/dev/null || echo 0)

    # Use awk for calculations to avoid dependency on bc
    local total_gb free_bytes free_gb inactive_bytes inactive_gb cache_bytes cache_gb available_gb used_gb

    total_gb=$(echo "$total_bytes" | awk '{printf "%.1f", $1/1024/1024/1024}')
    free_bytes=$(echo "$free_pages $page_size" | awk '{print $1*$2}')
    free_gb=$(echo "$free_bytes" | awk '{printf "%.1f", $1/1024/1024/1024}')
    inactive_bytes=$(echo "$inactive_pages $page_size" | awk '{print $1*$2}')
    inactive_gb=$(echo "$inactive_bytes" | awk '{printf "%.1f", $1/1024/1024/1024}')
    cache_bytes=$(echo "$cache_pages $page_size" | awk '{print $1*$2}')
    cache_gb=$(echo "$cache_bytes" | awk '{printf "%.1f", $1/1024/1024/1024}')
    available_gb=$(echo "$free_gb $inactive_gb $cache_gb" | awk '{printf "%.1f", $1+$2+$3}')
    used_gb=$(echo "$total_gb $available_gb" | awk '{printf "%.1f", $1-$2}')

    printf "%-15s %8s %8s %8s %8s\n" "" "total" "used" "free" "available"
    printf "%-15s %7.1fG %7.1fG %7.1fG %7.1fG\n" "Mem:" "$total_gb" "$used_gb" "$free_gb" "$available_gb"
}

# TrueNAS version detection
truenas_version() {
    if [[ -f /etc/version ]]; then
        cat /etc/version
    else
        echo "Unknown"
    fi
}

# TrueNAS-specific aliases
alias free='freebsd_meminfo'
alias pools='zpool list -o name,size,allocated,free,capacity,health'
alias datasets='zfs list -o name,used,avail,refer,mountpoint'
alias snapshots='zfs list -t snapshot -o name,used,refer,creation'
alias scrub='zpool scrub'
alias scrubstatus='zpool status | grep scrub'
alias iostat='zpool iostat 1'
alias services='service -e'
alias servicestatus='service -l'
alias jails='jls -v'
alias plugins='iocage list 2>/dev/null || echo "iocage not available"'
alias logs='tail -f /var/log/messages'
alias syslog='less /var/log/messages'
alias mountinfo='mount | column -t'

# FreeBSD-specific network tools
alias netports="sockstat -46lsc | sed -n '1p'; sockstat -46Llsc | sed '1d' | sort -uk6 -k2 -k5 -k7 | column -t"
alias listening='sockstat -46lsc | awk "NR==1{print; next} /[tu][cd]p/ && \$8>0 {print \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8}" | sort -k8 -k6 -k1 -k5 | column -t | grep "LISTEN\|FOREIGN"'

# ZFS health indicator
get_zfs_status() {
    local zfs_status_count
    zfs_status_count=$(zpool status 2>/dev/null | grep -i -E "(errors|degraded|offline|repaired|unrecoverable)" | grep -vc "errors: No known data errors")
    if [[ $zfs_status_count -gt 0 ]]; then
        echo "%F{red}⚠  ZFS%f"
    else
        echo "%F{green}✓ ZFS%f"
    fi
}

# Battery status for FreeBSD (ACPI)
get_battery() {
    if command -v acpiconf >/dev/null 2>&1; then
        local battery
        battery=$(acpiconf -i 0 2>/dev/null | awk '/Remaining capacity:/ {gsub(/%/, "", $3); print $3}')
        if [[ -n "$battery" ]]; then
            if [[ $battery -lt 20 ]]; then
                echo "%F{red}🔋 ${battery}%%%f"
            elif [[ $battery -lt 50 ]]; then
                echo "%F{yellow}🔋 ${battery}%%%f"
            else
                echo "%F{green}🔋 ${battery}%%%f"
            fi
        fi
    fi
}

# Ultimate ZFS health check
zhealth() {
    echo "🏊 === ZFS Pool Status ==="
    zpool status -v

    echo -e "\n📊 === Pool Space Usage ==="
    zpool list -o name,size,allocated,free,capacity,health

    echo -e "\n💾 === ZFS Datasets ==="
    zfs list -o name,used,available,refer,mountpoint,usedbychildren,usedbysnapshots,encryption,devices,usedbyrefreservation \
        -d 2 \
        -s name |
        grep -v '^freenas-boot/' 2>/dev/null || zfs list

    echo -e "\n📸 === Recent Snapshots ==="
    zfs list -t snapshot -s creation | tail -10

    echo -e "\n⚡ === I/O Statistics ==="
    zpool iostat -v 1 1
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
    iocage list --header 2>/dev/null | sort -rk3 -k2 | column -t || echo "iocage not available"

    echo "=== Resource Usage ==="
    for jail in $(jls -h jid 2>/dev/null); do
        [[ $jail == "jid" ]] && continue
        echo "Jail $jail: $(ps -J "$jail" | wc -l) processes"
    done 2>/dev/null
}

# Temperature monitoring for FreeBSD
temps() {
    echo "🌡️  System Temperatures:"
    for sensor in $(sysctl -a | grep temperature | cut -d: -f1); do
        temp=$(sysctl -n $sensor 2>/dev/null)
        if [[ -n $temp ]]; then
            echo "$sensor: $temp"
        fi
    done
}

# FreeBSD system update helper
sysupdate() {
    echo "🔄 System Update Helper:"

    # Detect if on TrueNAS Core (freenas-update present, pkg repo likely broken)
    if command -v freenas-update >/dev/null 2>&1; then
        echo "=== TrueNAS Core detected ==="
        echo "The package manager (pkg) is not supported on the host system."
        echo "Use the TrueNAS web interface for major updates and patches."
        echo ""
        echo "For CLI/system update:"
        echo "  sudo freenas-update check         # Check for updates"
        echo "  sudo freenas-update download      # Download updates"
        echo "  sudo freenas-update install       # Install updates (will reboot)"
        echo ""
        echo "=== Jail/Plugin updates ==="
        echo "For jails/plugins, use 'pkg' **inside** each jail, not on the host!"
    else
        echo "=== FreeBSD system detected ==="
        echo "=== Updating package index ==="
        if sudo pkg update 2>/dev/null; then
            echo "✅ Package index updated"
            echo "=== Available updates ==="
            pkg version -v 2>/dev/null | grep '<' || echo "No updates available or pkg repository not configured"
        else
            echo "⚠️ Package repository not available or configured"
            echo "This may be expected on TrueNAS systems where pkg is managed separately"
        fi
        echo "=== Update commands ==="
        echo "  sudo pkg upgrade    - Upgrade all packages"
    fi
}

# Custom completion functions for ZFS
_zfs_completion() {
    local -a datasets
    mapfile -t datasets < <(zfs list -H -o name 2>/dev/null)
    compadd "${datasets[@]}"
}
compdef _zfs_completion zfs

_zpool_completion() {
    local -a pools
    mapfile -t pools < <(zpool list -H -o name 2>/dev/null)
    compadd "${pools[@]}"
}
compdef _zpool_completion zpool

# Directory hashes for TrueNAS navigation
if [[ -d /mnt ]]; then
    hash -d pools=/mnt
    [[ -d /mnt/PoolONE/FreeNAS ]] && hash -d freenas=/mnt/PoolONE/FreeNAS
    [[ -d /mnt/FlashONE/iocage/jails ]] && hash -d jails=/mnt/FlashONE/iocage/jails
    [[ -d /mnt/PoolONE/FreeNAS/Media ]] && hash -d media=/mnt/PoolONE/FreeNAS/Media
    [[ -d /mnt/PoolONE/Nextcloud ]] && hash -d nextcloud=/mnt/PoolONE/Nextcloud
fi

# Module loaded successfully
[[ "$ZSH_DEBUG" == "true" ]] && echo "🐡 FreeBSD/TrueNAS configuration loaded"
