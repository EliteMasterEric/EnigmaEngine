# Changelog for 0.2

Changes marked with ⛧ will be listed in the short version of the changelog in `version.downloadMe`.

Initial release.

### Changes
- ⛧Reworked title and intro credits to be fully data driven.
- Added the ability to add text, clear text, add wacky text, choose more wacky text, or display/clear a graphic.
- ⛧Added 9-key support for songs.
  - Technically it's any number from 1 to 9.
- ⛧Added custom keybinds for 9-key songs.
- ⛧Rebindable fullscreen button.
- Move all the classes into packages for better organization.
- Replaced JSON parser with `tjson` to make data structure less strict on end users.
- Various bug fixes.
  - Fixed a bug where the game would crash if the `_meta.json` file for a song was missing.

### Plans before release

- Revamped the project XML file to be more 
- ⛧Split the game into `vanilla` and `base` builds.
  - Vanilla builds include Weeks 1-6 and the corresponding enemy characters and are good if you want to play the base game with the improved engine.
  - Base builds only include the Tutorial and are good if you want a baseline to install mods with.
- Split story mode menu assets into separate graphics so they can be individually reskinned or replaced.
- ⛧Basic script hook implementation.
  - The only available hooks right now are `onStartTitleScreen` and `onFinishTitleScreen`.
- ⛧Mod Configuration menu
- ⛧Made weeks data driven and added support for custom weeks.
- ⛧Added support for custom difficulties.
- Various bug fixes.
  - Cut out informational logging calls for macros (people thought they were errors).
  - Removed Herobrine.