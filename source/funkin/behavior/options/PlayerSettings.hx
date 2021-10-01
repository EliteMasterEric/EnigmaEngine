package funkin.behavior.options;

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
	}

	public static function reset()
	{
		player1 = null;
		player2 = null;
		numPlayers = 0;
	}
}
