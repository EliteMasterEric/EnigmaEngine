# Modding Notes

## Resources
1.7 Changelog: https://kadedev.github.io/Kade-Engine/changelogs/changelog-1.7
1.7 Diffs: https://github.com/KadeDev/Kade-Engine/pull/1901/files

Source Code Guide: https://gamebanana.com/tuts/13798

## Which asset folder to use?

* exclude: These files aren't in the build at all.
* sm: Easily add StepMania songs to the freeplay menu by putting them in this folder. Not used for mods.

* fonts: Use for any fonts to display in-game.
* songs: Use for song instrumentals and voice files.
* preload: 
* shared: 
* week#: 

## Debug keys:

- `0`: BF Animation Debugger
- `1`: End Song (During bot play, hides UI)
- `2`: Ten Seconds Time Travel
- `6`: Dad Animation Debugger
- `7`: Song Charter
- `8`: Stage Positioner
- `9`: Old BF Icon
- `R`: Restart Song

## Song Charter
-


## Animation Debugger

- `Q`: Zoom Camera Out
- `E`: Zoom Camera In
- `IJKL`: Pan the Camera
- `F`: Flip Character
- `W`: Previous Animation
- `S`: Previous Animation
- `Space`: Replay Current Animation
- `Arrow Keys`: Offset Animation by 1
- `Shift + Arrow Keys`: Offset Animation by 10
PR:
- `Escape` or `Enter`: Return to Main Menu
- `V`: Copy Offsets

## Stage Positioning Debugger

- `Q`: Zoom Camera Out
- `E`: Zoom Camera In
- `IJKL`: Pan the Camera
- `Space`: Cycle Characters
- `Mouse`: Drag Active Character
- `Escape`: Return to Main Menu

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

## Song data

Toggling "camera points to P1" enables Section.mustHitSection.

If mustHitSection is on, notes 0-3 are BF notes and 4-7 are Dad notes.
If mustHitSection is off, notes 0-3 are Dad notes and 4-7 are BF notes.

sectionNotes is:
[STARTTIME, NOTEDATA, HOLDDURATION]

Song attributes are:
```
{
  "notes": <NOTES>,
  // Starting BF character.
  "player1": "bf-pixel",
  // Starting Dad character.
  "player2": "senpai",
  // Starting GF character.
  "gfVersion": "gf-pixel",
  // Song Name
  "song": "Senpai",
  // Starting stage.
  "stage": "school",
  // Whether to load Voices.ogg
  "needsVoices": true,
  // The song's BPM.
  "bpm": 144,
  // The song's note scroll speed.
  "speed": 1.2

  // Events are currently used to control BPM changes.
  "eventObjects": <EVENTS>

  // Whether it's valid to save this song's high score.
  // Defaults to true.
  "validScore": true,
  // Note style to use (normal or pixel)
  // Defaults to normal.
  "noteStyle": "pixel",

  // CUSTOM VALUES
  // Controls the number of notes in each player's strumline.
  // Allows 1, 2, 3, 4, 5, 6, 7, 8, or 9.
  "strumlineSize": 4,
}
```

## Freeplay Song List

See `assets/preload/data/freeplaySonglist.txt`

`SONGNAME:ICONCHARACTER:WEEKNO`

## Song Data

* Audio files: `assets/songs/NAME/Inst.ogg` and `Voices.ogg`
  * Note: MP3 are used for HTML5 version.

## Formatting

To repeat:
* Edit hxformat.json
* Edit Project.xml and remove example_mods
* Perform "Start Format Files: By Glob" on "**/*.hx" and "**/*.json" and "**/*.xml"

How to merge without shitting your pants:
`git merge -Xignore-space-change -Xignore-all-space <BRANCH>`

## daWeirdVid.webm
```
/** 
 * ERIC: The background video player must be initialized 
 * with an empty WEBM first, then later replaced 
 * with the video we want. You can set this with a modchart. 
 */ 
var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm"; 
```