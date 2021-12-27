#!/bin/bash

# This script is used to setup the development environment on Ubuntu.
# Should be easy to adapt to other distros.

# https://haxe.org/download/linux/
echo "Installing Haxe..."
sudo add-apt-repository ppa:haxe/releases -y
sudo apt-get update
sudo apt-get install haxe -y
mkdir ~/haxelib && haxelib setup ~/haxelib

echo "Installing Haxe libraries..."

# System interface
haxelib install lime
haxelib install hxp
# Flash API compatibility layer
haxelib install openfl
# Game engine
haxelib install flixel
# Game engine utilities
haxelib install flixel-tools
# UI elements
haxelib install flixel-ui
# Additional game engine features.
haxelib install flixel-addons

# Perform setup steps

haxelib run lime setup
haxelib run lime setup flixel
haxelib run lime setup flixel-tools

# Install Enigma-specific dependencies

# Powerful string utilties
haxelib install haxe-strings
# Localization handling
haxelib install firetongue
# Required for debugging
haxelib install hxcpp-debug-server
# I think this is required for one of the video player classes?
haxelib git actuate https://github.com/jgranick/actuate
# Discord integration
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git hscript https://github.com/HaxeFoundation/hscript
# Lua modchart support
haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit
haxelib git linc_luajit https://github.com/EnigmaEngine/linc_luajit
# Atomic mod support
haxelib git polymod https://github.com/MasterEric/polymod develop
# More leniant JSON parsing. Using my fork because of: https://github.com/JWambaugh/TJSON/pull/34
haxelib git tjson https://github.com/MasterEric/TJSON
# Required for WEBM video cutscenes
haxelib git extension-webm https://github.com/EnigmaEngine/extension-webm
haxelib run lime rebuild extension-webm linux

# Install unit test dependencies
haxelib install munit
haxelib install hamcrest
haxelib git mockatoo https://github.com/EnigmaEngine/mockatoo

echo "Enigma Engine highly recommends installing Visual Studio Code, which is a free and open-source IDE."
echo "Download it here: https://code.visualstudio.com/"
echo "Once installed, open the command line and type 'code' to open the IDE."

echo ""
echo "Setup is complete. Have fun!"
