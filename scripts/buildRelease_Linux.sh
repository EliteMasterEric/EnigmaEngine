#!/bin/bash

# TODO: Finish this script to zip the file for you.

haxelib run lime build linux -32 -cpp
haxelib run lime build linux -64 -cpp
# haxelib run lime build linux -32 -cpp -DincludeDefaultWeeks
# haxelib run lime build linux -64 -cpp -DincludeDefaultWeeks