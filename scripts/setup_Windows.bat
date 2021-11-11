@echo off

title Enigma Engine Setup
echo Before continuing, please install the latest version of Haxe (v4.2.4 or later).
echo https://haxe.org/download/
echo Press any key to continue...
pause >nul

REM Install core engine dependencies

echo Installing Haxe libraries...

REM System interface
haxelib install lime
haxelib install hxp
REM Flash API compatibility layer
haxelib install openfl
REM Game engine
haxelib install flixel
REM Game engine utilities
haxelib install flixel-tools
REM UI elements
haxelib install flixel-ui
REM Additional game engine features.
haxelib install flixel-addons

REM Perform setup steps

haxelib run lime setup
haxelib run lime setup flixel
haxelib run lime setup flixel-tools

REM Install Enigma-specific dependencies

REM Powerful string utilties
haxelib install haxe-strings
REM Localization handling
haxelib install firetongue
REM Required for debugging
haxelib install hxcpp-debug-server
REM I think this is required for one of the video player classes?
haxelib git actuate https://github.com/jgranick/actuate
REM Discord integration
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git hscript https://github.com/HaxeFoundation/hscript
REM Lua modchart support
haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit
haxelib git linc_luajit https://github.com/EnigmaEngine/linc_luajit
REM Atomic mod support
haxelib git polymod https://github.com/MasterEric/polymod develop
REM More leniant JSON parsing. Using my fork because of: https://github.com/JWambaugh/TJSON/pull/34
haxelib git tjson https://github.com/MasterEric/TJSON
REM Required for WEBM video cutscenes
haxelib git extension-webm https://github.com/EnigmaEngine/extension-webm
haxelib run lime rebuild extension-webm windows

REM Install unit test dependencies
haxelib install munit
haxelib install hamcrest
haxelib git mockatoo https://github.com/EnigmaEngine/mockatoo

REM Install Visual Studio tools
echo Visual Studio Community Edition and Windows 10 SDK 1901 are required dependencies for Enigma Engine.
echo Total required disk space: ~5.5GB
echo If you have already successfully built Friday Night Funkin' mods in the past, you can skip this step.
echo Would you like to install them now?
CHOICE /C YN 
IF %ERRORLEVEL% EQU 1 goto InstallWindowsSDK
IF %ERRORLEVEL% EQU 2 goto SkipInstallWindowsSDK

:InstallWindowsSDK
echo Installing Windows 10 SDK...
curl -# -O https://download.visualstudio.microsoft.com/download/pr/7aa16be3-9952-4bd2-8ecf-eae91faa0a06/14fe35fa35c305b03032a885ff3ebefaf88fce5051ee84183d4c5de75783339e/vs_Community.exe
vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p
del vs_Community.exe

:SkipInstallWindowsSDK

echo Enigma Engine highly recommends installing Visual Studio Code, which is a free and open-source IDE.
echo Would you like to install it now?
CHOICE /C YN
IF %ERRORLEVEL% EQU 1 goto InstallVSCode
IF %ERRORLEVEL% EQU 2 goto SkipInstallVSCode

:InstallVSCode
echo Installing Visual Studio Code...
curl -# -o vs_code.exe -O https://code.visualstudio.com/sha/download?build=stable&os=win32-x64
vs_code.exe
del vs_code.exe

:SkipInstallVSCode

echo Setup is complete. Have fun!
