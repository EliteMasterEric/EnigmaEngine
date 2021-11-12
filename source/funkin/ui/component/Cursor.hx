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
 * Cursor.hx
 * Contains static utility functions used to customize the mouse cursor.
 */
package funkin.ui.component;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

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
