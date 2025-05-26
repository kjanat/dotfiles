# ============================================================================
# MODULAR ZSH CONFIGURATION LOADER
# ============================================================================
#
# This is the main .zshrc file that loads modular ZSH configuration components.
# It automatically detects the operating system and loads appropriate modules.
#
# Directory Structure:
#   ~/.config/zsh/
#   ├── core/           - Core ZSH functionality (OS-independent)
#   ├── modules/        - Feature modules
#   ├── os-specific/    - OS-specific configurations
#   ├── user/           - User customizations
#   └── cache/          - Temporary cache files
#
# Author: ZSH Modular Configuration System
# Based on: Ultimate TrueNAS ZSH Configuration
# ============================================================================

# Configuration directories
export ZSH_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export ZSH_CACHE_DIR="${ZSH_CONFIG_HOME}/cache"
export ZSH_MODULE_DIR="${ZSH_CONFIG_HOME}/modules"
export ZSH_CORE_DIR="${ZSH_CONFIG_HOME}/core"
export ZSH_OS_DIR="${ZSH_CONFIG_HOME}/os-specific"
export ZSH_USER_DIR="${ZSH_CONFIG_HOME}/user"

# Create directories if they don't exist
for dir in "$ZSH_CONFIG_HOME" "$ZSH_CACHE_DIR" "$ZSH_MODULE_DIR" "$ZSH_CORE_DIR" "$ZSH_OS_DIR" "$ZSH_USER_DIR"; do
    [[ ! -d "$dir" ]] && mkdir -p "$dir" 2>/dev/null
done

# Module loading function with error handling
load_module() {
    local module_name="$1"
    local module_file="$2"
    local required="${3:-false}"

    if [[ -f "$module_file" ]]; then
        # shellcheck source=/dev/null
        if source "$module_file" 2>/dev/null; then
            [[ "$ZSH_DEBUG" == "true" ]] && echo "✅ Loaded: $module_name"
            return 0
        else
            echo "❌ Error loading $module_name: $module_file" >&2
            [[ "$required" == "true" ]] && return 1
        fi
    else
        if [[ "$required" == "true" ]]; then
            echo "❌ Required module not found: $module_name ($module_file)" >&2
            return 1
        else
            [[ "$ZSH_DEBUG" == "true" ]] && echo "⚠️ Optional module not found: $module_name"
        fi
    fi
    return 0
}

# Detect operating system
detect_os() {
    if [[ "$(uname)" == "FreeBSD" ]]; then
        if [[ -f /etc/version ]] && grep -q "TrueNAS" /etc/version 2>/dev/null; then
            echo "truenas"
        else
            echo "freebsd"
        fi
    elif [[ "$(uname)" == "Linux" ]]; then
        echo "linux"
    elif [[ "$(uname)" == "Darwin" ]]; then
        echo "macos"
    else
        echo "generic"
    fi
}

export ZSH_OS="$(detect_os)"

# Module loading order and configuration
ZSH_CORE_MODULES=(
    "performance"    # Must be first for startup optimization
    "environment"    # Basic environment setup
    "terminal-fixes" # Terminal compatibility fixes
    "history"        # History configuration
    "options"        # ZSH options
    "keybindings"    # Key bindings
    "completion"     # Completion system
)

ZSH_FEATURE_MODULES=(
    "aliases"   # Command aliases
    "prompt"    # Prompt system
    "functions" # Utility functions
    "plugins"   # Plugin management
)

ZSH_OPTIONAL_MODULES=(
    "syntax-highlighting" # Syntax highlighting
    "autosuggestions"     # Auto-suggestions
    "startup-banner"      # Welcome banner
)

# Load core modules (required)
echo "🚀 Loading ZSH Modular Configuration..."
for module in "${ZSH_CORE_MODULES[@]}"; do
    load_module "core/$module" "$ZSH_CORE_DIR/$module.zsh" true || {
        echo "❌ Failed to load required core module: $module" >&2
        echo "   Please check: $ZSH_CORE_DIR/$module.zsh" >&2
        return 1
    }
done

# Load OS-specific configuration
os_config="$ZSH_OS_DIR/$ZSH_OS.zsh"
if [[ -f "$os_config" ]]; then
    load_module "os-specific/$ZSH_OS" "$os_config"
fi

# Load feature modules
for module in "${ZSH_FEATURE_MODULES[@]}"; do
    load_module "modules/$module" "$ZSH_MODULE_DIR/$module.zsh"
done

# Load optional modules
for module in "${ZSH_OPTIONAL_MODULES[@]}"; do
    load_module "modules/$module" "$ZSH_MODULE_DIR/$module.zsh"
done

# Load user customizations
for user_file in "$ZSH_USER_DIR"/*.zsh; do
    [[ -f "$user_file" ]] && load_module "user/$(basename "$user_file")" "$user_file"
done

# Source local .zshrc.local if it exists (for machine-specific settings)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Final initialization
[[ "$ZSH_DEBUG" == "true" ]] && echo "🎉 ZSH Modular Configuration loaded successfully!"

# Export configuration for use by modules
export ZSH_MODULAR_LOADED=true
export ZSH_CONFIG_VERSION="1.0.0"
