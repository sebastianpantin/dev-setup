#!/usr/bin/env bash
# Tests for this Neovim config.
#
# Runs against a *copy* of the config in an isolated XDG environment, with
# plugins pinned to lazy-lock.json, so it never touches your real plugins,
# state, or the repo's lockfile.
#
# Usage: tests/run.sh [--integration | --all] [--fresh] [--setup-only]
#   (default)      fast smoke tests (tests/smoke.lua)
#   --integration  mini.test suite driving real Neovim instances (tests/integration/)
#   --all          smoke tests, then the integration suite
#   --fresh        wipe the cached test environment and reinstall everything
#   --setup-only   install plugins, parsers and tools, but don't run tests
#
# NVIM_TEST_ENV overrides where the environment lives
# (default: ~/.cache/nvim-config-test).
set -euo pipefail

CONFIG_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${NVIM_TEST_ENV:-${XDG_CACHE_HOME:-$HOME/.cache}/nvim-config-test}"

# Pinned like the plugins; bump deliberately.
MINI_TEST_COMMIT=3cc4c29be99531b3fc4fb99f3fa964b492166728
MASON_TOOLS=(lua-language-server stylua)

SUITE=smoke
FRESH=0
SETUP_ONLY=0
for arg in "$@"; do
	case "$arg" in
	--integration) SUITE=integration ;;
	--all) SUITE=all ;;
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
# Read by the config to skip Mason auto-installs and lazy.nvim update checks.
export NVIM_CONFIG_TEST=1

# Copy rather than symlink: lazy.nvim rewrites lazy-lock.json on install.
rm -rf "$XDG_CONFIG_HOME"
mkdir -p "$XDG_CONFIG_HOME"
cp -r "$CONFIG_SRC" "$XDG_CONFIG_HOME/nvim"

# Clone a repo into $2 (if missing) and check out commit $3.
checkout() {
	if [[ ! -d "$2" ]]; then
		git clone --quiet --filter=blob:none "$1" "$2"
	fi
	git -C "$2" -c advice.detachedHead=false checkout --quiet "$3"
}

# Run a setup step, only showing its output if it fails.
step() {
	"$@" >"$ENV_DIR/setup.log" 2>&1 || {
		cat "$ENV_DIR/setup.log"
		echo "Setup failed: $*" >&2
		exit 1
	}
}

# Bootstrap lazy.nvim at the locked commit (init.lua would clone latest stable).
LAZY_COMMIT="$(grep -o '"lazy.nvim": {[^}]*}' "$CONFIG_SRC/lazy-lock.json" | grep -o '[0-9a-f]\{40\}')"
checkout https://github.com/folke/lazy.nvim.git "$XDG_DATA_HOME/nvim/lazy/lazy.nvim" "$LAZY_COMMIT"

MINI_TEST_DIR="$ENV_DIR/deps/mini.test"
checkout https://github.com/nvim-mini/mini.test.git "$MINI_TEST_DIR" "$MINI_TEST_COMMIT"

echo "==> Syncing plugins to lazy-lock.json"
step nvim --headless "+Lazy! restore" +qa
echo "==> Installing treesitter parsers"
step nvim --headless -c "luafile $XDG_CONFIG_HOME/nvim/tests/setup_parsers.lua"

MISSING_TOOLS=()
for tool in "${MASON_TOOLS[@]}"; do
	[[ -e "$XDG_DATA_HOME/nvim/mason/bin/$tool" ]] || MISSING_TOOLS+=("$tool")
done
if ((${#MISSING_TOOLS[@]})); then
	echo "==> Installing ${MISSING_TOOLS[*]} with Mason"
	step nvim --headless "+MasonInstall ${MISSING_TOOLS[*]}" +qa
fi

if ((SETUP_ONLY)); then
	exit 0
fi

cd "$XDG_CONFIG_HOME/nvim"

if [[ "$SUITE" != integration ]]; then
	echo "==> Running smoke tests"
	nvim --headless --cmd "luafile tests/smoke.lua"
fi

if [[ "$SUITE" != smoke ]]; then
	echo "==> Running integration tests"
	# New reference screenshots are written back to the source tree.
	export NVIM_TEST_SCREENSHOTS="$CONFIG_SRC/tests/screenshots"
	nvim --headless --clean --cmd "set rtp^=$MINI_TEST_DIR" -c "luafile tests/integration/run.lua"
fi
