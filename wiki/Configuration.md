# Configuration Guide

Learn how to customize and configure your dotfiles bootstrap system for your specific needs.

## 🎛️ Bootstrap Configuration

### Repository Settings

#### Changing Your Dotfiles Repository

Edit the `REPO` variable in all bootstrap scripts:

**bootstrap.sh:**

```bash
REPO="git@github.com:yourusername/dotfiles.git"
```

**bootstrap.ps1:**

```powershell
$repo = "git@github.com:yourusername/dotfiles.git"
```

**bootstrap.csh:**

```csh
set REPO = "git@github.com:yourusername/dotfiles.git"
```

#### Custom Directory Locations

Change where dotfiles are stored:

```bash
# Default locations
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

# Custom locations
DOTFILES_DIR="$HOME/.config/dotfiles"
BACKUP_DIR="$HOME/.config/dotfiles-backup"
```

### Backup Behavior

#### Custom Backup Directory

```bash
BACKUP_DIR="$HOME/backup/dotfiles-$(date +%Y%m%d)"
```

#### Skip Backup (Advanced)

```bash
# Add this to skip backup creation
# SKIP_BACKUP=true
```

## 🛠️ Setup Configuration

### Tool Selection

#### Windows (PowerShell)

Edit `setup.ps1` to customize tool installation:

```powershell
# Core tools (always installed)
$coreTools = @('git', 'vim', 'curl')

# Optional tools
$optionalTools = @('nodejs', 'python3', 'docker-desktop')

# Development tools
$devTools = @('vscode', 'github-cli', 'azure-cli')
```

#### Linux (Bash/Zsh)

Edit `setup.sh` for package customization:

```bash
# Core packages
CORE_PACKAGES="git vim curl zsh"

# Development packages
DEV_PACKAGES="nodejs npm python3 python3-pip docker"

# Optional packages
OPTIONAL_PACKAGES="tmux tree htop neofetch"
```

### Shell Configuration

#### Zsh Framework Selection

Choose your preferred Zsh framework in `setup.sh`:

```bash
# Options: "oh-my-zsh", "prezto", "zinit", "none"
ZSH_FRAMEWORK="oh-my-zsh"
```

#### PowerShell Profile Customization

Customize PowerShell setup in `setup.ps1`:

```powershell
# Oh My Posh theme
$OhMyPoshTheme = "$HOME\.themes\kjanat.omp.json"

# PowerShell modules to install
$PowerShellModules = @(
    'posh-git',
    'PSReadLine',
    'Terminal-Icons'
)
```

## 🎨 Theme Configuration

### Oh My Posh (PowerShell/Zsh)

#### Using Custom Themes

1.  Add your theme file to `themes/` directory
2.  Update setup script to reference it:

```powershell
$customTheme = "$PSScriptRoot\themes\mytheme.omp.json"
```

#### Theme Selection

Edit the theme reference in setup scripts:

```bash
# Zsh
OH_MY_POSH_THEME="$HOME/.themes/kjanat.omp.json"

# PowerShell
$OhMyPoshTheme = "$HOME\.themes\kjanat.omp.json"
```

### Shell Prompt Customization

#### Basic Bash Prompt

```bash
# In your dotfiles .bashrc
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
```

#### Zsh Prompt (without framework)

```bash
# In your dotfiles .zshrc
PROMPT='%F{blue}%n@%m%f:%F{green}%~%f %# '
```

## 📁 Template Configuration

### Git Configuration Template

Customize `templates/gitconfig.template`:

```ini
[user]
    name = Your Name
    email = your.email@example.com
    signingkey = YOUR_GPG_KEY_ID

[core]
    editor = code --wait
    autocrlf = input
    excludesfile = ~/.gitignore_global

[commit]
    gpgsign = true

[alias]
    # Your custom aliases
    pushf = push --force-with-lease
    uncommit = reset --soft HEAD~1
```

### Shell Aliases Template

Modify `templates/shell-aliases.template`:

```bash
# Custom aliases
alias myproject='cd ~/Projects/my-important-project'
alias serve='python3 -m http.server 8080'
alias docker-clean='docker system prune -af'

# Environment-specific
alias vpn-connect='sudo openvpn /path/to/config.ovpn'
alias backup='rsync -av ~/Documents/ /backup/location/'
```

## 🔧 Advanced Configuration

### Custom Bootstrap Hooks

Add custom logic to bootstrap scripts:

```bash
# In bootstrap.sh - add before final echo
if [ -f "$HOME/.custom-bootstrap-hook" ]; then
    echo "Running custom bootstrap hook..."
    source "$HOME/.custom-bootstrap-hook"
fi
```

### Environment-Specific Setup

Create environment-specific setup files:

```bash
# setup-work.sh
source ./setup.sh
# Add work-specific tools
sudo apt install slack-desktop teams
```

### Multi-Machine Synchronization

#### SSH Key Setup for Git

```bash
# Add to setup scripts
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
    echo "Add this key to your GitHub account:"
    cat ~/.ssh/id_rsa.pub
fi
```

#### Machine-Specific Configurations

Use hostname-based configs in your dotfiles:

```bash
# In your .zshrc
case $(hostname) in
    "work-laptop")
        export WORK_ENV=true
        source ~/.config/work-aliases
        ;;
    "home-desktop")
        export GAMING_ENV=true
        source ~/.config/gaming-aliases
        ;;
esac
```

## 🎯 Platform-Specific Configuration

### Windows WSL Integration

For WSL support in `setup.ps1`:

```powershell
# Check if running in WSL
if ($env:WSL_DISTRO_NAME) {
    # WSL-specific configuration
    Write-Host "Configuring for WSL environment..."
}
```

### macOS-Specific Settings

Add macOS detection to `setup.sh`:

```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific tools
    brew install --cask rectangle spectacle
fi
```

### FreeBSD/TrueNAS Optimization

Customize `setup.csh` for TrueNAS:

```csh
# TrueNAS-specific configuration
if (`uname` == "FreeBSD" && -d /usr/local/www/freenasUI) then
    echo "Configuring for TrueNAS environment..."
    # TrueNAS-specific setup
endif
```

## 📊 Monitoring and Maintenance

### Configuration Validation

Add validation to setup scripts:

```bash
# Validate configuration
validate_config() {
    echo "Validating configuration..."
    
    # Check required tools
    for tool in git vim curl; do
        if ! command -v $tool &> /dev/null; then
            echo "Error: $tool not installed"
            return 1
        fi
    done
    
    echo "Configuration valid ✓"
}
```

### Update Mechanisms

Add update functionality:

```bash
# In your dotfiles
update_dotfiles() {
    echo "Updating dotfiles..."
    dotfiles pull
    echo "Updating bootstrap scripts..."
    (cd ~/.dotfiles-bootstrap && git pull)
}
```

---

*For platform-specific configuration details, see [Platform Notes](Platform-Notes.md)*
