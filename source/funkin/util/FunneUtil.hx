package funkin.util;

/**
 * Static utility function used for doing funny weird stuff.
 */
import flixel.FlxG;

class FunneUtil
{
	/**
	 * Crashes the game, like Bob does at the end of ONSLAUGHT.
	 * Only works on SYS platforms like Windows/Mac/Linux/Android/iOS
	 */
	public static function crashTheGame()
	{
		#if sys
		Sys.exit(0);
		#end
	}

	/**
	 * Opens the given URL in the user's browser.
	 * @param targetURL The URL to open.
	 */
	public static function openURL(targetURL:String)
	{
		// Different behavior for certain platforms.
		#if linux
		Sys.command('/usr/bin/xdg-open', [targetURL, "&"]);
		#else
		FlxG.openURL(targetURL);
		#end
	}
}
