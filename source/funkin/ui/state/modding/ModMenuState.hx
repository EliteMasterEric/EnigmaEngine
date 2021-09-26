package funkin.ui.state.modding;

import funkin.behavior.mods.ModCore;
import funkin.ui.component.modding.ModList;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import funkin.ui.state.title.Caching;
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
		var txt:FlxText = new FlxText(0, 0, FlxG.width, "ui design is my passion", 32);

		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);

		unloadedModsUI = new ModList(20, 20, 300, FlxG.height - 20 - 20);
		loadedModsUI = new ModList(20, 20, 300, FlxG.height - 20 - 20);

		add(unloadedModsUI);
		add(loadedModsUI);

		initModLists();

		super.create();
	}

	@:hscript
	public var test:String = "Testing";

	function initModLists()
	{
		var modDatas = ModCore.getAllMods();

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
			// We default to ALL mods loaded.
			unloadedMods = [];
			loadedMods = modDatas;
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
		FlxG.switchState(new Caching());
		#else
		FlxG.switchState(new TitleState());
		#end
	}
}
