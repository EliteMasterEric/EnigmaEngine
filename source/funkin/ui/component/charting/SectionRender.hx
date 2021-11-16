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
 * SectionRender.hx
 * A component used to render an individual section in the charter.
 */
package funkin.ui.component.charting;

import funkin.behavior.options.Options.EditorGridOption;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.behavior.play.Section.SwagSection;
import funkin.ui.state.charting.ChartingState;

class SectionRender extends FlxSprite
{
	public var section:SwagSection;
	public var icon:FlxSprite;
	public var lastUpdated:Bool;

	public function new(x:Float, y:Float, GRID_SIZE:Int, ?Height:Int = 16)
	{
		super(x, y);

		makeGraphic(GRID_SIZE * ChartingState.GRID_WIDTH_IN_CELLS, GRID_SIZE * Height, 0xffe7e6e6);

		var h = GRID_SIZE;
		if (Math.floor(h) != h)
			h = GRID_SIZE;

		if (EditorGridOption.get())
		{
			FlxGridOverlay.overlay(this, GRID_SIZE, Std.int(h), GRID_SIZE * ChartingState.GRID_WIDTH_IN_CELLS, GRID_SIZE * Height);
		}
	}

	override function update(elapsed)
	{
	}
}
