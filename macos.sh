#!/usr/bin/env bash

set -u

############################################################
# PACKAGE MANAGERS
############################################################

# homebrew
if [[ ! -x "$(command -v brew)" ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# pip3
brew install python

# npm
brew install node nodenv

# mac app store
brew install mas

############################################################
# DOTFILES
############################################################

ln -s ~/.dotfiles/rcrc ~/.rcrc
brew tap thoughtbot/formulae
brew install rcm
rcup

############################################################
# UTILITIES
############################################################

# better shell
brew install fish
which fish | sudo tee -a /etc/shells
chsh -s $(which fish)

# trash instead of rm
brew install trash

# better grep
brew install ag

# better top
brew install htop

# newest git and git client
brew install git gh tig diff-so-fancy

# tree
brew install tree

# rename utility
brew install rename

# tmux
brew install tmux

# Exuberant ctags
brew install ctags

# text editor
brew tap neovim/neovim
brew install neovim
pip3 install neovim
sudo gem install neovim
npm install -g neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim -c "PlugInstall"

# programming font
brew tap homebrew/cask-fonts
brew install font-fira-code

# j to quickly jump to fuzzy-matched directory
brew install autojump

# heroku cli
brew install heroku/brew/heroku

# direnv
brew install direnv

############################################################
# Logitech C920 custom setup
# Automatically set correct settings when camera is connected
############################################################

cd logitech-c920-camera-settings
make
cd ..

############################################################
# LANGUAGES
############################################################

# ruby
brew install chruby chruby-fish ruby-install

# html, js
npm install -g prettier

# sh
brew install shellcheck

############################################################
# APPLICATIONS
############################################################

brew install \
  finicky \
  skype \
  slack \
  zoom \
  karabiner-elements \
  telegram \
  google-chrome \
  the-unarchiver \
  mac2imgur \
  spectacle

mas install 418073146 # Snap
mas install 568494494 # Pocket

############################################################
# MAC OS CONFIGURATION
# based on https://mths.be/macos
############################################################

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Custom keybindings like Ctrl-w to delete last word in any textfield
mkdir -p ~/Library/KeyBindings
ln `dirname $0`/osx/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict

# Input languages
curl -s -L https://github.com/alex-kononovich/russian-layout-for-hardware-workman/raw/master/russian%20for%20hadrware%20workman.keylayout > russian_for_hardware_workman.keylayout
sudo mv russian_for_hardware_workman.keylayout /Library/Keyboard\ Layouts/
# Layout ID is hadrcoded in .keylayout file
# This settings needs to be XML, otherwise ID will be string http://apple.stackexchange.com/a/127250
# Layout will appear after logout/login
defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add '<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>8920</integer><key>KeyboardLayout Name</key><string>Russian</string></dict>'
sudo rm /System/Library/Caches/com.apple.IntlDataCache*
sudo find /var/ -name "*IntlDataCache*" -exec rm {} \;

# Fix problem with Tig - it gets suspended when C-y is pressed
# https://github.com/jonas/tig/issues/214
stty dsusp undef

# Terminal theme
TERM_PROFILE='chalk-dark';
CURRENT_PROFILE="$(defaults read com.apple.terminal 'Default Window Settings')";
if [ "${CURRENT_PROFILE}" != "${TERM_PROFILE}" ]; then
  open "${HOME}/.dotfiles/osx/${TERM_PROFILE}.terminal";
  sleep 1; # Wait a bit to make sure the theme is loaded
  defaults write com.apple.terminal 'Default Window Settings' -string "${TERM_PROFILE}";
  defaults write com.apple.terminal 'Startup Window Settings' -string "${TERM_PROFILE}";
fi;

# Restart automatically if the computer freezes
sudo systemsetup -setrestartfreeze on

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Use scroll gesture with the Ctrl (^) modifier key to zoom
sudo defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
sudo defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
# Follow the keyboard focus while zoomed in
sudo defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 12
defaults write NSGlobalDomain InitialKeyRepeat -int 12

# Time format
defaults write NSGlobalDomain AppleICUForce24HourTime -int 1

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Set Home as the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

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

# Set Safari’s home page to `about:blank` for faster loading
defaults write com.apple.Safari HomePage -string "about:blank"

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Enable “Do Not Track”
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Update extensions automatically
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Restore windows from last session
defaults write com.apple.Safari AlwaysRestoreSessionAtLaunch -int 1

# Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Disable the annoying line marks
defaults write com.apple.Terminal ShowLineMarks -int 0

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable double space as period
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo "Done. Note that some of these changes require a logout/restart to take effect."

