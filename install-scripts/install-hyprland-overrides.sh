#!/bin/bash
set -e

HYPRLAND_DIR="$HOME/.config/hypr"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OVERRIDES_DIR="$(cd "$SCRIPT_DIR/../hyprland-overrides" 2>/dev/null && pwd || echo "$SCRIPT_DIR/../hyprland-overrides")"
MAIN_CONFIG="$HYPRLAND_DIR/hyprland.lua"

# Check if hyprland config directory exists
if [ ! -d "$HYPRLAND_DIR" ]; then
    echo "Hyprland config directory not found at $HYPRLAND_DIR"
    echo "Please install hyprland first"
    exit 1
fi

# Omarchy quattro (Hyprland >= 0.55) configures Hyprland in Lua and ignores
# hyprland.conf entirely. Bail out loudly rather than writing dead config.
if [ ! -f "$MAIN_CONFIG" ]; then
    echo "$MAIN_CONFIG not found."
    echo "This script targets the Lua config used by Omarchy quattro / Hyprland >= 0.55."
    echo "On an older .conf-based setup, check out an earlier commit of this repo."
    exit 1
fi

# Check if overrides directory exists
if [ ! -d "$OVERRIDES_DIR" ]; then
    echo "Overrides directory not found at $OVERRIDES_DIR"
    echo "Please create the hyprland-overrides directory in the repository root"
    exit 1
fi

# Find all *-overrides.lua files in the overrides directory
shopt -s nullglob
override_files=("$OVERRIDES_DIR"/*-overrides.lua)

if [ ${#override_files[@]} -eq 0 ]; then
    echo "No override files found in $OVERRIDES_DIR"
    echo "Create files like: bindings-overrides.lua, monitors-overrides.lua, etc."
    exit 1
fi

# Omarchy's hyprland.lua only loads a fixed set of user modules, so an override
# whose target isn't in that set would never be read. Derive the set instead of
# hardcoding it, so this keeps working if Omarchy adds or renames one.
loaded_modules=$(grep -oP 'require\("hypr\.\K[a-z_]+' "$MAIN_CONFIG" | sort -u)

echo "Found ${#override_files[@]} override file(s)"

for override_path in "${override_files[@]}"; do
    override_file=$(basename "$override_path")

    # Determine target config by stripping "-overrides"
    # e.g., "monitors-overrides.lua" -> "monitors.lua"
    module_name="${override_file%-overrides.lua}"
    target_config="$HYPRLAND_DIR/$module_name.lua"

    if ! grep -qx "$module_name" <<<"$loaded_modules"; then
        echo "⚠ Skipping $override_file: $MAIN_CONFIG does not require(\"hypr.$module_name\")"
        echo "  Modules it does load: $(tr '\n' ' ' <<<"$loaded_modules")"
        continue
    fi

    if [ ! -f "$target_config" ]; then
        echo "Creating $target_config"
        touch "$target_config"
    fi

    # dofile, not require: Omarchy's bootstrap.lua only clears package.loaded for
    # the hypr.* / default.hypr.* prefixes, so a require() on a path outside
    # ~/.config would stay cached and go stale across `hyprctl reload`.
    LOAD_LINE="dofile(\"$override_path\")"

    if grep -Fxq "$LOAD_LINE" "$target_config"; then
        echo "✓ Load line already exists in $target_config"
    elif grep -q "dofile(\".*/$override_file\")" "$target_config"; then
        # Same override, different path spelling (e.g. an unnormalized ../).
        # Rewrite in place rather than appending, which would double every bind.
        echo "Updating stale load line in $target_config"
        tmp=$(mktemp)
        grep -v "dofile(\".*/$override_file\")" "$target_config" > "$tmp"
        mv "$tmp" "$target_config"
        echo "$LOAD_LINE" >> "$target_config"
        echo "✓ Load line updated"
    else
        echo "Adding load line to $target_config"
        {
            echo ""
            echo "-- Personal overrides, version-controlled in this repo."
            echo "$LOAD_LINE"
        } >> "$target_config"
        echo "✓ Load line added successfully"
    fi

    # Warn about the pre-quattro wiring, which Hyprland no longer reads.
    stale_conf="$HYPRLAND_DIR/$module_name.conf"
    if [ -f "$stale_conf" ] && grep -q -- "-overrides.conf" "$stale_conf"; then
        echo "⚠ $stale_conf still sources a .conf override. Hyprland ignores it now; safe to delete."
    fi
done

echo "Hyprland overrides setup complete!"
echo "Validate with: hyprctl reload && hyprctl configerrors"
