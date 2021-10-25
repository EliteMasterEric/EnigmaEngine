/**
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
 * Main.hx
 * The main class of the application. The constructor sets up and loads the game.
 */
package;

import funkin.const.GameDimensions;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.util.FlxColor;
import funkin.behavior.Debug;
import funkin.behavior.media.WebmHandler;
import funkin.behavior.mods.ModCore;
import funkin.ui.component.Cursor;
import funkin.behavior.options.Options;
import funkin.ui.state.modding.ModSplashState;
import funkin.ui.state.title.CachingState;
import funkin.ui.state.title.TitleState;
import funkin.util.input.GestureUtil;
import lime.app.Application;
import openfl.Assets;
import openfl.display.BlendMode;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import openfl.text.TextFormat;
#if FEATURE_DISCORD
import funkin.behavior.api.Discord.DiscordClient;
#end

class Main extends Sprite
{
	/**
	 * Width of the game in pixels.
	 */
	var gameWidth:Int = GameDimensions.width;

	/**
	 * Height of the game in pixels.
	 */
	var gameHeight:Int = GameDimensions.height;

	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.

	/**
	 * The zoom of the game.
	 * Set to `-1` to automatically calculate to fit your window dimensions.
	 * Set to `1` to prevent scaling the graphics with the game window.
	 */
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.

	/**
	 * The framerate of the game in frames per second.
	 */
	var framerate:Int = 120;

	/**
	 * Whether to skip the HaxeFlixel logo and 'do do dlip do DAH' tune that appears in release mode.
	 */
	var skipSplash:Bool = true;

	/**
	 * Whether to start the game in fullscreen on desktop targets
	 */
	var startFullscreen:Bool = false;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	public static var webmHandler:WebmHandler;

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		// Enforce resolution on mobile builds.
		#if mobile
		zoom = 1;
		gameWidth = 1280;
		gameHeight = 720;
		framerate = 60;
		#end

		// Run this first so we can see logs.
		Debug.onInitProgram();

		#if FEATURE_FILESYSTEM
		Debug.logTrace("App has access to file system. Begin mod check and precaching...");
		if (ModCore.hasMods())
		{
			initialState = ModSplashState;
		}
		else
		{
			initialState = CachingState;
		}
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		#else
		Debug.logTrace("App has no access to file system. Starting game...");
		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		#end
		addChild(game);

		// Perform custom initialization.
		Cursor.setupCursor();
		GestureUtil.initMouseControls();

		#if FEATURE_DISCORD
		Debug.logTrace("App has Discord integration support...");
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		fpsCounter = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		toggleFPS(FPSCounterOption.get());
		#if !mobile
		#end

		// Finish up loading debug tools.
		Debug.onGameStart();
	}

	var game:FlxGame;

	var fpsCounter:FPS;

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		fpsCounter.visible = fpsEnabled;
	}

	public function changeFPSColor(color:FlxColor)
	{
		fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}
}
