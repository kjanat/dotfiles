#!/bin/csh

echo "Setting up dotfiles alias and tools..."

set rcfile = "$HOME/.cshrc"
set aliasline = "alias dotfiles 'git --git-dir=\$HOME/.dotfiles --work-tree=\$HOME'"

if (! -f $rcfile) then
    touch $rcfile
endif

if (`grep -c 'alias dotfiles' $rcfile` == 0) then
    echo $aliasline >> $rcfile
    echo "Alias 'dotfiles' added to $rcfile"
else
    echo "Alias already exists in $rcfile"
endif

if ( $?USER == 1 ) then
    echo "Installing tools using pkg..."
    sudo pkg install -y git vim curl zsh
else
    echo "Run as a user with sudo privileges to install packages."
endif

echo "Setup complete. Run 'source ~/.cshrc' to activate the alias."
