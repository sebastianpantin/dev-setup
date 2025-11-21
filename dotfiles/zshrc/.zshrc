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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh