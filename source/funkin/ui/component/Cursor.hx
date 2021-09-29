package funkin.ui.component;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

// Add fancy utility functions to sprites.
using flixel.util.FlxSpriteUtil;

class Cursor
{
	public static function setupCursor()
	{
		// Pick your poison.

		setupCursorSystem();
		// setupCursorCircle();
	}

	/**
	 * Enable the default operating system cursor.
	 */
	static function setupCursorSystem()
	{
		FlxG.mouse.useSystemCursor = true;
	}

	/**
	 * Use the default mouse cursor provided by Flixel.
	 */
	static function setupCursorDefault()
	{
		FlxG.mouse.unload();
	}

	/**
	 * Create a white circle to use as a cursor graphic
	 */
	static function setupCursorCircle()
	{
		var sprite = new FlxSprite();
		sprite.makeGraphic(15, 15, FlxColor.TRANSPARENT);
		sprite.drawCircle();
		FlxG.mouse.load(sprite.pixels);
	}
}
