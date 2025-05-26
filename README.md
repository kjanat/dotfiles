# Dotfiles Bootstrap & Setup Scripts

This folder contains cross-platform scripts to bootstrap and configure your personal dotfiles setup across:

-   **Linux** (bash/zsh/fish)
-   **Windows** (PowerShell / WSL)
-   **FreeBSD / TrueNAS** (csh/tcsh)

> [!NOTE]
> Your actual dotfiles are managed separately at [kjanat/dotfiles](https://github.com/kjanat/dotfiles).  
> These scripts clone and configure that repo as a bare Git repo in `~/.dotfiles`.

## Overview

This dotfiles management system uses the "bare repository" approach, which allows you to:

-   Track dotfiles directly in your home directory
-   Avoid symlinks and complex management scripts
-   Maintain a clean separation between the dotfiles repo and working files
-   Easily sync across multiple machines

---

## Usage

### 1. Bootstrap your dotfiles

```bash
./bootstrap
```

This script auto-detects your shell and runs the correct bootstrap for:

-   bash/zsh (bootstrap.sh)
-   PowerShell (bootstrap.ps1)
-   csh (bootstrap.csh)

It will:

-   Clone your dotfiles from kjanat/dotfiles
-   Backup any conflicting files
-   Set up your home dir with your configs

### 2. Set up your shell and tooling

```bash
./setup
```

This script:

-   Adds the dotfiles Git alias to your shell config
-   Installs common tools (git, vim, etc.)
-   Configures optional components (e.g., Oh My Posh on Windows)

---

## Features by Platform

### PowerShell (Windows)

-   Git/Vim installation using winget or chocolatey
-   PowerShell Core installation
-   Oh My Posh theme integration
-   PowerShell profile configuration

### Bash/Zsh (Linux)

-   Core development tools installation
-   Shell configuration
-   Optional Zsh setup with framework support

### CSH/TCSH (FreeBSD)

-   Basic dotfiles management
-   Essential tools installation

---

## Directory Structure

```plaintext
dotfiles/
├── bootstrap*       → universal bootstrap dispatcher
├── bootstrap.sh     → bash/zsh installer
├── bootstrap.ps1    → PowerShell installer
├── bootstrap.csh    → csh installer
├── setup*           → universal setup dispatcher
├── setup.sh         → bash/zsh tooling
├── setup.ps1        → PowerShell tooling
├── setup.csh        → csh tooling
├── .themes/         → themes folder for shells
│   └── kjanat.omp.json  → Oh My Posh theme for PowerShell
└── README.md        → documentation
```

Make the scripts executable:

```bash
chmod +x bootstrap bootstrap.sh setup setup.sh
```

---

## Managing Your Dotfiles

After setup, use the `dotfiles` command to manage your configurations:

```bash
# Show status of tracked dotfiles
dotfiles status

# Add a new file to be tracked
dotfiles add ~/.config/some-config-file

# Commit changes
dotfiles commit -m "Add config for some-app"

# Push changes to remote repository
dotfiles push

# Pull latest changes on another machine
dotfiles pull
```

---

## Customization

### Adding New Tools to Setup

Edit the appropriate setup file for your platform to add additional tools:

-   `setup.ps1` for PowerShell
-   `setup.sh` for Bash/Zsh
-   `setup.csh` for CSH/TCSH

### Adding New Dotfiles

1.  Create/edit the file in your home directory.
2.  Track it with `dotfiles add <path-to-file>`.
3.  Commit and push the changes.

---

### Related

[kjanat/dotfiles](https://github.com/kjanat/dotfiles) – your actual config repo

---

### Gitignore Settings

```gitignore
# Backup and temp folders
*.swp
*~
.DS_Store
*.bak
*.old

# Dotfiles boot artifacts (not needed in repo)
dotfiles-backup/
```
