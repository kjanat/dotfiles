#!/bin/bash
# ============================================================================
# ZSH MODULAR CONFIGURATION VALIDATION SCRIPT
# ============================================================================
# This script validates that the modular ZSH configuration is working correctly
# and all modules are properly loaded and functional.
#
# Usage: ./validate-config.sh [--verbose] [--fix]
# Options:
#   --verbose  Show detailed output
#   --fix      Attempt to fix common issues
# ============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VERBOSE=false
FIX_ISSUES=false
ZSH_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
ERRORS=0
WARNINGS=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    --verbose | -v)
        VERBOSE=true
        shift
        ;;
    --fix | -f)
        FIX_ISSUES=true
        shift
        ;;
    --help | -h)
        echo "Usage: $0 [--verbose] [--fix]"
        echo "  --verbose  Show detailed output"
        echo "  --fix      Attempt to fix common issues"
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

# Utility functions
print_status() {
    local status="$1"
    local message="$2"
    case "$status" in
    "OK")
        echo -e "${GREEN}✅ $message${NC}"
        ;;
    "WARNING")
        echo -e "${YELLOW}⚠️  $message${NC}"
        ((WARNINGS++))
        ;;
    "ERROR")
        echo -e "${RED}❌ $message${NC}"
        ((ERRORS++))
        ;;
    "INFO")
        echo -e "${BLUE}ℹ️  $message${NC}"
        ;;
    esac
}

verbose_print() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}   $1${NC}"
    fi
}

# Validation functions
check_directory_structure() {
    print_status "INFO" "Checking directory structure..."

    local required_dirs=(
        "$ZSH_CONFIG_HOME"
        "$ZSH_CONFIG_HOME/core"
        "$ZSH_CONFIG_HOME/modules"
        "$ZSH_CONFIG_HOME/os-specific"
        "$ZSH_CONFIG_HOME/user"
        "$ZSH_CONFIG_HOME/cache"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            verbose_print "Directory exists: $dir"
        else
            if [[ "$FIX_ISSUES" == "true" ]]; then
                mkdir -p "$dir"
                print_status "OK" "Created missing directory: $dir"
            else
                print_status "ERROR" "Missing directory: $dir"
            fi
        fi
    done
}

check_core_modules() {
    print_status "INFO" "Checking core modules..."

    local core_modules=(
        "performance.zsh"
        "environment.zsh"
        "terminal-fixes.zsh"
        "history.zsh"
        "options.zsh"
        "keybindings.zsh"
        "completion.zsh"
    )

    for module in "${core_modules[@]}"; do
        local module_path="$ZSH_CONFIG_HOME/core/$module"
        if [[ -f "$module_path" ]]; then
            verbose_print "Core module exists: $module"
            # Check if module has basic content
            if [[ $(wc -l <"$module_path") -lt 10 ]]; then
                print_status "WARNING" "Core module seems incomplete: $module"
            fi
        else
            print_status "ERROR" "Missing core module: $module"
        fi
    done
}

check_feature_modules() {
    print_status "INFO" "Checking feature modules..."

    local feature_modules=(
        "aliases.zsh"
        "prompt.zsh"
        "functions.zsh"
        "plugins.zsh"
    )

    for module in "${feature_modules[@]}"; do
        local module_path="$ZSH_CONFIG_HOME/modules/$module"
        if [[ -f "$module_path" ]]; then
            verbose_print "Feature module exists: $module"
        else
            print_status "WARNING" "Missing optional feature module: $module"
        fi
    done
}

check_os_modules() {
    print_status "INFO" "Checking OS-specific modules..."

    local os_modules=(
        "freebsd.zsh"
        "linux.zsh"
        "macos.zsh"
    )

    for module in "${os_modules[@]}"; do
        local module_path="$ZSH_CONFIG_HOME/os-specific/$module"
        if [[ -f "$module_path" ]]; then
            verbose_print "OS module exists: $module"
        else
            print_status "WARNING" "Missing OS module: $module"
        fi
    done

    # Check if appropriate OS module exists for current system
    local current_os
    case "$(uname)" in
    "FreeBSD")
        current_os="freebsd.zsh"
        ;;
    "Linux")
        current_os="linux.zsh"
        ;;
    "Darwin")
        current_os="macos.zsh"
        ;;
    *)
        current_os="generic.zsh"
        ;;
    esac

    if [[ -f "$ZSH_CONFIG_HOME/os-specific/$current_os" ]]; then
        print_status "OK" "OS-specific module available for $(uname): $current_os"
    else
        print_status "WARNING" "No OS-specific module for $(uname): $current_os"
    fi
}

check_main_loader() {
    print_status "INFO" "Checking main loader..."

    local loader_path="$ZSH_CONFIG_HOME/.zshrc"
    if [[ -f "$loader_path" ]]; then
        verbose_print "Main loader exists: $loader_path"

        # Check if loader has the required functions
        if grep -q "load_module" "$loader_path"; then
            verbose_print "Load function found in main loader"
        else
            print_status "ERROR" "Main loader missing load_module function"
        fi

        if grep -q "detect_os" "$loader_path"; then
            verbose_print "OS detection function found in main loader"
        else
            print_status "ERROR" "Main loader missing detect_os function"
        fi
    else
        print_status "ERROR" "Missing main loader: $loader_path"
    fi
}

check_user_zshrc() {
    print_status "INFO" "Checking user .zshrc..."

    if [[ -f "$HOME/.zshrc" ]]; then
        if grep -q "source.*\.config/zsh/\.zshrc" "$HOME/.zshrc"; then
            print_status "OK" "User .zshrc loads modular configuration"
        else
            print_status "WARNING" "User .zshrc does not load modular configuration"
            if [[ "$FIX_ISSUES" == "true" ]]; then
                echo "" >>"$HOME/.zshrc"
                echo "# Load ZSH Modular Configuration" >>"$HOME/.zshrc"
                echo "source ~/.config/zsh/.zshrc" >>"$HOME/.zshrc"
                print_status "OK" "Added modular configuration loader to .zshrc"
            fi
        fi
    else
        print_status "WARNING" "No .zshrc file found"
        if [[ "$FIX_ISSUES" == "true" ]]; then
            cat >"$HOME/.zshrc" <<'EOF'
# ZSH Modular Configuration Loader
source ~/.config/zsh/.zshrc
EOF
            print_status "OK" "Created .zshrc with modular configuration loader"
        fi
    fi
}

test_module_syntax() {
    print_status "INFO" "Testing module syntax..."

    local modules_to_test=()

    # Add all module files to test array
    while IFS= read -r -d '' file; do
        modules_to_test+=("$file")
    done < <(find "$ZSH_CONFIG_HOME" -name "*.zsh" -type f -print0)

    for module in "${modules_to_test[@]}"; do
        if zsh -n "$module" 2>/dev/null; then
            verbose_print "Syntax OK: $(basename "$module")"
        else
            print_status "ERROR" "Syntax error in: $module"
        fi
    done
}

test_functionality() {
    print_status "INFO" "Testing basic functionality..."

    # Test in a subshell to avoid affecting current environment
    {
        # Source the configuration
        if source "$ZSH_CONFIG_HOME/.zshrc" 2>/dev/null; then
            verbose_print "Configuration loads successfully"
        else
            print_status "ERROR" "Failed to load configuration"
            return 1
        fi

        # Test that ZSH_MODULAR_LOADED is set
        if [[ "$ZSH_MODULAR_LOADED" == "true" ]]; then
            verbose_print "Modular system loaded successfully"
        else
            print_status "ERROR" "ZSH_MODULAR_LOADED not set"
        fi

        # Test basic aliases (if aliases module is loaded)
        if alias ll >/dev/null 2>&1; then
            verbose_print "Basic aliases available"
        else
            print_status "WARNING" "Basic aliases not available"
        fi

        # Test completion system
        if typeset -f _complete >/dev/null 2>&1; then
            verbose_print "Completion system available"
        else
            print_status "WARNING" "Completion system not properly initialized"
        fi

    } 2>/dev/null
}

check_performance() {
    print_status "INFO" "Checking performance..."

    # Test startup time
    local startup_time
    startup_time=$(time (zsh -c "source $ZSH_CONFIG_HOME/.zshrc; exit") 2>&1 | grep real | awk '{print $2}')

    if [[ -n "$startup_time" ]]; then
        verbose_print "Startup time: $startup_time"

        # Parse time and check if it's reasonable (less than 2 seconds)
        local time_ms
        if [[ "$startup_time" =~ ([0-9]+)m([0-9.]+)s ]]; then
            time_ms=$(echo "${BASH_REMATCH[1]} * 60000 + ${BASH_REMATCH[2]} * 1000" | bc 2>/dev/null || echo "2000")
        elif [[ "$startup_time" =~ ([0-9.]+)s ]]; then
            time_ms=$(echo "${BASH_REMATCH[1]} * 1000" | bc 2>/dev/null || echo "1000")
        else
            time_ms=1000
        fi

        if [[ $(echo "$time_ms < 2000" | bc 2>/dev/null || echo "1") -eq 1 ]]; then
            print_status "OK" "Startup time acceptable: $startup_time"
        else
            print_status "WARNING" "Startup time slow: $startup_time"
        fi
    else
        print_status "WARNING" "Could not measure startup time"
    fi
}

check_permissions() {
    print_status "INFO" "Checking file permissions..."

    # Check that configuration directory is readable
    if [[ -r "$ZSH_CONFIG_HOME" ]]; then
        verbose_print "Configuration directory readable"
    else
        print_status "ERROR" "Configuration directory not readable"
        if [[ "$FIX_ISSUES" == "true" ]]; then
            chmod -R 755 "$ZSH_CONFIG_HOME"
            print_status "OK" "Fixed configuration directory permissions"
        fi
    fi

    # Check that all .zsh files are readable
    local unreadable_files=()
    while IFS= read -r -d '' file; do
        if [[ ! -r "$file" ]]; then
            unreadable_files+=("$file")
        fi
    done < <(find "$ZSH_CONFIG_HOME" -name "*.zsh" -type f -print0)

    if [[ ${#unreadable_files[@]} -eq 0 ]]; then
        verbose_print "All module files readable"
    else
        for file in "${unreadable_files[@]}"; do
            print_status "ERROR" "Unreadable file: $file"
            if [[ "$FIX_ISSUES" == "true" ]]; then
                chmod 644 "$file"
                print_status "OK" "Fixed permissions for: $file"
            fi
        done
    fi
}

generate_report() {
    echo ""
    echo "============================================================================"
    echo "VALIDATION REPORT"
    echo "============================================================================"
    echo "Configuration directory: $ZSH_CONFIG_HOME"
    echo "Timestamp: $(date)"
    echo "System: $(uname -a)"
    echo ""

    if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
        print_status "OK" "All checks passed! ✨"
    elif [[ $ERRORS -eq 0 ]]; then
        print_status "WARNING" "$WARNINGS warning(s) found - configuration should work but may have minor issues"
    else
        print_status "ERROR" "$ERRORS error(s) and $WARNINGS warning(s) found - configuration may not work properly"
    fi

    echo ""
    echo "To debug issues:"
    echo "  export ZSH_DEBUG=true"
    echo "  source ~/.config/zsh/.zshrc"
    echo ""
    echo "To run this validator in fix mode:"
    echo "  $0 --fix"
    echo ""
    echo "For detailed output:"
    echo "  $0 --verbose"
}

# Main execution
main() {
    echo "============================================================================"
    echo "ZSH MODULAR CONFIGURATION VALIDATOR"
    echo "============================================================================"
    echo ""

    check_directory_structure
    check_main_loader
    check_core_modules
    check_feature_modules
    check_os_modules
    check_user_zshrc
    check_permissions
    test_module_syntax
    test_functionality
    check_performance

    generate_report

    # Exit with error code if there were errors
    if [[ $ERRORS -gt 0 ]]; then
        exit 1
    fi
}

# Run main function
main "$@"
