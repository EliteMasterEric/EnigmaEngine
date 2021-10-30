# Changelog for 0.3

Changes marked with ⛧ will be listed in the short version of the changelog in `version.downloadMe`.

First public release. Now has support for data-driven custom weeks and a mod configuration menu, among other things.

### Changes
- Refactored thousands of lines of code.
  - The game's logic is now far more grok-able, and thus more maintainable.
  - Affected classes include Replay, Options, Note, StoryMenuState, Character, TitleState, and PlayState.
  - Added a LOT of documentation.
- ⛧Basic script hook implementation.
  - Script hooks basically let you make plugins for your mods, imagine modcharts but not just for songs.
  - The only available hooks right now are `onStartCreateTitleScreen` and `onFinishCreateTitleScreen`, but a LOT MORE will be available.
- ⛧Made weeks data driven and added support for custom weeks.
  - You can use custom backgrounds for the story menu (either a color or a 1280x400 image).
  - By default, weeks will use the colors from Week 7.
  - Split story mode menu assets into separate graphics so they can be individually reskinned or replaced.
- ⛧Added support for custom difficulties.
- ⛧Added support for animated health icons.
- ⛧Reworked the input system.
  - Should now have improved performance and accuracy.
  - Necessary to support 9-key mode.
- Did some refactoring of the Options menu.
  - New `Advanced Key Binds` option for rebinding 9-key binds.
- ⛧Split the game into `vanilla` and `base` builds.
  - Bundle assets into the executable file.
  - Vanilla builds include Weeks 1-6 and the corresponding enemy characters and are good if you want to play the base game with the improved engine.
  - Base builds only include the Tutorial and are good if you want a baseline to install mods with.
- Project XML reworked with additional improvements.
  - Added new defines: `-DincludeDefaultWeeks`, `-DembedAssets`.
- Added a unit test suite to help prevent regressions. See `test/README.md` for more info.
- Various bug fixes.
  - Fixed a bug where the game would crash if the `_meta.json` file for a song was missing.
  - Cut out informational logging calls for macros (people thought they were errors).
  - Fixed a bug where compiling the project outside of a Git repository would cause the build to fail.
  - Fixed a bug where player inputs would hit notes on the CPU's side of the field.
    - Yeah I made a LOT of changes and I'm still working out the kinks.
  - Fixed a bug where strumlines would render with a gap between (I spent HOURS diagnosing the code but the problem was with the spritesheet).
  - Removed Herobrine.


## To Implement
Current Bug Checklist
[] Polymod doesn't list files properly when mods are disabled.
[] CPU strumline is oriented wrong top 
[] Duets don't work properly (both players are on the same strumline)
[] Are sustains broken again?
[] Boyfriend facing the wrong way.
[] Author icon not displaying in default opening credits.

- Finish moving all default characters to data files.
- Test out custom characters.
- Test out custom songs.
- Test out custom weeks.
- Test out custom difficulties.
- Formatting changes.
  - Clean up the codebase to get rid of swears and unreadable variable names (shit, daThing, stuff).
  - Replace all instances of string concatenation with templating.
  - Replace all double quotes with single quotes.
  - Sort all import lines.
  - Replace `dad` with `cpu` and `bf` with `player` where applicable.
- Test for and fix any bugs.
  - Test all default weeks on multiple difficulties.
  - Test Freeplay and Story Mode.
  - Test all the debug views including the Chart Editor.
  - Check to make sure key presses register on all strumline sizes.
