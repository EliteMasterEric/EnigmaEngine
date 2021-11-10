/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * AudioAssets.hx
 * Contains static utility functions used for working with audio assets.
 */
package funkin.util.assets;

import funkin.behavior.Debug;
import openfl.Assets as OpenFlAssets;

class AudioAssets
{
	public static function cacheSound(soundPath:String)
	{
		FlxG.sound.cache(soundPath);
	}

	/**
	 * Plays the provided audio track.
	 */
	public static function playSound()
	{
	}

	/**
	 * Attempts to load and play the provided audio track. Overrides the current background music track.
	 * Only one music track can be loaded at a time.
	 */
	public static function playMusic(songPath:String, shouldCache:Bool = true, volume:Float = 1, looped:Bool = false)
	{
		if (shouldCache)
			cacheSound(songPath);

		if (LibraryAssets.soundExists(songPath))
		{
			FlxG.sound.playMusic(songPath, volume, looped);
		}
		else
		{
			Debug.logError('Could not play music ($songPath) because the file does not exist.');
		}
	}

	/**
	 * Returns whether music has played with `AudioAssets.playMusic()`
	 * @return Bool
	 */
	public static function isMusicLoaded():Bool
	{
		return FlxG.sound.music != null;
	}

	/**
	 * Pause the currently playing background music if it has started playing.
	 * Starting it again can be done by simply calling `AudioAssets.resumeMusic()`.
	 */
	public static function pauseMusic()
	{
		FlxG.sound.music.pause();
	}

	/**
	 * Resume the currently playing background music if it has been paused.
	 */
	public static function resumeMusic()
	{
		FlxG.sound.music.play();
	}

	/**
	 * Stop the currently playing background music if it has started playing.
	 * Starting it again requires calling `AudioAssets.playMusic()` again.
	 */
	public static function stopMusic()
	{
		FlxG.sound.music.stop();
	}
}
