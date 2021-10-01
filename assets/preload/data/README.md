# data

The following changes have been made here:

* Moved the song data files into the `songs` folder.
* Added the `characters` folder and moved character offset data there.
* Moved data for Weeks 1-6 to the `_includeDefaultWeeks` folder. These overlay the files at build time if you use the `-DincludeDefaultWeeks` argument.
* Week name data is now in the `weeks` data files.
* The IDs of the weeks that appear, and in what order, are specified in the `weekOrder.txt` file.
    * To add your custom week without removing other custom weeks, create an `_append/data/weekOrder.txt` file in your mods folder and add the ID there. APPEND, don't override, whenever possible.
* freeplaySonglist.txt now specifies a week ID rather than a week index.

## To Do

* Add stage data here.
* Remove stageList.txt, and make it based on the data files.
* Test if `noteStyleList.txt` works properly.
* Actually make `noteTypeList.txt` work properly.
* Actually make `difficulties.txt` work properly.