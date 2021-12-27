# scripts/play/stage

This folder contains script hooks that initialize each stage, and perform stage actions.

If you have events which occur in a specific song, 

## Script Hooks

These are the functions which you can define in your script, which will be called at the appropriate point in the song.

* `onCreate()` - Called when the stage is created, before the song starts.
* `getCharacterPosition(index:Int, id:String):Array<Int>` - Called after the stage is created, and allows you to specify the position of the characters.
	- index is one of `BOYFRIEND`, `GIRLFRIEND`, or `DAD` (static constants accessible from the script), and `id` is the character ID.
* `onBeatHit(beat:Int)` - Called once every beat in the song. `beat` is the beat number.
* `onStepHit(step:Int)` - Called once every step in the song, four times per beat. `step` is the step number.
* `onUpdate(elapsed:Float)` - Called once every frame. `elapsed` is the time since the last frame.
	- This function is called multiple times a frame, KEEP IT LIGHT.
* `onPlayerHitNote(note:Note)` - Called when the player would hit a note. `note` is the full Note object.
	- Return false to cancel the note hit, causing the player to miss the note.
* `onCPUHitNote(note:Note)` - Called when the CPU would hit a note. `note` is the full Note object.
	- Return false to cancel the note hit, causing the CPU to miss the note.
* `onPlayerMissNote(note:Note)` - Called when the player would miss a note. `note` is the full Note object.
* `onCPUMissNote(note:Note)` - Called when the CPU would miss a note. `note` is the full Note object.
	- This will only generally happen if you use a script to make it miss.
* `onDestroy()` - Called when the stage is destroyed, after the song ends.

## Available Functions

Here are just some of the functions that are available to you within script hooks.

* `add(object:FlxBasic)` - Add an object to the stage. If you want to access the object later (for example, to animate it) make sure to store it as a variable (see `spooky.hscript` for an example).
* `remove(object:FlxBasic)` - Remove an object from the stage.
* `getBoyfriend()` - Returns a reference to the Boyfriend character. You can play animations on it and stuff.
* `getGirlfriend()` - Returns a reference to the Girlfriend character. You can play animations on it and stuff.
* `getDad()` - Returns a reference to the Dad character. You can play animations on it and stuff.
* `setPixelMode(value:Bool)` - Set this to true on Pixel art stages to disable anti-aliasing on stage objects.
* `GraphicsAssets.loadImage(path:String)` - Load a static stage image from the provided path.
* `GraphicsAssets.loadSparrowAtlas(path:String)` - Load an animated stage image from the provided path.

## Available Values

* `distractions` - Whether distractions are enabled in the user's preferences. Don't do any fancy animations if this is false.
* `currentBeat` - The current beat of the song.
* `currentStep` - The current step of the song.
