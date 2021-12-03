# scripts/play/stage

This folder contains script hooks that initialize each stage, and perform stage actions.

If you have events which occur in a specific song, 

## Script Hooks

These are the functions which you can define in your script, which will be called at the appropriate point in the song.

* `onCreate()` - Called when the stage is created, before the song starts.
* `onBeatHit(beat:Int)` - Called once every beat in the song. `beat` is the beat number.
* `onStepHit(step:Int)` - Called once every step in the song, four times per beat. `step` is the step number.
* `onUpdate(elapsed:Float)` - Called once every frame. `elapsed` is the time since the last frame.
	- This function is called multiple times a frame, KEEP IT LIGHT.
* `onPlayerHitNote(note:Note)` - Called when the player would hit a note. `note` is the full Note object.
	- This function is CANCELLABLE. Call `cancel()` to cancel the event.
* `onCPUHitNote(note:Note)` - Called when the CPU would hit a note. `note` is the full Note object.
	- This function is CANCELLABLE. Call `cancel()` to cancel the event, causing the CPU to miss the note.
* `onPlayerMissNote(note:Note)` - Called when the player would miss a note. `note` is the full Note object.
* `onCPUMissNote(note:Note)` - Called when the CPU would miss a note. `note` is the full Note object.
* `onUpdateNote(note:Note)` - Called when a note is updated. `note` is the full Note object.
	- This function is called many times a frame, KEEP IT LIGHT.
	- This function is CANCELLABLE. Call `cancel()` to cancel the event. Doing so will prevent the note from calling the standard update functions, for position, etc.
* `onDestroy()` - Called when the stage is destroyed, after the song ends.

## Available Functions
