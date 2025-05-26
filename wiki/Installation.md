# Installation Guide

Complete step-by-step instructions for setting up the dotfiles bootstrap system on any supported platform.

## 📋 Prerequisites

### All Platforms

-   Git installed and configured
-   Internet connection for cloning repositories
-   Basic familiarity with command line/terminal

### Platform-Specific Requirements

#### Windows

-   PowerShell 5.1+ or PowerShell Core 7+
-   Windows 10/11 or Windows Server 2016+
-   Administrator privileges (for package installation)

#### Linux

-   Bash 4.0+ or Zsh 5.0+
-   sudo privileges (for package installation)
-   Package manager (apt, yum, dnf, pacman, etc.)

#### FreeBSD/TrueNAS

-   csh/tcsh shell
-   pkg package manager access
-   Root or sudo access

## 🚀 Installation Steps

### Step 1: Clone the Bootstrap Repository

```bash
git clone https://github.com/yourusername/dotfiles-bootstrap.git
cd dotfiles-bootstrap
```

### Step 2: Make Scripts Executable (Unix-like systems)

```bash
chmod +x bootstrap bootstrap.sh setup setup.sh
chmod +x bootstrap.csh setup.csh
```

### Step 3: Run Bootstrap

The bootstrap script will auto-detect your platform and run the appropriate installer:

```bash
./bootstrap
```

#### Manual Platform Selection (if needed)

**PowerShell (Windows):**

```powershell
.\bootstrap.ps1
```

**Bash/Zsh (Linux/macOS):**

```bash
./bootstrap.sh
```

**CSH/TCSH (FreeBSD):**

```csh
./bootstrap.csh
```

### Step 4: Run Setup

Install tools and configure your environment:

```bash
./setup
```

### Step 5: Verify Installation

Check that the dotfiles command is working:

```bash
dotfiles status
```

You should see your dotfiles repository status.

## 🔧 What Gets Installed

### Bootstrap Phase

-   Clones your dotfiles repository as a bare repo in `~/.dotfiles`
-   Creates backups of conflicting files in `~/.dotfiles-backup`
-   Sets up the `dotfiles` command alias
-   Creates a symlink to this README for easy access

### Setup Phase

#### All Platforms

-   Git configuration
-   Basic shell aliases
-   `dotfiles` command integration

#### Windows (PowerShell)

-   Git (via winget/chocolatey)
-   Vim (via winget/chocolatey)
-   PowerShell Core (if not installed)
-   Oh My Posh (optional)
-   Custom PowerShell profile

#### Linux

-   git, vim, curl, zsh
-   Shell configuration updates
-   Optional Zsh framework setup

#### FreeBSD

-   git, vim, curl, zsh
-   Basic shell configuration

## 🎨 Customization During Installation

### Pre-Installation Customization

Before running bootstrap, you can customize:

1.  **Repository URL**: Edit the `REPO` variable in bootstrap scripts
2.  **Backup Directory**: Change `BACKUP_DIR` in bootstrap scripts
3.  **Tool Selection**: Modify setup scripts to add/remove tools

### Post-Installation Customization

After installation, customize by:

1.  **Adding new dotfiles**: `dotfiles add ~/.config/newfile`
2.  **Modifying existing configs**: Edit files directly, then commit with `dotfiles`
3.  **Installing additional tools**: Modify and re-run setup scripts

## 🔍 Verification

### Check Dotfiles Status

```bash
dotfiles status
```

### Check Installed Tools

```bash
# Git
git --version

# Vim
vim --version

# Zsh (if installed)
zsh --version
```

### Check Shell Integration

Start a new shell session and verify:

-   `dotfiles` command is available
-   Custom aliases work
-   Prompt is styled (if using themes)

## 🚨 Troubleshooting Installation

### Common Issues

1.  **Permission Denied**: Ensure scripts are executable
2.  **Git Clone Fails**: Check internet connection and repository URL
3.  **Package Installation Fails**: Verify you have appropriate privileges
4.  **Command Not Found**: Restart your shell or source your profile

### Getting Help

If you encounter issues:

1.  Check the [Troubleshooting Guide](Troubleshooting.md)
2.  Review the [FAQ](FAQ.md)
3.  Check platform-specific [Platform Notes](Platform-Notes.md)

## 📚 Next Steps

After successful installation:

1.  **Customize your dotfiles**: Start adding your personal configurations
2.  **Explore the documentation**: Learn about advanced features
3.  **Set up synchronization**: Configure automatic syncing across devices
4.  **Backup strategy**: Consider how you'll backup your dotfiles

---

*For detailed platform-specific notes, see [Platform Notes](Platform-Notes.md)*
