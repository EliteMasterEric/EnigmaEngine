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

import funkin.ui.component.base.XMLLayoutState;
import flixel.addons.ui.FlxUIButton;
import funkin.behavior.Debug;
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

class ModMenuState extends XMLLayoutState // extends MusicBeatState
{
	var loadAllButton:FlxUIButton;
	var unloadAllButton:FlxUIButton;
	var revertButton:FlxUIButton;
	var saveAndExitButton:FlxUIButton;
	var exitWithoutSavingButton:FlxUIButton;

	final UPPER_BUTTON_Y = 56 + 120;
	final LOWER_BUTTON_Y = FlxG.height - 300;

	var unloadedModsUI:ModList;
	var loadedModsUI:ModList;

	override function getXMLId()
	{
		return 'assets/ui/mod_menu';
	}

	override function create()
	{
		super.create();
		trace('Initialized ModMenuState.');
	}

	/*
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
			unloadedModsUI = new ModList(16, 56, MODLIST_HEIGHT, false);
			loadedModsUI = new ModList(MODLIST_LOADED_XPOS, 56, MODLIST_HEIGHT, true);

			unloadedModsUI.cbAddToOtherList = loadedModsUI.addMod.bind();
			loadedModsUI.cbAddToOtherList = unloadedModsUI.addMod.bind();

			var buttonCenterX = FlxG.width / 2 - 64;

			loadAllButton = new FlxUIButton(buttonCenterX, UPPER_BUTTON_Y, "Load All Mods", onClickLoadAll);
			unloadAllButton = new FlxUIButton(buttonCenterX, loadAllButton.y + 32, "Unload All Mods", onClickUnloadAll);
			revertButton = new FlxUIButton(buttonCenterX, unloadAllButton.y + 32, "Revert Mod Config", onClickRevert);
			saveAndExitButton = new FlxUIButton(buttonCenterX, LOWER_BUTTON_Y, "Save Config and Exit", onClickSaveAndExit);
			exitWithoutSavingButton = new FlxUIButton(buttonCenterX, saveAndExitButton.y + 32, "Exit without Saving", onClickExitWithoutSaving);

			loadAllButton.setLabelFormat("VCR OSD Mono", 16, FlxColor.BLACK, CENTER);
			unloadAllButton.setLabelFormat("VCR OSD Mono", 16, FlxColor.BLACK, CENTER);
			revertButton.setLabelFormat("VCR OSD Mono", 16, FlxColor.BLACK, CENTER);
			saveAndExitButton.setLabelFormat("VCR OSD Mono", 16, FlxColor.BLACK, CENTER);
			exitWithoutSavingButton.setLabelFormat("VCR OSD Mono", 16, FlxColor.BLACK, CENTER);

			loadAllButton.resize(160, 40);
			unloadAllButton.resize(160, 40);
			revertButton.resize(160, 40);
			saveAndExitButton.resize(160, 40);
			exitWithoutSavingButton.resize(160, 40);

			add(unloadedModsUI);
			add(loadedModsUI);

			add(loadAllButton);
			add(unloadAllButton);
			add(revertButton);
			add(saveAndExitButton);
			add(exitWithoutSavingButton);

			initModLists();

			super.create();
		}
	 */
	function initModLists()
	{
		var modDatas = ModCore.getAllMods().filter(function(m)
		{
			return m != null;
		});

		var loadedModIds = ModCore.getConfiguredMods();

		var loadedMods:Array<ModMetadata> = [];
		var unloadedMods:Array<ModMetadata> = [];

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

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			loadMainGame();
		}

		super.update(elapsed);
	}

	function writeModPreferences()
	{
		var loadedModIds:Array<String> = loadedModsUI.listCurrentMods().map(function(mod:ModMetadata) return mod.id);

		var modConfigStr = loadedModIds.join('~');

		FlxG.save.data.modConfig = modConfigStr;
	}

	function loadMainGame()
	{
		#if FEATURE_FILESYSTEM
		FlxG.switchState(new CachingState());
		#else
		FlxG.switchState(new TitleState());
		#end
	}

	function onClickLoadAll()
	{
		var unloadedMods:Array<ModMetadata> = unloadedModsUI.listCurrentMods();

		// Add all unloaded mods to the loaded list.
		for (i in unloadedMods)
		{
			loadedModsUI.addMod(i);
		}

		// Remove all mods from the unloaded list.
		unloadedModsUI.clearModList();
	}

	function onClickUnloadAll()
	{
		var loadedMods:Array<ModMetadata> = loadedModsUI.listCurrentMods();

		// Add all loaded mods to the unloaded list.
		for (i in loadedMods)
		{
			unloadedModsUI.addMod(i);
		}

		// Remove all mods from the loaded list.
		loadedModsUI.clearModList();
	}

	function onClickRevert()
	{
		// Clear both mod lists so we're starting from scratch.
		unloadedModsUI.clearModList();
		loadedModsUI.clearModList();

		// Add the content to the mod lists again.
		initModLists();
	}

	function onClickSaveAndExit()
	{
		// Save mod preferences.
		writeModPreferences();

		// Just move to the main game.
		loadMainGame();
	}

	function onClickExitWithoutSaving()
	{
		// Just move to the main game.
		loadMainGame();
	}
}
