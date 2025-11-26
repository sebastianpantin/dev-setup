# Export path
export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH
export PATH=$HOME/.local/share/bob/nvim-bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.config/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.config/zsh-custom"

# Theme
ZSH_THEME=""
source $ZSH_CUSTOM/catppuccin_macchiato-zsh-syntax-highlighting.zsh

# Plugins
plugins=(git zsh-nvm zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Init different stuff
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Aliases
alias cat='bat'
alias ls='exa -l'

# Git aliases and functions
alias gsave='git add -A && git commit -m "SAVEPOINT"'

# Git functions
gdefault() {
    git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

gupall() {
    git pull --rebase --prune "$@" && git submodule update --init --recursive
}

gpb() {
    git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
}

gbclean() {
    local DEFAULT=$(gdefault)
    git branch --format '%(refname:short) %(upstream)' | awk '{if ($2) print $1;}' | grep -v "${1-$DEFAULT}\$" | xargs git branch -d -f
}

gbdone() {
    local DEFAULT=$(gdefault)
    git checkout "${1-$DEFAULT}" && gupall && gbclean "${1-$DEFAULT}"
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Source local machine-specific configuration if it exists
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
