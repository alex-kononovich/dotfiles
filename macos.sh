#!/usr/bin/env bash

set -u

# Homebrew
if [[ ! -x "$(command -v brew)" ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew bundle

# Link dotfiles
ln -sf ~/.dotfiles/rcrc ~/.rcrc
rcup

# rustup
if [[ ! -x "$(command -v cargo)" ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# Fish shell
if [[ "$SHELL" != "$(command -v fish)" ]]; then
  which fish | sudo tee -a /etc/shells
  chsh -s $(which fish)
fi

# Node
eval "$(nodenv init -)"
nodenv install --skip-existing 24.13.0
nodenv global 24.13.0
npm install --global typescript-language-server typescript

# Logitech camera settings (requires node)
if [[ ! -f ~/.local/bin/xpc_set_event_stream_handler ]]; then
  cd logitech-c920-camera-settings
  make
  cd ..
fi

# macos configuration
# based on https://mths.be/macos

# Custom keybindings like Ctrl-w to delete last word in any textfield
if [[ ! -f ~/Library/KeyBindings/DefaultKeyBinding.dict ]]; then
  mkdir -p ~/Library/KeyBindings
  ln `dirname $0`/osx/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict
fi

# Input languages
if [[ ! -f /Library/Keyboard\ Layouts/russian_for_hardware_workman.keylayout ]]; then
  curl -s -L https://github.com/alex-kononovich/russian-layout-for-hardware-workman/raw/master/russian%20for%20hadrware%20workman.keylayout > russian_for_hardware_workman.keylayout
  sudo mv russian_for_hardware_workman.keylayout /Library/Keyboard\ Layouts/
  # Layout ID is hadrcoded in .keylayout file
  # This settings needs to be XML, otherwise ID will be string http://apple.stackexchange.com/a/127250
  # Layout will appear after logout/login
  defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add '<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>8920</integer><key>KeyboardLayout Name</key><string>Russian</string></dict>'
fi

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Change where screenshots are saved
if [[ ! -d ~/Screenshots ]]; then
  mkdir ~/Screenshots
  defaults write com.apple.screencapture location -string "~/Screenshots"
fi

# Set Home as the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Don't show tags in sidebar
defaults write com.apple.finder ShowRecentTags -int 0

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

echo "Done! Some settings require restart"
