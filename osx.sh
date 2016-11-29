#!/usr/bin/env bash

# One-time setup

mkdir -p ~/Library/KeyBindings
ln `dirname $0`/osx/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict

# Fix problem with Tig - it gets suspended when C-y is pressed
# https://github.com/jonas/tig/issues/214
stty dsusp undef

# Apps

brew cask install tomighty # Pomodoro timer
