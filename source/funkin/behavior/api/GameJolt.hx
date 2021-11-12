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
 * GameJolt.hx
 * Adds basic integration with GameJolt. This could be fun...
 * Adds support for unlocking trophies, and retreiving them.
 * GameJolt definitely allows HTML5 builds of FNF mods! 
 */
package funkin.behavior.api;

#if FEATURE_GAMEJOLT
import flixel.addons.api.FlxGameJolt;

class GameJolt
{
	public static var initialized = false;

	public static function initAPI(gameId:Int, apiKey:String)
	{
		FlxGameJolt.init(gameId, apiKey, false);
		Debug.logInfo('GameJolt: Initialized integration with game ID ${gameId}.');
	}

	public static function loginUser(username:String, gameToken:String)
	{
		if (FlxGameJolt.initialized)
		{
			FlxGameJolt.authUser(username, gameToken);
			Debug.logInfo('GameJolt: Authenticated as user ${FlxGameJolt.username}.');
		}
	}

	public static function unlockTrophy(trophyId:Int)
	{
		if (FlxGameJolt.initialized)
		{
			if (FlxGameJolt.username != 'No user')
			{
				FlxGameJolt.addTrophy(trophyId);
				Debug.logInfo('GameJolt: Added trophy ID ${trophyId}.');
			}
		}
	}
}
#end
