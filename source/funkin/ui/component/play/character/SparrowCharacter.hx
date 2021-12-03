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
 * SparrowCharacter.hx
 * A Sparrow character uses a SparrowV2 spritesheet to render the character.
 * This is the standard rendering type used by the vanilla game.
 */
package funkin.ui.component.play.character;

import funkin.data.CharacterData;

class SparrowCharacter extends BaseCharacter
{
	public function new(/*charData:CharacterData*/)
	{
		super('Sparrow');
	}

	public override function toString():String
	{
		return 'Character[${characterId}][Sparrow]';
	}
}
