# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME=""

# Which plugins would you like to load?
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# Preferred editor
export EDITOR='nvim'

# Load platform-specific configurations
[[ -f $HOME/.zsh/platform.zsh ]] && source $HOME/.zsh/platform.zsh

# Load aliases
[[ -f $HOME/.zsh/aliases.zsh ]] && source $HOME/.zsh/aliases.zsh

# Load functions
fpath=($ZSH_CUSTOM/functions $fpath)
[[ -d $ZSH_CUSTOM/functions ]] && autoload -U $ZSH_CUSTOM/functions/*

# pure theme setup (if available)
if [[ -d "$HOME/.zsh/pure" ]]; then
  fpath+=("$HOME/.zsh/pure")
  autoload -U promptinit; promptinit
  # turn on git stash status
  zstyle :prompt:pure:git:stash show yes
  prompt pure
fi

# fzf integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Add local bin to path
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# Add dotfiles bin to path
[[ -d "$HOME/repo/dotfiles/bin" ]] && export PATH="$HOME/repo/dotfiles/bin:$PATH"

# Load zsh-autosuggestions if available
if [[ -f "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Load zsh-syntax-highlighting if available
if [[ -f "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# asdf
[[ -d "$HOME/.asdf" ]] && export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Load private environment variables
[[ -f "$HOME/.zsh/private.zsh" ]] && source "$HOME/.zsh/private.zsh"
