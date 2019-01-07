#!/usr/bin/env bash

set -u

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

############################################################
# PACKAGE MANAGERS
############################################################

# homebrew
if [[ ! -x "$(command -v brew)" ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# pip3
brew install python

# pip
brew install python@2

# npm
brew install node

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
echo '/usr/local/bin/fish' | sudo tee -a /etc/shells
chsh -s /usr/local/bin/fish

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
brew install tmux

# Exuberant ctags
brew install ctags

# text editor
brew tap neovim/neovim
brew install neovim
pip install neovim
pip3 install neovim
sudo gem install neovim
npm install -g neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim -c "PlugInstall"

# programming font
brew tap caskroom/fonts
brew cask install font-fira-code

# j to quickly jump to fuzzy-matched directory
brew install autojump

# heroku cli
brew install heroku

# video downloader
brew install youtube-dl

# music player
brew install cmus

# control cmus using media keys
brew tap thefox/brewery
brew install cmus-control
brew services start thefox/brewery/cmus-control

############################################################
# LANGUAGES
############################################################

# haskell
brew install haskell-stack
stack setup
stack install hlint brittany

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

# Disable transparency
defaults write com.apple.universalaccess reduceTransparency -bool true

# Restart automatically if the computer freezes
sudo systemsetup -setrestartfreeze on

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Disable hibernation (speeds up entering sleep mode)
sudo pmset -a hibernatemode 0

# Remove the sleep image file to save disk space
sudo rm /private/var/vm/sleepimage
# Create a zero-byte file instead…
sudo touch /private/var/vm/sleepimage
# …and make sure it can’t be rewritten
sudo chflags uchg /private/var/vm/sleepimage

# Menu bar
defaults write com.apple.systemuiserver menuExtras -array \
	"/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
	"/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
	"/System/Library/CoreServices/Menu Extras/AirPort.menu" \
	"/System/Library/CoreServices/Menu Extras/TextInput.menu" \
	"/System/Library/CoreServices/Menu Extras/Clock.menu"

# Disable the over-the-top focus ring animation
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Use scroll gesture with the Ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
# Follow the keyboard focus while zoomed in
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 12
defaults write NSGlobalDomain InitialKeyRepeat -int 12

# Time format
defaults write NSGlobalDomain AppleICUForce24HourTime -int 1

# Input languages
curl -s -L https://github.com/flskif/russian-layout-for-hardware-workman/raw/master/russian%20for%20hadrware%20workman.keylayout > russian_for_hardware_workman.keylayout
sudo mv russian_for_hardware_workman.keylayout /Library/Keyboard\ Layouts/
# Layout ID is hadrcoded in .keylayout file
# This settings needs to be XML, otherwise ID will be string http://apple.stackexchange.com/a/127250
# Layout will appear after logout/login
defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add '<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>8920</integer><key>KeyboardLayout Name</key><string>Russian</string></dict>'
sudo rm /System/Library/Caches/com.apple.IntlDataCache*
sudo find /var/ -name "*IntlDataCache*" -exec rm {} \;

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

# Disable local Time Machine backups
hash tmutil &> /dev/null && sudo tmutil disablelocal

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

# Snap
defaults write com.iktm.snap showInStatusBar -int 0
defaults write com.iktm.snap apps -data 62706c6973743030d40102030405064d4e582476657273696f6e58246f626a65637473592461726368697665725424746f7012000186a0af1012070811191f2027282b3034353a3e3f44484955246e756c6cd2090a0b105a4e532e6f626a656374735624636c617373a40c0d0e0f80028008800b800e8011d41213140a151617185661707055524c576b6579436f6465586b6579466c6167738003100580068007d31a0a1b1c1d1e574e532e626173655b4e532e72656c61746976658000800580045f103166696c653a2f2f6c6f63616c686f73742f4170706c69636174696f6e732f476f6f676c652532304368726f6d652e617070d2212223245a24636c6173736e616d655824636c6173736573554e5355524ca22526554e5355524c584e534f626a65637412000a0000d22122292a5b4170706c69636174696f6ea22926d41213140a2c2d17188009100b80068007d31a0a1b1c1d3380008005800a5f102866696c653a2f2f6c6f63616c686f73742f4170706c69636174696f6e732f5361666172692e617070d41213140a36371718800c100180068007d31a0a1b1c1d3d80008005800d5f103466696c653a2f2f6c6f63616c686f73742f4170706c69636174696f6e732f5574696c69746965732f5465726d696e616c2e617070d41213140a40411718800f101180068007d31a0a1b1c1d478000800580105f102866696c653a2f2f6c6f63616c686f73742f4170706c69636174696f6e732f5468696e67732e617070d221224a4b5e4e534d757461626c654172726179a34a4c26574e5341727261795f100f4e534b657965644172636869766572d14f5054726f6f74800100080011001a0023002d00320037004c0052005700620069006e007000720074007600780081008800900099009b009d009f00a100a800b000bc00be00c000c200f600fb0106010f01150118011e0127012c0131013d01400149014b014d014f01510158015a015c015e01890192019401960198019a01a101a301a501a701de01e701e901eb01ed01ef01f601f801fa01fc0227022c023b023f02470259025c02610000000000000201000000000000005100000000000000000000000000000263

# Spectacle
defaults write com.divisiblebyzero.Spectacle StatusItemEnabled -int 0

# Prevent play/pause media button from starting iTunes
# TODO: this requires System Integrity Protection to be disabled, check it with
# `csrutil status` and stop the setup script from running until it is disabled
# launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist

echo "Done. Note that some of these changes require a logout/restart to take effect."

