#!/bin/bash

rm -rf $HOME/.bashrc
rm -rf $HOME/.bash_profile

ln -s "$HOME/.dotfiles/vscode/.bashrc" "$HOME/.bashrc"
ln -s "$HOME/.dotfiles/vscode/.bash_profile" "$HOME/.bash_profile"
