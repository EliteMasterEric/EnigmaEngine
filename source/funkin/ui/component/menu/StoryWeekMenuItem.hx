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
 * StoryWeekMenuItem.hx
 * An item in the list of weeks in the story menu.
 * Handles graphics loading and flashing animations.
 */
package funkin.ui.component.menu;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import funkin.behavior.options.Options;
import funkin.behavior.play.Week;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;

class StoryWeekMenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;
	public var weekData(default, null):Week;

	public function new(x:Float, y:Float, weekData:Week)
	{
		super(x, y);
		this.weekData = weekData;
		this.week = new FlxSprite().loadGraphic(GraphicsAssets.loadImage(weekData.titleGraphic));
		this.week.antialiasing = AntiAliasingOption.get();
		add(this.week);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17 * (60 / FramerateCapOption.get()));

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = 0xFF33ffff;
		else if (FlashingLightsOption.get())
			week.color = FlxColor.WHITE;
	}
}
