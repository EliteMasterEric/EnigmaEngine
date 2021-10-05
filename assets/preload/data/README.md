# data

The following changes have been made here:

* Moved the song data files into the `songs` folder.
* Added the `characters` folder and moved character offset data there.
* Moved data for Weeks 1-6 to the `_includeDefaultWeeks` folder. These overlay the files at build time if you use the `-DincludeDefaultWeeks` argument.
* Week name data is now in the `weeks` data files.
* The IDs of the weeks that appear, and in what order, are specified in the `weekOrder.txt` file.
    * To add your custom week without removing other custom weeks, create an `_append/data/weekOrder.txt` file in your mods folder and add the ID there. APPEND, don't override, whenever possible.
* freeplaySonglist.txt now specifies a week ID rather than a week index.
* You can add to or replace `difficulties.txt`; entries take the format `id:songSuffix`.
    * `songSuffix` is whatever you put after the song name in your data files to refer to that difficulty.
    * The default difficulty is either `normal`, or the first element in the list if you got rid of Normal.
    * The difficulty list will use the same order as `difficulties.txt`
    * The game will look for a graphic in `images/storymenu/difficulty` matching the ID of the difficulty.
    * You don't have to include every difficulty for every song. If a song is missing a difficulty, the song in Free Play and any weeks that contain it in Story Mode will be hidden/inaccessible.
    * Here's an example. To add an Insane difficulty, create a `_append/data/difficulties.txt` in your mod folder, and add the line `insane:-insane`. Create a graphic called `images/storymenu/difficulty/insane.png` in your mod folder, and add a chart file to your custom song with the filename `songname-insane.json`.
        * You don't even need to include the `Easy`, `Normal`, or `Hard` difficulties if you don't want to, but I recommend it for accessibility.

## To Do

* Add stage data here.
* Remove stageList.txt, and make it based on the data files.
* Test if `noteStyleList.txt` works properly.
* Actually make `noteTypeList.txt` work properly.
