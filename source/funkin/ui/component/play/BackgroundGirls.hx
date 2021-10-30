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

		animation.addByIndices('danceLeft', 'BG girls group', Util.buildArrayFromRange(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG girls group', Util.buildArrayFromRange(30, 15), "", 24, false);

		animation.play('danceLeft');
	}

	var danceDir:Bool = false;

	public function getScared():Void
	{
		animation.addByIndices('danceLeft', 'BG fangirls dissuaded', Util.buildArrayFromRange(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG fangirls dissuaded', Util.buildArrayFromRange(30, 15), "", 24, false);
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
