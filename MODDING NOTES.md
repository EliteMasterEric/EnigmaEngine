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

## Song charting

Press 7 to display the chart.

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
  // 1 uses only the 9K Center note.
  // 4 is the default.
  // 5 adds the 9K Center note between left and right.
  // 6 uses the vs Shaggy 6K layout (Left/Up/Right Alt Left/Down/Alt Right).
  // 8 uses the vs Shaggy 9K layout excluding the Center key.
  // 9 uses the vs Shaggy 9K layout.
  // Other values are unsupported.
  "strumlineSize": 4,
}
```

## Adding/Removing Weeks

See `WeekData.hx`.

## Freeplay Song List

See `assets/preload/data/freeplaySonglist.txt`

`SONGNAME:ICONCHARACTER:WEEKNO`

## Song Data

* Audio files: `assets/songs/NAME/Inst.ogg` and `Voices.ogg`
  * Note: MP3 are used for HTML5 version.