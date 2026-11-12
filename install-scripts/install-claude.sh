#!/bin/bash

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SOURCE_DIR/utils.sh"

CLAUDE_REPO_DIR="$(cd "$SOURCE_DIR/../claude" && pwd)"
CLAUDE_DIR="$HOME/.claude"

install_package jq

if [ ! -x "$HOME/.local/bin/claude" ]; then
	echo "Installing Claude Code..."
	curl -fsSL https://claude.ai/install.sh | bash
fi

mkdir -p "$CLAUDE_DIR"

if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && [ ! -L "$CLAUDE_DIR/CLAUDE.md" ]; then
	mv "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak"
fi
ln -sfn "$CLAUDE_REPO_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# Merged, not linked: Claude Code and plugins rewrite settings.json with
# machine-specific entries such as hook paths.
settings="$CLAUDE_DIR/settings.json"
[ -f "$settings" ] || echo '{}' > "$settings"
jq -s '.[0] * .[1]' "$settings" "$CLAUDE_REPO_DIR/settings.json" > "$settings.tmp" \
	&& mv "$settings.tmp" "$settings"

echo "Claude Code setup complete!"
