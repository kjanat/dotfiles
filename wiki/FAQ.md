# Frequently Asked Questions

Common questions and answers about the dotfiles bootstrap system.

## 🤔 General Questions

### Q: What's the difference between this repository and my dotfiles repository?

**A:** This repository contains the **bootstrap and setup scripts** that help you install and configure your actual dotfiles. Your actual configuration files (`.zshrc`, `.vimrc`, etc.) should be in a separate repository that gets cloned by these scripts.

### Q: Why use a bare Git repository for dotfiles?

**A:** The bare repository approach allows you to:

-   Track files directly in your home directory without symlinks
-   Avoid complex directory structures
-   Maintain clean separation between the dotfiles repo and working files
-   Easily sync across multiple machines
-   Keep your home directory clean

### Q: Can I use this with my existing dotfiles?

**A:** Yes! The bootstrap script will backup any conflicting files before installing your dotfiles. You can then merge your existing configurations as needed.

## 🛠️ Setup Questions

### Q: The bootstrap script says "command not found" - what's wrong?

**A:** Make sure you've made the script executable:

```bash
chmod +x bootstrap setup
```

On Windows, ensure you're running from PowerShell and have execution policy set:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Q: Can I run the setup scripts multiple times?

**A:** Yes! The setup scripts are designed to be idempotent - they check if things are already installed/configured before making changes.

### Q: How do I change which tools get installed?

**A:** Edit the appropriate setup script for your platform:

-   `setup.ps1` for Windows/PowerShell
-   `setup.sh`  for Linux/macOS/Bash/Zsh
-   `setup.csh` for FreeBSD/CSH

### Q: The setup script failed to install a package - what should I do?

**A:**

1.  Check you have appropriate permissions (sudo/admin)
2.  Verify your package manager is working
3.  Check your internet connection
4.  Look at the specific error message and see [Troubleshooting](Troubleshooting.md)

## 📁 Dotfiles Management

### Q: How do I add a new configuration file to my dotfiles?

**A:**

```bash
# Create or edit the file in your home directory
vim ~/.gitconfig

# Add it to your dotfiles repository
dotfiles add ~/.gitconfig

# Commit the change
dotfiles commit -m "Add git configuration"

# Push to remote
dotfiles push
```

### Q: How do I see what files are being tracked?

**A:**

```bash
# See status of tracked files
dotfiles status

# List all tracked files
dotfiles ls-tree --full-tree -r HEAD --name-only
```

### Q: How do I remove a file from tracking?

**A:**

```bash
# Stop tracking but keep the file
dotfiles rm --cached ~/.some-file

# Remove from tracking and delete the file
dotfiles rm ~/.some-file

# Commit the change
dotfiles commit -m "Remove some-file from tracking"
```

### Q: Can I have different dotfiles for different machines?

**A:** Yes! You can use branches or hostname-based conditionals:

**Branch approach:**

```bash
# Create a branch for work machine
dotfiles checkout -b work-machine
# Make work-specific changes
dotfiles commit -m "Work-specific configurations"
```

**Conditional approach in your configs:**

```bash
# In .zshrc
case $(hostname) in
    "work-laptop")
        source ~/.config/work-specific
        ;;
    "home-desktop")
        source ~/.config/home-specific
        ;;
esac
```

## 🔧 Technical Questions

### Q: Where are my dotfiles actually stored?

**A:** Your dotfiles are stored in a bare Git repository at `~/.dotfiles`. Your actual configuration files remain in their normal locations in your home directory.

### Q: What happens to my existing configuration files?

**A:** The bootstrap script automatically backs them up to `~/.dotfiles-backup` before installing your dotfiles. You can restore them if needed or merge changes manually.

### Q: Can I use this system with private repositories?

**A:** Yes! Just make sure you have SSH keys set up or use personal access tokens for HTTPS. The bootstrap scripts support both methods.

### Q: How do I update the bootstrap scripts themselves?

**A:**

```bash
# In your bootstrap directory
git pull origin main
```

### Q: Can I customize the backup directory location?

**A:** Yes! Edit the `BACKUP_DIR` variable in the bootstrap scripts before running them.

## 🎨 Customization Questions

### Q: How do I add my own shell theme?

**A:**

1.  Add your theme file to the `themes/` directory
2.  Update the setup script to reference it
3.  For Oh My Posh themes, use the `.omp.json` format

### Q: Can I add custom aliases that work across all my machines?

**A:** Yes! Create a shell aliases file in your dotfiles repository and source it from your shell configuration files (`.bashrc`, `.zshrc`, etc.).

### Q: How do I add custom functions to the setup process?

**A:** You can modify the setup scripts directly or create custom hook files that get sourced during setup.

## 🚨 Troubleshooting Questions

### Q: The dotfiles command isn't working after setup

**A:**

1.  Start a new shell session
2.  Check if the alias is in your shell config file
3.  Manually source your shell config: `source ~/.bashrc` or `source ~/.zshrc`
4.  Verify the dotfiles directory exists: `ls -la ~/.dotfiles`

### Q: I'm getting permission errors during setup

**A:**

-   **Linux/macOS:** Make sure you have sudo privileges
-   **Windows:** Run PowerShell as Administrator
-   **FreeBSD:** Ensure you have root or sudo access

### Q: My shell prompt looks weird after setup

**A:** This usually means a theme wasn't installed correctly. Check:

1.  If Oh My Posh is installed: `oh-my-posh --version`
2.  If the theme file exists: `ls ~/.themes/`
3.  Try resetting to a basic prompt temporarily

### Q: Git clone fails with authentication error

**A:**

1.  Check if your SSH keys are set up: `ssh -T git@github.com`
2.  Or use HTTPS with a personal access token
3.  Make sure the repository URL is correct in the bootstrap script

## 🔄 Migration Questions

### Q: How do I migrate from another dotfiles system?

**A:** See the detailed [Migration Guide](Migration-Guide.md) for specific instructions for different systems like GNU Stow, Homesick, etc.

### Q: Can I migrate from manual symlink management?

**A:** Yes! The process involves:

1.  Backing up your current symlinks
2.  Moving actual files to your home directory
3.  Adding them to the dotfiles repository
4.  Removing old symlinks

### Q: How do I sync dotfiles between multiple machines?

**A:**

```bash
# On machine 1: push changes
dotfiles add .
dotfiles commit -m "Update configurations"
dotfiles push

# On machine 2: pull changes
dotfiles pull
```

## 📱 Platform-Specific Questions

### Q: Does this work on Windows Subsystem for Linux (WSL)?

**A:** Yes! Use the Linux/bash approach within WSL. You can also set up integration between Windows and WSL dotfiles.

### Q: Can I use this on macOS?

**A:** Absolutely! Use the bash/zsh setup scripts. You might want to add Homebrew-specific packages to your setup script.

### Q: What about BSD systems other than FreeBSD?

**A:** The FreeBSD scripts should work on most BSD systems, but you might need to adjust package manager commands (e.g., `pkg_add` for OpenBSD).

---

*Still have questions? Check the [Troubleshooting Guide](Troubleshooting.md) or [Platform Notes](Platform-Notes.md)*
