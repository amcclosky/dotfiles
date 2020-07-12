#!/bin/bash

rm -rf $HOME/.bashrc
rm -rf $HOME/.bash_profile

ln -s "$HOME/.bashrc" "$HOME/.dotfiles/vscode/.bashrc"
ln -s "$HOME/.bash_profile" "$HOME/.dotfiles/vscode/.bash_profile"
