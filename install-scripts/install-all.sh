#!/bin/bash

echo "Installing all..."

./install-cli-tools.sh
./install-stow.sh
./install-zsh.s
./install-dotfiles.sh
./install-oh-my-zsh.sh


echo "Installation done..."

echo "Running setups..."
./set-shell.sh