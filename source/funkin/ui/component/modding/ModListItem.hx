package funkin.ui.component.modding;

import flixel.addons.ui.FlxUISprite;
import flixel.FlxSprite;
import flixel.text.FlxText;
import polymod.Polymod.ModMetadata;
import flixel.addons.ui.FlxUIGroup;

class ModListItem extends FlxUIGroup
{
	public var modId(default, null):String;

	var modMetadata(default, null):ModMetadata;

	// Name (version)
	var uiTitle:FlxText;
	var uiAuthor:FlxText;
	var uiIcon:FlxSprite;

	public function new(modMetadata:ModMetadata)
	{
		this.modId = modMetadata.id;
		this.modMetadata = modMetadata;

		this.name = this.modId;

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
			uiIcon = new FlxUISprite(0, 0).loadGraphic(bitmapData);
			// uiIcon.resize(100, 100);

			add(uiIcon);
		});
		future.onError(function(error)
		{
			trace(error);
		});
	}
}
