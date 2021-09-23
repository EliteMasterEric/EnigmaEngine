package;

import flixel.group.FlxGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.ui.FlxUIList;
import polymod.Polymod.ModMetadata;

class ModMenuState extends MusicBeatState
{
	var unloadedMods = [];
	var loadedMods = [];

	var unloadedModsList:FlxUIList;
	var loadedModsList:FlxUIList;

	// menu, left, right
	var cursorArea = 'menu';
	var selectionIndex = 0;

	override function create()
	{
		var txt:FlxText = new FlxText(0, 0, FlxG.width, "ui design is my passion", 32);

		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);

		super.create();
	}

	function updateModListUI()
	{
		while (unloadedEntriesGroup.members.length > 0)
		{
			unloadedEntriesGroup.remove(unloadedEntriesGroup.members[0], true);
		}
		while (loadedEntriesGroup.members.length > 0)
		{
			loadedEntriesGroup.remove(loadedEntriesGroup.members[0], true);
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

class ModListEntry extends FlxGroup
{
	public var modId(default, null):String;

	var modMetadata(default, null):ModMetadata;

	// Name (version)
	var uiTitle:FlxText;
	var uiAuthor:FlxText;
	var uiIcon:FlxSprite;

	public function new(modId:String, modMetadata:ModMetadata)
	{
		this.modId = modId;
		this.modMetadata = modMetadata;

		loadIcon(modMetadata.icon);

		super();
	}

	function loadIcon(bytes:haxe.io.Bytes)
	{
		// Convert a haxe byte array to the proper data structure.
		var future = openfl.utils.ByteArray.loadFromBytes(bytes);

		future.onComplete(function(openFlBytes:openfl.utils.ByteArray)
		{
			trace('Loaded icon bytes for mod ${modId}.');
			// Convert the bytes into bitmap data.
			var bitmapData = openfl.display.BitmapData.fromBytes(openFlBytes);
			// Tie the bitmap data to a sprite.
			uiIcon = new FlxSprite(0, 0).loadGraphic(bitmapData);
		});
		future.onError(function(error)
		{
			trace(error);
		});
	}
}
