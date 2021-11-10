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
  - The only available scripts right now are `shouldShowOutdatedScreen.hscript` (which should output whether to show the screen that states the engine version is outdated) and `menu/TitleScreen.hscript` (which contains three functions, called onCreate, onCreditsDone, and onExit), but a LOT MORE will be available in the future (such as scripts for custom modchart).
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
- Split the game into `vanilla` and `base` builds.
  - Bundle assets into the executable file.
  - Vanilla builds include Weeks 1-6 and the corresponding enemy characters and are good if you want to play the base game with the improved engine.
  - Base builds only include the Tutorial and are good if you want a baseline to install mods with.
- You can now press SPACE to skip the starting splash screen and load all mods.
- Project XML reworked with additional improvements.
  - Added new defines: `-DincludeDefaultWeeks`, `-DembedAssets`.
- Added a unit test suite to help prevent regressions. See `test/README.md` for more info.
- Song data JSON can now specify the song asset used. This is useful if two charts use the same song file or if different difficulties of a chart use modified audio.
- Various bug fixes.
  - Fixed a bug where the game would crash if the `_meta.json` file for a song was missing.
  - Cut out informational logging calls for macros (people thought they were errors).
  - Fixed a bug where compiling the project outside of a Git repository would cause the build to fail.
  - Fixed a bug where player inputs would hit notes on the CPU's side of the field.
    - Yeah I made a LOT of changes and I'm still working out the kinks.
  - Boyfriend is no longer facing the wrong way.
  - Notes no longer spawn on the left edge of the screen.
  - Notes are no longer a TEENY bit offset horizontally.
  - The CPU strumline is no longer offset.
  - Sustains should now render properly.
  - Longer strumlines should be scaled properly.
  - Strumlines should not move once hitting a note, even on longer strumlines.
  - Fixed a bug where mod configuration would not persist between sessions.
  - Fixed a bug where songs would end early.
  - Fixed a bug where the game would try to end the song every frame, causing the game to basically crash at the results screen.
  - Fixed a bug where, during 'duets', the other character's notes would be swapped twice, putting all notes on one strumline.
  - Fixed a bug where animated author icon was not displaying in default opening credits.
  - Fixed issues with rendering of sustain notes. Partially.
  - Removed Herobrine.

## Known Issues
- [ ] Pausing will occasionally not stop the song properly.
  - Haven't been able to reliably reproduce this.
- [ ] Polymod doesn't list files properly when mods are disabled.
  - Know the approximate cause but the fix is fairly involved, and currently no functionality truly breaks because of it.
- [ ] Custom difficulties should not display in Story Weeks that don't have them.
- [ ] Story weeks with no valid difficulties should be completely hidden.
- [ ] Camera zoom is weird on the Tutorial song.
- [ ] Story mode character graphics have bad offsets.
- [ ] Charter is completely 🅱️roke like don't even go near it.

## To Implement
- [] [Use HXP for project files.](https://github.com/haxelime/lime/issues/1486)
  - Might fix issues with `includeDefaultWeeks`?
- [] Deprecate week-specific libraries. Data will go in `shared/stage` or applicable subfolder.
- [] Fully preload/cache song JSON data during startup.
- [] Finish moving all default characters to data files.
- [] Formatting changes.
  - Clean up the codebase to get rid of swears and unreadable variable names (shit, daThing, stuff).
  - Replace all instances of string concatenation with templating.
  - Replace all double quotes with single quotes.
  - Sort all import lines.
  - Replace `dad` with `cpu` and `bf` with `player` where applicable.
- [] Un-hardcode EVERYTHING.
  - Look for switch/case structures that check for specific levels or characters.
  - Move that data to the song/stage/character metadata as appropriate.
- [] Test for and fix any bugs.
  - Test all default weeks on multiple difficulties.
  - Test all the debug views including the Chart Editor.
  - Check to make sure key presses register on all strumline sizes.

