#!/usr/bin/env bash

set -u

# install homebrew
if [[ ! -x "$(command -v brew)" ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

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
brew install git tig

# tree
brew install tree

# tmux
brew install tmux reattach-to-user-namespace

# Exuberant ctags
brew install ctags

# text editor
brew tap neovim/neovim
brew install neovim

# bash files checker
brew install shellcheck

# programming font
brew tap caskroom/fonts
brew cask install font-fira-code

brew install autojump

# haskell
brew install haskell-stack
stack setup
stack install hdevtools hindent hoogle ghc-mod hasktags

# node
brew install node

# elm (using npm until all packages migrate to homebrew)
npm install -g elm elm-format elm-test elm-oracle elm-upgrade

# code formatters
npm install -g js-beautify pug-beautifier

# applications from cask
brew cask install \
  skype \
  telegram \
  google-chrome \
  things \
  spectacle

# applications from appstore
brew install mas
mas install 427475982 # BreakTime
mas install 418073146 # Snap
mas install 568494494 # Pocket
