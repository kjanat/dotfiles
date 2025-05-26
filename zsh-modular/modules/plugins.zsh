# ============================================================================
# MODULE: PLUGINS
# ============================================================================
# Plugin management system for ZSH enhancements including syntax highlighting and autosuggestions.

# Plugin directory configuration
ZSH_PLUGIN_DIR="${ZSH_CONFIG_DIR}/plugins"
ZSH_CACHE_DIR="${ZSH_CONFIG_DIR}/cache"

# Create plugin and cache directories if they don't exist
[[ ! -d "$ZSH_PLUGIN_DIR" ]] && mkdir -p "$ZSH_PLUGIN_DIR"
[[ ! -d "$ZSH_CACHE_DIR" ]] && mkdir -p "$ZSH_CACHE_DIR"

# Plugin loader function
load_plugin() {
    local plugin_name="$1"
    local plugin_file="$ZSH_PLUGIN_DIR/$plugin_name/$plugin_name.plugin.zsh"

    if [[ -f "$plugin_file" ]]; then
        source "$plugin_file"
        [[ "$ZSH_DEBUG" == "true" ]] && echo "✅ Loaded plugin: $plugin_name"
        return 0
    else
        [[ "$ZSH_DEBUG" == "true" ]] && echo "❌ Plugin not found: $plugin_name"
        return 1
    fi
}

# Load syntax highlighting (multiple possible locations)
load_syntax_highlighting() {
    local highlighting_locations=(
        "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "/opt/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    )

    for location in "${highlighting_locations[@]}"; do
        if [[ -f "$location" ]]; then
            source "$location"

            # Custom highlighting styles
            ZSH_HIGHLIGHT_STYLES[default]=none
            ZSH_HIGHLIGHT_STYLES[unknown - token]=fg=red,bold
            ZSH_HIGHLIGHT_STYLES[reserved - word]=fg=cyan,bold
            ZSH_HIGHLIGHT_STYLES[suffix - alias]=fg=green,underline
            ZSH_HIGHLIGHT_STYLES[global - alias]=fg=cyan
            ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
            ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
            ZSH_HIGHLIGHT_STYLES[path]=underline
            ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
            ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
            ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[history - expansion]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[command - substitution]=none
            ZSH_HIGHLIGHT_STYLES[command - substitution - delimiter]=fg=magenta
            ZSH_HIGHLIGHT_STYLES[process - substitution]=none
            ZSH_HIGHLIGHT_STYLES[process - substitution - delimiter]=fg=magenta
            ZSH_HIGHLIGHT_STYLES[single - hyphen - option]=fg=cyan
            ZSH_HIGHLIGHT_STYLES[double - hyphen - option]=fg=cyan
            ZSH_HIGHLIGHT_STYLES[back - quoted - argument]=none
            ZSH_HIGHLIGHT_STYLES[back - quoted - argument - delimiter]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[single - quoted - argument]=fg=yellow
            ZSH_HIGHLIGHT_STYLES[double - quoted - argument]=fg=yellow
            ZSH_HIGHLIGHT_STYLES[dollar - quoted - argument]=fg=yellow
            ZSH_HIGHLIGHT_STYLES[rc - quote]=fg=magenta
            ZSH_HIGHLIGHT_STYLES[dollar - double - quoted - argument]=fg=magenta
            ZSH_HIGHLIGHT_STYLES[back - double - quoted - argument]=fg=magenta
            ZSH_HIGHLIGHT_STYLES[back - dollar - quoted - argument]=fg=magenta
            ZSH_HIGHLIGHT_STYLES[assign]=none
            ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
            ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
            ZSH_HIGHLIGHT_STYLES[named - fd]=none
            ZSH_HIGHLIGHT_STYLES[numeric - fd]=none
            ZSH_HIGHLIGHT_STYLES[arg0]=fg=green

            [[ "$ZSH_DEBUG" == "true" ]] && echo "✅ Syntax highlighting loaded from $location"
            return 0
        fi
    done

    [[ "$ZSH_DEBUG" == "true" ]] && echo "❌ Syntax highlighting not found"
    return 1
}

# Load autosuggestions (multiple possible locations)
load_autosuggestions() {
    local suggestion_locations=(
        "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "/opt/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
    )

    for location in "${suggestion_locations[@]}"; do
        if [[ -f "$location" ]]; then
            source "$location"

            # Configure autosuggestions
            ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
            ZSH_AUTOSUGGEST_STRATEGY=(history completion)
            ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
            ZSH_AUTOSUGGEST_USE_ASYNC=1

            # Custom accept key bindings
            bindkey '^[[1;5C' forward-word # Ctrl+Right to accept word
            bindkey '^I' complete-word     # Tab for completion

            [[ "$ZSH_DEBUG" == "true" ]] && echo "✅ Autosuggestions loaded from $location"
            return 0
        fi
    done

    [[ "$ZSH_DEBUG" == "true" ]] && echo "❌ Autosuggestions not found"
    return 1
}

# Load additional completions
load_additional_completions() {
    local completion_dirs=(
        "/usr/local/share/zsh/site-functions"
        "/usr/share/zsh/site-functions"
        "/opt/local/share/zsh/site-functions"
        "$HOME/.zsh/completions"
        "$ZSH_PLUGIN_DIR/completions"
    )

    local loaded_dirs=0
    for comp_dir in "${completion_dirs[@]}"; do
        if [[ -d "$comp_dir" ]]; then
            fpath=("$comp_dir" $fpath)
            loaded_dirs=$((loaded_dirs + 1))
        fi
    done

    if [[ $loaded_dirs -gt 0 ]]; then
        [[ "$ZSH_DEBUG" == "true" ]] && echo "✅ Additional completions loaded from $loaded_dirs directories"
    fi

    # Load bash completion compatibility
    if autoload -U +X bashcompinit 2>/dev/null; then
        bashcompinit
        [[ "$ZSH_DEBUG" == "true" ]] && echo "✅ Bash completion compatibility loaded"
    fi
}

# Plugin management functions
plugin_list() {
    echo "📦 Available plugins in $ZSH_PLUGIN_DIR:"
    if [[ -d "$ZSH_PLUGIN_DIR" ]]; then
        for plugin in "$ZSH_PLUGIN_DIR"/*; do
            if [[ -d "$plugin" ]]; then
                local plugin_name=$(basename "$plugin")
                if [[ -f "$plugin/$plugin_name.plugin.zsh" ]]; then
                    echo "  ✅ $plugin_name (ready)"
                else
                    echo "  ❌ $plugin_name (missing plugin file)"
                fi
            fi
        done
    else
        echo "  No plugins directory found"
    fi
}

plugin_install() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: plugin_install <git_url> <plugin_name>"
        echo "Example: plugin_install https://github.com/zsh-users/zsh-syntax-highlighting.git zsh-syntax-highlighting"
        return 1
    fi

    local git_url="$1"
    local plugin_name="$2"
    local plugin_dir="$ZSH_PLUGIN_DIR/$plugin_name"

    if [[ -d "$plugin_dir" ]]; then
        echo "❌ Plugin $plugin_name already exists"
        return 1
    fi

    if command -v git >/dev/null; then
        echo "📦 Installing plugin $plugin_name..."
        git clone "$git_url" "$plugin_dir" && echo "✅ Plugin $plugin_name installed successfully"
    else
        echo "❌ Git not available for plugin installation"
        return 1
    fi
}

plugin_update() {
    local plugin_name="$1"

    if [[ -z "$plugin_name" ]]; then
        echo "🔄 Updating all plugins..."
        for plugin in "$ZSH_PLUGIN_DIR"/*; do
            if [[ -d "$plugin" && -d "$plugin/.git" ]]; then
                local name=$(basename "$plugin")
                echo "Updating $name..."
                (cd "$plugin" && git pull)
            fi
        done
    else
        local plugin_dir="$ZSH_PLUGIN_DIR/$plugin_name"
        if [[ -d "$plugin_dir/.git" ]]; then
            echo "🔄 Updating plugin $plugin_name..."
            (cd "$plugin_dir" && git pull)
        else
            echo "❌ Plugin $plugin_name not found or not a git repository"
            return 1
        fi
    fi
}

plugin_remove() {
    local plugin_name="$1"

    if [[ -z "$plugin_name" ]]; then
        echo "Usage: plugin_remove <plugin_name>"
        return 1
    fi

    local plugin_dir="$ZSH_PLUGIN_DIR/$plugin_name"
    if [[ -d "$plugin_dir" ]]; then
        echo "🗑️  Removing plugin $plugin_name..."
        rm -rf "$plugin_dir" && echo "✅ Plugin $plugin_name removed"
    else
        echo "❌ Plugin $plugin_name not found"
        return 1
    fi
}

# Custom completion functions for TrueNAS/ZFS
setup_custom_completions() {
    # ZFS dataset completion
    _zfs_datasets() {
        local -a datasets
        datasets=($(zfs list -H -o name 2>/dev/null))
        compadd "$@" $datasets
    }

    # ZFS pool completion
    _zfs_pools() {
        local -a pools
        pools=($(zpool list -H -o name 2>/dev/null))
        compadd "$@" $pools
    }

    # Register completions if ZFS is available
    if command -v zfs >/dev/null; then
        compdef _zfs_datasets zfs
        compdef _zfs_pools zpool
        [[ "$ZSH_DEBUG" == "true" ]] && echo "✅ ZFS completions registered"
    fi

    # Service completion for FreeBSD
    if command -v service >/dev/null && [[ "$OSTYPE" == "freebsd"* ]]; then
        _freebsd_services() {
            local -a services
            services=($(service -l 2>/dev/null))
            compadd "$@" $services
        }
        compdef _freebsd_services service
        [[ "$ZSH_DEBUG" == "true" ]] && echo "✅ FreeBSD service completions registered"
    fi
}

# Performance tracking for plugin loading
track_load_time() {
    local start_time=$SECONDS
    "$@"
    local end_time=$SECONDS
    local duration=$((end_time - start_time))

    if [[ $duration -gt 1 ]]; then
        [[ "$ZSH_DEBUG" == "true" ]] && echo "⏱️  Plugin loading took ${duration}s"
    fi
}

# Auto-load plugins from directory
auto_load_plugins() {
    if [[ -d "$ZSH_PLUGIN_DIR" ]]; then
        local loaded_count=0
        for plugin in "$ZSH_PLUGIN_DIR"/*; do
            if [[ -d "$plugin" ]]; then
                local plugin_name=$(basename "$plugin")
                # Skip certain plugins that are loaded manually
                case "$plugin_name" in
                zsh-syntax-highlighting | zsh-autosuggestions) continue ;;
                esac

                if load_plugin "$plugin_name"; then
                    loaded_count=$((loaded_count + 1))
                fi
            fi
        done

        [[ "$ZSH_DEBUG" == "true" ]] && [[ $loaded_count -gt 0 ]] && echo "📦 Auto-loaded $loaded_count plugins"
    fi
}

# Main plugin loading sequence
main() {
    # Load core enhancements
    track_load_time load_syntax_highlighting
    track_load_time load_autosuggestions
    track_load_time load_additional_completions

    # Set up custom completions
    track_load_time setup_custom_completions

    # Auto-load additional plugins
    track_load_time auto_load_plugins

    # Performance optimization: reduce escape sequence timeout
    export KEYTIMEOUT=1
}

# Initialize plugins
main

# Module loaded successfully
[[ "$ZSH_DEBUG" == "true" ]] && echo "🔌 Plugin system loaded"
