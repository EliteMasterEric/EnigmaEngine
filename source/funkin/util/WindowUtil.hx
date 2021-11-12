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
 * WindowUtil.hx
 * Contains static utility functions used for doing funny weird stuff.
 * This includes the command to open an external URL, as well as purposefully crash the game,
 * or manipulate the window.
 */
package funkin.util;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.util.FlxAxes;
import funkin.const.GameDimensions;
import lime.app.Application as LimeApplication;
import lime.math.Rectangle;
import lime.system.System as LimeSystem;

class WindowUtil
{
	/**
	 * Set the title of the current window.
	 * Has a allergic reaction when exposed to Unicode.
	 * @param value 
	 */
	public static function setWindowTitle(value:String):Void
	{
		LimeApplication.current.window.title = value;
	}

	/**
	 * Sets whether the window should encompass the full screen.
	 * Works on desktop and HTML5.
	 * @param value Whe
	 */
	public static function setFullscreen(value:Bool):Void
	{
		LimeApplication.current.window.fullscreen = value;
	}

	/**
	 * Sets whether the window should encompass the full screen.
	 * Works on desktop and HTML5.
	 */
	public static function toggleFullscreen():Void
	{
		setFullscreen(!LimeApplication.current.window.fullscreen);
	}

	/**
	 * Enables or disabled Borderless Windowed mode.
	 */
	public static function setBorderlessWindowed(value:Bool)
	{
		if (value)
		{
			// Disable fullscreen mode, disable window borders, and make the window span the display.
			setFullscreen(false);
			LimeApplication.current.window.borderless = true;
			var screenSize:Rectangle = LimeSystem.getDisplay(0).bounds;
			repositionWindow(Std.int(screenSize.left), Std.int(screenSize.top));
			resizeWindow(Std.int(screenSize.width), Std.int(screenSize.height));
		}
		else
		{
			LimeApplication.current.window.borderless = false;
			resizeWindow();
			// Center the window.
		}
	}

	/**
	 * Put the game into windowed mode.
	 * Disable fullscreen mode and borderless windowed mode.
	 */
	public static function forceWindowedMode()
	{
		setFullscreen(false);
		setBorderlessWindowed(false);
	}

	/**
	 * Modifies the size of the current window.
	 * @param width The desired width. Defaults to 1280.
	 * @param height The desired height. Defaults to 720.
	 */
	public static function resizeWindow(width:Int = 1280, height:Int = 720)
	{
		LimeApplication.current.window.width = width;
		LimeApplication.current.window.height = height;
	}

	/**
	 * Modifies the position of the current window.
	 * @param x The desired X position.
	 * @param y The desired Y position.
	 */
	public static function repositionWindow(x:Int, y:Int)
	{
		LimeApplication.current.window.x = x;
		LimeApplication.current.window.y = y;
	}

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

/**
 * Steps to shake the window:
 * - When you want to start shaking, initialize a WindowShakeEvent object.
 * - Then, add a call to `windowShakeEvent.update()` in your state's update loop.
 * The window will shake for the specified duration with the specified intensity.
 * - To shake the window again with different settings, create a new event.
 * - To shake the window again with the same duration and intensity, simply call `windowShakeEvent.reset()`.
 */
class WindowShakeEvent
{
	public var intensity(default, null):Float;
	public var duration(default, null):Float;
	public var axes(default, null):FlxAxes;

	var timeRemaining:Float = 0;

	var basePosition:FlxPoint;
	var offset:FlxPoint;

	/*
	 * @param intensity The distance to shake the window, in pixels.
	 * @param duration The time to shake the window, in seconds.
	 * @param axes The directions to shake the window in. Defaults to XY (both).
	 */
	public function new(intensity:Float, duration:Float, axes:FlxAxes = FlxAxes.XY)
	{
		this.intensity = intensity;
		this.duration = duration;
		this.axes = axes;

		reset();
	}

	/**
	 * Restart the timer and enable shaking again.
	 */
	public function reset()
	{
		this.timeRemaining = this.duration;
	}

	/**
	 * Reset the window position back to normal.
	 */
	function cleanup()
	{
		this.basePosition = new FlxPoint(LimeApplication.current.window.x, LimeApplication.current.window.y);
		this.offset = FlxPoint.get();
	}

	public function update(elapsed:Float)
	{
		if (timeRemaining <= 0)
			return;

		// Keep track of elapsed time.
		timeRemaining -= elapsed;

		if (timeRemaining > 0)
		{
			// Choose a new random position.
			switch (this.axes)
			{
				case XY:
					offset.x = FlxG.random.float(-intensity, intensity);
					offset.y = FlxG.random.float(-intensity, intensity);
				case X:
					offset.x = FlxG.random.float(-intensity, intensity);
				case Y:
					offset.y = FlxG.random.float(-intensity, intensity);
			}
		}
		else
		{
			cleanup();
		}

		// Apply the new window position.
		var newPos = FlxPoint.get().addPoint(basePosition).addPoint(offset);
		WindowUtil.repositionWindow(Std.int(newPos.x), Std.int(newPos.y));
	}
}
