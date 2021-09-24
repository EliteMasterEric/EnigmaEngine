package funkin.ui.audio;

import funkin.behavior.play.Conductor;
import funkin.assets.Paths;
import flixel.FlxG;

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
