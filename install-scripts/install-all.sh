#!/bin/bash

# The scripts below are called by relative path, so run from this directory
# no matter where install-all.sh was started from.
cd "$(dirname "$0")" || exit 1

# Ask for the sudo password once and keep it fresh, so long installs
# (.NET, Android SDK) don't stop halfway at a password prompt.
sudo -v || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Installing all..."

./install-cli-tools.sh
./install-stow.sh
./install-zsh.sh
./install-dotfiles.sh
./install-oh-my-zsh.sh
./install-claude.sh
./install-work-tools.sh
./install-android.sh
./install-hyprland-overrides.sh


echo "Installation done..."

echo "Running setups..."
./set-shell.sh
