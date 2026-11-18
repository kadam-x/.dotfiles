#!/usr/bin/env bash
# Stow dotfiles into $HOME.
#   ./install.sh            ask which set to install
#   ./install.sh cli        CLI packages only (nvim, zsh, tmux, ...)
#   ./install.sh full       CLI + desktop packages
#   ./install.sh uninstall  remove all symlinks (files in the repo are untouched)
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME"

command -v stow >/dev/null || { echo "error: GNU stow is not installed" >&2; exit 1; }

# Packages that share a target dir across cli/ and desktop/ must not be folded
# into a single directory symlink, or the second one can't be stowed.
NO_FOLD=(scripts)

packages() { # list package dirs (incl. dot-named ones) in a group
  find "$DOTFILES/$1" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}

stow_group() { # $1 = group, $2 = stow action flag
  local group=$1 action=$2 pkg flags
  echo "==> $group"
  for pkg in $(packages "$group"); do
    flags=()
    [[ " ${NO_FOLD[*]} " == *" $pkg "* ]] && flags+=(--no-folding)
    stow -d "$DOTFILES/$group" -t "$TARGET" "${flags[@]}" "$action" "$pkg"
    echo "    $pkg"
  done
}

mode=${1:-}
if [[ -z $mode ]]; then
  echo "What do you want to install?"
  echo "  1) cli   - terminal tools only (servers, WSL, ...)"
  echo "  2) full  - cli + desktop (Wayland, bars, launchers, themes)"
  read -rp "Choice [1/2]: " choice
  case $choice in
    1|cli) mode=cli ;;
    2|full) mode=full ;;
    *) echo "aborted"; exit 1 ;;
  esac
fi

case $mode in
  cli)       stow_group cli -R ;;
  full)      stow_group cli -R; stow_group desktop -R ;;
  uninstall) stow_group cli -D; [[ -d $DOTFILES/desktop ]] && stow_group desktop -D ;;
  *) echo "usage: $0 [cli|full|uninstall]" >&2; exit 1 ;;
esac

echo "done."
