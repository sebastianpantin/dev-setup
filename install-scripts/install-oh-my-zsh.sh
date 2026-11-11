#!/bin/bash

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "Error: zsh is not installed. Please install it first."
    exit 1
fi

# .zshrc expects oh-my-zsh here, not in the installer's default ~/.oh-my-zsh
export ZSH="$HOME/.config/.oh-my-zsh"

# Check if oh-my-zsh is already installed
if [ -d "$ZSH" ]; then
    echo "oh-my-zsh is already installed."
    exit 0
fi

# Install oh-my-zsh
echo "Installing oh-my-zsh..."

# --keep-zshrc leaves the stowed .zshrc symlink in place
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

echo "oh-my-zsh installed successfully!"
