#!/usr/bin/env bash
# Headless smoke tests for this Neovim config.
#
# Runs against a *copy* of the config in an isolated XDG environment, with
# plugins pinned to lazy-lock.json, so it never touches your real plugins,
# state, or the repo's lockfile.
#
# Usage: tests/run.sh [--fresh] [--setup-only]
#   --fresh       wipe the cached test environment and reinstall everything
#   --setup-only  install plugins and parsers, but don't run the tests
#
# NVIM_TEST_ENV overrides where the environment lives
# (default: ~/.cache/nvim-config-test).
set -euo pipefail

CONFIG_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${NVIM_TEST_ENV:-${XDG_CACHE_HOME:-$HOME/.cache}/nvim-config-test}"

FRESH=0
SETUP_ONLY=0
for arg in "$@"; do
	case "$arg" in
	--fresh) FRESH=1 ;;
	--setup-only) SETUP_ONLY=1 ;;
	*)
		echo "Unknown argument: $arg" >&2
		exit 2
		;;
	esac
done

if ((FRESH)); then
	rm -rf "$ENV_DIR"
fi

export XDG_CONFIG_HOME="$ENV_DIR/config"
export XDG_DATA_HOME="$ENV_DIR/data"
export XDG_STATE_HOME="$ENV_DIR/state"
export XDG_CACHE_HOME="$ENV_DIR/cache"

# Copy rather than symlink: lazy.nvim rewrites lazy-lock.json on install.
rm -rf "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CONFIG_HOME"
cp -r "$CONFIG_SRC" "$XDG_CONFIG_HOME/nvim"

# Bootstrap lazy.nvim at the locked commit (init.lua would clone latest stable).
LAZY_DIR="$XDG_DATA_HOME/nvim/lazy/lazy.nvim"
LAZY_COMMIT="$(grep -o '"lazy.nvim": {[^}]*}' "$CONFIG_SRC/lazy-lock.json" | grep -o '[0-9a-f]\{40\}')"
if [[ ! -d "$LAZY_DIR" ]]; then
	git clone --quiet --filter=blob:none https://github.com/folke/lazy.nvim.git "$LAZY_DIR"
fi
git -C "$LAZY_DIR" -c advice.detachedHead=false checkout --quiet "$LAZY_COMMIT"

echo "==> Syncing plugins to lazy-lock.json"
nvim --headless "+Lazy! restore" "+lua require('nvim-treesitter.install').ensure_installed_sync()" +qa \
	>"$ENV_DIR/setup.log" 2>&1 || {
	cat "$ENV_DIR/setup.log"
	echo "Plugin setup failed" >&2
	exit 1
}

if ((SETUP_ONLY)); then
	exit 0
fi

echo "==> Running smoke tests"
cd "$XDG_CONFIG_HOME/nvim"
exec nvim --headless --cmd "luafile tests/smoke.lua"
