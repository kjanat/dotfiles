#!/bin/csh

set REPO = "git@github.com:kjanat/dotfiles.git"
set DOTFILES_DIR = "$HOME/.dotfiles"
set BACKUP_DIR = "$HOME/.dotfiles-backup"

if (! -d $DOTFILES_DIR) then
    git clone --bare $REPO $DOTFILES_DIR
endif

alias dotfiles "git --git-dir=$DOTFILES_DIR --work-tree=$HOME"

mkdir -p $BACKUP_DIR

set output = `dotfiles checkout >& /dev/stderr`
if ($status != 0) then
    echo "Backing up conflicting files."
    foreach line (`dotfiles checkout 2>&1 | grep -E "\s+\." | awk '{print $1}'`)
        set filepath = $line
        mkdir -p "$BACKUP_DIR/`dirname $filepath`"
        mv "$HOME/$filepath" "$BACKUP_DIR/$filepath"
    end
    dotfiles checkout
endif

dotfiles config --local status.showUntrackedFiles no

echo "Dotfiles successfully installed."
