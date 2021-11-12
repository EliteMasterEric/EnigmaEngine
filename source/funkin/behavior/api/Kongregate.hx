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
