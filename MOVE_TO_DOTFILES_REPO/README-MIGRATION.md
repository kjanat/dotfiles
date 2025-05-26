# IMPORTANT: Files Moved

The following files have been moved from this bootstrap repository to the `MOVE_TO_DOTFILES_REPO/` directory because they are actual dotfiles that belong in your separate dotfiles repository:

-   `.bashrc` - Comprehensive Bash configuration with modular structure
-   `.tmux.conf` - Advanced Tmux configuration with plugins and custom layouts
-   `.zshrc` - Main ZSH configuration file
-   `truenas.zshrc` - TrueNAS-specific ZSH configuration  
-   `zsh-modular/` - Modular ZSH configuration system
-   `ZSH-README.md` - ZSH system documentation
-   `themes/` - Shell and terminal themes (Oh My Posh themes, etc.)
-   `servstat.sh` - Universal service status utility function

## What You Need To Do

1.  **Copy these files to your actual dotfiles repository** (the one at [kjanat/dotfiles](https://github.com/kjanat/dotfiles)):

   ```bash
   cp -r MOVE_TO_DOTFILES_REPO/* /path/to/your/actual/dotfiles/repo/
   ```

2.  **Commit them to your dotfiles repository**:

   ```bash
   cd /path/to/your/actual/dotfiles/repo/
   git add .
   git commit -m "Add ZSH configuration and modular system"
   git push
   ```

3.  **Remove the temporary directory**:

   ```bash
   rm -rf MOVE_TO_DOTFILES_REPO/
   ```

## Why This Change?

This bootstrap repository should only contain:

-   Bootstrap scripts for setting up dotfiles
-   Setup scripts for installing tools
-   Templates for the setup process
-   Documentation and wiki files

Your actual configuration files (.zshrc, .vimrc, etc.) belong in your separate dotfiles repository that gets cloned by the bootstrap scripts.

This separation keeps the bootstrap system clean and reusable while maintaining your personal configurations separately.
