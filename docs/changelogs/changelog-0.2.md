# Changelog for 0.2

Changes marked with ⛧ will be listed in the short version of the changelog in `version.downloadMe`.

First public release. Now has support for data-driven custom weeks, data-driven title sequence, 9-key songs, custom difficulties, and a mod configuration menu, among other things.

### Changes
- Refactored thousands of lines of code.
  - The game's logic is now far more grok-able, and thus more maintainable.
  - Affected classes include Replay, Options, Note, StoryMenuState, Character, TitleState, and PlayState.
  - Move all the classes into packages for better organization.
  - Added a LOT of documentation.
  - Replaced JSON parser with `tjson` to make data structure less strict on end users.
- ⛧Reworked title and intro credits to be fully data driven.
  - Added the ability to add text, clear text, add wacky text, choose more wacky text, or display/clear a graphic.
- ⛧Made weeks data driven and added support for custom weeks.
  - You can use custom backgrounds for the story menu (either a color or a 1280x400 image).
  - By default, weeks will use the colors from Week 7.
  - Split story mode menu assets into separate graphics so they can be individually reskinned or replaced.
- ⛧Added support for custom difficulties.
- ⛧Added support for animated health icons.
- ⛧Added 9-key support for songs.
  - Technically it's any number from 1 to 9.
  - Added custom keybinds for 9-key songs.
- ⛧Reworked the input system.
  - Necessary to support 9-key mode.
  - Added the ability to rebind the fullscreen button.
- Did some refactoring of the Options menu.
  - New `Advanced Key Binds` option
- ⛧Split the game into `vanilla` and `base` builds.
  - Bundle assets into the executable file.
  - Vanilla builds include Weeks 1-6 and the corresponding enemy characters and are good if you want to play the base game with the improved engine.
  - Base builds only include the Tutorial and are good if you want a baseline to install mods with.
- Project XML reworked with additional improvements.
  - Added new defines: `-DincludeDefaultWeeks`, `-DembedAssets`.
  - Added some of the skeleton for a test suite, but `-DexecuteTests` is not functional yet.
- Various bug fixes.
  - Fixed a bug where the game would crash if the `_meta.json` file for a song was missing.
  - Cut out informational logging calls for macros (people thought they were errors).
  - Fixed a bug where compiling the project outside of a Git repository would cause the build to fail.
  - Removed Herobrine.


## To Implement

- ⛧Mod Configuration menu
- Test out custom weeks.
- Test out custom difficulties.
- ⛧Basic script hook implementation.
  - Script hooks basically let you make plugins for your mods, imagine modcharts but not just for songs.
  - The only available hooks right now are `onStartMainMenu` and `onFinishMainMenu`, but a LOT MORE will be available.
- Formatting changes.
  - Clean up the codebase to get rid of swears and unreadable variable names (shit, daThing, stuff).
  - Replace all instances of string concatenation with templating.
  - Replace all double quotes with single quotes.
  - Sort all import lines.
  - Add license header and docs header to every file.
  - Replace all uses of `StringTools` with `haxe-strings`.
  - Replace `dad` with `cpu` and `bf` with `player` where applicable.
- Test for and fix any bugs.
  - Check to make sure key presses register on all strumline sizes.
  - Check to make sure sustain notes position and clip themselves properly.