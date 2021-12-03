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
 * BackgroundGirls.hx
 * A sprite for a crowd of background girls, used in Week 6.
 * TODO: Make stage objects generic and remove this class.
 */
package funkin.ui.component.play;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;
import funkin.util.Util;

class BackgroundGirls extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = GraphicsAssets.loadSparrowAtlas('weeb/bgFreaks', 'week6', true);

		animation.addByIndices('danceLeft', 'BG girls group', Util.buildArrayFromRange(0, 14), "", 24, false);
		animation.addByIndices('danceRight', 'BG girls group', Util.buildArrayFromRange(15, 30), "", 24, false);

		animation.play('danceLeft');
	}

	var danceDir:Bool = false;

	public function getScared():Void
	{
		animation.addByIndices('danceLeft', 'BG fangirls dissuaded', Util.buildArrayFromRange(0, 14), "", 24, false);
		animation.addByIndices('danceRight', 'BG fangirls dissuaded', Util.buildArrayFromRange(15, 30), "", 24, false);
		dance();
	}

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
