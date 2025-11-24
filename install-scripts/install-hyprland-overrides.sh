#!/bin/bash
set -e

HYPRLAND_DIR="$HOME/.config/hypr"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDES_DIR="$SCRIPT_DIR/../hyprland-overrides"

# Check if hyprland config directory exists
if [ ! -d "$HYPRLAND_DIR" ]; then
    echo "Hyprland config directory not found at $HYPRLAND_DIR"
    echo "Please install hyprland first"
    exit 1
fi

# Check if overrides directory exists
if [ ! -d "$OVERRIDES_DIR" ]; then
    echo "Overrides directory not found at $OVERRIDES_DIR"
    echo "Please create the hyprland-overrides directory in the repository root"
    exit 1
fi

# Find all *-overrides.conf files in the overrides directory
shopt -s nullglob
override_files=("$OVERRIDES_DIR"/*-overrides.conf)

if [ ${#override_files[@]} -eq 0 ]; then
    echo "No override config files found in $OVERRIDES_DIR"
    echo "Create files like: hyprland-overrides.conf, monitors-overrides.conf, etc."
    exit 1
fi

echo "Found ${#override_files[@]} override config file(s)"

# Process each override config
for override_path in "${override_files[@]}"; do
    override_file=$(basename "$override_path")
    SOURCE_LINE="source = $override_path"
    
    # Determine target config file by stripping "-overrides" from filename
    # e.g., "monitors-overrides.conf" -> "monitors.conf"
    base_name="${override_file%-overrides.conf}.conf"
    target_config="$HYPRLAND_DIR/$base_name"
    
    # Create target config if it doesn't exist
    if [ ! -f "$target_config" ]; then
        echo "Creating $target_config"
        touch "$target_config"
    fi
    
    # Check if source line already exists
    if grep -Fxq "$SOURCE_LINE" "$target_config"; then
        echo "✓ Source line already exists in $target_config"
    else
        echo "Adding source line to $target_config"
        echo "" >> "$target_config"
        echo "$SOURCE_LINE" >> "$target_config"
        echo "✓ Source line added successfully"
    fi
done

echo "Hyprland overrides setup complete!"
