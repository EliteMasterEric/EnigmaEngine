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
 * StageDebugState.hx
 * A stage debugger.
 * Used to ensure the offsets of player characters, as well as stage props, are correct.
 */
package funkin.ui.state.debug;

import funkin.util.assets.AudioAssets;
import funkin.ui.component.Cursor;
import funkin.ui.component.GameCamera;
import funkin.ui.component.play.stage.OldStage;
import funkin.ui.state.play.PlayState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import funkin.ui.component.play.character.BaseCharacter;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using hx.strings.Strings;

class StageDebugState extends FlxState
{
	public var daStage:String;
	public var playerCharId:String;
	public var gfCharId:String;
	public var cpuCharId:String;

	var _file:FileReference;

	var gfChar:BaseCharacter;
	var playerChar:BaseCharacter;
	var cpuChar:BaseCharacter;
	var STAGE:Stage;
	var camFollow:FlxObject;
	var posText:FlxText;
	var currentChar:FlxSprite;
	var currentCharIndex:Int = 0;
	var currentCharId:String;
	var currentChars:Array<FlxSprite>;
	var dragging:Bool = false;
	var oldMousePosX:Int;
	var oldMousePosY:Int;
	var camHUD:FlxCamera;
	var camGame:FlxCamera;
	var charMode:Bool = true;
	var usedObjects:Array<FlxSprite> = [];

	public function new(daStage:String = 'stage', gfCharId:String = 'gf', playerCharId:String = 'bf', cpuCharId:String = 'dad')
	{
		super();
		this.daStage = daStage;
		this.gfCharId = gfCharId;
		this.playerCharId = playerCharId;
		this.cpuCharId = cpuCharId;
		this.currentCharId = gfCharId;
	}

	override function create()
	{
		AudioAssets.stopMusic();
		Cursor.showCursor();

		STAGE = PlayState.STAGE;

		gfChar = PlayState.gfChar;
		playerChar = PlayState.playerChar;
		cpuChar = PlayState.cpuChar;
		currentChars = [cpuChar, playerChar, gfChar];
		if (!gfChar.visible) // for when gf is an opponent
			currentChars.pop();
		currentChar = currentChars[currentCharIndex];

		for (i in STAGE.toAdd)
		{
			add(i);
		}

		for (index => array in STAGE.layInFront)
		{
			switch (index)
			{
				case 0:
					add(gfChar);
					for (bg in array)
						add(bg);
				case 1:
					add(cpuChar);
					for (bg in array)
						add(bg);
				case 2:
					add(playerChar);
					for (bg in array)
						add(bg);
			}
		}

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camGame = new FlxCamera();
		camGame.zoom = 0.7;
		FlxG.cameras.add(camGame);
		FlxG.cameras.add(camHUD);
		GameCamera.setDefaultCameras([camGame]);
		FlxG.camera = camGame;
		camGame.follow(camFollow);

		posText = new FlxText(0, 0);
		posText.size = 26;
		posText.scrollFactor.set();
		posText.cameras = [camHUD];
		add(posText);

		addHelpText();
	}

	var helpText:FlxText;

	function addHelpText():Void
	{
		var helpTextValue = "Help:\nQ/E : Zoom in and out\nI/J/K/L : Pan Camera\nSpace : Cycle Object\nShift : Switch Mode (Char/Stage)\nClick and Drag : Move Active Object\nZ/X : Rotate Object\nR : Reset Rotation\nCTRL-S : Save Offsets to File\nESC : Return to Stage\nPress F1 to hide/show this!\n";
		helpText = new FlxText(940, 0, 0, helpTextValue, 15);
		helpText.scrollFactor.set();
		helpText.cameras = [camHUD];
		helpText.color = FlxColor.WHITE;

		add(helpText);
	}

	public override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.E)
			camGame.zoom += 0.1;
		if (FlxG.keys.justPressed.Q)
		{
			if (camGame.zoom > 0.11) // me when floating point error
				camGame.zoom -= 0.1;
		}
		Debug.quickWatch(camGame.zoom, 'Camera Zoom');

		if (FlxG.keys.justPressed.SHIFT)
		{
			charMode = !charMode;
			dragging = false;
			if (charMode)
				getNextChar();
			else
				getNextObject();
		}

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

		if (FlxG.keys.justPressed.SPACE)
		{
			if (charMode)
			{
				getNextChar();
			}
			else
			{
				getNextObject();
			}
		}

		if (FlxG.mouse.pressed
			&& FlxCollision.pixelPerfectPointCheck(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), currentChar)
			&& !dragging)
		{
			dragging = true;
			updateMousePos();
		}

		if (dragging && FlxG.mouse.justMoved)
		{
			currentChar.setPosition(-(oldMousePosX - FlxG.mouse.x) + currentChar.x, -(oldMousePosY - FlxG.mouse.y) + currentChar.y);
			updateMousePos();
		}

		if (dragging && FlxG.mouse.justReleased || FlxG.keys.justPressed.TAB)
			dragging = false;

		if (FlxG.keys.pressed.Z)
			currentChar.angle -= 1 * Math.ceil(elapsed);
		else if (FlxG.keys.pressed.X)
			currentChar.angle += 1 * Math.ceil(elapsed);
		else if (FlxG.keys.pressed.R)
			currentChar.angle = 0;

		posText.text = (currentCharId + " X: " + currentChar.x + " Y: " + currentChar.y + " Rotation: " + currentChar.angle);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new PlayState());
			PlayState.stageTesting = true;
			for (i in STAGE.toAdd)
			{
				remove(i);
			}

			for (group in STAGE.swagGroup)
			{
				remove(group);
			}

			for (index => array in STAGE.layInFront)
			{
				switch (index)
				{
					case 0:
						remove(gfChar);
						for (bg in array)
							remove(bg);
					case 1:
						remove(cpuChar);
						for (bg in array)
							remove(bg);
					case 2:
						remove(playerChar);
						for (bg in array)
							remove(bg);
				}
			}
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			saveBoyPos();

		if (FlxG.keys.justPressed.F1)
			FlxG.save.data.preferences.showEditorHelp = !FlxG.save.data.preferences.showEditorHelp;

		helpText.visible = FlxG.save.data.preferences.showEditorHelp;

		super.update(elapsed);
	}

	function updateMousePos()
	{
		oldMousePosX = FlxG.mouse.x;
		oldMousePosY = FlxG.mouse.y;
	}

	function getNextObject():Void
	{
		for (key => value in STAGE.swagBacks)
		{
			if (!usedObjects.contains(value))
			{
				usedObjects.push(value);
				currentCharId = key;
				currentChar = value;
				return;
			}
		}
		usedObjects = [];
		getNextObject();
	}

	function getNextChar()
	{
		++currentCharIndex;
		if (currentCharIndex >= currentChars.length)
		{
			currentChar = currentChars[0];
			currentCharIndex = 0;
		}
		else
			currentChar = currentChars[currentCharIndex];
		switch (currentCharIndex)
		{
			case 0:
				currentCharId = cpuCharId;
			case 1:
				currentCharId = playerCharId;
			case 2:
				currentCharId = gfCharId;
		}
	}

	function saveBoyPos():Void
	{
		var result = "";

		for (spriteName => sprite in STAGE.swagBacks)
		{
			var text = spriteName + " X: " + sprite.x + " Y: " + sprite.y + " Rotation: " + sprite.angle;
			result += text + "\n";
		}
		var curCharIndex:Int = 0;
		var char:String = '';
		for (sprite in currentChars)
		{
			switch (curCharIndex)
			{
				case 0:
					char = gfCharId;
				case 1:
					char = playerCharId;
				case 2:
					char = cpuCharId;
			}
			result += char
				+ ' X: '
				+ currentChars[curCharIndex].x + " Y: " + currentChars[curCharIndex].y + " Rotation: " + currentChars[curCharIndex].angle + "\n";
			++curCharIndex;
		}

		if ((result != null) && (result.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(result.trim(), daStage + "Positions.txt");
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
		FlxG.log.notice("Successfully saved Positions DATA.");
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

	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Positions data");
	}
}
