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
 * ModMenuState.hx
 * Provides a menu for configuring installed mods.
 */
package funkin.ui.state.modding;

import funkin.behavior.mods.ModCore;
import funkin.ui.component.modding.ModList;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import funkin.ui.state.title.CachingState;
import funkin.ui.state.title.TitleState;
import flixel.addons.ui.FlxUIList;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import polymod.Polymod.ModMetadata;

class ModMenuState extends MusicBeatState
{
	var unloadedMods:Array<ModMetadata> = [];
	var loadedMods:Array<ModMetadata> = [];

	var unloadedModsUI:ModList;
	var loadedModsUI:ModList;

	override function create()
	{
		var txt:FlxText = new FlxText(0, 16, FlxG.width, "Mod Configuration", 32);

		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter(X);
		add(txt);

		var MODLIST_HEIGHT = FlxG.height - 20 - 20;
		// Measure from the right side.
		var MODLIST_LOADED_XPOS = FlxG.width - 500 - 16;
		unloadedModsUI = new ModList(16, 48, MODLIST_HEIGHT);
		loadedModsUI = new ModList(MODLIST_LOADED_XPOS, 48, MODLIST_HEIGHT);

		add(unloadedModsUI);
		add(loadedModsUI);

		initModLists();

		super.create();
	}

	@:hscript
	public var test:String = "Testing";

	function initModLists()
	{
		var modDatas = ModCore.getAllMods().filter(function(m)
		{
			return m != null;
		});

		var loadedModIds = ModCore.getConfiguredMods();

		if (loadedModIds != null)
		{
			// If loadedModIds != null, return.
			loadedMods = modDatas.filter(function(m)
			{
				return loadedModIds.contains(m.id);
			});
			unloadedMods = modDatas.filter(function(m)
			{
				return !loadedModIds.contains(m.id);
			});
		}
		else
		{
			// No existing configuration.
			// We default to ALL mods loaded.
			unloadedMods = [];
			loadedMods = modDatas;
			// TODO: DEBUG
			var testMod = loadedMods.pop();
			unloadedMods.push(testMod);
			unloadedMods.push(testMod);
			unloadedMods.push(testMod);
			unloadedMods.push(testMod);
			unloadedMods.push(testMod);
			unloadedMods.push(testMod);
			unloadedMods.push(testMod);
			unloadedMods.push(testMod);
			unloadedMods.push(testMod);
			unloadedMods.push(testMod);
		}

		for (i in loadedMods)
		{
			loadedModsUI.addMod(i);
		}
		for (i in unloadedMods)
		{
			unloadedModsUI.addMod(i);
		}
	}

	function loadMainGame()
	{
		#if FEATURE_FILESYSTEM
		FlxG.switchState(new CachingState());
		#else
		FlxG.switchState(new TitleState());
		#end
	}
}
