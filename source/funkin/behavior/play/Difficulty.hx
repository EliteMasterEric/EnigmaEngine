package funkin.behavior.play;

import flixel.graphics.FlxGraphic;
import funkin.util.assets.DataAssets;
import funkin.util.assets.GraphicsAssets;

typedef Difficulty =
{
	var id:String;
	var songSuffix:String;
	var graphic:FlxGraphic;
}

class DifficultyCache
{
	public static final defaultDifficulty = "normal";

	public static var difficultyList(default, null):Array<String> = [];
	public static var difficultyData(default, null) = new Map<String, Difficulty>();

	public static function initDifficulties()
	{
		if (Lambda.count(difficultyData) > 0)
			return;

		var difficultyRawList:Array<String> = DataAssets.loadLinesFromFile("data/difficulties.txt");
		for (element in difficultyRawList)
		{
			// Each item is of the format id:songSuffix
			var elementItems = element.split(":");
			var difficultyGraphic = GraphicsAssets.loadImage('storymenu/difficulty/${elementItems[0]}');
			if (difficultyGraphic != null)
			{
				var difficulty:Difficulty = {
					id: elementItems[0],
					songSuffix: elementItems[1],
					graphic: difficultyGraphic
				}

				difficultyList.push(difficulty.id);
				difficultyData.set(difficulty.id, difficulty);
			}
		}
	}

	public static function size():Int
	{
		return Lambda.count(difficultyData);
	}

	public static function get(?difficultyId:String = ''):Null<Difficulty>
	{
		if (difficultyId == '')
			return difficultyData.get(defaultDifficulty);
		return difficultyData.get(difficultyId);
	}

	public static function getByIndex(index:Int):Null<Difficulty>
	{
		var diffId = difficultyList[index];
		return get(diffId);
	}

	/**
	 * Get a list of all available song suffixes, for all available difficulties.
	 * @return A list of song suffix strings.
	 */
	public static function listSuffixes():Array<String>
	{
		return values().map(function(d:Difficulty)
		{
			return d.songSuffix;
		});
	}

	public static function values():Array<Difficulty>
	{
		return Lambda.array(difficultyData);
	}

	public static function getFallback():Null<Difficulty>
	{
		return get(difficultyList[0]);
	}

	public static function getSuffix(difficultyId:String):String
	{
		return get(difficultyId).songSuffix;
	}
}
