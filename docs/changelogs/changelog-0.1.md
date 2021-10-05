# Changelog for 0.1

Changes marked with ⛧ will be listed in the short version of the changelog in `version.downloadMe`.

Initial release. No modloader or custom weeks yet.

### Changes
- Forked Enigma from Kade Engine v1.7.1-prerelease.
- ⛧Added initial ModCore support.
- ⛧Reworked characters to be fully data driven.
- ⛧Added a log file for improved debugging.
- Added an improved logging system, which directs messages to `trace()`, the Flixel command line, and the log file.
    - Redirected existing `trace` calls to use the new system.
- Added custom commands to the HaxeFlixel console.
    - Added commands for creating tracking windows for BF, Dad, and GF during play mode, as well as starting a song in Free Play by its ID.
- Various bug fixes.
    - Fixes to ensure custom songs in freeplay work properly.
