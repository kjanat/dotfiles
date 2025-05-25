# shellcheck disable=SC2148
# Universal Service Status Function for Unix Systems
# Works on: FreeBSD/TrueNAS, Debian/Ubuntu, RHEL/Fedora/CentOS, macOS, OpenBSD, NetBSD
servstat() {
    local filter=""
    local show_disabled=false
    local show_details=false
    local sort_output=false
    local output_format="table"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
        -a | --all)
            show_disabled=true
            shift
            ;;
        -d | --details)
            show_details=true
            shift
            ;;
        -s | --sort)
            sort_output=true
            shift
            ;;
        -j | --json)
            output_format="json"
            shift
            ;;
        -r | --running)
            filter="running"
            shift
            ;;
        -x | --stopped)
            filter="stopped"
            shift
            ;;
        -h | --help)
            echo "Universal Service Status Tool"
            echo "Usage: servstat [OPTIONS] [SERVICE_NAME]"
            echo ""
            echo "Options:"
            echo "  -a, --all        Show all services (including disabled)"
            echo "  -d, --details    Show detailed service information"
            echo "  -s, --sort       Sort services alphabetically"
            echo "  -j, --json       Output in JSON format"
            echo "  -r, --running    Show only running services"
            echo "  -x, --stopped    Show only stopped services"
            echo "  -h, --help       Show this help message"
            echo ""
            echo "Examples:"
            echo "  servstat                    # Show all enabled services"
            echo "  servstat ssh                # Show specific service status"
            echo "  servstat -a -s              # Show all services, sorted"
            echo "  servstat -r                 # Show only running services"
            echo "  servstat -d ssh             # Show detailed info for ssh"
            echo ""
            echo "Supported Systems: FreeBSD, OpenBSD, NetBSD, macOS, Debian, Ubuntu, RHEL, Fedora, CentOS, Alpine"
            return 0
            ;;
        -*)
            echo "Unknown option: $1"
            echo "Use 'servstat --help' for usage information"
            return 1
            ;;
        *)
            # Single service query
            _servstat_single_service "$1" "$show_details"
            return $?
            ;;
        esac
    done

    # Main service overview
    _servstat_overview "$filter" "$show_disabled" "$show_details" "$sort_output" "$output_format"
}

# Detect operating system and service manager
_detect_system() {
    local os_type=""
    local service_manager=""

    # Detect OS
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        case "$ID" in
        debian | ubuntu | linuxmint | pop) os_type="debian" ;;
        rhel | fedora | centos | rocky | alma | ol) os_type="redhat" ;;
        alpine) os_type="alpine" ;;
        arch | manjaro) os_type="arch" ;;
        opensuse* | sles) os_type="suse" ;;
        freebsd) os_type="freebsd" ;;
        # *) os_type="linux" ;;
        esac
    elif [[ "$(uname)" == "FreeBSD" ]]; then
        os_type="freebsd"
    elif [[ "$(uname)" == "OpenBSD" ]]; then
        os_type="openbsd"
    elif [[ "$(uname)" == "NetBSD" ]]; then
        os_type="netbsd"
    elif [[ "$(uname)" == "Darwin" ]]; then
        os_type="macos"
    else
        os_type="unknown"
    fi

    # Detect service manager
    if command -v systemctl >/dev/null 2>&1 && [[ -d /etc/systemd ]]; then
        service_manager="systemd"
    elif command -v service >/dev/null 2>&1 && [[ "$os_type" =~ ^(freebsd|openbsd|netbsd)$ ]]; then
        service_manager="bsd_rc"
    elif command -v rc-service >/dev/null 2>&1; then
        service_manager="openrc"
    elif command -v launchctl >/dev/null 2>&1 && [[ "$os_type" == "macos" ]]; then
        service_manager="launchd"
    elif [[ -d /etc/init.d ]] && command -v service >/dev/null 2>&1; then
        service_manager="sysv"
    else
        service_manager="unknown"
    fi

    echo "$os_type|$service_manager"
}

# Get service list based on system type
_get_service_list() {
    local show_all system_info os_type service_manager

    show_all="$1"
    system_info="$(_detect_system)"
    os_type="${system_info%|*}"
    service_manager="${system_info#*|}"

    case "$service_manager" in
    systemd)
        if [[ "$show_all" == true ]]; then
            systemctl list-unit-files --type=service --no-legend --no-pager | awk '{print $1}' | sed 's/.service$//'
        else
            systemctl list-units --type=service --no-legend --no-pager | awk '{print $1}' | sed 's/.service$//'
        fi
        ;;
    bsd_rc)
        if [[ "$show_all" == true ]]; then
            find /etc/rc.d/ /usr/local/etc/rc.d/ -maxdepth 1 -type f -print0 2>/dev/null | xargs -0 basename -a 2>/dev/null | sort -u
        else
            service -e 2>/dev/null
        fi
        ;;
    openrc)
        if [[ "$show_all" == true ]]; then
            rc-service -l 2>/dev/null
        else
            rc-status -s 2>/dev/null | awk '{print $1}'
        fi
        ;;
    launchd)
        if [[ "$show_all" == true ]]; then
            launchctl list 2>/dev/null | awk 'NR>1 {print $3}' | grep -v '^-$'
        else
            launchctl list 2>/dev/null | awk 'NR>1 && $1 != "-" {print $3}' | grep -v '^-$'
        fi
        ;;
    sysv)
        if [[ "$show_all" == true ]]; then
            for file in /etc/init.d/*; do
                [[ -f "$file" ]] || continue
                local basename_file
                basename_file="${file##*/}"
                case "$basename_file" in
                README|skeleton|rc|rcS) continue ;;
                *) echo "$basename_file" ;;
                esac
            done 2>/dev/null
        else
            service --status-all 2>/dev/null | grep '\[ + \]' | awk '{print $NF}'
        fi
        ;;
    *)
        echo "ps|cron|kernel" | tr '|' '\n' # Fallback to basic processes
        ;;
    esac
}

# Get service status
_get_service_status() {
    local system_info os_type service_manager service_name status enabled

    service_name="$1"
    system_info="$(_detect_system)"
    os_type="${system_info%|*}"
    service_manager="${system_info#*|}"
    status="unknown"
    enabled="unknown"

    case "$service_manager" in
    systemd)
        local state enable_state

        state=$(systemctl is-active "$service_name" 2>/dev/null)
        enable_state=$(systemctl is-enabled "$service_name" 2>/dev/null)

        case "$state" in
        active) status="running" ;;
        inactive | dead) status="stopped" ;;
        failed) status="error" ;;
        *) status="unknown" ;;
        esac

        case "$enable_state" in
        enabled | static) enabled="yes" ;;
        disabled) enabled="no" ;;
        *) enabled="unknown" ;;
        esac
        ;;
    bsd_rc)
        local status_output status_code

        status_output=$(service "$service_name" onestatus 2>/dev/null)
        status_code=$?

        if [[ $status_code -eq 0 ]]; then
            if echo "$status_output" | grep -q "is running"; then
                status="running"
            else
                status="stopped"
            fi
        else
            status="error"
        fi

        # Check if enabled in rc.conf
        if sysrc -n "${service_name}_enable" 2>/dev/null | grep -q "YES"; then
            enabled="yes"
        else
            enabled="no"
        fi
        ;;
    openrc)
        if rc-service "$service_name" status >/dev/null 2>&1; then
            status="running"
        else
            status="stopped"
        fi

        if rc-update show default 2>/dev/null | grep -q "^$service_name"; then
            enabled="yes"
        else
            enabled="no"
        fi
        ;;
    launchd)
        local pid
        pid=$(launchctl list "$service_name" 2>/dev/null | awk 'NR==2 {print $1}')
        if [[ "$pid" != "-" ]] && [[ -n "$pid" ]]; then
            status="running"
        else
            status="stopped"
        fi
        enabled="unknown" # launchd doesn't have simple enable/disable
        ;;
    sysv)
        local sysv_status status_code

        sysv_status=$(service "$service_name" status 2>/dev/null)
        status_code=$?

        if [[ $status_code -eq 0 ]]; then
            if echo "$sysv_status" | grep -q -E "running|active|started"; then
                status="running"
            else
                status="stopped"
            fi
        else
            status="error"
        fi

        # Check runlevel links
        if ls /etc/rc*.d/S*"$service_name" >/dev/null 2>&1; then
            enabled="yes"
        else
            enabled="no"
        fi
        ;;
    *)
        # Fallback: check if process exists
        if pgrep -f "$service_name" >/dev/null 2>&1; then
            status="running"
        else
            status="stopped"
        fi
        enabled="unknown"
        ;;
    esac

    echo "$status|$enabled"
}

# Function to check single service
_servstat_single_service() {
    local service_name show_details system_info os_type service_manager

    service_name="$1"
    show_details="$2"
    system_info="$(_detect_system)"
    os_type="${system_info%|*}"
    service_manager="${system_info#*|}"

    if [[ -z "$service_name" ]]; then
        echo "❌ No service name provided"
        return 1
    fi

    # Normalize service name (remove .service suffix if present)
    service_name="${service_name%.service}"

    echo "🔍 Service: $service_name"
    echo "🖥️  System: $os_type ($service_manager)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Get service status
    local status_info status enabled

    status_info="$(_get_service_status "$service_name")"
    status="${status_info%|*}"
    enabled="${status_info#*|}"

    # Display status with colors
    local status_icon="❓"
    local status_color=""

    case "$status" in
    running)
        status_icon="✅"
        status_color="\033[32m" # Green
        ;;
    stopped)
        status_icon="❌"
        status_color="\033[31m" # Red
        ;;
    error)
        status_icon="⚠️"
        status_color="\033[33m" # Yellow
        ;;
    *)
        status_icon="❓"
        status_color="\033[37m" # Gray
        ;;
    esac

    echo -e "${status_color}Status: ${status_icon} ${status^}\033[0m"

    # Boot enabled status
    local enabled_icon="❓"
    case "$enabled" in
    yes) enabled_icon="✅" ;;
    no) enabled_icon="❌" ;;
    *) enabled_icon="❓" ;;
    esac
    echo "Boot Enable: $enabled_icon $enabled"

    if [[ "$show_details" == true ]]; then
        echo ""
        echo "📋 Detailed Information:"

        # System-specific details
        case "$service_manager" in
        systemd)
            echo ""
            echo "📊 Systemd Unit Info:"
            systemctl show "$service_name" --no-page 2>/dev/null | grep -E "^(Description|LoadState|ActiveState|SubState|MainPID|ExecStart)" | while IFS= read -r line; do
                echo "  $line"
            done

            echo ""
            echo "📝 Recent Journal Entries:"
            journalctl -u "$service_name" --no-pager -n 5 2>/dev/null | tail -5 | while IFS= read -r line; do
                echo "  $line"
            done
            ;;
        bsd_rc)
            echo ""
            echo "📁 RC Configuration:"
            local rc_script=""
            if [[ -f "/etc/rc.d/$service_name" ]]; then
                rc_script="/etc/rc.d/$service_name"
            elif [[ -f "/usr/local/etc/rc.d/$service_name" ]]; then
                rc_script="/usr/local/etc/rc.d/$service_name"
            fi

            if [[ -n "$rc_script" ]]; then
                echo "  Script: $rc_script"
                echo "  Permissions: $(find "$rc_script" -printf '%M %u %g\n' 2>/dev/null || stat -f "%Sp %Su %Sg" "$rc_script" 2>/dev/null || stat -c '%A %U %G' "$rc_script" 2>/dev/null || echo "unknown")"
            fi

            # Show rc.conf variables
            echo ""
            echo "🔧 RC Variables:"
            sysrc -a 2>/dev/null | grep "^${service_name}_" | head -5 | while IFS= read -r line; do
                echo "  $line"
            done
            ;;
        launchd)
            echo ""
            echo "🍎 Launchd Info:"
            launchctl list "$service_name" 2>/dev/null | while IFS= read -r line; do
                echo "  $line"
            done
            ;;
        esac

        # Process information if running
        if [[ "$status" == "running" ]]; then
            echo ""
            echo "🏃 Process Information:"

            local pids
            pids=$(pgrep -f "$service_name" 2>/dev/null | head -5)

            if [[ -n "$pids" ]]; then
                echo "  PIDs: $pids"
                echo "  Process Details:"
                if command -v ps >/dev/null 2>&1; then
                    # Different ps options for different systems
                    if [[ "$os_type" == "macos" ]] || [[ "$os_type" =~ bsd ]]; then
                        ps -o pid,pcpu,pmem,vsz,rss,comm -p "$pids" 2>/dev/null | head -6
                    else
                        ps -o pid,pcpu,pmem,vsz,rss,comm -p "$pids" 2>/dev/null | head -6
                    fi
                fi
            else
                echo "  No processes found (service may use different process names)"
            fi
        fi

        # Network connections
        if command -v netstat >/dev/null 2>&1; then
            echo ""
            echo "🌐 Network Connections:"
            local connections
            connections=$(netstat -tulpn 2>/dev/null | grep "$service_name" | head -3)
            if [[ -n "$connections" ]]; then
                echo "$connections"
            else
                echo "  No network connections found"
            fi
        fi

        # Log files
        echo ""
        echo "📝 Log Files:"
        local log_patterns found_logs
        log_patterns=("/var/log/${service_name}.log" "/var/log/${service_name}/*.log" "/var/log/messages" "/var/log/syslog")
        found_logs=false
        for pattern in "${log_patterns[@]}"; do
            if ls "$pattern" 2>/dev/null >/dev/null; then
                echo "  Found: $pattern"
                found_logs=true
            fi
        done

        if [[ "$found_logs" == false ]]; then
            echo "  No specific log files found"
        fi
    fi

    echo ""
    echo "🔧 Management Commands:"
    case "$service_manager" in
    systemd)
        echo "  sudo systemctl start $service_name      # Start service"
        echo "  sudo systemctl stop $service_name       # Stop service"
        echo "  sudo systemctl restart $service_name    # Restart service"
        echo "  sudo systemctl reload $service_name     # Reload configuration"
        echo "  sudo systemctl enable $service_name     # Enable at boot"
        echo "  sudo systemctl disable $service_name    # Disable at boot"
        echo "  systemctl status $service_name          # Show status"
        echo "  journalctl -u $service_name -f          # Follow logs"
        ;;
    bsd_rc)
        echo "  sudo service $service_name start        # Start service"
        echo "  sudo service $service_name stop         # Stop service"
        echo "  sudo service $service_name restart      # Restart service"
        echo "  sudo service $service_name reload       # Reload configuration"
        echo "  sudo sysrc ${service_name}_enable=YES   # Enable at boot"
        echo "  sudo sysrc ${service_name}_enable=NO    # Disable at boot"
        ;;
    openrc)
        echo "  sudo rc-service $service_name start     # Start service"
        echo "  sudo rc-service $service_name stop      # Stop service"
        echo "  sudo rc-service $service_name restart   # Restart service"
        echo "  sudo rc-update add $service_name        # Enable at boot"
        echo "  sudo rc-update del $service_name        # Disable at boot"
        ;;
    launchd)
        echo "  sudo launchctl load /path/to/$service_name.plist    # Load service"
        echo "  sudo launchctl unload /path/to/$service_name.plist  # Unload service"
        echo "  launchctl list | grep $service_name                 # Check status"
        ;;
    sysv)
        echo "  sudo service $service_name start        # Start service"
        echo "  sudo service $service_name stop         # Stop service"
        echo "  sudo service $service_name restart      # Restart service"
        echo "  sudo update-rc.d $service_name enable   # Enable at boot (Debian)"
        echo "  sudo chkconfig $service_name on         # Enable at boot (RHEL)"
        ;;
    esac
}

# Function for service overview
_servstat_overview() {
    local filter show_disabled show_details sort_output output_format system_info os_type service_manager

    filter="$1"
    show_disabled="$2"
    show_details="$3"
    sort_output="$4"
    output_format="$5"
    system_info="$(_detect_system)"
    os_type="${system_info%|*}"
    service_manager="${system_info#*|}"

    if [[ "$service_manager" == "unknown" ]]; then
        echo "❌ No supported service manager found on this system"
        echo "🖥️  System: $os_type"
        echo "💡 This system may use a custom service management solution"
        return 1
    fi

    echo "🖥️  Universal Service Status Overview"
    echo "🔧 System: $os_type ($service_manager)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Get service list
    local service_list
    service_list="$(_get_service_list "$show_disabled")"

    if [[ -z "$service_list" ]]; then
        echo "❌ No services found"
        return 1
    fi

    # Collect service information
    local services=()
    local running_count=0
    local stopped_count=0
    local error_count=0
    local unknown_count=0

    echo "🔍 Scanning services..."

    while IFS= read -r svc; do
        [[ -z "$svc" ]] && continue

        local status_info status enabled

        status_info="$(_get_service_status "$svc")"
        status="${status_info%|*}"
        enabled="${status_info#*|}"

        local status_icon="❓"
        case "$status" in
        running)
            status_icon="✅"
            ((running_count++))
            ;;
        stopped)
            status_icon="❌"
            ((stopped_count++))
            ;;
        error)
            status_icon="⚠️"
            ((error_count++))
            ;;
        *)
            status_icon="❓"
            ((unknown_count++))
            ;;
        esac

        local enabled_icon="❓"
        case "$enabled" in
        yes) enabled_icon="✅" ;;
        no) enabled_icon="❌" ;;
        *) enabled_icon="❓" ;;
        esac

        # Apply filters
        if [[ -n "$filter" ]]; then
            case "$filter" in
            "running")
                [[ "$status" != "running" ]] && continue
                ;;
            "stopped")
                [[ "$status" != "stopped" ]] && continue
                ;;
            esac
        fi

        # Store service info
        if [[ "$output_format" == "json" ]]; then
            services+=("{\"name\":\"$svc\",\"status\":\"$status\",\"enabled\":\"$enabled\",\"status_icon\":\"$status_icon\",\"enabled_icon\":\"$enabled_icon\"}")
        else
            services+=("$svc|$status_icon|$status|$enabled_icon|$enabled")
        fi

    done <<<"$service_list"

    # Output results
    if [[ "$output_format" == "json" ]]; then
        echo "{"
        echo "  \"system\": {"
        echo "    \"os\": \"$os_type\","
        echo "    \"service_manager\": \"$service_manager\""
        echo "  },"
        echo "  \"summary\": {"
        echo "    \"total\": $((running_count + stopped_count + error_count + unknown_count)),"
        echo "    \"running\": $running_count,"
        echo "    \"stopped\": $stopped_count,"
        echo "    \"errors\": $error_count,"
        echo "    \"unknown\": $unknown_count"
        echo "  },"
        echo "  \"services\": ["
        local first=true
        for service_info in "${services[@]}"; do
            [[ "$first" == false ]] && echo ","
            echo -n "    $service_info"
            first=false
        done
        echo ""
        echo "  ]"
        echo "}"
    else
        # Summary
        echo ""
        echo "📊 Summary: 🟢 $running_count running | 🔴 $stopped_count stopped | ⚠️ $error_count errors | ❓ $unknown_count unknown"
        echo ""

        # Table header
        printf "%-25s %-8s %-10s %-8s %-10s\n" "SERVICE" "STATUS" "STATE" "BOOT" "ENABLED"
        printf "%-25s %-8s %-10s %-8s %-10s\n" "-------" "------" "-----" "----" "-------"

        # Sort if requested
        local sorted_services=("${services[@]}")
        if [[ "$sort_output" == true ]]; then
            mapfile -t sorted_services < <(printf '%s\n' "${services[@]}" | sort)
        fi

        for service_info in "${sorted_services[@]}"; do
            IFS='|' read -r name status_icon state enabled_icon enabled_state <<<"$service_info"
            printf "%-25s %-8s %-10s %-8s %-10s\n" "${name:0:24}" "$status_icon" "$state" "$enabled_icon" "$enabled_state"
        done

        echo ""
        echo "💡 Universal Tips:"
        echo "  • Use 'servstat <service>' for detailed cross-platform info"
        echo "  • Use 'servstat -r' to show only running services"
        echo "  • Use 'servstat -d <service>' for detailed analysis"
        echo "  • Use 'servstat -j' for JSON output (great for scripts)"
        echo "  • Use 'servstat --help' for all options"

        # System-specific tips
        case "$service_manager" in
        systemd)
            echo "  • Systemd detected: Use 'journalctl -u <service>' for logs"
            ;;
        bsd_rc)
            echo "  • BSD RC detected: Check /etc/rc.conf for service config"
            ;;
        openrc)
            echo "  • OpenRC detected: Use 'rc-status' for runlevel info"
            ;;
        launchd)
            echo "  • Launchd detected: Check ~/Library/LaunchAgents for user services"
            ;;
        esac
    fi
}

# Universal Auto-completion for servstat
# Works on: zsh, bash, and other shells across all Unix systems

# ZSH completion (most advanced)
if command -v compdef >/dev/null 2>&1; then
    _servstat_completion_zsh() {
        local -a services options
        # shellcheck disable=SC2034
        local state line context

        # Define options
        local -a options=(
            '-a[show all services including disabled]'
            '--all[show all services including disabled]'
            '-d[show detailed service information]'
            '--details[show detailed service information]'
            '-s[sort services alphabetically]'
            '--sort[sort services alphabetically]'
            '-j[output in JSON format]'
            '--json[output in JSON format]'
            '-r[show only running services]'
            '--running[show only running services]'
            '-x[show only stopped services]'
            '--stopped[show only stopped services]'
            '-h[show help message]'
            '--help[show help message]'
        )

        _arguments -C \
            "${options[@]}" \
            '*:service:->services' && return 0

        case $state in
        services)
            # Get services based on current options
            local show_all=false
            # shellcheck disable=SC2154
            for word in "${words[@]}"; do
                case $word in
                -a | --all) show_all=true ;;
                esac
            done

            # Cache services for performance
            if [[ -z $_servstat_services_cache ]] || [[ $_servstat_cache_time -lt $(($(date +%s) - 300)) ]]; then
                mapfile -t _servstat_services_cache < <(_get_service_list $show_all 2>/dev/null)
                _servstat_cache_time=$(date +%s)
            fi

            services=("${_servstat_services_cache[@]}")
            _describe 'services' services
            ;;
        esac
    }
    compdef _servstat_completion_zsh servstat
fi

# BASH completion
if command -v complete >/dev/null 2>&1 && [[ -n "$BASH_VERSION" ]]; then
    _servstat_completion_bash() {
        local cur prev opts services
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        # shellcheck disable=SC2034
        prev="${COMP_WORDS[COMP_CWORD - 1]}"

        # Options for completion
        opts="-a --all -d --details -s --sort -j --json -r --running -x --stopped -h --help"

        # If current word starts with -, complete options
        if [[ ${cur} == -* ]]; then
            mapfile -t COMPREPLY < <(compgen -W "${opts}" -- "${cur}")
            return 0
        fi

        # Complete service names
        local show_all=false
        for word in "${COMP_WORDS[@]}"; do
            case $word in
            -a | --all) show_all=true ;;
            esac
        done

        # Cache services for performance (bash version)
        if [[ -z $_servstat_bash_cache ]] || [[ $_servstat_bash_cache_time -lt $(($(date +%s) - 300)) ]]; then
            _servstat_bash_cache="$(_get_service_list $show_all 2>/dev/null | tr '\n' ' ')"
            _servstat_bash_cache_time=$(date +%s)
        fi

        services="$_servstat_bash_cache"
        mapfile -t COMPREPLY < <(compgen -W "${services}" -- "${cur}")
    }
    complete -F _servstat_completion_bash servstat
fi

# FISH completion (if fish shell is detected)
if command -v fish >/dev/null 2>&1 && [[ -n "$FISH_VERSION" ]]; then
    # Fish completion is typically defined in separate files
    # This creates a temporary completion that can be sourced
    _create_fish_completion() {
        cat >/tmp/servstat.fish <<'EOF'
# Fish completion for servstat
complete -c servstat -s a -l all -d "Show all services including disabled"
complete -c servstat -s d -l details -d "Show detailed service information"  
complete -c servstat -s s -l sort -d "Sort services alphabetically"
complete -c servstat -s j -l json -d "Output in JSON format"
complete -c servstat -s r -l running -d "Show only running services"
complete -c servstat -s x -l stopped -d "Show only stopped services"
complete -c servstat -s h -l help -d "Show help message"

# Dynamic service name completion
complete -c servstat -f -a "(__servstat_get_services)"

function __servstat_get_services
    # Check if _get_service_list function exists and call it
    if type -q _get_service_list
        _get_service_list false 2>/dev/null
    else
        # Fallback service detection for fish
        if command -v systemctl >/dev/null 2>&1
            systemctl list-units --type=service --no-legend --no-pager 2>/dev/null | awk '{print $1}' | sed 's/.service$//'
        else if command -v service >/dev/null 2>&1
            service -e 2>/dev/null
        else
            echo "ssh nginx apache2 mysql postgresql"
        end
    end
end
EOF
        echo "Fish completion created at /tmp/servstat.fish"
        echo "Source it with: source /tmp/servstat.fish"
    }
fi

# Universal completion fallback for other shells
# This works with basic tab completion in most POSIX shells
if [[ -z "$ZSH_VERSION" ]] && [[ -z "$BASH_VERSION" ]] && [[ -z "$FISH_VERSION" ]]; then
    # Try to set up basic completion for other shells
    if command -v bind >/dev/null 2>&1; then
        # For shells that support readline
        _servstat_basic_completion() {
            local services
            services="$(_get_service_list false 2>/dev/null | tr '\n' ' ')"
            echo "$services"
        }

        # This is a basic approach - may not work in all shells
        bind 'set completion-ignore-case on' 2>/dev/null
    fi
fi

# Smart completion helper function
_servstat_smart_complete() {
    local current_word="$1"
    local all_words="$2"

    # Determine if we should show all services
    local show_all=false
    echo "$all_words" | grep -q -E '\-a|\-\-all' && show_all=true

    # Get appropriate service list
    local services
    services="$(_get_service_list $show_all 2>/dev/null)"

    # Filter services based on current input
    if [[ -n "$current_word" ]]; then
        echo "$services" | grep "^$current_word" 2>/dev/null
    else
        echo "$services"
    fi
}

# Completion cache management
_servstat_clear_cache() {
    unset _servstat_services_cache _servstat_cache_time _servstat_bash_cache _servstat_bash_cache_time
    echo "🗑️ Service completion cache cleared"
}

# Add cache clearing as a hidden option
alias servstat-clear-cache='_servstat_clear_cache'

# Performance optimization: preload common services on shell startup
_servstat_preload_cache() {
    # Only preload if we haven't cached recently (5 min threshold)
    if [[ -z $_servstat_cache_time ]] || [[ $_servstat_cache_time -lt $(($(date +%s) - 300)) ]]; then
        # Run in background to avoid slowing shell startup
        (
            mapfile -t _servstat_services_cache < <(_get_service_list false 2>/dev/null)
            _servstat_cache_time=$(date +%s)
        ) &
    fi
}

# Auto-preload cache for better performance (optional)
# Uncomment the next line to enable background cache preloading
# _servstat_preload_cache

# Completion testing function
_test_servstat_completion() {
    echo "🧪 Testing servstat completion support:"
    echo ""

    # Test shell detection
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "✅ ZSH detected - Advanced completion available"
        echo "   • Option completion with descriptions"
        echo "   • Dynamic service list based on flags"
        echo "   • Intelligent caching"
    elif [[ -n "$BASH_VERSION" ]]; then
        echo "✅ BASH detected - Full completion available"
        echo "   • Option and service name completion"
        echo "   • Context-aware service lists"
        echo "   • Performance caching"
    elif [[ -n "$FISH_VERSION" ]]; then
        echo "🐟 FISH detected - Manual setup required"
        echo "   • Run '_create_fish_completion' to generate fish completion"
        echo "   • Then source the generated file"
    else
        echo "⚙️ Other shell detected - Basic completion available"
        echo "   • Limited completion support"
        echo "   • Consider switching to zsh or bash for better experience"
    fi

    echo ""
    echo "🎯 Testing service detection:"

    local system_info os_type service_manager

    system_info="$(_detect_system)"
    os_type="${system_info%|*}"
    service_manager="${system_info#*|}"

    echo "   • OS:              $os_type"
    echo "   • Service Manager: $service_manager"

    echo ""
    echo "📋 Sample services for completion:"
    _get_service_list false 2>/dev/null | head -10 | while read -r service; do
        echo "   • $service"
    done

    echo ""
    echo "💡 Try typing: servstat <TAB> or servstat ssh<TAB>"
}

# Make test function available
alias test-servstat-completion='_test_servstat_completion'
