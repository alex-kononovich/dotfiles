.PHONY: all build install

all: build install

build: xpc_set_event_stream_handler.m
	gcc -framework Foundation -o ~/.local/bin/xpc_set_event_stream_handler xpc_set_event_stream_handler.m

install:
	npm install --global uvcc
	cp logitech-c920-update-camera-settings ~/.local/bin/
	cp logitech-c920-camera-settings.plist ~/Library/LaunchAgents/
	launchctl unload ~/Library/LaunchAgents/logitech-c920-camera-settings.plist
	launchctl load ~/Library/LaunchAgents/logitech-c920-camera-settings.plist
