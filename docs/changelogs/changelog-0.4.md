# Changelog for 0.3

Changes marked with ⛧ will be listed in the short version of the changelog in `version.downloadMe`.

This release, and all subsequent releases, will provide two builds for each platform. The `base` build only includes the tutorial, whereas the `full` build includes the six vanilla weeks.

## Added
- Added character JSON data, week JSON data, and difficulty data to the initial caching step.
- Added a Preload Stages option to load stage graphics in memory during the initial loading screen.
## Changed
- Reworked the initial caching loading screen.
- The game no longer freezes when the game window loses focus.
- Made accuracy display into a stepwise function.
  - Accuracies lower than 95% don't show decimal precision at all, and accuracies higher than 98% show triple-digit precision.
## Fixed


## Work-in-Progress
- [] Custom stage support
- [] Additional character types (spine, dragonbones, multisparrow)
- [] Multiple character support
- [] Modhook support
- [] Pre-cache song data
- [] Ghost misses and ghost tapping should not affect accuracy.
