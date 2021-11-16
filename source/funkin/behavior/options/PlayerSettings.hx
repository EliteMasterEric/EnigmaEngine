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
 * PlayerSettings.hx
 * A static handler for player settings. Not sure why it was built to handle two players...
 */
package funkin.behavior.options;

import flixel.FlxG;
import flixel.util.FlxSignal;
import funkin.behavior.options.CustomControls;

class PlayerSettings
{
	public static var numPlayers(default, null) = 0;
	public static var numAvatars(default, null) = 0;
	public static var player1(default, null):PlayerSettings;
	public static var player2(default, null):PlayerSettings;

	public static final onAvatarAdd = new FlxTypedSignal<PlayerSettings->Void>();
	public static final onAvatarRemove = new FlxTypedSignal<PlayerSettings->Void>();

	public var id(default, null):Int;

	public final controls:CustomControls;

	function new(id, scheme)
	{
		this.id = id;
		this.controls = new CustomControls('player$id', scheme);
	}

	public static function init():Void
	{
		if (player1 == null)
		{
			player1 = new PlayerSettings(0, Solo);
			++numPlayers;
		}

		#if FEATURE_GAMEPAD
		var numGamepads = FlxG.gamepads.numActiveGamepads;
		if (numGamepads > 0)
		{
			var gamepad = FlxG.gamepads.getByID(0);
			if (gamepad == null)
				throw 'Unexpected null gamepad. id:0';

			player1.controls.addDefaultGamepad(0);
		}

		if (numGamepads > 1)
		{
			if (player2 == null)
			{
				player2 = new PlayerSettings(1, None);
				++numPlayers;
			}

			var gamepad = FlxG.gamepads.getByID(1);
			if (gamepad == null)
				throw 'Unexpected null gamepad. id:0';

			player2.controls.addDefaultGamepad(1);
		}
		#end
	}

	public static function reset()
	{
		player1 = null;
		player2 = null;
		numPlayers = 0;
	}
}
