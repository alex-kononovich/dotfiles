#!/usr/bin/env bash

set -u

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

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

