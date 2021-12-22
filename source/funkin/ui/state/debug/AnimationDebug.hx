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
 * AnimationDebug.hx
 * A character animation debugger.
 * Used to ensure the offset of each animation on a character is correct.
 */
package funkin.ui.state.debug;

import funkin.util.assets.AudioAssets;
import funkin.ui.state.play.PlayState;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.ui.component.play.character.BaseCharacter;
import funkin.ui.component.play.character.CharacterFactory;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using hx.strings.Strings;

class AnimationDebug extends FlxState
{
	var _file:FileReference;

	var playerChar:BaseCharacter;
	var cpuChar:BaseCharacter;
	var currentChar:BaseCharacter;

	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var isDad:Bool = true;
	var daAnim:String = 'spooky';
	var camFollow:FlxObject;

	public function new(daAnim:String = 'spooky')
	{
		super();
		this.daAnim = daAnim;
	}

	override function create()
	{
		AudioAssets.stopMusic();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		if (daAnim == 'bf')
			isDad = false;

		if (isDad)
		{
			cpuChar = CharacterFactory.buildCharacter(daAnim);
			cpuChar.screenCenter();
			add(cpuChar);

			currentChar = cpuChar;
			cpuChar.flipX = false;
		}
		else
		{
			playerChar = CharacterFactory.buildCharacter('bf');
			playerChar.screenCenter();
			add(playerChar);

			currentChar = playerChar;
			playerChar.flipX = false;
		}

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		textAnim.scrollFactor.set();
		add(textAnim);

		displayCharOffsets();

		addHelpText();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function displayCharOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim in currentChar.getAnimations())
		{
			var offsets = currentChar.getAnimationOffsets(anim);
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.BLUE;
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function saveCharOffsets():Void
	{
		var result = "";

		for (anim in currentChar.getAnimations())
		{
			var offsets = currentChar.getAnimationOffsets(anim);
			result += '$anim ${offsets.join(" ")}\n';
		}

		if ((result != null) && (result.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(result.trim(), '${daAnim}Offsets.txt');
		}
	}

	/**
	 * Called when the save file dialog is completed.
	 */
	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved OFFSET DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the offset data.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Offset data");
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	var helpText:FlxText;

	function addHelpText():Void
	{
		var helpTextValue = "Help:\nQ/E : Zoom in and out\nF : Flip\nI/J/K/L : Pan Camera\nW/S : Cycle Animation\nArrows : Offset Animation\nShift-Arrows : Offset Animation x10\nSpace : Replay Animation\nCTRL-S : Save Offsets to File\nEnter/ESC : Exit\nPress F1 to hide/show this!\n";
		helpText = new FlxText(940, 20, 0, helpTextValue, 15);
		helpText.scrollFactor.set();
		helpText.color = FlxColor.BLUE;

		add(helpText);
	}

	override function update(elapsed:Float)
	{
		textAnim.text = currentChar.getAnimation();

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new PlayState());

		if (FlxG.keys.justPressed.E)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Q)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.justPressed.F)
			currentChar.flipX = !currentChar.flipX;

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			if (FlxG.keys.pressed.I)
				camFollow.velocity.y = -90;
			else if (FlxG.keys.pressed.K)
				camFollow.velocity.y = 90;
			else
				camFollow.velocity.y = 0;

			if (FlxG.keys.pressed.J)
				camFollow.velocity.x = -90;
			else if (FlxG.keys.pressed.L)
				camFollow.velocity.x = 90;
			else
				camFollow.velocity.x = 0;
		}
		else
		{
			camFollow.velocity.set();
		}

		if (FlxG.keys.justPressed.W)
		{
			curAnim -= 1;
		}

		if (FlxG.keys.justPressed.S)
		{
			curAnim += 1;
		}

		if (curAnim < 0)
			curAnim = animList.length - 1;

		if (curAnim >= animList.length)
			curAnim = 0;

		if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
		{
			currentChar.playAnimation(animList[curAnim]);

			updateTexts();
			displayCharOffsets(false);
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			var offsets = currentChar.getAnimationOffsets(animList[curAnim]);
			if (upP)
			{
				offsets[1] += 1 * multiplier;
			}
			if (downP)
			{
				offsets[1] -= 1 * multiplier;
			}
			if (leftP)
			{
				offsets[0] += 1 * multiplier;
			}
			if (rightP)
			{
				offsets[0] -= 1 * multiplier;
			}
			currentChar.setAnimationOffsets(animList[curAnim], offsets);

			updateTexts();
			displayCharOffsets(false);
			currentChar.playAnimation(animList[curAnim]);
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			saveCharOffsets();

		if (FlxG.keys.justPressed.F1)
			FlxG.save.data.preferences.showEditorHelp = !FlxG.save.data.preferences.showEditorHelp;

		helpText.visible = FlxG.save.data.preferences.showEditorHelp;

		super.update(elapsed);
	}
}
