#!/bin/bash
cd ./test
haxelib run munit gen
#haxelib run munit test
haxelib run lime test linux -debug