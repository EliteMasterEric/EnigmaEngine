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
 * StrumlineArrow.hx
 * A sprite which is used for the strumline.
 * Graphics loading is handled by EnigmaNote, but this keeps track of its own angle
 * so it can be adjusted and rotated by modcharts. 
 */
package funkin.ui.component.play;

import funkin.ui.state.play.PlayState;
import funkin.util.NoteUtil;
import flixel.animation.FlxBaseAnimation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using hx.strings.Strings;

class StrumlineArrow extends FlxSprite
{
	/**
	 * Flag which is set to true if a Lua Modchart has modified this arrow's position.
	 */
	public var luaModifiedPos:Bool = false;

	/**
	 * The sprite angle as handled by a Lua Modchart.
	 */
	public var modAngle:Float = 0; // The angle set by modcharts

	/**
	 * The sprite angle as handled by this strumline arrow.
	 */
	public var localAngle:Float = 0; // The angle to be edited inside here

	var baseOffset:Float = 0;

	public function new(xx:Float, yy:Float)
	{
		this.x = xx;
		this.y = yy;
		super(x, y);
		// Get the note width and use it to calculate the offset.
		var noteWidth = NoteUtil.NOTE_GEOMETRY_DATA[NoteUtil.fetchStrumlineSize()][0];
		baseOffset = noteWidth / 2;

		playAnim('static');
	}

	override function update(elapsed:Float)
	{
		if (!luaModifiedPos)
			angle = localAngle + modAngle;
		else
			angle = modAngle;
		super.update(elapsed);

		// TODO: What the HELL?
		if (FlxG.keys.justPressed.THREE)
		{
			localAngle += 10;
		}
	}

	public function playAnim(AnimName:String, ?force:Bool = false):Void
	{
		animation.play(AnimName, force);

		if (!AnimName.startsWith('dirCon'))
		{
			localAngle = 0;
		}
		updateHitbox();
		offset.set(frameWidth / 2, frameHeight / 2);

		// Dehardcoded.
		offset.x -= baseOffset;
		offset.y -= baseOffset;

		angle = localAngle + modAngle;
	}
}
