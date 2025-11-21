#!/bin/bash

echo "Installing all..."

./install-cli-tools.sh
./install-stow.sh
./install-zsh.sh
./install-oh-my-zsh.sh
./install-dotfiles.sh

echo "Installation done..."

echo "Running setups..."
./set-shell.sh