# Platform-Specific Notes

Important considerations and special instructions for different operating systems and environments.

## 🐧 Linux

### Package Managers

#### Debian/Ubuntu (APT)

```bash
# Essential packages
sudo apt update
sudo apt install -y git vim curl zsh build-essential

# Development tools
sudo apt install -y nodejs npm python3 python3-pip

# Optional tools
sudo apt install -y tmux tree htop neofetch bat fd-find ripgrep
```

#### Red Hat/Fedora (DNF/YUM)

```bash
# Essential packages
sudo dnf install -y git vim curl zsh @development-tools

# Development tools
sudo dnf install -y nodejs npm python3 python3-pip

# Optional tools
sudo dnf install -y tmux tree htop neofetch bat fd-find ripgrep
```

#### Arch Linux (Pacman)

```bash
# Essential packages
sudo pacman -S git vim curl zsh base-devel

# Development tools
sudo pacman -S nodejs npm python python-pip

# Optional tools
sudo pacman -S tmux tree htop neofetch bat fd ripgrep
```

### Shell Configuration

#### Default Shell Change

```bash
# Check available shells
cat /etc/shells

# Change default shell
chsh -s /usr/bin/zsh
```

#### Font Installation for Themes

```bash
# Ubuntu/Debian
sudo apt install fonts-nerd-font-*

# Arch Linux
sudo pacman -S ttf-nerd-fonts-symbols

# Manual installation
mkdir -p ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip
unzip Hack.zip -d ~/.local/share/fonts/
fc-cache -fv
```

### Environment Variables

```bash
# Add to .bashrc/.zshrc
export EDITOR=vim
export VISUAL=vim
export BROWSER=firefox
export TERM=xterm-256color
```

## 🍎 macOS

### Package Management with Homebrew

#### Initial Setup

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Essential packages
brew install git vim curl zsh

# Development tools
brew install node python3

# Optional tools
brew install tmux tree htop neofetch bat fd ripgrep
```

#### Cask Applications

```bash
# GUI applications
brew install --cask visual-studio-code
brew install --cask iterm2
brew install --cask rectangle
brew install --cask alfred
```

### System Preferences

#### Terminal Configuration

-   **iTerm2**: Recommended terminal with better customization
-   **Font**: Install Nerd Fonts for proper theme display
-   **Color Profile**: Use Solarized Dark or similar

#### Keyboard Shortcuts

```bash
# Enable key repeat for all applications
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
```

### File System Notes

-   **Case Sensitivity**: macOS uses case-insensitive filesystem by default
-   **Hidden Files**: Use `⌘ + Shift + .` to toggle hidden file visibility
-   **Permissions**: Use `sudo` carefully, prefer Homebrew for package management

## 🪟 Windows

### PowerShell Setup

#### PowerShell Core Installation

```powershell
# Via winget
winget install Microsoft.PowerShell

# Via Chocolatey
choco install powershell-core

# Via direct download
# https://github.com/PowerShell/PowerShell/releases
```

#### Execution Policy

```powershell
# Check current policy
Get-ExecutionPolicy

# Set for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# For development machine (less secure)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

### Package Managers

#### Winget (Recommended)

```powershell
# Essential tools
winget install Git.Git
winget install vim.vim
winget install Microsoft.VisualStudioCode

# Development tools
winget install OpenJS.NodeJS
winget install Python.Python.3

# Optional tools
winget install Microsoft.WindowsTerminal
winget install JanDeDobbeleer.OhMyPosh
```

#### Chocolatey (Alternative)

```powershell
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Essential tools
choco install git vim vscode

# Development tools
choco install nodejs python3

# Optional tools
choco install microsoft-windows-terminal oh-my-posh
```

### Windows Terminal Configuration

#### Settings.json Example

```json
{
    "defaultProfile": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
    "profiles": {
        "defaults": {
            "fontFace": "Hack Nerd Font",
            "fontSize": 12,
            "colorScheme": "One Half Dark"
        },
        "list": [
            {
                "guid": "{574e775e-4f2a-5b96-ac1e-a2962a402336}",
                "name": "PowerShell",
                "source": "Windows.Terminal.PowershellCore",
                "startingDirectory": "%USERPROFILE%"
            }
        ]
    }
}
```

### WSL Integration

#### Setup WSL2

```powershell
# Enable WSL
wsl --install

# Set default version
wsl --set-default-version 2

# Install Ubuntu
wsl --install -d Ubuntu
```

#### Cross-Platform File Access

```bash
# Access Windows files from WSL
cd /mnt/c/Users/username/

# Access WSL files from Windows
# \\wsl$\Ubuntu\home\username\
```

## 🔧 FreeBSD/TrueNAS

### Package Management

#### pkg Commands

```bash
# Update package database
sudo pkg update

# Essential packages
sudo pkg install -y git vim curl zsh

# Development tools
sudo pkg install -y node npm python39 py39-pip

# Optional tools
sudo pkg install -y tmux tree htop neofetch
```

### Shell Configuration

#### CSH/TCSH Specifics

```csh
# .cshrc configuration
set path = ($path ~/.local/bin)
setenv EDITOR vim
setenv PAGER less

# Aliases (different syntax than bash)
alias ll 'ls -alhF'
alias dotfiles 'git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

#### ZSH on FreeBSD

```bash
# Install ZSH
sudo pkg install zsh

# Change shell
chsh -s /usr/local/bin/zsh

# Note: ZSH location differs from Linux (/usr/local/bin vs /usr/bin)
```

### TrueNAS Specific

#### Jail Environment

```bash
# If working in TrueNAS jails
# Packages install to /usr/local/
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
```

#### Storage Considerations

-   **Boot Drive**: Limited space, keep dotfiles minimal
-   **Datasets**: Consider storing larger configs on ZFS datasets
-   **Permissions**: Be careful with file permissions in shared environments

## 🐚 Shell-Specific Notes

### Bash

#### Version Differences

```bash
# Check Bash version
bash --version

# macOS uses old Bash (3.x) by default
# Install newer version via Homebrew
brew install bash
```

#### Bash-Specific Features

```bash
# Bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# History configuration
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=10000
export HISTFILESIZE=10000
shopt -s histappend
```

### Zsh

#### Framework Compatibility

-   **Oh My Zsh**: Most popular, many themes/plugins
-   **Prezto**: Faster, more minimal
-   **Zinit**: Plugin manager focus
-   **Starship**: Cross-shell prompt

#### Zsh-Specific Features

```bash
# Autocompletion
autoload -Uz compinit && compinit

# Correction
setopt correct

# Globbing
setopt extended_glob
```

### Fish

#### Fish Shell Setup

```bash
# Install Fish
sudo apt install fish  # Ubuntu
brew install fish       # macOS
sudo pkg install fish  # FreeBSD

# Configure Fish
fish_config
```

#### Fish-Specific Syntax

```fish
# Different variable syntax
set -x EDITOR vim

# Different function syntax
function dotfiles
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv
end
```

## 🔒 Security Considerations

### SSH Keys

```bash
# Generate secure SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# For older systems that don't support ed25519
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
```

### File Permissions

```bash
# Secure dotfiles permissions
chmod 600 ~/.ssh/config
chmod 700 ~/.ssh/
chmod 644 ~/.gitconfig
```

### Environment Variables

```bash
# Don't commit sensitive data
# Use separate .env files or system keychain
export API_KEY="$(security find-generic-password -s api_key -w)"  # macOS
```

## 🌐 Network Considerations

### Corporate Networks

```bash
# Proxy configuration
export http_proxy=http://proxy.company.com:8080
export https_proxy=$http_proxy
export no_proxy=localhost,127.0.0.1,.company.com

# Git proxy
git config --global http.proxy $http_proxy
```

### Firewall Issues

```bash
# Alternative Git protocols
git config --global url."https://github.com/".insteadOf git@github.com:
```

---

*For troubleshooting platform-specific issues, see [Troubleshooting Guide](Troubleshooting.md)*
