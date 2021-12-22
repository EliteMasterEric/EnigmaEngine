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
 * CharacterFactory.hx
 * This function contains utility functions to build a character for you.
 * It fetches the metadata for the character ID and determines the proper type to use.
 * This can be the standard TextureAtlas sprite, or a more advanced type.
 */
package funkin.ui.component.play.character;

import funkin.data.CharacterData;
import funkin.data.CharacterData.CharacterDataHandler;
import funkin.util.assets.DataAssets;

class CharacterFactory
{
	public static function buildCharacter(charId:String):BaseCharacter
	{
		var data:CharacterData = CharacterDataHandler.fetch(charId);
		if (data == null)
		{
			Debug.logError('CharacterFactory: No data found for character ID: $charId');
			return null;
		}

		switch (data.atlasType)
		{
			// case 'model3d':
			// case 'adobeatlas':
			// case 'spine':
			// case 'dragonbones':
			case 'multisparrow':
				Debug.logInfo('CharacterFactory: Creating MultiSparrow character');
				return new MultiSparrowCharacter(data);
			case 'packer':
				Debug.logInfo('CharacterFactory: Creating Packer character');
				return new PackerCharacter(data);
			case 'sparrow':
				Debug.logInfo('CharacterFactory: Creating Sparrow character');
				return new SparrowCharacter(data);
			default:
				Debug.logWarn('CharacterFactory: Unknown atlas type (${data.atlasType}), defaulting to Sparrow...');
				return new SparrowCharacter(data);
		}
	}
}
