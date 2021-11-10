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
 * Boyfriend.hx
 * An extension of `Character.hx` which includes additional logic for Boyfriend specifically. 
 */
package funkin.ui.component.play;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using hx.strings.Strings;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (getCurAnimation().startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (getCurAnimation().endsWith('miss') && isCurAnimationFinished() && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}

			if (curCharacter.endsWith('-car') && !getCurAnimation().startsWith('sing') && isCurAnimationFinished())
				playAnim('idleHair');

			if (getCurAnimation() == 'firstDeath' && isCurAnimationFinished())
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}
}
