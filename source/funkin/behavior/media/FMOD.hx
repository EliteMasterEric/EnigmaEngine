package funkin.behavior.media;

import lime.utils.Assets;
import funkin.assets.Paths;
#if cpp
import faxe.Faxe;
#end

/**
 * FMOD is an API and library made by cool people who undestand FAR better than I do how computers store and play sound.
 * This class provides an interface for it.
 * 
 * FMOD doesn't just let you play sound files; it also lets you play sound directly from memory
 * (useful for cutscenes, which store the sound inside the video container)
 * or utilize FMOD Studio sound banks, which allow you to build dynamic sound based on parameters.
 * 
 * FMOD plays really nicely on a variety of platforms, so you can probably make it work,
 * even if some other platform has problems with sound playback.
 * 
 * NOTE: Completely ignores HaxeFlixel's sound system, so mute/volume keys are ignored.
 * 
 * TODO: Add microphone support.
 * TODO: Add DSP effect support.
 *   This would allow for stuff like VST and WinAmp plugins to be used, along with various other built-in or custom effects.
 *   https://fmod.com/resources/documentation-api?version=2.00&page=core-api-common-dsp-effects.html#fmod_dsp_type
 * 
 * @author MasterEric
 */
class FMODCore
{
	static var initialized = false;

	/**
	 * Initialize FMOD if it hasn't been already.
	 */
	static function init()
	{
		#if cpp
		if (!initialized)
		{
			Faxe.fmod_init(36);
			initialized = true;
		}
		#end
	}

	/**
	 * Retrieve a Music asset from Lime and play it.
	 * Should probably work with Polymod? IDK.
	 * @param path 
	 */
	public static function playSound(soundPath:String)
	{
		#if cpp
		init();

		var fmodChannel = FMODSound.playSound(soundPath);
		var volume = fmodChannel.getVolume();
		#else
		Debug.logError("ERROR: Faxe not working on this platform yet.");
		#end
	}

	/**
	 * Retrieve a Music asset from Lime and play it.
	 * Should probably work with Polymod? IDK.
	 * @param path 
	 */
	public static function playSoundData(soundPath:String)
	{
		#if cpp
		init();

		var limeSound = lime.utils.Assets.getAudioBuffer(soundPath);

		var fmodChannel = FMODSound.playSound(soundPath);
		var volume = fmodChannel.getVolume();
		#else
		Debug.logError("ERROR: Faxe not working on this platform yet.");
		#end
	}

	public static function playGarbage()
	{
		#if cpp
		init();

		var result = Faxe.fmod_load_sound_from_callback("foobar", 44100);
		printFMODResult(result);

		var s:cpp.Pointer<FmodCreateSoundExInfo> = cast null;
		var createSoundEx:FmodCreateSoundExInfo = cast s.ref;

		// createSoundEx.
		var fmodChannel = FMODSound.playSound("foobar");

		var volume = fmodChannel.getVolume();
		trace('volume: ${volume}');
		#end
	}

	public static function tick()
	{
		#if cpp
		// This might be important.
		Faxe.fmod_update();
		#end
	}

	#if cpp
	public static function printFMODResult(result:FmodResult)
	{
		switch (result)
		{
			case FMOD_OK:
				Debug.logTrace('[FMOD] Success.');
			case FMOD_ERR_INVALID_HANDLE:
				Debug.logError('[FMOD] Invalid handle. Is FMOD initialized?');
			default:
				Debug.logWarn('[FMOD] Unhandled error value: ${result}');
		}
	}
	#end
}

#if cpp
class FMODSound
{
	/**
	 * Load a given sound into memory to prepare it for playback.
	 * @param soundPath The sound path. Can be one provided `Paths.sound` or `Paths.music`
	 * @param stream Decode the file in real time. Small CPU hit in exchange for far less RAM usage.
	 * @returns Whether loading was successful.
	 */
	public static function loadSound(soundPath:String, stream:Bool = true):Bool
	{
		Debug.logTrace('[FMOD] Loading sound ${soundPath}...');
		var result:FmodResult = Faxe.fmod_load_sound(soundPath, false, stream);
		FMODCore.printFMODResult(result);
		return result == FMOD_OK;
	}

	/**
	 * Plays a given sound. Make sure to call loadSound() first.
	 * @param soundPath The sound path. Can be one provided `Paths.sound` or `Paths.music`
	 * @return The audio channel.
	 */
	public static function playSound(soundPath:String):FMODChannel
	{
		return new FMODChannel(FaxeRef.playSound(soundPath, false));
	}
}

/**
 * Some explanation:
 * An Event is an instanceable unit of sound. It can be triggered, controlled, or stopped from game code,
 *   and parameters like pitch can be modified using parameters.
 * A Bank is an exported collection of events, their metadata, and their raw samples, together in one file.
 *   Load it into memory to add support for the given events.
 * 
 * This is REALLY powerful in the right hands. You can split your music up into different layers that react to parameters driven by the player.
 * Examples include:
 * You could make Boyfriend ACTUALLY sing a note off-key when he misses.
 * You could distort the audio based on Boyfriend's health.
 * You could add a backing track at certain times, like when Boyfriend hits a hazard note.
 * You could have the song play effects at random times, like reverb from a train entering a tunnel.
 * You could add layered or randomized sounds to a track.
 * You could add 3D sounds and reverb (which would be really useful if FNF wasn't a 2D game).
 * 
 * Only downside is that the music isn't easily accessible in the game files, but who cares,
 * you can just combine the stems and release the soundtrack online.
 * 
 * @see https://www.youtube.com/channel/UCekk9jO-MTyWEbD2l0m6PTA
 */
class FMODBank
{
	/**
	 * Load a sound bank's metadata into memory. You should be able to use a `Lime` asset path.
	 * @param path 
	 */
	public static function loadBank(path:String)
	{
		Faxe.fmod_load_bank(path);
	}

	/**
	 * Load a playable instance of a named event and store it in memory, under the given key.
	 		* Will automatically skip loading if an event of that key is already loaded.
	 		* @param path The path of the event within the bank.
	 		* @param name A readable string to refer to this sound event.
	 */
	public static function loadEvent(path:String, name:String)
	{
		if (name == null)
			name = path;
		Faxe.fmod_load_event(path, name);
	}

	/**
	 * Begin playback of a loaded sound event, by name.
	 */
	public static function playEvent(name:String)
	{
		Faxe.fmod_play_event("event:/FreakyMenu");
	}

	/**
	 * Check the state of a given event.
	 */
	public static function getEventState(name:String):FmodStudioPlaybackState
	{
		return Faxe.fmod_get_event_state(name);
	}

	/**
	 * Check whether the event is playing.
	 */
	public static function isEventPlaying(name:String):Bool
	{
		return getEventState(name) == FMOD_STUDIO_PLAYBACK_PLAYING;
	}

	/**
	 * Check whether the event is stopped.
	 */
	public static function isEventStopped(name:String):Bool
	{
		return getEventState(name) == FMOD_STUDIO_PLAYBACK_STOPPED;
	}

	/**
	 * Check whether the event is paused.
	 * @returns Whether the event is paused.
	 */
	public static function isEventPaused(name:String):Bool
	{
		return Faxe.fmod_event_paused(name);
	}

	/**
	 * Attempt to set the pause status of the given event.
	 * @returns Whether pausing succeeded.
	 */
	public static function pauseEvent(name:String, shouldPause:Bool)
	{
		Faxe.fmod_pause_event(name, shouldPause);
	}

	/**
	 * Convenience function to toggle the pause status of the event.
	 * @returns Whether pausing succeeded.
	 */
	public static function togglePauseEvent(name:String)
	{
		pauseEvent(name, !isEventPaused(name));
	}

	/**
	 * Retrieve the value of a parameter of a given name for a given event.
	 * @param eventName The name of the event.
	 * @param paramName The name of the parameter.
	 * @return The floating point value.
	 */
	public static function getEventParameter(eventName:String, paramName:String):Float
	{
		return Faxe.fmod_get_param(eventName, paramName);
	}

	/**
	 * Set the value of a parameter of a given name for a given event.
	 * @param eventName The name of the event.
	 * @param paramName The name of the parameter.
	 * @param paramValue The value of the parameter.
	 * @return Whether setting was successful.
	 */
	public static function setEventParameter(eventName:String, paramName:String, paramValue:Float):Bool
	{
		return Faxe.fmod_set_param(eventName, paramName, paramValue);
	}
}

class FMODChannel
{
	var channelRef:FmodChannelRef;

	public function new(channelRef:FmodChannelRef)
	{
		this.channelRef = channelRef;
	}

	public function getVolume():Float
	{
		var f:cpp.Float32 = 0.0;
		var fp:cpp.Pointer<cpp.Float32> = cpp.Pointer.addressOf(f);
		var result = channelRef.getVolume(fp);
		FMODCore.printFMODResult(result);
		return f;
	}

	/**
	 * Set the volume of this sound channel.
	 * @param newVolume The new volume to use, 0-1. 
	 * @return Success.
	 */
	public function setVolume(newVolume:Float):Bool
	{
		var f:cpp.Float32 = newVolume;
		var result = channelRef.setVolume(f);
		FMODCore.printFMODResult(result);
		return result == FMOD_OK;
	}
}
#end
