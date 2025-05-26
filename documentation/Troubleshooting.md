# Troubleshooting Guide

Solutions for common issues you might encounter with the dotfiles bootstrap system.

## 🚨 Bootstrap Issues

### Bootstrap Script Fails to Start

**Symptoms:**

-   "Permission denied" errors
-   "Command not found" errors
-   Script doesn't execute

**Solutions:**

#### Unix-like Systems (Linux, macOS, FreeBSD)

```bash
# Make scripts executable
chmod +x bootstrap bootstrap.sh setup setup.sh bootstrap.csh setup.csh

# If you still get permission denied, check the shebang line
head -1 bootstrap.sh  # Should be #!/usr/bin/env bash
```

#### Windows/PowerShell

```powershell
# Check execution policy
Get-ExecutionPolicy

# Set execution policy if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run with explicit PowerShell call if needed
pwsh -ExecutionPolicy Bypass -File .\bootstrap.ps1
```

### Git Clone Failures

**Symptoms:**

-   "Repository not found"
-   "Permission denied (publickey)"
-   "Connection timeout"

**Solutions:**

#### SSH Authentication Issues

```bash
# Test SSH connection
ssh -T git@github.com

# Generate SSH key if needed
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add key to SSH agent
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub/GitLab account
cat ~/.ssh/id_ed25519.pub
```

#### Repository URL Issues

```bash
# Check if repository exists and is accessible
git ls-remote https://github.com/yourusername/dotfiles.git

# Try HTTPS instead of SSH
# In bootstrap script, change:
REPO="https://github.com/yourusername/dotfiles.git"
```

#### Network/Firewall Issues

```bash
# Test general connectivity
ping github.com

# Test Git over HTTPS
git config --global http.proxy http://proxy.company.com:8080

# For corporate networks, you might need:
git config --global http.sslVerify false  # Not recommended for production
```

### Backup Creation Problems

**Symptoms:**

-   "No space left on device"
-   "Permission denied" when creating backups
-   Backup directory creation fails

**Solutions:**

```bash
# Check disk space
df -h

# Check permissions
ls -la ~

# Create backup directory manually with correct permissions
mkdir -p ~/.dotfiles-backup
chmod 755 ~/.dotfiles-backup

# Use alternative backup location
export BACKUP_DIR="/tmp/dotfiles-backup-$(date +%Y%m%d)"
```

## 🛠️ Setup Issues

### Package Installation Failures

#### Linux Package Manager Issues

**APT (Ubuntu/Debian):**

```bash
# Update package list
sudo apt update

# Fix broken packages
sudo apt --fix-broken install

# Clear cache
sudo apt clean && sudo apt autoclean
```

**YUM/DNF (RHEL/Fedora):**

```bash
# Clean cache
sudo yum clean all
# or
sudo dnf clean all

# Update package database
sudo yum makecache
# or
sudo dnf makecache
```

**Pacman (Arch Linux):**

```bash
# Update package database
sudo pacman -Sy

# Fix keyring issues
sudo pacman -S archlinux-keyring
```

#### Windows Package Manager Issues

**Winget:**

```powershell
# Update winget
winget upgrade winget

# Reset winget sources
winget source reset

# Manually install if needed
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle
Add-AppxPackage winget.msixbundle
```

**Chocolatey:**

```powershell
# Reinstall Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Update all packages
choco upgrade all
```

### Shell Configuration Issues

#### Zsh Not Working

```bash
# Check if Zsh is installed
which zsh

# Install Zsh if missing
# Ubuntu/Debian:
sudo apt install zsh

# RHEL/Fedora:
sudo dnf install zsh

# Set Zsh as default shell
chsh -s $(which zsh)
```

#### Oh My Zsh Installation Problems

```bash
# Manual installation
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# If curl fails, try wget
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Fix permissions
chmod 755 ~/.oh-my-zsh
```

#### PowerShell Profile Issues

```powershell
# Check profile path
$PROFILE

# Create profile directory if missing
New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force

# Test profile syntax
powershell -NoProfile -Command "& { . '$PROFILE' }"
```

## 🔧 Dotfiles Command Issues

### "dotfiles: command not found"

**Symptoms:**

-   `dotfiles status` returns "command not found"
-   Alias not working after setup

**Solutions:**

#### Check Alias Definition

```bash
# For bash/zsh
grep -n "dotfiles" ~/.bashrc ~/.zshrc ~/.profile

# Manual alias definition
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

```powershell
# For PowerShell
Get-Content $PROFILE | Select-String "dotfiles"

# Manual function definition
function dotfiles { git --git-dir="$HOME\.dotfiles" --work-tree="$HOME" @args }
```

#### Reload Shell Configuration

```bash
# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc

# Fish
source ~/.config/fish/config.fish
```

```powershell
# PowerShell
. $PROFILE
```

#### Check Repository State

```bash
# Verify .dotfiles directory exists
ls -la ~/.dotfiles

# Check if it's a valid Git repository
git --git-dir=$HOME/.dotfiles status
```

### Dotfiles Checkout Issues

**Symptoms:**

-   "error: pathspec did not match any file(s) known to git"
-   Files not appearing after checkout

**Solutions:**

```bash
# Check repository contents
git --git-dir=$HOME/.dotfiles ls-tree -r HEAD

# Force checkout
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -f

# Reset to latest commit
git --git-dir=$HOME/.dotfiles --work-tree=$HOME reset --hard HEAD
```

## 🎨 Theme and Display Issues

### Oh My Posh Theme Problems

**Symptoms:**

-   Broken characters in prompt
-   Theme not loading
-   Colors not displaying correctly

**Solutions:**

#### Install Nerd Fonts

```bash
# Linux
sudo apt install fonts-nerdfonts

# macOS
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
```

#### Windows Terminal Configuration

```json
{
    "profiles": {
        "defaults": {
            "fontFace": "Hack Nerd Font",
            "fontSize": 12
        }
    }
}
```

#### Reset to Basic Prompt

```bash
# Temporarily disable Oh My Posh
export PROMPT='%n@%m %~ %# '  # Zsh
export PS1='\u@\h \w \$ '     # Bash
```

### Terminal Display Issues

#### Character Encoding Problems

```bash
# Set UTF-8 encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# For older systems
export LANG=C.UTF-8
```

#### Color Display Issues

```bash
# Test color support
echo -e "\033[31mRed\033[0m \033[32mGreen\033[0m \033[34mBlue\033[0m"

# Force color support
export TERM=xterm-256color
```

## 🔄 Synchronization Issues

### Merge Conflicts

**Symptoms:**

-   "Your branch and 'origin/main' have diverged"
-   Conflicts during `dotfiles pull`

**Solutions:**

```bash
# See what conflicts exist
dotfiles status

# For simple conflicts, force remote version
dotfiles reset --hard origin/main

# For complex conflicts, use merge tool
dotfiles mergetool

# Manual conflict resolution
dotfiles diff
# Edit conflicted files manually
dotfiles add .
dotfiles commit -m "Resolve merge conflicts"
```

### Push/Pull Authentication Issues

```bash
# Update remote URL to use SSH
dotfiles remote set-url origin git@github.com:yourusername/dotfiles.git

# Or update to use HTTPS with token
dotfiles remote set-url origin https://token@github.com/yourusername/dotfiles.git

# Check current remote
dotfiles remote -v
```

## 🐛 Platform-Specific Issues

### Windows/WSL Issues

#### Path Conversion Problems

```bash
# In WSL, ensure proper path handling
export WINHOME=$(wslpath $(cmd.exe /C "echo %USERPROFILE%") 2>/dev/null | tr -d '\r')
```

#### File Permission Issues

```bash
# Fix Windows/WSL file permissions
chmod +x ~/.local/bin/*
```

### macOS Issues

#### Homebrew Problems

```bash
# Reset Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Fix permissions
sudo chown -R $(whoami) /usr/local/var/homebrew
```

#### System Integrity Protection

```bash
# Some system files can't be modified
# Use ~/.config for user-specific configs instead of system directories
```

### FreeBSD/TrueNAS Issues

#### Package Manager Problems

```bash
# Update package database
sudo pkg update

# Fix repository issues
sudo pkg bootstrap -f
```

#### Shell Integration Issues

```csh
# For csh/tcsh, ensure proper syntax
set path = ($path ~/.local/bin)
alias dotfiles 'git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
```

## 🆘 Getting More Help

### Debug Mode

Enable debug output in scripts:

```bash
# Add to top of script
set -x  # Bash/Zsh
set echo verbose  # Csh
```

```powershell
# PowerShell
$VerbosePreference = "Continue"
```

### Log Collection

```bash
# Capture full output
./bootstrap.sh 2>&1 | tee bootstrap.log

# System information
uname -a > system-info.txt
echo $SHELL >> system-info.txt
```

### Community Support

1.  **Check existing issues** in the repository
2.  **Search documentation** in the wiki
3.  **Create detailed bug reports** with:
   -   Operating system and version
   -   Shell and version
   -   Full error messages
   -   Steps to reproduce

---

*For platform-specific troubleshooting, see [Platform Notes](Platform-Notes.md)*
