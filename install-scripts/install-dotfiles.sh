#!/bin/bash

if ! command -v stow &> /dev/null; then
    echo "Error: stow is not installed. Please install it first."
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "$0")/../dotfiles" && pwd)"

echo "Installing dotfiles from: $DOTFILES_DIR"

# Change to dotfiles directory
cd "$DOTFILES_DIR" || exit 1

# Remove old configs before stowing
echo "Removing old configs..."
for dir in */; do
    if [ -d "$dir" ]; then
        package="${dir%/}"
        # Remove common config locations for each package (both files and directories)
        [ -e "$HOME/.config/$package" ] && rm -rf "$HOME/.config/$package"
        [ -e "$HOME/.config/$package.toml" ] && rm -f "$HOME/.config/$package.toml"
        [ -e "$HOME/.$package" ] && rm -rf "$HOME/.$package"
        [ -e "$HOME/.local/share/$package" ] && rm -rf "$HOME/.local/share/$package"
        [ -e "$HOME/.cache/$package" ] && rm -rf "$HOME/.cache/$package"
    fi
done

# Loop through all directories in dotfiles and stow them

for dir in */; do
    if [ -d "$dir" ]; then
        package="${dir%/}"
        echo "Stowing $package..."
        stow -v "$package" -t "$HOME"
    fi
done

echo "Dotfiles installation complete!"
