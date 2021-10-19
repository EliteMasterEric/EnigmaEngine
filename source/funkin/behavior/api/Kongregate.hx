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
 * Kongregate.hx
 * Adds basic integration with Kongregate. This could be fun...
 * Adds support for submitting scores, and... saving and loading shared content? Could we load mods with this?
 * IDK if Kongregate would allow FNF mods...
 */
package funkin.behavior.api;

#if FEATURE_KONGREGATE
import flixel.addons.api.FlxKongregate;

class Kongregate
{
	public static var initialized = false;

	public static function initAPI(gameId:Int, apiKey:String)
	{
		// TODO
	}

	public static function loginUser(username:String, gameToken:String)
	{
		// TODO
	}

	public static function unlockAchievement(trophyId:Int)
	{
		// TODO
	}
}
#end
