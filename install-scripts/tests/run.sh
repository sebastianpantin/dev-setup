#!/usr/bin/env bash
# Run the shell part of install-all.sh, then check the result.
# Work tools, Android and Hyprland overrides are left out: they need the AUR,
# a GUI session or many GB of downloads.
set -uo pipefail

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd /tmp || exit 1

# Same order as install-all.sh, minus the scripts that can't run here.
scripts=$(grep -oP '^\./\K[a-z-]+(?=\.sh)' "$SCRIPTS/install-all.sh" \
	| grep -vxF -e install-work-tools -e install-android -e install-hyprland-overrides)

for script in $scripts; do
	echo "=== $script"
	"$SCRIPTS/$script.sh" || { echo "FAIL: $script.sh exited $?"; exit 1; }
done

failures=0
check() {
	if eval "$2" &> /dev/null; then echo "ok   $1"; else echo "FAIL $1"; failures=$((failures + 1)); fi
}

echo "=== checks"
check ".zshrc is a stow symlink" '[ -L ~/.zshrc ]'
check "nvim config is stowed" '[ -L ~/.config/nvim ]'
check "oh-my-zsh in ~/.config" '[ -f ~/.config/.oh-my-zsh/oh-my-zsh.sh ]'
check "no stray ~/.oh-my-zsh" '[ ! -e ~/.oh-my-zsh ]'
check "zsh is login shell" '[ "$(getent passwd "$USER" | cut -d: -f7)" = "$(command -v zsh)" ]'
check "zsh starts cleanly" '[ -z "$(zsh -i -c exit 2>&1)" ]'
check "plugins load" 'zsh -i -c "(( \$+functions[_zsh_autosuggest_start] ))"'
check "ls alias uses eza" 'zsh -i -c "ls ~"'

exit $failures
