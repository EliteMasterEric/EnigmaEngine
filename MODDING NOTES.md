# Modding Notes

## Resources

https://gamebanana.com/tuts/13798

## Which asset folder to use?

* exclude: These files aren't in the build at all.
* sm: Easily add StepMania songs to the freeplay menu by putting them in this folder. Not used for mods.

* fonts: Use for any fonts to display in-game.
* songs: Use for song instrumentals and voice files.
* preload: 
* shared: 
* week#: 

## Modcharts

With Modcharts you can:
* Add special behavior to a chart (such as moving or disappearing strumlines) without recompiling the game.
* Perform special conditions at the start, on update, upon hitting a step, upon hitting a beat, upon pressing a key.
* Perform behavior only on certain difficulties or after a certain note.
* Switch the current boyfriend or dad character used.
* Create and draw a sprite (path relative to the Lua file, i.e. `assets/data/NAME/`).
  * Position or do whatever with that actor ID (`setActorX(value, id)`)
* Initialize, pause, or resume a background webm video (videoName in `assets/videos/NAME.webp`).

You can:
* Add, set, or drain HP at certain points in a song.
* Display and move an obstruction.
* Hide or move the strumline.
* Add a Spacebar Spam mechanic.

You can't:
* Add custom note types (this requires adding the notes to the hit verifier).
* Add extra note keys to the strumline (this requires adding keybinds etc).

Modchart Documentation: https://github.com/KadeDev/Kade-Engine/wiki
Add new callback functions to the Modchart API: `ModchartState.hx`
See an example modchart: `assets/preload/data/tutorial/modchart.lua`
Place modcharts in: `assets/preload/data/SONGNAME/modchart.lua`




## Adding/Removing Weeks

See `WeekData.hx`.

## Freeplay Song List

See `assets/preload/data/freeplaySonglist.txt`

`SONGNAME:ICONCHARACTER:WEEKNO`

## Song Data

* Audio files: `assets/songs/NAME/Inst.ogg` and `Voices.ogg`
  * Note: MP3 are used for HTML5 version.