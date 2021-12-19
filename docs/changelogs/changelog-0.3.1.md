# Changelog for 0.3.1

This minor update is focused on crash handling, stability and performance.

### Changes
- Replaced the crash handler.
### Fixes
- Fixed a bug where the window was scaled improperly on HXP builds.
- Fixed an issue where HXP builds would not embed assets properly, or preload the internal asset libraries properly.
- Fixed a bug where the game would crash when trying to load a Lua modchart when the file is embedded.
- Fixed an issue where HXP builds were not using the proper icons.
- Fixed a bug where the game would crash at the end of a week.
- Fixed a bug where pausing the game and returning to the menu would cause the game to crash.
