#!/usr/bin/env bash

# One-time setup. WIP

# Link .vim and .vimrc for NeoVim
mkdir ~/.config
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim

# needed for UltiSnips vim plugin
brew install python3
pip install neovim
