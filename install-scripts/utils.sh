#!/bin/bash

# Shared utility functions for install scripts

# Install a package using the appropriate package manager
# Usage: install_package <package_name>
install_package() {
	local package="$1"
	
	if [ -z "$package" ]; then
		echo "Error: No package name provided"
		return 1
	fi
	
	if command -v yay &> /dev/null; then
		yay -S --noconfirm --needed "$package"
	elif command -v apt &> /dev/null; then
		sudo apt update
		sudo apt install -y "$package"
	elif command -v pacman &> /dev/null; then
		sudo pacman -S --noconfirm --needed "$package"
	else
		echo "Unsupported package manager. Please install $package manually."
		return 1
	fi
}
