#!/bin/bash

# Source utilities
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SOURCE_DIR/utils.sh"

# Install CLI tools
echo "Installing CLI tools..."

install_package starship
install_package zoxide
install_package fzf
install_package bat
install_package exa

echo "All CLI tools installed successfully!"
