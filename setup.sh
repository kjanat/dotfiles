#!/usr/bin/env bash
# filepath: c:\\Users\\kjana\\Projects\\dotfiles\\setup.sh

# --- Configuration ---
DOTFILES_DIR="$HOME/.dotfiles"
ZSHRC_SOURCE="$DOTFILES_DIR/.zshrc" # Location of the .zshrc in your dotfiles repo
ZSHRC_DEST="$HOME/.zshrc"       # Destination for the .zshrc in the home directory

# --- Helper Functions ---
print_info() {
    echo -e "\\033[1;34m[INFO]\\033[0m $1"
}

print_success() {
    echo -e "\\033[1;32m[SUCCESS]\\033[0m $1"
}

print_warning() {
    echo -e "\\033[1;33m[WARNING]\\033[0m $1"
}

print_error() {
    echo -e "\\033[1;31m[ERROR]\\033[0m $1"
}

# --- Main Setup Logic ---
print_info "Starting dotfiles setup for Unix-like systems..."

# Determine shell configuration file
SHELL_RC_FILE=""
# CURRENT_SHELL_NAME is used to decide which rc file to write the alias to if not Zsh.
# shellcheck disable=SC2034 # Used in conditional logic below
CURRENT_SHELL_NAME=""

if [ -n "$BASH_VERSION" ]; then
    SHELL_RC_FILE="$HOME/.bashrc"
    CURRENT_SHELL_NAME="bash"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_RC_FILE="$HOME/.zshrc" # This will be the one symlinked or created
    CURRENT_SHELL_NAME="zsh"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_RC_FILE="$HOME/.config/fish/config.fish"
    CURRENT_SHELL_NAME="fish"
else
    # Fallback for other shells, though Zsh setup is prioritized
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_RC_FILE="$HOME/.bashrc"
        CURRENT_SHELL_NAME="bash"
    elif [ -f "$HOME/.zshrc" ]; then # Could be an existing user .zshrc
        SHELL_RC_FILE="$HOME/.zshrc"
        CURRENT_SHELL_NAME="zsh"
    else
        print_warning "Could not determine current shell config file. Dotfiles alias might not be set if not using Zsh."
    fi
fi

# Add dotfiles alias to common shell config files if not Zsh (Zsh gets it from .zshrc)
# This ensures the alias is available even if Zsh is not the default or fails to set up.
if [ "$CURRENT_SHELL_NAME" != "zsh" ] && [ -n "$SHELL_RC_FILE" ]; then
    if ! grep -q 'function dotfiles {' "$SHELL_RC_FILE" 2>/dev/null && ! grep -q 'alias dotfiles=' "$SHELL_RC_FILE" 2>/dev/null; then
        print_info "Adding 'dotfiles' alias to $SHELL_RC_FILE..."
        echo -e "\\n# Dotfiles alias managed by kjanat/dotfiles" >> "$SHELL_RC_FILE"
        echo "function dotfiles {" >> "$SHELL_RC_FILE"
        echo "   git --git-dir=\\"$DOTFILES_DIR\\" --work-tree=\\"$HOME\\" \\"\$@\\"" >> "$SHELL_RC_FILE"
        echo "}" >> "$SHELL_RC_FILE"
        print_success "'dotfiles' alias added to $SHELL_RC_FILE."
    else
        print_success "'dotfiles' alias already exists in $SHELL_RC_FILE."
    fi
elif [ "$CURRENT_SHELL_NAME" = "zsh" ]; then
    print_info "Current shell is Zsh. 'dotfiles' alias will be handled by $ZSHRC_DEST."
fi

# --- Package Installation ---
print_info "Checking for and installing essential packages (git, zsh, vim, curl)..."
PACKAGE_MANAGER=""
if command -v apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt-get"
elif command -v apt &> /dev/null; then
    PACKAGE_MANAGER="apt"
elif command -v yum &> /dev/null; then
    PACKAGE_MANAGER="yum"
elif command -v dnf &> /dev/null; then
    PACKAGE_MANAGER="dnf"
elif command -v pacman &> /dev/null; then
    PACKAGE_MANAGER="pacman"
elif command -v zypper &> /dev/null; then
    PACKAGE_MANAGER="zypper"
elif command -v pkg &> /dev/null; then
    PACKAGE_MANAGER="pkg"
elif command -v brew &> /dev/null; then
    PACKAGE_MANAGER="brew"
fi

HAS_UPDATE_FUNCTION=false
HAS_INSTALL_FUNCTION=false
# shellcheck disable=SC2034 # IS_SUDO_NEEDED is used by UPDATE_PKGS_IMPL/INSTALL_PKGS_IMPL
IS_SUDO_NEEDED=true # Default to using sudo

# Define placeholder functions that will be called if no specific manager logic is found
UPDATE_PKGS_IMPL() { :; } # No-op by default
INSTALL_PKGS_IMPL() { print_warning "No supported package manager found. Cannot install packages."; }

case "$PACKAGE_MANAGER" in
    apt-get|apt)
        HAS_UPDATE_FUNCTION=true
        UPDATE_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" update; else "$PACKAGE_MANAGER" update; fi }
        HAS_INSTALL_FUNCTION=true
        INSTALL_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" install -y git zsh vim curl; else "$PACKAGE_MANAGER" install -y git zsh vim curl; fi }
        ;;
    yum)
        # yum update can be verbose/interactive; often skipped in scripts.
        # HAS_UPDATE_FUNCTION remains false.
        HAS_INSTALL_FUNCTION=true
        INSTALL_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" install -y git zsh vim curl; else "$PACKAGE_MANAGER" install -y git zsh vim curl; fi }
        ;;
    dnf)
        HAS_UPDATE_FUNCTION=true # dnf check-update is generally non-intrusive
        UPDATE_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" check-update > /dev/null || true; else "$PACKAGE_MANAGER" check-update > /dev/null || true; fi }
        HAS_INSTALL_FUNCTION=true
        INSTALL_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" install -y git zsh vim curl; else "$PACKAGE_MANAGER" install -y git zsh vim curl; fi }
        ;;
    pacman)
        HAS_UPDATE_FUNCTION=true
        UPDATE_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" -Syu --noconfirm; else "$PACKAGE_MANAGER" -Syu --noconfirm; fi }
        HAS_INSTALL_FUNCTION=true
        INSTALL_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" -S --noconfirm git zsh vim curl; else "$PACKAGE_MANAGER" -S --noconfirm git zsh vim curl; fi }
        ;;
    zypper)
        HAS_UPDATE_FUNCTION=true
        UPDATE_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" refresh; else "$PACKAGE_MANAGER" refresh; fi }
        HAS_INSTALL_FUNCTION=true
        INSTALL_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" install -y git zsh vim curl; else "$PACKAGE_MANAGER" install -y git zsh vim curl; fi }
        ;;
    pkg) # FreeBSD
        HAS_UPDATE_FUNCTION=true
        UPDATE_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" update -q; else "$PACKAGE_MANAGER" update -q; fi }
        HAS_INSTALL_FUNCTION=true
        INSTALL_PKGS_IMPL() { if $IS_SUDO_NEEDED; then sudo "$PACKAGE_MANAGER" install -y git zsh vim curl; else "$PACKAGE_MANAGER" install -y git zsh vim curl; fi }
        ;;
    brew) # macOS
        IS_SUDO_NEEDED=false
        HAS_UPDATE_FUNCTION=true
        UPDATE_PKGS_IMPL() { "$PACKAGE_MANAGER" update; }
        HAS_INSTALL_FUNCTION=true
        INSTALL_PKGS_IMPL() { "$PACKAGE_MANAGER" install git zsh vim curl; }
        ;;
    *)
        # HAS_UPDATE_FUNCTION and HAS_INSTALL_FUNCTION remain false.
        # INSTALL_PKGS_IMPL will print the warning via the else block below.
        ;;
esac

if $HAS_UPDATE_FUNCTION; then
    print_info "Updating package lists..."
    UPDATE_PKGS_IMPL
fi

if $HAS_INSTALL_FUNCTION; then
    print_info "Installing packages (git, zsh, vim, curl)..."
    INSTALL_PKGS_IMPL
    if [ -n "$PACKAGE_MANAGER" ]; then # Check if a package manager was actually found
        print_success "Essential packages checked/installed."
    fi
else
    # This case is hit if PACKAGE_MANAGER was not found (HAS_INSTALL_FUNCTION is false)
    INSTALL_PKGS_IMPL # This will print the "No supported package manager" warning
fi

# Zsh configuration
print_info "Configuring Zsh..."

if command -v zsh &> /dev/null; then
    print_success "Zsh is installed."
    zsh_path=$(which zsh)

    # Symlink .zshrc from dotfiles repository
    if [ -f "$ZSHRC_SOURCE" ]; then
        if [ -L "$ZSHRC_DEST" ] && [ "$(readlink "$ZSHRC_DEST")" = "$ZSHRC_SOURCE" ]; then
            print_success ".zshrc is already correctly symlinked to your dotfiles."
        elif [ -f "$ZSHRC_DEST" ] && [ ! -L "$ZSHRC_DEST" ]; then # Exists and is a regular file
            print_warning ".zshrc already exists and is not a symlink. Backing it up to $ZSHRC_DEST.bak"
            mv "$ZSHRC_DEST" "$ZSHRC_DEST.bak"
            ln -s "$ZSHRC_SOURCE" "$ZSHRC_DEST"
            print_success ".zshrc backed up and symlinked to your dotfiles version."
        elif [ -L "$ZSHRC_DEST" ] && [ ! -e "$ZSHRC_DEST" ]; then # Is a broken symlink
            print_warning "Removing broken symlink at $ZSHRC_DEST"
            rm "$ZSHRC_DEST"
            ln -s "$ZSHRC_SOURCE" "$ZSHRC_DEST"
            print_success ".zshrc symlinked from your dotfiles."
        elif [ ! -e "$ZSHRC_DEST" ]; then # Does not exist at all
            ln -s "$ZSHRC_SOURCE" "$ZSHRC_DEST"
            print_success ".zshrc symlinked from your dotfiles."
        else
            # This case might be reached if $ZSHRC_DEST exists but isn't a regular file or a symlink we handled
            print_warning "Could not automatically symlink $ZSHRC_DEST. Current status is unclear. Manual check may be needed."
        fi
    else
        print_warning "$ZSHRC_SOURCE not found in your dotfiles. Cannot symlink .zshrc."
        print_warning "A basic $ZSHRC_DEST will be created if one doesn't exist, or your existing one will be used."
        if [ ! -e "$ZSHRC_DEST" ]; then # Use -e to check for any existence (file, dir, symlink)
            print_info "Creating a minimal $ZSHRC_DEST..."
            echo "# Minimal .zshrc created by setup.sh" > "$ZSHRC_DEST"
            echo "HISTFILE=~/.zsh_history" >> "$ZSHRC_DEST"
            echo "HISTSIZE=10000" >> "$ZSHRC_DEST"
            echo "SAVEHIST=10000" >> "$ZSHRC_DEST"
            echo "setopt appendhistory notify" >> "$ZSHRC_DEST"
            echo "PROMPT='%F{blue}%n@%m%f:%F{green}%~%f %# '" >> "$ZSHRC_DEST"
            # Add dotfiles alias here too for the minimal .zshrc case
            echo -e "\\n# Dotfiles alias managed by kjanat/dotfiles" >> "$ZSHRC_DEST"
            echo "function dotfiles {" >> "$ZSHRC_DEST"
            echo "   git --git-dir=\\"$DOTFILES_DIR\\" --work-tree=\\"$HOME\\" \\"\$@\\"" >> "$ZSHRC_DEST"
            echo "}" >> "$ZSHRC_DEST"
            print_success "Minimal .zshrc created with dotfiles alias."
        fi
    fi

    # Set Zsh as default shell if not already
    current_user_shell=$(getent passwd "$USER" | cut -d: -f7)

    if [ "$current_user_shell" != "$zsh_path" ]; then
        print_info "Current shell is $current_user_shell. Attempting to change to Zsh ($zsh_path)..."
        # Check if zsh_path is in /etc/shells
        if ! grep -Fxq "$zsh_path" /etc/shells; then
            print_warning "Zsh path ($zsh_path) not found in /etc/shells."
            print_info "Attempting to add $zsh_path to /etc/shells. This may require sudo."
            if command -v sudo &> /dev/null; then
                echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null
                if grep -Fxq "$zsh_path" /etc/shells; then
                    print_success "$zsh_path added to /etc/shells."
                else
                    print_error "Failed to add $zsh_path to /etc/shells. chsh might fail."
                fi
            else
                print_warning "sudo not available. Cannot add $zsh_path to /etc/shells automatically."
                print_warning "Please add it manually (e.g., echo '$zsh_path' | sudo tee -a /etc/shells) and then run 'chsh -s $zsh_path'."
            fi
        fi
        
        # Attempt to change shell
        if [ "$(id -u)" -eq 0 ]; then # If running as root
            chsh -s "$zsh_path" "$USER"
        elif command -v sudo &> /dev/null; then
            sudo chsh -s "$zsh_path" "$USER"
        else
            print_warning "sudo is not available. Cannot change shell automatically."
            print_warning "Please change your shell to Zsh manually by running: chsh -s $zsh_path"
        fi
        
        # Verify change (best effort, as it might require re-login)
        new_user_shell=$(getent passwd "$USER" | cut -d: -f7)
        if [ "$new_user_shell" = "$zsh_path" ]; then
            print_success "Default shell changed to Zsh for user $USER. Please log out and log back in for the change to take effect."
        else
            # Check if chsh command itself failed or if it's just a matter of re-login
            # Try to run chsh non-interactively with sudo to see if it would ask for a password
            if command -v sudo &> /dev/null && ! sudo -n chsh -s "$zsh_path" "$USER" &>/dev/null && [ "$(id -u)" -ne 0 ]; then
                 print_warning "Failed to change default shell. This might be due to password prompt for 'sudo chsh'."
                 print_warning "Try running 'sudo chsh -s $zsh_path $USER' manually."
            elif [ "$(id -u)" -ne 0 ] && ! chsh -s "$zsh_path" "$USER" &>/dev/null && ! command -v sudo &>/dev/null ; then
                 # This case means user is not root, chsh without sudo failed, and sudo is not available.
                 print_warning "Failed to change default shell. 'chsh' command may have failed without sudo, and sudo is not available."
                 print_warning "Try running 'chsh -s $zsh_path $USER' manually. Ensure $zsh_path is in /etc/shells."
            else
                # If chsh didn't obviously fail due to sudo password or lack of sudo, it might just need re-login.
                print_warning "Default shell change to Zsh may require a log out and log back in to reflect."
                print_warning "Current default reported as: $new_user_shell. Expected: $zsh_path."
            fi
            print_warning "Ensure Zsh ($zsh_path) is listed in /etc/shells. If not, add it and try 'chsh -s $(which zsh)' again."
        fi
    else
        print_success "Zsh is already the default shell."
    fi
else
    print_warning "Zsh is not installed. Skipping Zsh-specific configuration."
    print_warning "Please install Zsh manually if you wish to use it."
fi

print_info "Setup complete."
print_info "Please restart your shell or source your shell's configuration file (e.g., 'source $SHELL_RC_FILE' or 'source $ZSHRC_DEST')."
print_info "If Zsh was set as your default shell, you MUST log out and log back in for the change to take effect."
