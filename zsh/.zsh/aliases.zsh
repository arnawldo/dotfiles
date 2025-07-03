# Core aliases
alias zshconfig="$EDITOR ~/.zshrc"
alias reload="source ~/.zshrc"
alias ll="ls -la"
alias la="ls -a"
alias l="ls -l"

# Git aliases (complementing oh-my-zsh git plugin)
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate"

# Docker aliases (only loaded if docker is installed)
if command -v docker &> /dev/null; then
  alias dc="docker compose"
  alias dcu="docker compose up -d"
  alias dcd="docker compose down"
  alias dcl="docker compose logs -f"
fi

# Kubernetes aliases (only loaded if kubectl is installed)
if command -v kubectl &> /dev/null; then
  alias k="kubectl"
fi

# Podman aliases (only loaded if podman is installed)
if command -v podman &> /dev/null; then
  alias pd="podman"
  alias pc="podman-compose"
fi

# Tmux aliases
if command -v tmux &> /dev/null; then
  alias ta="tmux attach -t"
  alias ts="tmux new-session -s"
  alias tl="tmux list-sessions"
fi

# Neovim aliases
if command -v nvim &> /dev/null; then
  alias vim="nvim"
  alias vi="nvim"
fi
