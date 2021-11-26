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
- The Alphabet text can now properly render all symbols (including )
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
  - Fixed a bug where opponent graphics in story mode had incorrect offsets.
  - Fixed a bug where the judgement/combo graphic was moved to the upper left corner and ignored the user configuration.
  - Fixed a bug where the Play state HUD was not zooming properly.
  - Removed Herobrine.
  - Fixed a LOT of other bugs not listed here.
