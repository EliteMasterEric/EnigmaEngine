# Changelog for 0.4.0

Changes marked with ⛧ will be listed in the short version of the changelog in `version.downloadMe`.

This release, and all subsequent releases, will provide two builds for each platform. The `base` build only includes the tutorial, whereas the `full` build includes the six vanilla weeks.

### Additions
- [ ] ⛧ Add custom stage support.
  - A custom stage, including its components and their layout and behavior, are fully defined in an HScript file, which means they have full mod hook support.
- [ ] ⛧ Add mod hook support for characters.
  - This allows you to perform custom behavior of your choosing whenever something happens in the game, as long as that character is loaded. You can override animations and more.
- Added the `packer` atlas type, which allows the use of Packer format files for character sprites.
  - This is the character type used by Spirit.
- Added the `multisparrow` atlas type, which allows a single character to use multiple SparrowV2 spritesheets.
  - This is the character type used by Pixel BF (his death animation is in a separate file).
  - This will later be used for the Hellclown Tricky character in the .
- [ ] Add the `spine` atlas type, which allows for the use of Spine characters rather than Sparrow spritesheets.
  - [Spine](http://esotericsoftware.com/spine-demos) is a software tool created by Esoteric Software for creating 2D character animations.
### Changes
- All vanilla characters are now fully softcoded.
- [ ] Rework the character class to abstract the logic of the character from the rendering, making it possible to create and maintain new atlas types.
  - This includes the new Spine atlas type.
  - Additional atlas types are planned for the future (such as Adobe Animate).
- Reworked the crash handler to display a popup and write an uploadable log file.
- The game no longer freezes when the game window loses focus.
- Week data and difficulties are now cached at the start of the game.
- [ ] Add a Preload Stages option to load stage graphics in memory during the initial loading screen.
- [ ] Cache song data (charts) at the start of the game.
- [ ] Cache character data (jsons) at the start of the game.
- [ ] 'Ghost tapping' misses no longer affects your accuracy percentage.
- [ ] Add multicharacter rendering (think Chaotic Endless and Slaughter Me Street)
- Made accuracy display into a stepwise function.
  - Accuracies lower than 95% don't show decimal precision at all, and accuracies higher than 98% show triple-digit precision.
### Removals
- Pressing '7' on the keyboard no longer opens the charter.
  - I have removed the charter from the game until a future update, when it will be renovated (or moved to [a separate application](https://github.com/EnigmaEngine/EnigmaModMaker)).
  - Standard FNF chart files should be fully supported, I recommend using [ArrowVortex](https://www.youtube.com/watch?v=mYsGNn3CSAA) then finding a converter to FNF).
### Fixes
- Fixed a bug where the window was scaled improperly on HXP builds.
- Fixed an issue where HXP builds would not embed assets properly, or preload the internal asset libraries properly.
- Fixed a bug where the game would crash when trying to load a Lua modchart when the file is embedded.
- Fixed an issue where HXP builds were not using the proper icons.
- Fixed a bug where the game would crash at the end of a week.
- Fixed a bug where pausing the game and returning to the menu would cause the game to crash.
- Fixed a bug where rescaling the window would cause the play UI to be rendered off-center.
- [ ] Fix a bug where Bopeedo is missing it's 'HEY' animations.
- [ ] Fix a bug where custom health icons are not displayed properly.
- [ ] Fix a bug where the "appear" animation for the results screen appears twice.
- [ ] Fix a crash bug when opening the Free Play menu.

## Work-in-Progress


