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
 * PlayerSettings.hx
 * A static handler for player settings. Not sure why it was built to handle two players...
 */
package funkin.behavior.options;

import cpp.abi.Abi;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxSignal;
import funkin.behavior.options.Controls;
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

	public function setKeyboardScheme(scheme)
	{
		controls.setKeyboardScheme(scheme);
	}

	public static function init():Void
	{
		if (player1 == null)
		{
			player1 = new PlayerSettings(0, Solo);
			++numPlayers;
		}

		#if !FLX_NO_GAMEPAD
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
