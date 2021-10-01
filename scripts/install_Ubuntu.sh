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
haxelib install hscript
haxelib install actuate 

# Enigma-specific dependencies
haxelib install haxe-strings
haxelib install tjson
haxelib install firetongue

# Use specific bleeding-edge builds
haxelib remove discord_rpc
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib remove hxvm-luajit
haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit
haxelib remove polymod
haxelib git polymod https://github.com/EnigmaEngine/polymod
haxelib remove linc_luajit
haxelib git linc_luajit https://github.com/EnigmaEngine/linc_luajit
haxelib remove extension-webm
haxelib git extension-webm https://github.com/EnigmaEngine/extension-webm
haxelib run lime rebuild extension-webm linux

haxelib list
