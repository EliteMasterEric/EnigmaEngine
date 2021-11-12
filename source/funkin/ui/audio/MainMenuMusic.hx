/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * MainMenuMusic.hx
 * A static class used to handle playback of main menu music.
 */
package funkin.ui.audio;

import funkin.util.assets.AudioAssets;
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
			AudioAssets.resumeMusic();
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
			AudioAssets.stopMusic();
		}
	}
}
