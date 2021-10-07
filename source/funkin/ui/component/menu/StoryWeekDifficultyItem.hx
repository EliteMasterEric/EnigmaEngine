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
 * StoryWeekDifficultyItem.hx
 * The component which displays the currently selected difficulty.
 * Includes graphics loading and support for custom difficulties.
 */
package funkin.ui.component.menu;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.behavior.play.Week.WeekCache;
import funkin.behavior.play.Difficulty;
import funkin.util.assets.Paths;
import funkin.behavior.Debug;
import funkin.ui.component.input.InteractableSprite;
import funkin.ui.state.menu.MainMenuState;
import funkin.util.Util;
import funkin.util.assets.DataAssets;
import funkin.util.assets.GraphicsAssets;

class StoryWeekDifficultyItem extends InteractableSprite
{
	public var curDifficultyId(default, set):String = "normal";
	public var curDifficultyData(default, null):Difficulty = {
		id: "normal",
		songSuffix: "",
		graphic: null, // Load this later.
	};

	function set_curDifficultyId(newValue:String)
	{
		var diff = DifficultyCache.get(newValue);
		if (diff != null)
		{
			trace('Updating difficulty graphic...');
			this.curDifficultyId = newValue;
			this.curDifficultyData = diff;
			loadDifficultyGraphic();
		}
		else
		{
			Debug.logError('Attempted to specify invalid difficulty "${newValue}"');
		}
		return this.curDifficultyId;
	}

	public function changeDifficulty(index:Int)
	{
		var oldIndex = DifficultyCache.difficultyList.indexOf(curDifficultyId);
		if (oldIndex < 0)
		{
			Debug.logWarn('Difficulty not found in list, resetting...');
			oldIndex = 0;
		}

		var newIndex = oldIndex + index;
		if (newIndex < 0)
			newIndex = DifficultyCache.difficultyList.length - 1;
		if (newIndex >= DifficultyCache.difficultyList.length)
			newIndex = 0;

		this.curDifficultyId = DifficultyCache.difficultyList[newIndex];
	}

	public function new(x:Float, y:Float)
	{
		super(x, y);

		DifficultyCache.initDifficulties();

		loadDifficultyGraphic();
	}

	function loadDifficultyGraphic()
	{
		if (DifficultyCache.difficultyList.contains(curDifficultyId))
		{
			this.loadGraphic(DifficultyCache.get(curDifficultyId).graphic);
		}
		else
		{
			this.loadGraphic(DifficultyCache.getFallback().graphic);
		}
	}

	override function onJustPressed(pos:FlxPoint)
	{
		trace('Pressed menu difficulty item ${curDifficultyId}');
	}

	override function onJustReleased(pos:FlxPoint, pressDuration:Int)
	{
		trace('Released menu difficulty item ${curDifficultyId}');
	}
}
