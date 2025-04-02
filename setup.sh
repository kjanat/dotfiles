#!/usr/bin/env bash

echo "Setting up dotfiles alias and basic tools..."

SHELL_RC="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"
[ -n "$FISH_VERSION" ] && SHELL_RC="$HOME/.config/fish/config.fish"

if ! grep -q 'alias dotfiles=' "$SHELL_RC" 2>/dev/null; then
    echo "alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> "$SHELL_RC"
    echo "Dotfiles alias added to $SHELL_RC"
else
    echo "Dotfiles alias already present in $SHELL_RC"
fi

if command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y git zsh vim curl
elif command -v pkg &> /dev/null; then
    sudo pkg install -y git zsh vim curl
elif command -v brew &> /dev/null; then
    brew install git zsh vim curl
else
    echo "No known package manager found. Install git/zsh/vim manually."
fi

if command -v zsh &> /dev/null; then
    echo "Zsh found."
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "Changing shell to zsh for user $USER..."
        chsh -s "$(which zsh)"
    fi
fi

echo "Setup complete. Restart your shell or run 'source $SHELL_RC' to activate the alias."
