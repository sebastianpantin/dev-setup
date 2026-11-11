#!/bin/bash

# Shared utility functions for install scripts

# Install packages using the appropriate package manager
# Usage: install_package <package_name>...
install_package() {
	if [ $# -eq 0 ]; then
		echo "Error: No package name provided"
		return 1
	fi
	
	if command -v yay &> /dev/null; then
		yay -S --noconfirm --needed "$@"
	elif command -v apt &> /dev/null; then
		sudo apt update
		sudo apt install -y "$@"
	elif command -v pacman &> /dev/null; then
		sudo pacman -S --noconfirm --needed "$@"
	else
		echo "Unsupported package manager. Please install $* manually."
		return 1
	fi
}

# Add the current user to a group, if not already in it
# Usage: ensure_group <group>
ensure_group() {
	local group="$1"

	if ! groups "$USER" | grep -qw "$group"; then
		echo "Adding $USER to $group group..."
		sudo usermod -aG "$group" "$USER"
		echo "You'll need to log out and back in for group changes to take effect."
	fi
}
