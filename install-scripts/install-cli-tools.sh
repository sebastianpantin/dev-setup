#!/bin/bash

# Source utilities
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SOURCE_DIR/utils.sh"

# Install CLI tools
echo "Installing CLI tools..."

install_package starship zoxide fzf bat eza

echo "All CLI tools installed successfully!"
