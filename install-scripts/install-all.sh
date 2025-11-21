#!/bin/bash

echo "Installing all..."

./install-cli-tools.sh
./install-stow.sh
./install-zsh.s
./install-dotfiles.sh
./install-oh-my-zsh.sh
./install-work-tools.sh


echo "Installation done..."

echo "Running setups..."
./set-shell.sh