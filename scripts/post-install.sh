#!/usr/bin/env bash
# Post-installation tasks for dotfiles setup

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Configuration
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

# Utility functions
dotfiles() {
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

# Post-installation tasks
setup_git_hooks() {
    print_header "Setting up Git hooks"

    local hooks_dir="$DOTFILES_DIR/hooks"
    if [ ! -d "$hooks_dir" ]; then
        mkdir -p "$hooks_dir"
    fi

    # Create pre-commit hook to prevent sensitive data
    cat >"$hooks_dir/pre-commit" <<'EOF'
#!/bin/bash
# Pre-commit hook to prevent committing sensitive information

# Check for common patterns that shouldn't be committed
sensitive_patterns=(
    "password\s*="
    "secret\s*="
    "api_?key\s*="
    "token\s*="
    "private_key"
    "-----BEGIN.*PRIVATE KEY-----"
)

for pattern in "${sensitive_patterns[@]}"; do
    if git diff --cached --name-only | xargs grep -l -i -E "$pattern" 2>/dev/null; then
        echo "Error: Potential sensitive information detected!"
        echo "Pattern: $pattern"
        echo "Please review your changes and remove sensitive data."
        exit 1
    fi
done

exit 0
EOF

    chmod +x "$hooks_dir/pre-commit"
    print_success "Git pre-commit hook created"

    # Set up the hooks directory
    dotfiles config core.hooksPath "$hooks_dir"
    print_success "Git hooks configured"
}

create_helpful_aliases() {
    print_header "Creating helpful aliases"

    # Check if aliases file exists in dotfiles
    if ! dotfiles ls-tree HEAD --name-only | grep -q "\.aliases$\|\.bash_aliases$"; then
        print_info "Creating initial aliases file"

        cat >"$HOME/.aliases" <<'EOF'
# Common aliases for dotfiles management
alias dotfiles-status='dotfiles status'
alias dotfiles-log='dotfiles log --oneline -10'
alias dotfiles-diff='dotfiles diff'
alias dotfiles-add='dotfiles add'
alias dotfiles-commit='dotfiles commit'
alias dotfiles-push='dotfiles push'
alias dotfiles-pull='dotfiles pull'

# Quick dotfiles operations
alias dotf='dotfiles'
alias dots='dotfiles status'
alias dotl='dotfiles log --oneline -10'
alias dotd='dotfiles diff'

# Backup management
alias show-backup='ls -la ~/.dotfiles-backup/'
alias restore-backup='echo "Usage: cp ~/.dotfiles-backup/path/to/file ~/path/to/file"'

# System information
alias sysinfo='uname -a && echo "Shell: $SHELL" && echo "User: $USER"'
EOF

        dotfiles add "$HOME/.aliases"
        print_success "Created ~/.aliases file"

        # Add sourcing to shell configs if not already present
        for rcfile in "$HOME/.bashrc" "$HOME/.zshrc"; do
            if [ -f "$rcfile" ] && ! grep -q "source.*\.aliases\|\..*\.aliases" "$rcfile"; then
                echo >>"$rcfile"
                echo "# Source aliases" >>"$rcfile"
                echo "[ -f ~/.aliases ] && source ~/.aliases" >>"$rcfile"
                print_success "Added aliases sourcing to $(basename "$rcfile")"
            fi
        done
    else
        print_info "Aliases file already exists in dotfiles"
    fi
}

setup_gitignore_global() {
    print_header "Setting up global gitignore"

    if [ ! -f "$HOME/.gitignore_global" ]; then
        cat >"$HOME/.gitignore_global" <<'EOF'
# Global gitignore for dotfiles

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor files
*~
*.swp
*.swo
.vscode/
.idea/

# Temporary files
*.tmp
*.temp
*.log
*.bak
*.old

# Compiled files
*.o
*.so
*.pyc
*.pyo
__pycache__/

# System files
.env
.env.local
.env.*.local
node_modules/
.npm/
.yarn/

# Backup directories (for dotfiles)
.dotfiles-backup/
dotfiles-backup*/
EOF

        dotfiles add "$HOME/.gitignore_global"
        dotfiles config core.excludesfile "$HOME/.gitignore_global"
        print_success "Created and configured global gitignore"
    else
        print_info "Global gitignore already exists"
    fi
}

check_shell_integration() {
    print_header "Checking shell integration"

    local shell_name=$(basename "$SHELL")
    case "$shell_name" in
    bash)
        if grep -q "dotfiles" "$HOME/.bashrc" 2>/dev/null; then
            print_success "Dotfiles alias found in .bashrc"
        else
            print_warning "Dotfiles alias not found in .bashrc"
        fi
        ;;
    zsh)
        if grep -q "dotfiles" "$HOME/.zshrc" 2>/dev/null; then
            print_success "Dotfiles alias found in .zshrc"
        else
            print_warning "Dotfiles alias not found in .zshrc"
        fi
        ;;
    fish)
        if [ -f "$HOME/.config/fish/functions/dotfiles.fish" ]; then
            print_success "Dotfiles function found for fish"
        else
            print_warning "Dotfiles function not found for fish"
        fi
        ;;
    csh | tcsh)
        if grep -q "dotfiles" "$HOME/.cshrc" 2>/dev/null; then
            print_success "Dotfiles alias found in .cshrc"
        else
            print_warning "Dotfiles alias not found in .cshrc"
        fi
        ;;
    *)
        print_warning "Unknown shell: $shell_name"
        ;;
    esac
}

create_maintenance_script() {
    print_header "Creating maintenance script"

    local script_path="$HOME/.local/bin/dotfiles-maintenance"
    mkdir -p "$(dirname "$script_path")"

    cat >"$script_path" <<'EOF'
#!/usr/bin/env bash
# Dotfiles maintenance script

set -euo pipefail

dotfiles() {
    git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

echo "=== Dotfiles Maintenance ==="

# Check for uncommitted changes
if ! dotfiles diff-index --quiet HEAD --; then
    echo "⚠ You have uncommitted changes:"
    dotfiles status --porcelain
    echo
fi

# Show recent commits
echo "Recent commits:"
dotfiles log --oneline -5
echo

# Check remote status
echo "Checking remote status..."
dotfiles fetch
local_rev=$(dotfiles rev-parse HEAD)
remote_rev=$(dotfiles rev-parse @{u} 2>/dev/null || echo "")

if [ -n "$remote_rev" ]; then
    if [ "$local_rev" = "$remote_rev" ]; then
        echo "✓ Up to date with remote"
    elif [ "$(dotfiles merge-base HEAD @{u})" = "$local_rev" ]; then
        echo "⚠ Remote has new commits (pull needed)"
    elif [ "$(dotfiles merge-base HEAD @{u})" = "$remote_rev" ]; then
        echo "⚠ Local has new commits (push needed)"
    else
        echo "⚠ Branches have diverged"
    fi
else
    echo "⚠ No remote tracking branch"
fi

echo
echo "=== Maintenance Complete ==="
EOF

    chmod +x "$script_path"
    print_success "Created maintenance script at $script_path"

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        for rcfile in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
            if [ -f "$rcfile" ] && ! grep -q "\.local/bin" "$rcfile"; then
                echo >>"$rcfile"
                echo "# Add local bin to PATH" >>"$rcfile"
                echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$rcfile"
                print_success "Added ~/.local/bin to PATH in $(basename "$rcfile")"
                break
            fi
        done
    fi
}

setup_readme_access() {
    print_header "Setting up README access"

    # Create symlink to README for easy access
    if [ ! -L "$HOME/dotfiles-readme.md" ] && [ ! -f "$HOME/dotfiles-readme.md" ]; then
        local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
        ln -s "$script_dir/README.md" "$HOME/dotfiles-readme.md"
        print_success "Created symlink to README.md"
    fi

    # Add helpful function to view documentation
    for rcfile in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rcfile" ] && ! grep -q "dothelp" "$rcfile"; then
            cat >>"$rcfile" <<'EOF'

# Dotfiles help function
dothelp() {
    if command -v bat &>/dev/null; then
        bat ~/dotfiles-readme.md
    elif command -v less &>/dev/null; then
        less ~/dotfiles-readme.md
    else
        cat ~/dotfiles-readme.md
    fi
}
EOF
            print_success "Added dothelp function to $(basename "$rcfile")"
        fi
    done
}

generate_usage_guide() {
    print_header "Generating usage guide"

    cat >"$HOME/.dotfiles-usage.md" <<'EOF'
# Dotfiles Usage Guide

## Quick Commands

### Status and Information
```bash
dotfiles status          # Show status of tracked files
dotfiles log --oneline   # Show recent commits
dotfiles diff            # Show uncommitted changes
```

### Adding New Files
```bash
dotfiles add ~/.config/newfile    # Track a new file
dotfiles commit -m "Add newfile"  # Commit changes
dotfiles push                     # Push to remote
```

### Synchronization
```bash
dotfiles pull            # Pull latest changes
dotfiles push            # Push local changes
```

### Useful Aliases (if .aliases is sourced)
```bash
dots                     # dotfiles status
dotl                     # dotfiles log --oneline -10
dotd                     # dotfiles diff
```

## Troubleshooting

### Command not found
If `dotfiles` command is not available:
```bash
# Manually define the alias
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# Or restart your shell
exec $SHELL
```

### View backup files
```bash
ls -la ~/.dotfiles-backup/
```

### Restore a backup file
```bash
cp ~/.dotfiles-backup/path/to/file ~/path/to/file
```

## Maintenance

### Run maintenance check
```bash
dotfiles-maintenance     # If script was created
```

### Clean up
```bash
dotfiles gc              # Git garbage collection
dotfiles prune           # Remove tracking of deleted files
```

## Getting Help

- Run `dothelp` to view the main README
- Check `~/.dotfiles-usage.md` (this file) for quick reference
- Visit the documentation in the bootstrap repository

EOF

    print_success "Created usage guide at ~/.dotfiles-usage.md"
}

# Main function
main() {
    print_header "Running post-installation tasks"

    # Check if dotfiles repository exists
    if [ ! -d "$DOTFILES_DIR" ]; then
        print_error "Dotfiles repository not found at $DOTFILES_DIR"
        print_info "Please run the bootstrap script first"
        exit 1
    fi

    # Run tasks
    setup_git_hooks
    echo

    create_helpful_aliases
    echo

    setup_gitignore_global
    echo

    check_shell_integration
    echo

    create_maintenance_script
    echo

    setup_readme_access
    echo

    generate_usage_guide
    echo

    print_header "Post-installation Summary"
    print_success "Git hooks configured"
    print_success "Helpful aliases created"
    print_success "Global gitignore set up"
    print_success "Shell integration checked"
    print_success "Maintenance script created"
    print_success "Documentation access configured"

    echo
    print_info "Next steps:"
    echo "  1. Start a new shell session or run: source ~/.bashrc (or ~/.zshrc)"
    echo "  2. Run 'dotfiles status' to verify everything is working"
    echo "  3. Use 'dothelp' to view the README anytime"
    echo "  4. Check '~/.dotfiles-usage.md' for quick reference"
    echo "  5. Run 'dotfiles-maintenance' periodically to check status"
}

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Run post-installation tasks for dotfiles setup"
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo
    echo "This script sets up:"
    echo "  • Git hooks for security"
    echo "  • Helpful aliases"
    echo "  • Global gitignore"
    echo "  • Shell integration checks"
    echo "  • Maintenance scripts"
    echo "  • Documentation access"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
        show_help
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
done

# Run main function
main
