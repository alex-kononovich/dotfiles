#!/usr/bin/env bash

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

