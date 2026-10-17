#!/bin/bash
# Symlink the dotfiles into $HOME. Safe to re-run: existing files that
# aren't already links into the repo are moved aside to <file>.bak.
set -euo pipefail

DOTROOT="${HOME}/.dotfiles"

link() {
  local src="$DOTROOT/$1" dest="$HOME/$2"
  mkdir -p "$(dirname "$dest")"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    echo "ok      $dest"
    return
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    mv "$dest" "$dest.bak"
    echo "backup  $dest -> $dest.bak"
  fi
  ln -s "$src" "$dest"
  echo "link    $dest -> $src"
}

link .zshrc .zshrc
link .gitconfig .gitconfig
link .gitignore .gitignore_global
link mise/config.toml .config/mise/config.toml
