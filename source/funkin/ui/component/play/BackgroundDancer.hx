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
 * BackgroundDancer.hx
 * A sprite for a background dancer, used in Week 4.
 * TODO: Make stage objects generic and remove this class.
 */
package funkin.ui.component.play;

import funkin.behavior.options.Options.AntiAliasingOption;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;
import funkin.util.Util;

class BackgroundDancer extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = GraphicsAssets.loadSparrowAtlas("limo/limoDancer", 'week4', true);
		animation.addByIndices('danceLeft', 'bg dancer sketch PINK', Util.buildArrayFromRange(0, 14), "", 24, false);
		animation.addByIndices('danceRight', 'bg dancer sketch PINK', Util.buildArrayFromRange(15, 29), "", 24, false);
		animation.play('danceLeft');
		antialiasing = AntiAliasingOption.get();
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
