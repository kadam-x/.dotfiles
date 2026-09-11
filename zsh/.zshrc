# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# Session variables
export QT_QPA_PLATFORM="wayland"
export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"

# Aliases
alias l="eza -lh --icons=auto"
alias ld="eza -lhD --icons=auto"
alias ll="eza -lha --icons=auto --sort=name --group-directories-first"
alias ls="eza -1 --icons=auto"
alias lt="eza --icons=auto --tree"
alias sess='~/.local/bin/scripts/sessionizer.sh'
alias cat='bat'

# Autocompletion
autoload -Uz compinit
compinit

# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh

[ -f /usr/share/fzf/shell/completion.zsh ] && source /usr/share/fzf/shell/completion.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# Completion styling
zstyle ':completion:*' menu no
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}" 'ma=48;5;4;fg=15'
zstyle ':completion:*:descriptions' format '[%d]'

# zoxide (replaces cd)
eval "$(zoxide init zsh --cmd cd)"

# starship
eval "$(starship init zsh)"

export PATH="$PATH:/home/kadamx/.local/bin"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$(go env GOPATH)/bin
