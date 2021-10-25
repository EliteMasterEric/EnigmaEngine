#!/bin/bash
cd ./test
haxelib run munit gen
haxelib run lime test linux -debug