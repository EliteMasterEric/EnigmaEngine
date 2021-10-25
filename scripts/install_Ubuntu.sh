#!/bin/bash

#
# Installs Haxe, Lime, and any other necessary libraries
#

# Setup Haxe
export HAXELIB_ROOT=~/.haxe/lib
sudo add-apt-repository ppa:haxe/releases -y
sudo apt-get update
sudo apt-get install gcc-multilib g++-multilib haxe -y
mkdir "%HAXELIB_ROOT%"
haxelib setup "%HAXELIB_ROOT%"

# HaxeFlixel Game Engine
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-ui
haxelib install flixel-tools

# Enigma-specific dependencies
haxelib install haxe-strings
haxelib install firetongue
haxelib install munit
haxelib install hamcrest

# Use specific bleeding-edge builds
haxelib git hscript https://github.com/HaxeFoundation/hscript
haxelib git actuate https://github.com/jgranick/actuate
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit

# Use my forks.
haxelib git polymod https://github.com/MasterEric/polymod
# Wait until https://github.com/JWambaugh/TJSON/pull/34 is merged to revert back.
haxelib git tjson https://github.com/MasterEric/TJSON
haxelib git linc_luajit https://github.com/EnigmaEngine/linc_luajit
haxelib git mockatoo https://github.com/EnigmaEngine/mockatoo

# Build the WebM extension.
haxelib git extension-webm https://github.com/EnigmaEngine/extension-webm
haxelib run lime rebuild extension-webm linux

haxelib list
