# Basic .zshrc configuration managed by dotfiles
# filepath: .zshrc

# Enable history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory notify

# Basic prompt
PROMPT='%F{blue}%n@%m%f:%F{green}%~%f %# '

# Preferred editor for Zsh (e.g., vim, nano)
export EDITOR='vim'

# Basic aliases
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Source Oh My Zsh if installed
# if [ -d "$HOME/.oh-my-zsh" ]; then
#   export ZSH="$HOME/.oh-my-zsh"
#   ZSH_THEME="robbyrussell" # Or your preferred theme
#   plugins=(git) # Add your preferred plugins
#   source $ZSH/oh-my-zsh.sh
# fi

# Source local/private zsh settings if they exist
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# Dotfiles alias (if not already set by bootstrap)
if ! command -v dotfiles &> /dev/null; then
    function dotfiles {
       git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
    }
fi
