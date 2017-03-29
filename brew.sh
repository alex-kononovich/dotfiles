#!/usr/bin/env bash

set -u

# install homebrew
if [[ ! -x "$(command -v brew)" ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# GNU utilities, because macOS's are outdated
brew install coreutils

# better grep
brew install ag

# newest git
brew install git

# text editor
brew tap neovim/neovim
brew install neovim

# bash files checker
brew install shellcheck

# programming font
brew tap caskroom/fonts
brew cask install font-fira-code

brew install autojump

# applications from cask
brew cask install \
  skype \
  telegram \
  google-chrome \

# applications from appstore
brew install mas
mas install 427475982 # BreakTime
mas install 418073146 # Snap
