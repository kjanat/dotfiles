#!/usr/bin/env bash

REPO="git@github.com:kjanat/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup"

if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles repo already cloned."
else
    git clone --bare "$REPO" "$DOTFILES_DIR"
fi

function dotfiles {
   /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

mkdir -p "$BACKUP_DIR"
dotfiles checkout
if [ $? -ne 0 ]; then
    echo "Backing up conflicting files."
    dotfiles checkout 2>&1 | grep -E "\s+\." | awk '{print $1}' | while read -r file; do
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        mv "$HOME/$file" "$BACKUP_DIR/$file"
    done
    dotfiles checkout
fi

dotfiles config --local status.showUntrackedFiles no

echo "Dotfiles successfully installed."
