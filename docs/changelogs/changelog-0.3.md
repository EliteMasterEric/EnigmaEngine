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
- Song progress bar now displays time remaining and percentage complete.
- Project XML reworked with additional improvements.
  - Added new defines: `-DincludeDefaultWeeks`, `-DembedAssets`.
- Added a unit test suite to help prevent regressions. See `test/README.md` for more info.
- Song data JSON can now specify the song asset used. This is useful if two charts use the same song file or if different difficulties of a chart use modified audio.
- Various bug fixes.
  - Cut out some informational logging calls for macros (people thought they were errors).
  - Fixed a bug where sustains did not render properly.
    - It's probably the best it'll be for now.
  - Fixed a bug where the game would crash if the `_meta.json` file for a song was missing.
  - Fixed a bug where compiling the project outside of a Git repository would cause the build to fail.
  - Fixed a bug where player inputs would hit notes on the CPU's side of the field.
  - Fixed a bug where Boyfriend was facing the wrong way.
  - Fixed a bug where notes spawned on the left edge of the screen.
  - Fixed a bug where notes were a TEENY bit offset horizontally.
  - Fixed a bug where the CPU strumline was up the corner.
  - Fixed a bug where longer strumlines (6k, 9k) were not scaled properly.
  - Fixed a bug where strumlines would move once hitting a note.
  - Fixed a bug where mod configuration would not persist between sessions.
  - Fixed a bug where songs would end early.
  - Fixed a bug where the game would try to end the song every frame, causing the game to basically crash at the results screen.
  - Fixed a bug where, during 'duets', the other character's notes would be swapped twice, putting all notes on one strumline.
  - Fixed a bug where animated author icon was not displaying in default opening credits.
  - Fixed a bug where the CPU health icon was offset to the left.
  - Removed Herobrine.
  - Fixed a LOT of other bugs not listed here.

## Known Issues
- [ ] Story mode character graphics have incorrect offsets and need to be manually adjusted.
- [X] Percentage too long, no padded on single digit, 0:60 on progress bar.
- [ ] Progress bar not filling
- [ ] Hide song progress bar while song is in done state (no notes remaining)
- [ ] The Play State UI will be zoomed out until the opponent hits a note.
- [ ] The judgement/combo graphic has moved to the upper left corner.
- [ ] Sustain notes with short durations (only one segment) hide the segment behind the parent note.
- [ ] Some sustain notes in Dad Battle (appox 65 seconds in) do not render the parent note.
- [ ] Pausing will occasionally not stop the music from playing, causing the chart to skip ahead when unpausing.
  - Haven't been able to reliably reproduce this.
- [ ] Polymod does not correctly list available files when some or all mods are disabled.
  - Know the approximate cause but the fix is fairly involved, and currently no functionality truly breaks because of it.
- [ ] Difficulties should not display in the selector on Story Weeks that don't have them.
- [ ] Story weeks with no valid difficulties should be completely hidden.
- [ ] The camera moves around weirdly when focusing on Girlfriend during the Tutorial.
- [ ] Figure out all the stuff that's wrong with the charter.

## To Implement
- [] [Use HXP for project files.](https://github.com/haxelime/lime/issues/1486)
  - Might fix issues with `includeDefaultWeeks`?
- [] Finish moving all default characters to data files.
- [] Deprecate week-specific asset libraries. Data will go in `shared/stage` or applicable subfolder.
  - [x] tutorial
  - [x] week1
  - [x] week2
  - [] week3
  - [] week4
  - [] week5
  - [] week6
- [] Fully preload/cache all song JSON data during startup.
- [] Formatting changes.
  - Clean up the codebase to get rid of swears and unreadable variable names (shit, daThing, stuff).
  - Replace all instances of string concatenation with templating.
  - Replace all double quotes with single quotes unless necessary.
  - Sort all import lines.
  - Replace `dad` with `cpu` and `bf` with `player` where applicable.
- [] Un-hardcode EVERYTHING.
  - Look for switch/case structures that check for specific levels or characters.
  - Move that data to the song/stage/character metadata as appropriate.
- [] Move logging to a separate thread so it doesn't slow down the game.
- [] Test for and fix any bugs.
  - Test all default weeks on multiple difficulties.
  - Test all the debug views including the Chart Editor.
  - Check to make sure key presses register on all strumline sizes.

