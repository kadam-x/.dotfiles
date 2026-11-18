#!/usr/bin/env bash
# Stow dotfiles into $HOME.
#   ./install.sh            ask which set to install
#   ./install.sh cli        CLI packages only (nvim, zsh, tmux, ...)
#   ./install.sh full       CLI + desktop packages
#   ./install.sh uninstall  remove all symlinks (files in the repo are untouched)
# Existing files that would block a link are moved to ~/.dotfiles-backup/<timestamp>/.
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

BACKUP="$TARGET/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

backup_conflicts() { # clear whatever blocks stowing: stale links are removed, the rest is moved to $BACKUP
  local conflict path dest
  while read -r conflict; do
    [[ -z $conflict ]] && continue
    path="$TARGET/$conflict"
    if [[ -L $path ]]; then
      dest=$(readlink -f "$path" || true)
      # broken link, or a link left over from an older layout of this repo
      if [[ ! -e $path || $dest == "$DOTFILES"/* ]]; then
        rm "$path"
        echo "    removed stale link ~/$conflict"
        continue
      fi
    fi
    mkdir -p "$BACKUP/$(dirname "$conflict")"
    mv "$path" "$BACKUP/$conflict"
    echo "    backed up ~/$conflict -> $BACKUP/$conflict"
  done < <(stow -n "$@" 2>&1 | sed -n \
    -e 's/.*over existing target \(.*\) since .*/\1/p' \
    -e 's/.*existing target is not owned by stow: \(.*\)$/\1/p')
}

stow_group() { # $1 = group, $2 = stow action flag
  local group=$1 action=$2 pkg flags
  echo "==> $group"
  for pkg in $(packages "$group"); do
    flags=()
    [[ " ${NO_FOLD[*]} " == *" $pkg "* ]] && flags+=(--no-folding)
    [[ $action == -R ]] && backup_conflicts -d "$DOTFILES/$group" -t "$TARGET" "${flags[@]}" "$action" "$pkg"
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
