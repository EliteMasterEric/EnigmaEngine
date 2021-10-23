# Changelog for 0.2

Changes marked with ⛧ will be listed in the short version of the changelog in `version.downloadMe`.

First public release. Now has support for data-driven custom weeks, data-driven title sequence, 9-key songs, custom difficulties, and a mod configuration menu, among other things.

### Changes
- ⛧Reworked title and intro credits to be fully data driven.
- Added the ability to add text, clear text, add wacky text, choose more wacky text, or display/clear a graphic.
- ⛧Added 9-key support for songs.
  - Technically it's any number from 1 to 9.
- ⛧Added custom keybinds for 9-key songs.
- ⛧Split the game into `vanilla` and `base` builds.
  - Vanilla builds include Weeks 1-6 and the corresponding enemy characters and are good if you want to play the base game with the improved engine.
  - Base builds only include the Tutorial and are good if you want a baseline to install mods with.
- ⛧Rebindable fullscreen button.
- ⛧Mod Configuration menu
- ⛧Made weeks data driven and added support for custom weeks.
  - Added the ability to use custom backgrounds for the story menu (either a color or a 1280x400 image).
  - Changed the default weeks to use the custom colors from the Newgrounds release.
- ⛧Added support for custom difficulties.
- ⛧Added support for animated health icons.
- Revamped the project XML file to be more functional.
  - Added print calls to display what platform is being built.
  - Added define to include vanilla game data into the build. Use `-DincludeDefaultWeeks` to enable it.
- ⛧Bundled default assets into the executable file.
- Removed code related to importing StepMania charts. Never heard of anyone actually using this...
- Split story mode menu assets into separate graphics so they can be individually reskinned or replaced.
- Move all the classes into packages for better organization.
- Replaced JSON parser with `tjson` to make data structure less strict on end users.
- Various bug fixes.
  - Fixed a bug where the game would crash if the `_meta.json` file for a song was missing.
  - Cut out informational logging calls for macros (people thought they were errors).
  - Fixed a bug where compiling the project outside of a Git repository would cause the build to fail.
  - Removed Herobrine.

## To Implement

- Finish mod menu.
- Test out custom weeks.
- Test out custom difficulties.
- ⛧Basic script hook implementation.
  - The only available hooks right now are `onStartTitleScreen` and `onFinishTitleScreen`.
- Formatting changes.
  - Clean up the codebase to get rid of swears and unreadable variable names (shit, daThing, stuff).
  - Replace all instances of string concatenation with templating.
  - Replace all double quotes with single quotes.
  - Sort all import lines.
  - Add license header and docs header to every file.
  - Replace all uses of `StringTools` with `haxe-strings`.
  - Replace `FlxG.log.warn` with `Debug`
  - Replace `dad` with `cpu` and `bf` with `player` where applicable.
- Test for and fix any bugs.