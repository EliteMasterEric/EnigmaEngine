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
