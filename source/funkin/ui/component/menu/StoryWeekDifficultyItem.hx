/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * StoryWeekDifficultyItem.hx
 * The component which displays the currently selected difficulty.
 * Includes graphics loading and support for custom difficulties.
 */
package funkin.ui.component.menu;

import funkin.data.DifficultyData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.ui.component.input.InteractableSprite;
import funkin.ui.state.menu.MainMenuState;
import funkin.util.assets.DataAssets;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;
import funkin.util.Util;

class StoryWeekDifficultyItem extends InteractableSprite
{
	public var curDifficultyId(default, set):String = DifficultyDataHandler.defaultDifficulty;
	public var curDifficultyData(default, null):DifficultyData = DifficultyDataHandler.fetch(DifficultyDataHandler.defaultDifficulty);

	function set_curDifficultyId(newValue:String)
	{
		var diff = DifficultyDataHandler.fetch(newValue);
		if (diff != null)
		{
			trace('Updating difficulty graphic (${newValue}:${diff})...');
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
		var oldIndex = DifficultyDataHandler.indexOfId(curDifficultyId);
		if (oldIndex < 0)
		{
			Debug.logWarn('Difficulty not found in list, resetting...');
			oldIndex = 0;
		}

		var newIndex = oldIndex + index;
		if (newIndex < 0)
			newIndex = DifficultyDataHandler.difficultyIds.length - 1;
		if (newIndex >= DifficultyDataHandler.difficultyIds.length)
			newIndex = 0;

		this.curDifficultyId = DifficultyDataHandler.getByIndex(newIndex).id;
	}

	public function new(x:Float, y:Float)
	{
		super(x, y);

		loadDifficultyGraphic();
	}

	function loadDifficultyGraphic()
	{
		if (DifficultyDataHandler.difficultyIds.contains(curDifficultyId))
		{
			var g = DifficultyDataHandler.fetch(curDifficultyId).graphic;
			if (g != null)
			{
				this.loadGraphic(g);
				this.updateHitbox();
			}
			else
			{
				Debug.logError('Could not load difficulty graphic (${curDifficultyId})!');
			}
		}
		else
		{
			Debug.logWarn('Could not load difficulty data (${curDifficultyId}), using fallback graphic!');
			var g = DifficultyDataHandler.getFallback().graphic;
			if (g != null)
			{
				this.loadGraphic(g);
				this.updateHitbox();
			}
			else
			{
				Debug.logError('Could not load difficulty graphic <fallback>!');
			}
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
