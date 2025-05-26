# Dotfiles

Personal dotfiles configuration for cross-platform development environments.

## Quick Install

To install these dotfiles, use the bootstrap scripts from the [dotfiles-bootstrap](https://github.com/kjanat/dotfiles-bootstrap) repository:

### Linux/macOS

```bash
curl -fsSL https://raw.githubusercontent.com/kjanat/dotfiles-bootstrap/master/bootstrap.sh | bash
```

### Windows (PowerShell)

```powershell
iex (iwr 'https://raw.githubusercontent.com/kjanat/dotfiles-bootstrap/master/bootstrap.ps1').Content
```

## What's Included

### Shell Configurations

-   **`.bashrc`** - Comprehensive Bash configuration with cross-platform support
-   **`.zshrc`** - Main ZSH configuration with modular system support
-   **`truenas.zshrc`** - TrueNAS/FreeBSD-specific ZSH configuration
-   **`zsh-modular/`** - Modular ZSH system for organized configuration
-   **`.inputrc`** - GNU Readline configuration for command-line editing

### Terminal Applications

-   **`.tmux.conf`** - Advanced Tmux configuration with plugins and custom layouts
-   **`.screenrc`** - GNU Screen configuration for terminal multiplexing
-   **`.vimrc`** - Comprehensive Vim/Neovim configuration for text editing

### Development Tools

-   **`.gitconfig`** - Git configuration with aliases and security settings
-   **`.gitignore_global`** - Global Git ignore patterns for all projects
-   **`.editorconfig`** - Consistent coding styles across editors and IDEs
-   **`.direnvrc`** - Environment management with direnv

### Network and System Tools

-   **`.ssh/config`** - SSH client configuration with security best practices
-   **`.curlrc`** - Default curl options and settings
-   **`.wgetrc`** - Default wget options and settings

### Package Managers

-   **`.npmrc`** - npm (Node.js) package manager configuration
-   **`.yarnrc`** - Yarn Classic package manager configuration
-   **`.yarnrc.yml`** - Yarn Berry (v2+) package manager configuration
-   **`.pypirc`** - Python Package Index configuration
-   **`.pip/pip.conf`** - pip (Python) package installer configuration

### Utilities and Scripts

-   **`servstat.sh`** - Server status monitoring script
-   **`themes/`** - Oh My Posh and shell themes

### Documentation

-   **`ZSH-README.md`** - Detailed ZSH configuration documentation
-   **`README-MIGRATION.md`** - Migration notes and instructions

## Features

### Comprehensive Configuration Categories

#### Text Editors and Development

-   **Cross-platform Vim configuration** with syntax highlighting, plugin support, and development-focused settings
-   **EditorConfig** for consistent coding styles across different editors and IDEs
-   **Git integration** with comprehensive aliases, security settings, and global ignore patterns

#### Shell and Terminal

-   **Multi-shell support** (Bash, ZSH) with intelligent OS detection and platform-specific optimizations
-   **Terminal multiplexer configurations** (Tmux, Screen) with productivity-focused key bindings
-   **Command-line enhancement** with GNU Readline configuration for improved editing experience

#### Development Environment

-   **Environment management** with direnv for automatic project environment setup
-   **Package manager configurations** for Node.js (npm, Yarn), Python (pip, PyPI), and more
-   **SSH configuration** with security best practices and connection optimization

#### Network and System

-   **Network tool configurations** (curl, wget) with sensible defaults and security settings
-   **Service monitoring utilities** with cross-platform server status functions
-   **Security-focused settings** with modern encryption standards and best practices

## Repository Structure

```text
dotfiles/                          ← This repository (configurations)
├── .bashrc                        ← Bash configuration
├── .zshrc                         ← Main ZSH configuration
├── truenas.zshrc                  ← TrueNAS-specific ZSH config
├── zsh-modular/                   ← Modular ZSH system
│   ├── modules/                   ← Individual ZSH modules
│   ├── themes/                    ← ZSH themes
│   └── plugins/                   ← ZSH plugins
├── .inputrc                       ← GNU Readline configuration
├── .tmux.conf                     ← Tmux configuration
├── .screenrc                      ← GNU Screen configuration
├── .vimrc                         ← Vim/Neovim configuration
├── .gitconfig                     ← Git configuration
├── .gitignore_global              ← Global Git ignore patterns
├── .editorconfig                  ← Editor configuration
├── .direnvrc                      ← Environment management
├── .ssh/                          ← SSH configuration
│   └── config                     ← SSH client settings
├── .curlrc                        ← Curl default options
├── .wgetrc                        ← Wget default options
├── .npmrc                         ← npm configuration
├── .yarnrc                        ← Yarn Classic configuration
├── .yarnrc.yml                    ← Yarn Berry configuration
├── .pypirc                        ← Python Package Index config
├── .pip/                          ← Python pip configuration
│   └── pip.conf                   ← pip settings
├── themes/                        ← Oh My Posh and terminal themes
├── servstat.sh                    ← Server status monitoring
└── README.md                      ← This file

dotfiles-bootstrap/                ← Bootstrap repository (setup scripts)
├── bootstrap*                     ← Installation scripts
├── setup*                         ← Setup utilities
└── ...                           ← Documentation and utilities
```

## Key Features

### Cross-Platform Support

-   **Linux** - Full feature support with platform-specific optimizations
-   **macOS** - Native macOS integration and Homebrew support
-   **Windows** - WSL and native PowerShell compatibility
-   **FreeBSD/TrueNAS** - Specialized configuration for FreeBSD systems

### Development Environment

-   **Multi-language support** - Configurations for Python, Node.js, Go, Ruby, Rust, and more
-   **Version management** - Integration with nvm, rbenv, pyenv, and asdf
-   **Environment isolation** - Automatic environment setup with direnv
-   **Package management** - Optimized configurations for npm, yarn, pip, and other package managers

## Management

After installation, use the `dotfiles` command to manage your configurations:

```bash
# Check status
dotfiles status

# Add new dotfile
dotfiles add .vimrc

# Commit changes
dotfiles commit -m "Add vim configuration"

# Push changes
dotfiles push

# Pull latest changes
dotfiles pull
```

## Customization

### Adding Your Own Configurations

1.  **Fork this repository** to your GitHub account
2.  **Clone your fork** using the bootstrap scripts (update the URLs in bootstrap scripts)
3.  **Add your configurations** to the repository
4.  **Commit and push** your changes

### Modifying Existing Configurations

1.  **Edit the configuration files** directly in your home directory
2.  **Use the `dotfiles` command** to commit changes:

   ```bash
   dotfiles add .bashrc
   dotfiles commit -m "Update bash aliases"
   dotfiles push
   ```

### Platform-Specific Configurations

The configurations include automatic OS detection and will load platform-specific settings:

-   **Linux**: Full feature set with package manager integration
-   **macOS**: Homebrew integration and macOS-specific aliases
-   **Windows**: WSL detection and Windows-specific paths
-   **FreeBSD/TrueNAS**: Specialized utilities for server management

## Key Features Detail

### Bash Configuration (.bashrc)

-   Cross-platform OS detection
-   Package manager integration (apt, yum, brew, pkg)
-   Git status in prompt
-   Directory navigation shortcuts
-   File operation aliases
-   Development environment setup
-   System monitoring utilities

### ZSH Configuration (.zshrc)

-   Oh My ZSH integration
-   Modular configuration system
-   Plugin management
-   Theme support
-   Completion enhancements
-   History optimization

### Tmux Configuration (.tmux.conf)

-   TPM (Tmux Plugin Manager) support
-   Vim-style key bindings
-   Mouse support with copy/paste
-   Status bar customization
-   Session management
-   Cross-platform clipboard integration

## Troubleshooting

### Common Issues

1.  **Permission Denied**: Ensure scripts have execute permissions

   ```bash
   chmod +x ~/.dotfiles/servstat.sh
   ```

2.  **Missing Dependencies**: Install required packages

   ```bash
   # Ubuntu/Debian
   sudo apt install git curl zsh tmux
   
   # CentOS/RHEL
   sudo yum install git curl zsh tmux
   
   # macOS
   brew install git curl zsh tmux
   ```

3.  **ZSH Not Default Shell**: Change default shell

   ```bash
   chsh -s $(which zsh)
   ```

### Getting Help

-   Check the [bootstrap repository](https://github.com/kjanat/dotfiles-bootstrap) for installation issues
-   Review the configuration files for customization options
-   Open an issue on GitHub for bugs or feature requests

## Contributing

1.  Fork the repository
2.  Create a feature branch
3.  Make your changes
4.  Test on multiple platforms
5.  Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Repositories

-   [dotfiles-bootstrap](https://github.com/kjanat/dotfiles-bootstrap) - Bootstrap and setup scripts
-   [dotfiles](https://github.com/kjanat/dotfiles) - This repository (actual configurations)
