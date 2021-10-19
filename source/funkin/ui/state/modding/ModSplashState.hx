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
 * ModSplashState.hx
 * Provides a menu used at the start of the game, to allow mods to be configured
 * before the title screen appears.
 */
package funkin.ui.state.modding;

import funkin.util.assets.Paths;
import funkin.ui.state.title.CachingState;
import funkin.ui.state.title.TitleState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import funkin.util.assets.GraphicsAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.behavior.Debug;
import funkin.behavior.mods.ModCore;

class ModSplashState extends MusicBeatState
{
	var configFound = false;
	var modsToLoad = [];

	override function create()
	{
		#if FEATURE_MODCORE
		var modsToLoad = ModCore.getConfiguredMods();
		configFound = (modsToLoad != null && modsToLoad.length > 0);
		#else
		configFound = false;
		#end

		Debug.logInfo('Loading mod splash screen. Was an existing mod config found? ${configFound}');

		super.create();

		var gameLogo:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(GraphicsAssets.loadImage('logo'));
		gameLogo.scale.y = 0.3;
		gameLogo.scale.x = 0.3;
		gameLogo.x -= gameLogo.frameHeight;
		gameLogo.y -= 180;
		gameLogo.alpha = 0.8;
		gameLogo.antialiasing = FlxG.save.data.antialiasing;
		add(gameLogo);

		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"One or more mods have been detected.\n"
			+ (configFound ? "You have configured a custom mod order." : "No mod configuration found.")
			+ "\nPress a key to choose an option:\n\n"
			+ (configFound ? "1 : Play with configured mods." : "1: Play with all mods enabled.")
			+ "\n2 : Play without mods."
			+ "\n3 : Configure my mods.",
			32);

		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);

		FlxTween.angle(gameLogo, gameLogo.angle, -10, 2, {ease: FlxEase.quartInOut});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if (gameLogo.angle == -10)
				FlxTween.angle(gameLogo, gameLogo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else
				FlxTween.angle(gameLogo, gameLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		}, 0);

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			if (gameLogo.alpha == 0.8)
				FlxTween.tween(gameLogo, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
			else
				FlxTween.tween(gameLogo, {alpha: 0.8}, 0.8, {ease: FlxEase.quartInOut});
		}, 0);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ONE)
		{
			if (configFound)
			{
				Debug.logInfo("User chose to enable configured mods.");
				// Gotta run this before any assets get loaded.
				ModCore.loadConfiguredMods();
				loadMainGame();
			}
			else
			{
				Debug.logInfo("User chose to enable ALL available mods.");
				// Gotta run this before any assets get loaded.
				ModCore.loadAllMods();
				loadMainGame();
			}
		}
		else if (FlxG.keys.justPressed.TWO)
		{
			Debug.logInfo("User chose to DISABLE mods.");
			// Don't call ModCore.
			loadMainGame();
		}
		else if (FlxG.keys.justPressed.THREE)
		{
			Debug.logInfo("Moving to mod menu.");
			loadModMenu();
		}

		super.update(elapsed);
	}

	function loadMainGame()
	{
		#if FEATURE_FILESYSTEM
		FlxG.switchState(new CachingState());
		#else
		FlxG.switchState(new TitleState());
		#end
	}

	function loadModMenu()
	{
		FlxG.switchState(new ModMenuState());
	}
}
