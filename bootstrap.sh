#!/usr/bin/env bash

set -u

# Install everything
./brew.sh

# Copy dotfiles
ln -s ~/.dotfiles/rcrc ~/.rcrc
brew tap thoughtbot/formulae
brew install rcm
rcup

# Setup Neovim
mkdir -p ~/.config/nvim/
ln -s ~/.dotfiles/vimrc ~/.config/nvim/init.vim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
brew install python3
pip3 install neovim
nvim -c "PlugInstall"

# Configure macOS
./macos.sh

