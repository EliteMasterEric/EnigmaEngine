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
