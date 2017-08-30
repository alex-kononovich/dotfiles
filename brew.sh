#!/usr/bin/env bash

set -u

############################################################
# PACKAGE MANAGERS
############################################################

# homebrew
if [[ ! -x "$(command -v brew)" ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# pip3
brew install python3

# pip
brew install python

# npm
brew install node

# mac app store
brew install mas

############################################################
# UTILITIES
############################################################

# newest bash
brew install bash
echo '/usr/local/bin/bash' | sudo tee -a /etc/shells
chsh -s /usr/local/bin/bash

# GNU utilities, because macOS's are outdated
brew install coreutils

# better grep
brew install ag

# better top
brew install htop

# newest git and git client
brew install git tig diff-so-fancy

# tree
brew install tree

# rename utility
brew install rename

# tmux
brew install tmux reattach-to-user-namespace

# Exuberant ctags
brew install ctags

# text editor
brew tap neovim/neovim
brew install neovim

# programming font
brew tap caskroom/fonts
brew cask install font-fira-code

# j to quickly jump to fuzzy-matched directory
brew install autojump

# heroku cli
brew install heroku

# video downloader
brew install youtube-dl

############################################################
# LANGUAGES
############################################################

# haskell
brew install haskell-stack
stack setup
stack install hdevtools hindent hoogle ghc-mod hasktags

# elm (using npm until all packages migrate to homebrew)
npm install -g elm elm-format elm-test elm-oracle elm-upgrade

# vimscript
pip install vim-vint

# ruby
brew install chruby chruby-fish ruby-install

# html, js
npm install -g js-beautify

# pug
npm install -g pug-beautifier

# sh
brew install shellcheck

############################################################
# APPLICATIONS
############################################################

brew cask install \
  skype \
  telegram \
  google-chrome \
  the-unarchiver \
  mac2imgur \
  spectacle

mas install 427475982 # BreakTime
mas install 418073146 # Snap
mas install 568494494 # Pocket
