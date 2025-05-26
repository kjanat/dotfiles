#!/usr/bin/env bash
# System validation script for dotfiles setup

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

# Validation functions
check_command() {
    local cmd=$1
    local required=${2:-false}

    if command -v "$cmd" &>/dev/null; then
        local version=$(eval "$cmd --version 2>/dev/null | head -1" || echo "Unknown version")
        print_success "$cmd is installed ($version)"
        return 0
    else
        if [ "$required" = "true" ]; then
            print_error "$cmd is required but not installed"
            return 1
        else
            print_warning "$cmd is not installed (optional)"
            return 0
        fi
    fi
}

check_file() {
    local file=$1
    local required=${2:-false}

    if [ -f "$file" ]; then
        print_success "$file exists"
        return 0
    else
        if [ "$required" = "true" ]; then
            print_error "$file is required but not found"
            return 1
        else
            print_warning "$file not found (optional)"
            return 0
        fi
    fi
}

check_directory() {
    local dir=$1
    local required=${2:-false}

    if [ -d "$dir" ]; then
        print_success "$dir exists"
        return 0
    else
        if [ "$required" = "true" ]; then
            print_error "$dir is required but not found"
            return 1
        else
            print_warning "$dir not found (optional)"
            return 0
        fi
    fi
}

# Main validation
main() {
    print_header "System Validation for Dotfiles Setup"

    local errors=0

    # System Information
    print_header "System Information"
    print_info "OS: $(uname -s)"
    print_info "Architecture: $(uname -m)"
    print_info "Kernel: $(uname -r)"
    if [ -f /etc/os-release ]; then
        local distro=$(grep '^NAME=' /etc/os-release | cut -d'"' -f2)
        print_info "Distribution: $distro"
    fi
    print_info "Shell: $SHELL"
    print_info "User: $USER"
    print_info "Home: $HOME"
    echo

    # Required Commands
    print_header "Required Commands"
    check_command "git" true || ((errors++))
    check_command "curl" true || ((errors++))

    # Optional but Recommended Commands
    print_header "Recommended Commands"
    check_command "vim"
    check_command "zsh"
    check_command "tmux"
    check_command "tree"
    echo

    # Shell-specific checks
    print_header "Shell Configuration"
    case "$SHELL" in
    */bash)
        check_file "$HOME/.bashrc"
        check_file "$HOME/.bash_profile"
        ;;
    */zsh)
        check_file "$HOME/.zshrc"
        check_directory "$HOME/.oh-my-zsh"
        ;;
    */fish)
        check_file "$HOME/.config/fish/config.fish"
        ;;
    */csh | */tcsh)
        check_file "$HOME/.cshrc"
        ;;
    esac
    echo

    # Git Configuration
    print_header "Git Configuration"
    if command -v git &>/dev/null; then
        local git_user=$(git config --global user.name 2>/dev/null || echo "Not set")
        local git_email=$(git config --global user.email 2>/dev/null || echo "Not set")
        print_info "Git user.name: $git_user"
        print_info "Git user.email: $git_email"

        if [ "$git_user" = "Not set" ] || [ "$git_email" = "Not set" ]; then
            print_warning "Git user configuration incomplete"
        fi
    fi
    echo

    # SSH Configuration
    print_header "SSH Configuration"
    check_directory "$HOME/.ssh"
    check_file "$HOME/.ssh/id_rsa" || check_file "$HOME/.ssh/id_ed25519"
    if [ -f "$HOME/.ssh/id_rsa.pub" ] || [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
        print_success "SSH public key found"
    else
        print_warning "No SSH public key found"
    fi
    echo

    # Network Connectivity
    print_header "Network Connectivity"
    if ping -c 1 github.com &>/dev/null; then
        print_success "Can reach github.com"
    else
        print_error "Cannot reach github.com"
        ((errors++))
    fi

    if command -v git &>/dev/null; then
        if git ls-remote https://github.com/octocat/Hello-World.git &>/dev/null; then
            print_success "Git can access GitHub via HTTPS"
        else
            print_warning "Git cannot access GitHub via HTTPS"
        fi

        if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
            print_success "Git can access GitHub via SSH"
        else
            print_warning "Git cannot access GitHub via SSH"
        fi
    fi
    echo

    # Permissions
    print_header "Permissions"
    if [ -w "$HOME" ]; then
        print_success "Home directory is writable"
    else
        print_error "Home directory is not writable"
        ((errors++))
    fi

    if [ "$(id -u)" -eq 0 ]; then
        print_warning "Running as root (not recommended for personal dotfiles)"
    else
        print_success "Running as regular user"
    fi
    echo

    # Existing Dotfiles
    print_header "Existing Dotfiles Setup"
    if [ -d "$HOME/.dotfiles" ]; then
        print_info "Dotfiles repository already exists"
        if git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" status &>/dev/null; then
            print_success "Dotfiles repository is valid"
        else
            print_error "Dotfiles repository is corrupted"
            ((errors++))
        fi
    else
        print_info "No existing dotfiles repository found"
    fi

    if command -v dotfiles &>/dev/null || type dotfiles &>/dev/null; then
        print_success "Dotfiles command is available"
    else
        print_info "Dotfiles command not yet configured"
    fi
    echo

    # Summary
    print_header "Validation Summary"
    if [ $errors -eq 0 ]; then
        print_success "System validation passed! Ready for dotfiles setup."
        exit 0
    else
        print_error "System validation failed with $errors error(s). Please address the issues above."
        exit 1
    fi
}

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Validate system requirements for dotfiles setup"
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  -v, --verbose Enable verbose output"
    echo
    echo "This script checks:"
    echo "  • Required commands (git, curl)"
    echo "  • Optional tools (vim, zsh, etc.)"
    echo "  • Shell configuration files"
    echo "  • Git configuration"
    echo "  • SSH setup"
    echo "  • Network connectivity"
    echo "  • File permissions"
    echo "  • Existing dotfiles setup"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    -h | --help)
        show_help
        exit 0
        ;;
    -v | --verbose)
        set -x
        shift
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
