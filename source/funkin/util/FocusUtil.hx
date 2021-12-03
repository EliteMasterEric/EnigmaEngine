package funkin.util;

class FocusUtil
{
	public static function init()
	{
		// Ensure game doesn't break when losing focus.
		FlxG.autoPause = false;
	}

	public static function onFocus()
	{
		trace('FocusUtil: Window gained focus.');
	}

	public static function onFocusLost()
	{
		trace('FocusUtil: Window lost focus.');
	}
}
