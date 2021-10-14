package funkin.behavior.options;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

class KeyBinds
{
	public static var gamepad:Bool = false;

	public static function resetBinds():Void
	{
		// DFJK master race
		FlxG.save.data.leftBind = "D";
		FlxG.save.data.downBind = "F";
		FlxG.save.data.upBind = "J";
		FlxG.save.data.rightBind = "K";
		FlxG.save.data.killBind = "R";
		FlxG.save.data.fullscreenBind = "F11";
		FlxG.save.data.gpupBind = "DPAD_UP";
		FlxG.save.data.gpdownBind = "DPAD_DOWN";
		FlxG.save.data.gpleftBind = "DPAD_LEFT";
		FlxG.save.data.gprightBind = "DPAD_RIGHT";

		FlxG.save.data.left9KBind = "S";
		FlxG.save.data.down9KBind = "";
		FlxG.save.data.up9KBind = "D";
		FlxG.save.data.right9KBind = "F";
		FlxG.save.data.altLeftBind = "J";
		FlxG.save.data.altDownBind = "";
		FlxG.save.data.altUpBind = "K";
		FlxG.save.data.altRightBind = "L";
		FlxG.save.data.centerBind = "SPACE";

		// TODO: Fix these.
		FlxG.save.data.gpleft9KBind = "";
		FlxG.save.data.gpdown9KBind = "";
		FlxG.save.data.gpup9KBind = "";
		FlxG.save.data.gpright9KBind = "";
		FlxG.save.data.gpcenterBind = "";
		FlxG.save.data.gpaltLeftBind = "";
		FlxG.save.data.gpaltDownBind = "";
		FlxG.save.data.gpaltUpBind = "";
		FlxG.save.data.gpaltRightBind = "";

		PlayerSettings.player1.controls.loadKeyBinds();
	}

	public static function keyCheck():Void
	{
		if (FlxG.save.data.leftBind == null)
		{
			FlxG.save.data.leftBind = "D";
			trace("No LEFT");
		}
		if (FlxG.save.data.downBind == null)
		{
			FlxG.save.data.downBind = "F";
			trace("No DOWN");
		}
		if (FlxG.save.data.upBind == null)
		{
			FlxG.save.data.upBind = "J";
			trace("No UP");
		}
		if (FlxG.save.data.rightBind == null)
		{
			FlxG.save.data.rightBind = "K";
			trace("No RIGHT");
		}

		if (FlxG.save.data.gpupBind == null)
		{
			FlxG.save.data.gpupBind = "DPAD_UP";
			trace("No GUP");
		}
		if (FlxG.save.data.gpdownBind == null)
		{
			FlxG.save.data.gpdownBind = "DPAD_DOWN";
			trace("No GDOWN");
		}
		if (FlxG.save.data.gpleftBind == null)
		{
			FlxG.save.data.gpleftBind = "DPAD_LEFT";
			trace("No GLEFT");
		}
		if (FlxG.save.data.gprightBind == null)
		{
			FlxG.save.data.gprightBind = "DPAD_RIGHT";
			trace("No GRIGHT");
		}

		if (FlxG.save.data.left9KBind == null)
		{
			trace("No LEFT9K");
			FlxG.save.data.left9KBind = "S";
		}
		if (FlxG.save.data.down9KBind == null)
		{
			trace("No DOWN9K");
			FlxG.save.data.down9KBind = "";
		}
		if (FlxG.save.data.up9KBind == null)
		{
			trace("No UP9K");
			FlxG.save.data.up9KBind = "D";
		}
		if (FlxG.save.data.right9KBind == null)
		{
			trace("No RIGHT9K");
			FlxG.save.data.right9KBind = "F";
		}
		if (FlxG.save.data.centerBind == null)
		{
			trace("No CENTER");
			FlxG.save.data.centerBind = "SPACE";
		}
		if (FlxG.save.data.altLeftBind == null)
		{
			trace("No ALTLEFT");
			FlxG.save.data.altLeftBind = "J";
		}
		if (FlxG.save.data.altDownBind == null)
		{
			trace("No ALTDOWN");
			FlxG.save.data.altDownBind = "";
		}
		if (FlxG.save.data.altUpBind == null)
		{
			trace("No ALTUP");
			FlxG.save.data.altUpBind = "K";
		}
		if (FlxG.save.data.altRightBind == null)
		{
			trace("No ALTRIGHT");
			FlxG.save.data.altRightBind = "L";
		}

		if (FlxG.save.data.gpleft9KBind == null)
		{
			trace("No gpLEFT9K");
			FlxG.save.data.gpleft9KBind = "";
		}
		if (FlxG.save.data.gpdown9KBind == null)
		{
			trace("No gpDOWN9K");
			FlxG.save.data.gpdown9KBind = "";
		}
		if (FlxG.save.data.gpup9KBind == null)
		{
			trace("No gpUP9K");
			FlxG.save.data.gpup9KBind = "";
		}
		if (FlxG.save.data.gpright9KBind == null)
		{
			trace("No gpRIGHT9K");
			FlxG.save.data.gpright9KBind = "";
		}
		if (FlxG.save.data.gpcenterBind == null)
		{
			trace("No gpCENTER");
			FlxG.save.data.gpcenterBind = "";
		}
		if (FlxG.save.data.gpaltLeftBind == null)
		{
			trace("No gpALTLEFT");
			FlxG.save.data.gpaltLeftBind = "";
		}
		if (FlxG.save.data.gpaltDownBind == null)
		{
			trace("No gpALTDOWN");
			FlxG.save.data.gpaltDownBind = "";
		}
		if (FlxG.save.data.gpaltUpBind == null)
		{
			trace("No gpALTUP");
			FlxG.save.data.gpaltUpBind = "";
		}
		if (FlxG.save.data.gpaltRightBind == null)
		{
			trace("No gpALTRIGHT");
			FlxG.save.data.gpaltRightBind = "";
		}

		if (FlxG.save.data.killBind == null)
		{
			FlxG.save.data.killBind = "R";
			trace("No KILL");
		}
		if (FlxG.save.data.fullscreenBind == null)
		{
			FlxG.save.data.fullscreenBind = "F11";
			trace("No FULLSCREEN");
		}

		Debug.logTrace('Current basic keybinds are: ${FlxG.save.data.leftBind}-${FlxG.save.data.downBind}-${FlxG.save.data.upBind}-${FlxG.save.data.rightBind}');
	}
}
