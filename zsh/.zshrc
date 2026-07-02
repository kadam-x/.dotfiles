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
# Autocompletion - must be before plugins
autoload -Uz compinit
compinit

# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

# fzf
# in .zshrc, replace those two lines with:
[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh

[ -f /usr/share/fzf/shell/completion.zsh ] && source /usr/share/fzf/shell/completion.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# Completion styling
zstyle ':completion:*' menu no
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}" 'ma=48;5;4;fg=15'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

# zoxide (replaces cd)
eval "$(zoxide init zsh --cmd cd)"

# starship
eval "$(starship init zsh)"

# fzf-tab + zoxide tab binding
_z_tab() {
    if [[ "$BUFFER" == "z" ]] || [[ "$BUFFER" == z\ * ]]; then
        local query="${BUFFER#z }"
        BUFFER=""
        CURSOR=0
        zle -R
        zi --query "$query"
        zle reset-prompt
        return
    fi
    if (( ${+widgets[fzf-tab-complete]} )); then
        zle fzf-tab-complete
    else
        zle expand-or-complete
    fi
}
zle -N _z_tab
bindkey '\t' _z_tab

export PATH="$PATH:/home/kadamx/.local/bin"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
export PATH=$PATH:$(go env GOPATH)/bin
