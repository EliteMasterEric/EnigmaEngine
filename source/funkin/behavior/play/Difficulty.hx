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
 * Difficulty.hx
 * Contains functionality to handle default and custom difficulties.
 * Keeps track of the chart suffix and caches the graphic.
 */
package funkin.behavior.play;

import funkin.util.assets.Paths;
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

		var difficultyRawList:Array<String> = DataAssets.loadLinesFromFile(Paths.txt("data/difficulties"));
		for (element in difficultyRawList)
		{
			// Each item is of the format id:songSuffix
			var elementItems = element.split(":");
			var difficultyGraphic = GraphicsAssets.loadImage('storymenu/difficulty/${elementItems[0]}', null, true);
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
			else
			{
				Debug.logError('Could not initialize difficulty "${element}": missing graphic!');
			}
		}

		Debug.logInfo('Initialized ${difficultyList.length} difficulties: ${difficultyList}');
	}

	public static function size():Int
	{
		return Lambda.count(difficultyData);
	}

	public static function get(?difficultyId:String = ''):Null<Difficulty>
	{
		if (difficultyId == '')
			difficultyId = defaultDifficulty;
		var result = difficultyData.get(difficultyId);

		if (result == null)
		{
			if (size() == 0)
			{
				Debug.logError('No difficulties in list! Did you initialize it?');
			}
			else
			{
				Debug.logWarn('Could not find difficulty data for $difficultyId! Make sure to add a graphic and an entry to the data/difficulties file.');
			}
		}
		return result;
	}

	public static function getByIndex(index:Int):Null<Difficulty>
	{
		var diffId = difficultyList[index];
		return get(diffId);
	}

	public static function indexOfId(diff:String):Int
	{
		return difficultyList.indexOf(diff);
	}

	public static function indexOf(diff:Difficulty):Int
	{
		return indexOfId(diff.id);
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
