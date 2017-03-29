#!/usr/bin/env bash

# macOS settings
# based on https://mths.be/macos

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

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
TERM_PROFILE='hybrid-reduced-contrast';
CURRENT_PROFILE="$(defaults read com.apple.terminal 'Default Window Settings')";
if [ "${CURRENT_PROFILE}" != "${TERM_PROFILE}" ]; then
  open "${HOME}/.dotfiles/osx/${TERM_PROFILE}.terminal";
  sleep 1; # Wait a bit to make sure the theme is loaded
  defaults write com.apple.terminal 'Default Window Settings' -string "${TERM_PROFILE}";
  defaults write com.apple.terminal 'Startup Window Settings' -string "${TERM_PROFILE}";
fi;

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

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

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

# Snap
defaults write com.iktm.snap showInStatusBar -int 0
defaults write com.iktm.snap apps -data 62706c6973743030d40102030405064e4f582476657273696f6e58246f626a65637473592461726368697665725424746f7012000186a0af1013070811191f2027282b303435363b3f4045494a55246e756c6cd2090a0b105a4e532e6f626a656374735624636c617373a40c0d0e0f80028008800c800f8012d41213140a151617185661707055524c576b6579436f6465586b6579466c6167738003100580068007d31a0a1b1c1d1e574e532e626173655b4e532e72656c61746976658000800580045f103166696c653a2f2f6c6f63616c686f73742f4170706c69636174696f6e732f476f6f676c652532304368726f6d652e617070d2212223245a24636c6173736e616d655824636c6173736573554e5355524ca22526554e5355524c584e534f626a65637412000a0000d22122292a5b4170706c69636174696f6ea22926d41213140a2c2d2e1880091032800b8007d31a0a1b1c1d3380008005800a5f103866696c653a2f2f6c6f63616c686f73742f53797374656d2f4c6962726172792f436f726553657276696365732f46696e6465722e6170702f1000d41213140a37381718800d100b80068007d31a0a1b1c1d3e80008005800e5f102866696c653a2f2f6c6f63616c686f73742f4170706c69636174696f6e732f5361666172692e617070d41213140a414217188010100180068007d31a0a1b1c1d488000800580115f103466696c653a2f2f6c6f63616c686f73742f4170706c69636174696f6e732f5574696c69746965732f5465726d696e616c2e617070d221224b4c5e4e534d757461626c654172726179a34b4d26574e5341727261795f100f4e534b657965644172636869766572d1505154726f6f74800100080011001a0023002d00320037004d005300580063006a006f00710073007500770079008200890091009a009c009e00a000a200a900b100bd00bf00c100c300f700fc0107011001160119011f0128012d0132013e0141014a014c014e015001520159015b015d015f019a019c01a501a701a901ab01ad01b401b601b801ba01e501ee01f001f201f401f601fd01ff02010203023a023f024e0252025a026c026f02740000000000000201000000000000005200000000000000000000000000000276

# Spectacle
defaults write com.divisiblebyzero.Spectacle StatusItemEnabled -int 0

echo "Done. Note that some of these changes require a logout/restart to take effect."
