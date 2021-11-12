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
 * Character.hx
 * A sprite which represents either Boyfriend, Girlfriend, or an opponent during the Play state.
 * Handles loading of animations and offsets, and of character dancing animation status.
 */
package funkin.ui.component.play;

import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import flixel.addons.effects.FlxTrail;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.util.FlxColor;
import funkin.behavior.Debug;
import funkin.behavior.play.Conductor;
import funkin.util.assets.DataAssets;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;
import funkin.behavior.options.Options.AntiAliasingOption;

using hx.strings.Strings;

// Character is an FlxSpriteGroup that can contain multiple individual Character sprites.
class Character extends FlxSpriteGroup
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	/**
	 * Whether the current character is a player character.
	 */
	public var isPlayer:Bool = false;

	/**
	 * The ID of the current character.
	 */
	public var curCharacter:String = 'bf';

	public var barColor:FlxColor;

	public var holdTimer:Float = 0;

	var internalSprite:FlxSprite;

	/**
	 * When set to true, enables an after-image or trail to the current sprite.
	 * This is used by Spirit in Thorns.
	 */
	public var trailEnabled(default, set):Bool = false;

	var trail:FlxTrail;

	function set_trailEnabled(newValue:Bool):Bool
	{
		this.trailEnabled = newValue;
		if (newValue)
		{
			add(trail);
		}
		else
		{
			remove(trail);
		}
		return this.trailEnabled;
	}

	/**
	 * Contains a list of characters valid to use as a player or CPU.
	 */
	public static var characterList:Array<String> = [];

	/**
	 * Contains a list of background characters valid only to use as a GF.
	 */
	public static var girlfriendList:Array<String> = [];

	public static function initCharacterList()
	{
		characterList = DataAssets.listJSONsInPath('characters/');

		for (charId in characterList)
		{
			var charData:CharacterData = parseDataFile(charId);
			if (charData == null)
			{
				// TODO: Fix Polymod so unloaded mods don't appear in .list().
				Debug.logError('Character $charId failed to load.');
				characterList.remove(charId);
				continue;
			}
			if (charData.isGF)
			{
				characterList.remove(charId);
				girlfriendList.push(charId);
			}
		}
	}

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(0, 0);

		this.internalSprite = new FlxSprite(x, y);
		add(this.internalSprite);
		this.internalSprite.antialiasing = AntiAliasingOption.get();

		this.barColor = isPlayer ? 0xFF66FF33 : 0xFFFF0000;
		this.animOffsets = new Map<String, Array<Dynamic>>();
		this.curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:Null<FlxFramesCollection>;
		switch (curCharacter)
		{
			case 'gf-christmas':
				tex = GraphicsAssets.loadSparrowAtlas('characters/gfChristmas', 'shared');
				this.internalSprite.frames = tex;
				this.internalSprite.animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				this.internalSprite.animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				this.internalSprite.animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				this.internalSprite.animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24,
					false);
				this.internalSprite.animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "",
					24, false);
				this.internalSprite.animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				this.internalSprite.animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				this.internalSprite.animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');
			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = GraphicsAssets.loadSparrowAtlas('characters/DADDY_DEAREST', 'shared', true);
				this.internalSprite.frames = tex;
				this.internalSprite.animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				this.internalSprite.animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFaf66ce;

				playAnim('idle');
			case 'spooky':
				tex = GraphicsAssets.loadSparrowAtlas('characters/spooky_kids_assets', 'shared');
				this.internalSprite.frames = tex;
				this.internalSprite.animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				this.internalSprite.animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				this.internalSprite.animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFd57e00;

				playAnim('danceRight');
			case 'mom':
				tex = GraphicsAssets.loadSparrowAtlas('characters/Mom_Assets', 'shared');
				this.internalSprite.frames = tex;
				this.internalSprite.animation.addByPrefix('idle', "Mom Idle", 24, false);
				this.internalSprite.animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				this.internalSprite.animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFd8558e;

				playAnim('idle');
			case 'mom-car':
				tex = GraphicsAssets.loadSparrowAtlas('characters/momCar', 'shared');
				this.internalSprite.frames = tex;

				this.internalSprite.animation.addByPrefix('idle', "Mom Idle", 24, false);
				this.internalSprite.animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				this.internalSprite.animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);
				this.internalSprite.animation.addByIndices('idleHair', 'Mom Idle', [10, 11, 12, 13], "", 24, true);

				loadOffsetFile(curCharacter);
				barColor = 0xFFd8558e;

				playAnim('idle');
			case 'monster':
				tex = GraphicsAssets.loadSparrowAtlas('characters/Monster_Assets', 'shared');
				this.internalSprite.frames = tex;
				this.internalSprite.animation.addByPrefix('idle', 'monster idle', 24, false);
				this.internalSprite.animation.addByPrefix('singUP', 'monster up note', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'monster down', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFf3ff6e;
				playAnim('idle');
			case 'monster-christmas':
				tex = GraphicsAssets.loadSparrowAtlas('characters/monsterChristmas', 'shared');
				this.internalSprite.frames = tex;
				this.internalSprite.animation.addByPrefix('idle', 'monster idle', 24, false);
				this.internalSprite.animation.addByPrefix('singUP', 'monster up note', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'monster down', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFf3ff6e;
				playAnim('idle');
			case 'pico':
				tex = GraphicsAssets.loadSparrowAtlas('characters/Pico_FNF_assetss', 'shared');
				this.internalSprite.frames = tex;
				this.internalSprite.animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				this.internalSprite.animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					this.internalSprite.animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					this.internalSprite.animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					this.internalSprite.animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					this.internalSprite.animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					this.internalSprite.animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					this.internalSprite.animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					this.internalSprite.animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					this.internalSprite.animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				this.internalSprite.animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				this.internalSprite.animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				loadOffsetFile(curCharacter);
				barColor = 0xFFb7d855;

				playAnim('idle');

				flipX = true;
			case 'bf-christmas':
				tex = GraphicsAssets.loadSparrowAtlas('characters/bfChristmas', 'shared');
				this.internalSprite.frames = tex;
				this.internalSprite.animation.addByPrefix('idle', 'BF idle dance', 24, false);
				this.internalSprite.animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				this.internalSprite.animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				this.internalSprite.animation.addByPrefix('hey', 'BF HEY', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;
			case 'bf-car':
				tex = GraphicsAssets.loadSparrowAtlas('characters/bfCar', 'shared');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByIndices('idleHair', 'BF idle dance', [10, 11, 12, 13], "", 24, true);

				loadOffsetFile(curCharacter);
				playAnim('idle');

				barColor = 0xFF31b0d1;

				flipX = true;
			case 'bf-pixel':
				this.internalSprite.frames = GraphicsAssets.loadSparrowAtlas('characters/bfPixel', 'shared');
				this.internalSprite.animation.addByPrefix('idle', 'BF IDLE', 24, false);
				this.internalSprite.animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				barColor = 0xFF31b0d1;

				flipX = true;
			case 'bf-pixel-dead':
				this.internalSprite.frames = GraphicsAssets.loadSparrowAtlas('characters/bfPixelsDEAD', 'shared');
				this.internalSprite.animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				this.internalSprite.animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				this.internalSprite.animation.addByPrefix('deathLoop', "Retry Loop", 24, false);
				this.internalSprite.animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				this.internalSprite.animation.play('firstDeath');

				loadOffsetFile(curCharacter);
				playAnim('firstDeath');
				// Pixel sprites are 1/6 size.
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;

				barColor = 0xFF31b0d1;
			case 'senpai':
				this.internalSprite.frames = GraphicsAssets.loadSparrowAtlas('characters/senpai', 'shared');
				this.internalSprite.animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				this.internalSprite.animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFffaa6f;

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'senpai-angry':
				this.internalSprite.frames = GraphicsAssets.loadSparrowAtlas('characters/senpai', 'shared');
				this.internalSprite.animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				this.internalSprite.animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFffaa6f;
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				this.internalSprite.antialiasing = false;
			case 'spirit':
				this.internalSprite.frames = GraphicsAssets.loadPackerAtlas('characters/spirit', 'shared');
				this.internalSprite.animation.addByPrefix('idle', "idle spirit_", 24, false);
				this.internalSprite.animation.addByPrefix('singUP', "up_", 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', "right_", 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', "left_", 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFFff3c6e;

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				this.internalSprite.antialiasing = false;
			case 'parents-christmas':
				this.internalSprite.frames = GraphicsAssets.loadSparrowAtlas('characters/mom_dad_christmas_assets', 'shared');
				this.internalSprite.animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				this.internalSprite.animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				this.internalSprite.animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				this.internalSprite.animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				this.internalSprite.animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				this.internalSprite.animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				this.internalSprite.animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				loadOffsetFile(curCharacter);
				barColor = 0xFF9a00f8;

				playAnim('idle');
			default:
				loadAnimationsFromDataFile();
		}

		this.trail = new FlxTrail(this.internalSprite, null, 4, 24, 0.3, 0.069);
		this.trail.changeValuesEnabled(true, true, true, true);
		// Set this.trailEnabled = true to add the trail.
		// add(this.trail);

		if (curCharacter.startsWith('bf'))
			dance();
	}

	private static function parseDataFile(charId:String):CharacterData
	{
		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData = DataAssets.loadJSON('characters/${charId}');
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${charId}');
			return null;
		}

		var data:CharacterData = cast jsonData;
		return data;
	}

	function loadAnimationsFromDataFile()
	{
		Debug.logInfo('Generating character (${curCharacter}) from JSON data...');

		var data:CharacterData = parseDataFile(curCharacter);
		if (data == null)
			return;

		// Make sure to load characters from cache if applicable.
		var tex:Null<FlxFramesCollection> = null;
		switch (data.atlasType)
		{
			case 'packer':
				tex = GraphicsAssets.loadPackerAtlas(data.asset, 'shared');
			// case 'sparrow':
			default:
				tex = GraphicsAssets.loadSparrowAtlas(data.asset, 'shared', true);
		}
		if (tex == null)
		{
			Debug.logError('Failed to parse animation data for character ${curCharacter}');
			return;
		}

		this.internalSprite.frames = tex;

		for (anim in data.animations)
		{
			var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
			var looped = anim.looped == null ? false : anim.looped;
			var flipX = anim.flipX == null ? false : anim.flipX;
			var flipY = anim.flipY == null ? false : anim.flipY;

			if (anim.frameIndices != null)
			{
				this.internalSprite.animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", frameRate, looped, flipX, flipY);
			}
			else
			{
				this.internalSprite.animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, flipX, flipY);
			}

			animOffsets[anim.name] = anim.offsets == null ? [0, 0] : anim.offsets;
		}

		if (data.scale != null)
		{
			setGraphicSize(Std.int(this.width * data.scale));
			updateHitbox();
		}

		// Disable anti-aliasing on pixel art.
		if (data.isPixel)
		{
			antialiasing = false;
		}

		this.barColor = FlxColor.fromString(data.barColor);

		playAnim(data.startingAnim);
	}

	function loadOffsetFile(character:String, library:String = 'shared')
	{
		var offset:Array<String> = DataAssets.loadLinesFromFile(Paths.txt('images/characters/' + character + "Offsets", library));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (getCurAnimation() == null)
		{
			Debug.logWarn('Animation was null or missing! Is your character metadata complete?');
			return;
		}
		if (!isPlayer)
		{
			if (getCurAnimation().startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			if (curCharacter.endsWith('-car')
				&& !getCurAnimation().startsWith('sing')
				&& isCurAnimationFinished()
				&& animation.getByName('idleHair') != null)
				playAnim('idleHair');

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			else if (curCharacter == 'gf' || curCharacter == 'spooky')
				dadVar = 4.1; // fix double dances
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				if (curCharacter == 'gf' || curCharacter == 'spooky')
					playAnim('danceLeft'); // overridden by dance correctly later
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (getCurAnimation() == 'hairFall' && isCurAnimationFinished())
				{
					danced = true;
					playAnim('danceRight');
				}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * Manages characters dancing to the beat, or playing their idle animation.
	 */
	public function dance(forced:Bool = false, altAnim:Bool = false)
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-christmas' | 'gf-car' | 'gf-pixel':
					if (!getCurAnimation().startsWith('hair') && !getCurAnimation().startsWith('sing'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'spooky':
					if (!getCurAnimation().startsWith('sing'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				/*
					// new dance code is gonna end up cutting off animation with the idle
					// so here's example code that'll fix it. just adjust it to ya character 'n shit
					case 'custom character':
						if (!getCurAnimation().endsWith('custom animation'))
							playAnim('idle', forced);
				 */
				default:
					if (altAnim && animation.getByName('idle-alt') != null)
						playAnim('idle-alt', forced);
					else
						playAnim('idle', forced);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName.endsWith('alt') && animation.getByName(AnimName) == null)
		{
			#if debug
			Debug.logWarn(['Such alt animation doesnt exist: ' + AnimName]);
			#end
			AnimName = AnimName.split('-')[0];
		}

		this.internalSprite.animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			setOffset(daOffset[0], daOffset[1]);
		}
		else
			setOffset(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public override function setGraphicSize(width:Int = 0, height:Int = 0)
	{
		this.internalSprite.setGraphicSize(width, height);
	}

	public override function updateHitbox()
	{
		this.internalSprite.updateHitbox();
	}

	public override function getPosition(?point:FlxPoint = null):flixel.math.FlxPoint
	{
		return this.internalSprite.getPosition();
	}

	public override function setPosition(x:Float = 0, y:Float = 0)
	{
		this.internalSprite.setPosition(x, y);
	}

	public function setScrollFactor(x:Float = 1, y:Float = 1)
	{
		this.internalSprite.scrollFactor.set(x, y);
	}

	public override function getMidpoint(?point:FlxPoint = null):flixel.math.FlxPoint
	{
		return this.internalSprite.getMidpoint(point);
	}

	public override function getGraphicMidpoint(?point:FlxPoint = null):flixel.math.FlxPoint
	{
		return this.internalSprite.getGraphicMidpoint(point);
	}

	public function hasAnimation(name:String)
	{
		return this.internalSprite.animation.getByName(name) != null;
	}

	public function isValid()
	{
		return this.internalSprite.frames != null;
	}

	public function getCurAnimation():String
	{
		return this.internalSprite.animation.curAnim == null ? null : this.internalSprite.animation.curAnim.name;
	}

	public function isCurAnimationFinished()
	{
		if (this.internalSprite.animation.curAnim == null)
			return true;
		return this.internalSprite.animation.curAnim.finished;
	}

	public function getCurAnimFrame():Int
	{
		return this.internalSprite.animation.curAnim == null ? 0 : this.internalSprite.animation.curAnim.curFrame;
	}

	public function setOffset(x:Int, y:Int)
	{
		this.internalSprite.offset.set(x, y);
	}

	public function setVisible(visible:Bool = true)
	{
		this.internalSprite.visible = visible;
	}
}

typedef CharacterData =
{
	/**
	 * The readable name for this character.
	 * Used for menus like the Chart Editor.
	 */
	var name:String;

	/**
	 * The location of this asset relative to `assets/images`.
	 */
	var asset:String;

	/**
	 * The animation used when the character is initialized.
	 */
	var startingAnim:String;

	/**
	 * Value is true if the character is a Girlfriend character.
	 * Meant only to dance in the BG and play animations.
	 * Will not have singing animations.
	 * @default false
	 */
	var ?isGF:Bool;

	/**
	 * Value is true if the character graphic is pixel art.
	 * Forcibly disables anti-aliasing.
	 * @default false
	 */
	var ?isPixel:Bool;

	/**
	 * Multiplier to scale the sprite by.
	 * Default is 1 for no scaling.
	 * Set this to 6 for pixel characters from Week 6.
	 * @default 1
	 */
	var ?scale:Float;

	/**
	 * Define what type of texture atlas is used for this sheet.
	 * Set this to 'packer' for the Spirit and 'sparrow' for everyone else.
	 * @default 'sparrow'
	 */
	var ?atlasType:String;

	/**
	 * The color of this character's health bar.
	 */
	var barColor:String;

	/**
	 * A list of animations to add to this character.
	 * If you're creating a GF, you should make a danceLeft and a danceRight.
	 * If you're creating a BF, you should add an idle, and singLEFT, singUP, etc.
	 */
	var animations:Array<AnimationData>;
}

typedef AnimationData =
{
	/**
	 * The name of this animation as referenced by the game.
	 */
	var name:String;

	/**
	 * The prefix for this animation's frames within the XML file.
	 */
	var prefix:String;

	/**
	 * The X and Y offset of this animation relative to the others. Defaults to 0, 0.
	 * @default [0, 0]
	 */
	var ?offsets:Array<Int>;

	/**
	 * Whether this animation is looped.
	 * @default false
	 */
	var ?looped:Bool;

	/**
	 * Set this to true to flip the sprites of this animation horizontally.
	 * @default false
	 */
	var ?flipX:Bool;

	/**
	 * Set this to true to flip the sprites of this animation vertically.
	 * @default false
	 */
	var ?flipY:Bool;

	/**
	 * The frame rate of this animation.
	 * @default 24
	 */
	var ?frameRate:Int;

	/**
	 * If you want this animation to use only certain frames of an animation with a given prefix,
	 * select them here.
	 * @example [] (all frames)
	 * @default [0, 1, 2, 3] (use only the first four frames)
	 */
	var ?frameIndices:Array<Int>;
}
