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
 * Cursor.hx
 * Contains static utility functions used to customize the mouse cursor.
 */
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

	public static function showCursor(shouldShow:Bool = true)
	{
		FlxG.mouse.visible = shouldShow;
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
