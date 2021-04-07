# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
#alias l='ls -CF'

rt() { ssh -t "$@" 'tmux new -As ct'; }

[[ -f "$HOME/.bash_aliases.local" ]] && source "$HOME/.bash_aliases.local"
