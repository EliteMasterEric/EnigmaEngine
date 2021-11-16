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
 * KeyBindMenu.hx
 * The substate which overlays the screen when remapping basic keybinds.
 */
package funkin.ui.state.options;

import funkin.behavior.options.PlayerSettings;
import funkin.util.assets.Paths;
import funkin.behavior.options.CustomControls;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxInput;
import flixel.input.FlxKeyManager;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import funkin.behavior.options.Options;
import lime.app.Application;

using hx.strings.Strings;

class KeyBindMenu extends FlxSubState
{
	var keyTextDisplay:FlxText;
	var keyWarning:FlxText;
	var warningTween:FlxTween;
	var keyText:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];
	var defaultKeys:Array<String> = ["A", "S", "W", "D", "R"];
	var defaultGpKeys:Array<String> = ["DPAD_LEFT", "DPAD_DOWN", "DPAD_UP", "DPAD_RIGHT"];
	var curSelected:Int = 0;

	var keys:Array<String> = [
		FlxG.save.data.binds.leftBind,
		FlxG.save.data.binds.downBind,
		FlxG.save.data.binds.upBind,
		FlxG.save.data.binds.rightBind
	];
	var gpKeys:Array<String> = [
		FlxG.save.data.binds.gpleftBind,
		FlxG.save.data.binds.gpdownBind,
		FlxG.save.data.binds.gpupBind,
		FlxG.save.data.binds.gprightBind
	];
	var tempKey:String = "";
	var blacklist:Array<String> = ["ESCAPE", "ENTER", "BACKSPACE", "SPACE", "TAB"];

	var blackBox:FlxSprite;
	var infoText:FlxText;

	var state:String = "select";

	override function create()
	{
		for (i in 0...keys.length)
		{
			var k = keys[i];
			if (k == null)
				keys[i] = defaultKeys[i];
		}

		for (i in 0...gpKeys.length)
		{
			var k = gpKeys[i];
			if (k == null)
				gpKeys[i] = defaultGpKeys[i];
		}

		persistentUpdate = true;

		keyTextDisplay = new FlxText(-10, 0, 1280, "", 72);
		keyTextDisplay.scrollFactor.set(0, 0);
		keyTextDisplay.setFormat("VCR OSD Mono", 42, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		keyTextDisplay.borderSize = 2;
		keyTextDisplay.borderQuality = 3;

		blackBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackBox);

		infoText = new FlxText(-10, 580, 1280,
			'Current Mode: ${CustomControls.gamepad ? 'GAMEPAD' : 'KEYBOARD'}. Press TAB to switch\n(${CustomControls.gamepad ? 'RIGHT Trigger' : 'Escape'} to save, ${CustomControls.gamepad ? 'LEFT Trigger' : 'Backspace'} to leave without saving. ${CustomControls.gamepad ? 'START To change a keybind' : ''})',
			72);
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 2;
		infoText.borderQuality = 3;
		infoText.alpha = 0;
		infoText.screenCenter(FlxAxes.X);
		add(infoText);
		add(keyTextDisplay);

		blackBox.alpha = 0;
		keyTextDisplay.alpha = 0;

		FlxTween.tween(keyTextDisplay, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(infoText, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

		OptionsMenu.instance.acceptInput = false;

		textUpdate();

		super.create();
	}

	var frames = 0;

	override function update(elapsed:Float)
	{
		#if FEATURE_GAMEPAD
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		#end

		if (frames <= 10)
			frames++;

		infoText.text = 'Current Mode: ${CustomControls.gamepad ? 'GAMEPAD' : 'KEYBOARD'}. Press TAB to switch\n(${CustomControls.gamepad ? 'RIGHT Trigger' : 'Escape'} to save, ${CustomControls.gamepad ? 'LEFT Trigger' : 'Backspace'} to leave without saving. ${CustomControls.gamepad ? 'START To change a keybind' : ''})\n${lastKey != "" ? lastKey + " is blacklisted!" : ""}';

		switch (state)
		{
			case "select":
				if (FlxG.keys.justPressed.UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}

				if (FlxG.keys.justPressed.DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}

				if (FlxG.keys.justPressed.TAB)
				{
					CustomControls.gamepad = !CustomControls.gamepad;
					textUpdate();
				}

				if (FlxG.keys.justPressed.ENTER)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					state = "input";
				}
				else if (FlxG.keys.justPressed.ESCAPE)
				{
					quit();
				}
				else if (FlxG.keys.justPressed.BACKSPACE)
				{
					reset();
				}
				#if FEATURE_GAMEPAD
				if (gamepad != null) // GP Logic
				{
					if (gamepad.justPressed.DPAD_UP)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(-1);
						textUpdate();
					}
					if (gamepad.justPressed.DPAD_DOWN)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(1);
						textUpdate();
					}

					if (gamepad.justPressed.START && frames > 10)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
						state = "input";
					}
					else if (gamepad.justPressed.LEFT_TRIGGER)
					{
						quit();
					}
					else if (gamepad.justPressed.RIGHT_TRIGGER)
					{
						reset();
					}
				}
				#end

			case "input":
				if (CustomControls.gamepad)
				{
					tempKey = gpKeys[curSelected];
					gpKeys[curSelected] = "?";
				}
				else
				{
					tempKey = keys[curSelected];
					keys[curSelected] = "?";
				}
				textUpdate();
				state = "waiting";

			case "waiting":
				#if FEATURE_GAMEPAD
				if (gamepad != null && CustomControls.gamepad) // GP Logic
				{
					if (FlxG.keys.justPressed.ESCAPE)
					{ // just in case you get stuck
						gpKeys[curSelected] = tempKey;
						state = "select";
						FlxG.sound.play(Paths.sound('confirmMenu'));
					}

					if (gamepad.justPressed.START)
					{
						addKeyGamepad(defaultKeys[curSelected]);
						save();
						state = "select";
					}

					if (gamepad.justPressed.ANY)
					{
						trace(gamepad.firstJustPressedID());
						addKeyGamepad(gamepad.firstJustPressedID());
						save();
						state = "select";
						textUpdate();
					}
				}
				else
				{
				#end
					if (FlxG.keys.justPressed.ESCAPE)
					{
						keys[curSelected] = tempKey;
						state = "select";
						FlxG.sound.play(Paths.sound('confirmMenu'));
					}
					else if (FlxG.keys.justPressed.ENTER)
					{
						addKey(defaultKeys[curSelected]);
						save();
						state = "select";
					}
					else if (FlxG.keys.justPressed.ANY)
					{
						addKey(FlxG.keys.getIsDown()[0].ID.toString());
						save();
						state = "select";
					}
				#if FEATURE_GAMEPAD
				}
				#end

			case "exiting":

			default:
				state = "select";
		}

		if (FlxG.keys.justPressed.ANY)
			textUpdate();

		super.update(elapsed);
	}

	function textUpdate()
	{
		keyTextDisplay.text = "\n\n";

		if (CustomControls.gamepad)
		{
			for (i in 0...4)
			{
				var textStart = (i == curSelected) ? "> " : "  ";
				trace(gpKeys[i]);
				keyTextDisplay.text += textStart + keyText[i] + ": " + gpKeys[i] + "\n";
			}
		}
		else
		{
			for (i in 0...4)
			{
				var textStart = (i == curSelected) ? "> " : "  ";
				keyTextDisplay.text += textStart + keyText[i] + ": " + ((keys[i] != keyText[i]) ? (keys[i] + " / ") : "") + keyText[i] + " ARROW\n";
			}
		}

		keyTextDisplay.screenCenter();
	}

	function save()
	{
		FlxG.save.data.binds.upBind = keys[2];
		FlxG.save.data.binds.downBind = keys[1];
		FlxG.save.data.binds.leftBind = keys[0];
		FlxG.save.data.binds.rightBind = keys[3];

		FlxG.save.data.binds.gpupBind = gpKeys[2];
		FlxG.save.data.binds.gpdownBind = gpKeys[1];
		FlxG.save.data.binds.gpleftBind = gpKeys[0];
		FlxG.save.data.binds.gprightBind = gpKeys[3];

		FlxG.save.flush();

		PlayerSettings.player1.controls.loadKeyBinds();
	}

	function reset()
	{
		for (i in 0...5)
		{
			keys[i] = defaultKeys[i];
		}
		quit();
	}

	function quit()
	{
		state = "exiting";

		save();

		OptionsMenu.instance.acceptInput = true;

		FlxTween.tween(keyTextDisplay, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0}, 1.1, {
			ease: FlxEase.expoInOut,
			onComplete: function(flx:FlxTween)
			{
				close();
			}
		});
		FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
	}

	function addKeyGamepad(r:String)
	{
		var shouldReturn:Bool = true;

		var notAllowed:Array<String> = ["START"];
		var swapKey:Int = -1;

		for (x in 0...gpKeys.length)
		{
			var oK = gpKeys[x];
			if (oK == r)
			{
				swapKey = x;
				gpKeys[x] = null;
			}
			if (notAllowed.contains(oK))
			{
				gpKeys[x] = null;
				lastKey = r;
				return;
			}
		}

		if (notAllowed.contains(r))
		{
			gpKeys[curSelected] = tempKey;
			lastKey = r;
			return;
		}

		if (shouldReturn)
		{
			if (swapKey != -1)
			{
				gpKeys[swapKey] = tempKey;
			}
			gpKeys[curSelected] = r;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		else
		{
			gpKeys[curSelected] = tempKey;
			lastKey = r;
		}
	}

	public var lastKey:String = "";

	function addKey(r:String)
	{
		var shouldReturn:Bool = true;

		var notAllowed:Array<String> = [];
		var swapKey:Int = -1;

		for (x in blacklist)
		{
			notAllowed.push(x);
		}

		trace(notAllowed);

		for (x in 0...keys.length)
		{
			var oK = keys[x];
			if (oK == r)
			{
				swapKey = x;
				keys[x] = null;
			}
			if (notAllowed.contains(oK))
			{
				keys[x] = null;
				lastKey = oK;
				return;
			}
		}

		if (notAllowed.contains(r))
		{
			keys[curSelected] = tempKey;
			lastKey = r;
			return;
		}

		lastKey = "";

		if (shouldReturn)
		{
			// Swap keys instead of setting the other one as null
			if (swapKey != -1)
			{
				keys[swapKey] = tempKey;
			}
			keys[curSelected] = r;
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		else
		{
			keys[curSelected] = tempKey;
			lastKey = r;
		}
	}

	function changeItem(_amount:Int = 0)
	{
		curSelected += _amount;

		if (curSelected > 3)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 3;
	}
}
