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
 * MainMenuMusic.hx
 * A static class used to handle playback of main menu music.
 */
package funkin.ui.audio;

import flixel.FlxG;
import funkin.behavior.play.Conductor;
import funkin.util.assets.Paths;

class MainMenuMusic
{
	/**
	 * Plays the main menu music.
	 * If it was previously paused, it will continue where it left off.
	 */
	public static function playMenuMusic()
	{
		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(102);
		}
		else
		{
			FlxG.sound.music.play();
		}
	}

	/**
	 * Stops the main menu music.
	 * Attempting to play it again will start where it left off.
	 */
	public static function pauseMenuMusic()
	{
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			FlxG.sound.music.pause();
		}
	}

	/**
	 * Stops the main menu music.
	 * Attempting to play it again will restart it.
	 */
	public static function stopMenuMusic()
	{
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
		{
			FlxG.sound.music.stop();
		}
	}
}
