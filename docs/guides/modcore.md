# Modding Guide
Enigma Engine is home to a powerful and useful tool known as ModCore. ModCore makes it easy to append, replace, or merge files without editing the game's code.

Enigma Engine's ModCore is powered by [Polymod](https://github.com/larsiusprime/Polymod). Polymod is what handles loading the relevant assets, ensuring they are injected properly. It also handles ensuring mods are loaded in the proper order.The basic premise is that mods within the mods folder of your Enigma Engine install will be automatically loaded into the game.

Currently, ModCore allows users to do the following:

Install and uninstall mods as easily as moving them into and out of the mods folder (with a mod menu coming soon).
Replace any existing assets (including graphics, song data, or audio files).
Append to or modify files without breaking mods that overlap.
Using mods
To install a mod, place the folder inside the mods folder. To disable or uninstall a mod, take it out of the folder.

One day, we'll probably have a mod menu that lets you control what order mods are loaded in.

## Developing Mods
This page includes basic documentation for the development of mods.

## Metadata
You will want several pieces of metadata in order for Enigma Engine to identify and display your mod. Only _polymod_meta.json is mandatory, while other mods are recommended.

`_polymod_meta.json`
This file tells Polymod all about your mod, such as name and description. This file is MANDATORY.
Learn more about how to write this file below.
`_polymod_icon.png`
This icon will be used by mod browsers in the future. Make sure to provide one, 256x256 should be pretty good.
`LICENSE.txt`
This is the general sofware license used by the mod. Without a license, your mod is under All Rights Reserved.
`ASSET_LICENSE.txt`
This is the license specifically for the mod's assets.
Creative Commons is recommended.
`CODE_LICENSE.txt` (for code/script-specific licensing terms.
GPLv3, Apache, or MIT are recommended.
`_polymod_pack.txt`
Used for modpacks.
`_polymod_meta.json`
Here is an example of a valid mod metadata file.

Note that both api_version and mod_version should use valid [Semantic Versioning 2.0.0](https://semver.org) values.
``` json
{
	"title":"Daisy",
	"description":"This mod has a daisy",
	"author":"Lars A. Doucet",
	"api_version":"0.1.0",
	"mod_version":"1.0.0-alpha",
	"license":"CC BY 4.0,MIT"
}
```

`title`, `description`, `author`, and `license` should be self-explanatory. Be sure to put good values here as they will eventually be displayed in the mod menu.
`mod_version` should be a version number that you set, and increment every time the mod changes.
`api_version` is a version set by Enigma Engine. This uses Semantic Versioning; one or more breaking changes that will require fixes in existing mods (which should happen very rarely and will include a migration guide here on the wiki) will increment the major version, feature additions that don't break existing mods will increment the minor version, and backwards compatible bug fix changes and tweaks will increment the patch version. If the API version you specify in your mod is not compatible, Enigma Engine will not load it.
## Assets
You can create complex and elaborate mods simply by adding the relevant assets to your mod folder. By adding song data files to the data/songs folder, the game will be able to detect and load them if you add the relevant data to the weeks

### Adding and Replacing
Asset additions and replacements are simple; just place the assets in the relevant subfolder.

Here's what the mod folder might look like for a simple "XXX over Boyfriend" mod.

```
<modRoot> (name this anything)
|- _polymod_meta.json
|- images
  |- characters
    |- BOYFRIEND.xml
    |- BOYFRIEND.png
|- data
  |- characters
    |- boyfriend.json
```
Some tips:

- The folder structure corresponds with that used by the [game's asset folder](https://github.com/EnigmaEngine/EnigmaEngine/tree/stable/assets). Assets which go into the preload folder are instead moved up to the mod root folder but otherwise the structure remains the same.
Check out a real example at [ENA Skin Pack for ModCore]()
- Assets which share the same name as assets already in the game will replace those assets.
- Song files have been moved into a subdirectory at data/songs/<songname> rather than being in data/<songname>. As long as you place the song in the CORRECT subdirectory, the game will automatically detect it.
- Code for adding new characters has been abstracted to read from a file in `data/characters/`
- Data files which are new and do not share the same name as an existing asset (such as new song files in data/songs will be readable by the game as long as you add them to Free Play or a custom week; see the Appending section below.
  
### Appending
Appending to assets is only slightly more involved. Appending is used when you want to add to the end of a particular text file without getting rid of what's already there.

For example, using the above method on introText.txt will get rid of the base game's intro text values, as well as any that other mods may have added. This may or may not be what you want. Appending will put your values at the end of the file for other mods to add to.

To perform asset appending, place the assets in the relevant subfolder under the _append folder, like so. Note the underscore before it.

```
<modRoot> (name this anything)
|- _polymod_meta.json
|- _append
  |- data
    |- introText.txt
    |- freeplaySonglist.txt
```
Some tips:

- freeplaySonglist.txt now uses song IDs (aka the name of the song directory, which has no spaces or symbols) to identify the songs in Free Play and the order they appear.
- If you use the Adding and Replacing method above to add a new song to the game, it won't appear in the Free Play song list unless you append its ID, character icon, and week number to freeplaySonglist.txt.
Merging
Merging is the most powerful yet the most convoluted method. Use it only if you can't use replacement or appending.

Merging locates a given key in a file and replaces it with the intended value.

For CSV and TSV files, the value in the first column is assumed to be the ID. Each ID in the merge CSV is located in the base CSV, and that row is replaced with the row from the merge CSV.
For LINES text files, Polymod will use the first line as the pattern to check for, it will look it, and insert the other lines of the merge file after that one, before continuing with the rest of the file. .txt files use the LINES format by default. For example, if the base file reads:
```
ABC
DEF
GHI
```
And the merge file reads:

```
DEF
123
```
The merged file will look like:
  
```
ABC
DEF
123
GHI
```
For `PLAINTEXT` text files, Polymod will throw a warning that merging is not supported.
For `XML` files, you need to add a child key called merge which specifies the key and value to match on. All other values will be replaced. See here for more info.
For `JSON` files, create a single top-level array named merge. Each element is an object with two keys: A key target like abc.d[3].e, and a value to insert payload. See here for more info.
Modpacks
To create a modpack, make a mod containing a _polymod_pack.txt file with the following text:

`foo:1.0.0,bar:1.*.*,abc,xyz`
ModCore will search for, and load, the mods with the IDs foo, bar, abc, and xyz, in that order. It will fail any mods that fail the version check (foo must be exactly 1.0.0 while bar allows any 1.x version) and only load the mods which don't fail.

### Scripts
Coming soon...

Distributing Mods
The ideal means of distributing a mod is by creating a mod folder and distributing it, so that users can download Enigma Engine and install the mod themselves (or, in the future, use a tool that helps them do that).

However, if you are still set on distributing your mod as a standalone executable, here are the steps to follow for that:

- Follow the guide at [Building Enigma Engine](https://github.com/EnigmaEngine/EnigmaEngine/wiki/building-enigma-engine) and clone the stable branch.
- Develop your mod using the standard method with the mods folder, since that has better debugging.
- Go to Enigma.hx and change the static variable ENABLE_MODS to false. This disables all of the behavior related to mods without having to perform messy code cleanup.
- Install your mod data directly into the assets folder. Add any files you want to add, replace any files you want to replace, directly modify or append any files you want to change.
Remember that main menu assets and song charts go into the preload directory.
- If you want to remove the basic weeks, modify data/freeplaySongList to remove them from free play, and modify the week data file to remove those weeks from story mode.
- You can also delete any files in music, data files in data/songs, or asset files that you know are only used by those weeks.
- Build, test, and distribute that.

  Although this method of creating mods is not the preferred method (ideally you can distribute mods in both formats for the purposes of forwards compatibility) it is still officially endorsed, and you may create issues and bug reports related to it.
