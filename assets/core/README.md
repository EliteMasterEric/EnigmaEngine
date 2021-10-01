# core

The `core` asset folder contains assets which are imported and used even before `preload` assets. Namely, it contains assets which are loaded and used BEFORE MODS ARE LOADED. This means they can't be modified by mods.

If we placed them in one of the other folders, it would cause an issue with caching where the proper image would not load.
