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

# Packages that add single files to a directory other programs also write to.
# They are named differently from that directory, so the cleanup above leaves
# it alone, and stowed with --no-folding, so stow links only the files and
# never turns the directory into a link into this repo.
PARTIAL_PACKAGES=(fcitx5-keyboard)

stow_flags() {
    [[ " ${PARTIAL_PACKAGES[*]} " == *" $1 "* ]] && echo "--no-folding"
}

for dir in */; do
    if [ -d "$dir" ]; then
        package="${dir%/}"
        if [ -n "$(stow_flags "$package")" ]; then
            # Remove stock files this package replaces, e.g. Omarchy's
            # ~/.config/fcitx5/conf/keyboard.conf, so stow doesn't hit a
            # conflict. Never touch a path that resolves into this repo.
            while IFS= read -r file; do
                target="$HOME/${file#./}"
                [ -f "$target" ] && [ ! -L "$target" ] || continue
                [[ "$(realpath "$target")" == "$DOTFILES_DIR"/* ]] && continue
                rm -f "$target"
            done < <(cd "$package" && find . -type f)
        fi
        echo "Stowing $package..."
        stow -v $(stow_flags "$package") "$package" -t "$HOME"
    fi
done

echo "Dotfiles installation complete!"
