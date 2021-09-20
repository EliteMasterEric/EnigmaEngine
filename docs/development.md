# Building

Building Enigma Engine is easy, as long as you follow the guide carefully. If you miss a step, and an error pops up, it's your fault and not mine.

Note that this guide is for developers who want to contribute changes to the Enigma Engine itself.

* If you just want to play the game, go to [the releases tab](https://github.com/MasterEric/Enigma-Engine/releases) instead.
* If you want to make a basic mod, go to the [ModCore tutorial](https://github.com/MasterEric/Engima-Engine/wiki/modcore).

## Prerequisites

* A machine with the platform you want to build for. You can't make a Windows build on a Mac, you can't make a Linux build on Windows, etc.
    * If you're making a build for HTML5/browser, you can use any platform.
* Familiarity with the command line for your operating sytem (Powershell or CMD on Windows, the terminal on Mac/Linux).
* [Visual Studio Code](https://code.visualstudio.com/), the preferred development environment for Enigma Engine. The repo includes several launch configurations and settings for VS Code that make development easier.

## Dependencies

You will need to install the following dependencies:

* [Haxe (Latest Version)](https://haxe.org/download/). If you're already using 4.1.5, that should work fine, but I haven't had any issues with 4.2.3 and it's easier to download and use the latest version.
* Git
    * On Windows and MacOS platforms, you can download this from [git-scm](https://git-scm.com/downloads).
    * On Linux platforms, use the package manager for your distro. If you're on Ubuntu, run `sudo apt install git`. If you're not on Ubuntu, you already know how to install Git.

### Windows Visual Studio Dependencies

This one is a pain. If you're on Windows, building for it requires installing several gigabytes of SDKs.

Go to [this link](https://visualstudio.microsoft.com/downloads/) and download Visual Studio 2019 edition, then when prompted with downloading additional components, choose these:

-   MSVC v142 - VS 2019 C++ x64/x86 build tools
-   Windows SDK (10.0.17763.0)

## Haxe Library Dependencies

Now that all the other dependencies are done, we will need to install the Haxe libraries we need. Thankfully, this is easy, since it can be done through haxelib.

Open the command line for your OS and run these to install the libraries used for the game engine:
```
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib install flixel-tools
haxelib install flixel-addons
haxelib install flixel-ui
```

Then run this to set up console commands you will be using:
```
haxelib run lime setup
```

Then run this to install the dependencies that Enigma Engine uses:
```
haxelib install hxcpp-debug-server
haxelib install hscript
haxelib install actuate
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git faxe https://github.com/uhrobots/faxe
haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit
haxelib remove linc_luajit 
haxelib git linc_luajit https://github.com/MasterEric/linc_luajit.git
haxelib remove polymod
haxelib git polymod https://github.com/MasterEric/polymod.git
```

Then run these to install extension-webm, which is used for cutscenes:
```
haxelib git extension-webm https://github.com/KadeDev/extension-webm
lime rebuild extension-webm <PLATFORM>
```
Remember to replace `<PLATFORM>` with either `windows`, `mac`, or `linux` depending on what you use.

## Downloading the Game

We're going to use Git to clone the repository.

PRO TIP: If you're looking to become an experienced programmer, you need to learn to use Git and use it well. Do some research and find some good tutorials that explain how a Git repository is structured and how to properly interact with one.

If you're just looking to build the game, perform the following steps:

* Open the command line and use `cd` to navigate to the directory where you want to put the game.
* Run the following command:
```
git clone https://github.com/MasterEric/Enigma-Engine
```
* The uncompiled game files will now be in the directory you set.
* (OPTIONAL) If you want to use a specific version of Engima Engine, run `cd` to enter the folder, then run `git checkout 0.1-EE` or whatever version you want to download.

## Compiling the Game
There are two ways to build and run the game during development:

You can simply run `lime build windows`, but this is a bit clunky and it also misses out on a bunch of useful tools.

The recommended method is the following:

* Open Visual Studio Code and open the repository folder.
* When the workspace opens, you will be presented with a popup telling you to install some recommended extensions. Do this (you'll only have to do this once).
    * This will add support for Haxe syntax highlighting, Haxe code style formatting, support for the Lime build tool, and support for the HXCPP debugger.
* Click the arrow in the left side to switch to the Run and Debug tab.
* Select the platform you want from the dropdown and click the Run button.

This will automatically rebuild the game for you, then run the game, with debugging features enabled. See the next section for info on this.

## Debugging the Game

Now that you can compile and run the game from VSCode, you can start developing on features. However, you will likely experience one or more bugs or problems during development. Thankfully, powerful tools have been developed which Enigma Engine utilizes to their FULLEST.

### Breakpoints

When you run FNF as a Debug build from the Run and Debug menu, you get integration with VSCode's debugging tools. A set of controls will pop up, allowing you to stop, restart, or pause the game.

You can also set breakpoints; go to the line of code you are having trouble with, hover your mouse over the line number, and click the red dot on the left side. This creates a breakpoint; when the game reaches that particular line in the program, VSCode will pause it and show you useful information  in the left panel. This includes the call stack (which shows which functions were called by what other functions to get to this line), and a list of all local and member variables, which is very useful for determining the state of the program at a given point and diagnosing behavior.

While stopped at a breakpoint, you can click `Step Over` to move ahead one line in the program, `Step Into` to start stepping through the function being run on the current line, `Step Out` to continue running the program until the end of this function, or `Resume` to continue running the program until another breakpoint is hit.

### Crash Inspection

Sometimes the game will try to do something that doesn't make sense, like accessing an attribute of a null object. In this case, it will fail and the program will crash.

However, if you are running the game using the Run and Debug menu, VSCode will intercept this crash, find the line of code that caused it, and stop there like a breakpoint. This is very useful for diagnosing issues, since simply telling people that a Null Object Reference error occurred isn't useful unless you can show them what code is causing the error.

### HaxeFlixel Debugger

The third useful tool which Enigma has adapated itself to make full use of is the Debugger.

Among other things, the HaxeFlixel Debugger has the following tools:
* A Log view which outputs messages output by Haxe. These messages also show up in the VSCode Debug Console and in the log file (check `export/debug/<PLATFORM>/bin/log`).
* A Stats view with info about frame rate and memory usage.
* A VCR at the top which lets you pause the game or reset the current scene.
* A button at the top right which enables red boxes around each sprite.
* A Tools view that includes tools which allow you to select (Pointer), move (Mover), and transform (Transform) sprites.
* A Watch view, that lets you preview values you have set to be watched.
* A Console view you can type in.

You can drag these views around or hide them to suit your preferred layout.

### HaxeFlixel Console

The most powerful of these tools is definitely the console. You can type in most Haxe code into the console, and it will interpret and run it for you. Additionally, Enigma Engine has the unique feature of including several custom commands for the Debug Console, which are documented below

Name|Example|Description
----|-------|-----------
trackBoyfriend|`trackBoyfriend()`|Create a Tracker window displaying stats about the Boyfriend sprite.
trackGirlfriend|`trackGirlfriend()`|Create a Tracker window displaying stats about the Girlfriend sprite.
trackDad|`trackDad()`|Create a Tracker window displaying stats about the Dad sprite.
setLogLevel|`setLogLevel('WARN')`|Set the logging level; messages with lower significance are not displayed or written to the log file.
playSong|`playSong('Dad Battle', 2)`|Open the song with the given name and the given difficulty in Free Play,
chartSong|`chartSong('Dad Battle', 2)`|Open the song with the given name and the given difficulty in the Chart Editor.

If you have any other suggestions for console commands you feel would be useful for development, feel free to [suggest a feature](https://github.com/MasterEric/Enigma-Engine/issues).
