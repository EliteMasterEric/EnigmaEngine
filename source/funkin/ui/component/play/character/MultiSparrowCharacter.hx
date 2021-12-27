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
 * MultiSparrowCharacter.hx
 * A Muli-Sparrow character is split into several SparrowV2 spritesheets.
 * Notable characters using this include BF Pixel and Hellclown Tricky from the Tricky Mod.
 */
package funkin.ui.component.play.character;

import funkin.util.assets.GraphicsAssets;
import flixel.graphics.frames.FlxFramesCollection;
import funkin.behavior.options.Options.AntiAliasingOption;
import flixel.FlxSprite;
import funkin.data.CharacterData;

using hx.strings.Strings;

class MultiSparrowCharacter extends BaseCharacter
{
	/**
	 * Sprites are keyed by the asset name.
	 */
	public var baseSprites:Map<String, FlxSprite> = new Map<String, FlxSprite>();

	/**
	 * Animations are keyed by name, and point to the asset name they use.
	 */
	public var animSpriteKeys:Map<String, String> = new Map<String, String>();

	/**
	 * The offsets to use for each animation.
	 */
	var animOffsets:Map<String, Array<Int>> = new Map<String, Array<Int>>();

	var currentSprite:FlxSprite;

	public function new(charData:CharacterData)
	{
		super(charData);

		loadAnimations(charData);

		playAnimation(charData.startingAnim);
	}

	function buildSprite(animData:AnimationData, charData:CharacterData):FlxSprite
	{
		var sprite = new FlxSprite(0, 0);
		// Hide the sprite by default.
		sprite.visible = false;
		add(sprite);

		var asset = animData.asset != null ? animData.asset : charData.asset;
		var tex:FlxFramesCollection = GraphicsAssets.loadSparrowAtlas(asset, 'shared', true);
		if (tex == null)
		{
			Debug.logError('Could not load Multi-Sparrow sprite: ${asset}');
			return null;
		}

		sprite.frames = tex;

		baseSprites.set(asset, sprite);
		animSpriteKeys.set(animData.name, asset);

		if (charData.isPixel)
		{
			sprite.antialiasing = false;
		}
		else
		{
			sprite.antialiasing = AntiAliasingOption.get();
		}

		if (charData.scale != null)
		{
			sprite.setGraphicSize(Std.int(sprite.width * charData.scale));
			sprite.updateHitbox();
		}

		return sprite;
	}

	function loadAnimations(charData:CharacterData)
	{
		for (animData in charData.animations)
		{
			var childSprite = null;

			var asset = animData.asset != null ? animData.asset : charData.asset;
			if (baseSprites.exists(asset))
			{
				childSprite = baseSprites.get(asset);
			}
			else
			{
				childSprite = buildSprite(animData, charData);
			}

			// Failure to load.
			if (childSprite == null)
				continue;

			var frameRate = animData.frameRate == null ? 24 : animData.frameRate;
			var looped = animData.looped == null ? false : animData.looped;
			var flipX = animData.flipX == null ? false : animData.flipX;
			var flipY = animData.flipY == null ? false : animData.flipY;

			if (animData.frameIndices != null)
			{
				childSprite.animation.addByIndices(animData.name, animData.prefix, animData.frameIndices, "", frameRate, looped, flipX, flipY);
			}
			else
			{
				childSprite.animation.addByPrefix(animData.name, animData.prefix, frameRate, looped, flipX, flipY);
			}

			animOffsets[animData.name] = animData.offsets == null ? [0, 0] : animData.offsets;
		}
	}

	public override function getAnimationOffsets(name:String):Array<Int>
	{
		return animOffsets.get(name);
	}

	public override function getAnimations():Array<String>
	{
		var result = [];
		for (key in animSpriteKeys.keys())
		{
			result.push(key);
		}
		return result;
	}

	public override function setAnimationOffsets(name:String, value:Array<Int>):Void
	{
		animOffsets.set(name, value);
	}

	public override function hasAnimation(animName:String)
	{
		return animSpriteKeys.exists(animName);
	}

	public override function setScrollFactor(x:Float = 1, y:Float = 1):Void
	{
		for (sprite in baseSprites)
		{
			sprite.scrollFactor.set(x, y);
		}
	}

	public override function setVisible(visible:Bool):Void
	{
		for (sprite in baseSprites)
		{
			sprite.visible = visible;
		}
	}

	/**
	 * Hide all child sprites of this character.
	 */
	function hideAll():Void
	{
		for (asset in baseSprites.keys())
		{
			var sprite = baseSprites.get(asset);
			if (sprite != null)
				sprite.visible = false;
		}
	}

	/**
	 * Show a specific child sprite of this character.
	 */
	function showSprite(asset:String):FlxSprite
	{
		var sprite = baseSprites.get(asset);
		if (sprite != null)
		{
			sprite.visible = true;
			return sprite;
		}
		else
		{
			Debug.logError('Multi-Sparrow character could not find sprite for asset: ${asset}');
			return null;
		}
	}

	public override function playAnimation(animName:String, ?restart:Bool = false):Void
	{
		// An animation is already playing.
		if (forceAnimation)
			return;

		if (cbOnPlayAnimation != null)
		{
			if (!cbOnPlayAnimation(animName))
			{
				return;
			}
		}

		if (animName == null)
		{
			Debug.logWarn('Tried to play a null animation!');
			return;
		}

		if (animName.endsWith('alt') && !hasAnimation(animName))
		{
			Debug.logWarn('Character ($characterId) does not support alt animation $animName! Falling back...');
			animName = animName.substring(0, animName.length - 3);
		}

		if (!hasAnimation(animName))
		{
			Debug.logWarn('Character ($characterId) does not support animation $animName! Falling back to idle...');
			if (!hasAnimation('idle'))
			{
				Debug.logError('Character ($characterId) does not support idle animation! Check your character data!');
				return;
			}
			animName = 'idle';
		}

		hideAll();
		var sprite = showSprite(animSpriteKeys.get(animName));
		if (sprite == null)
		{
			Debug.logError('Could not find sprite for animation $animName! Skipping...');
			return;
		}

		sprite.animation.play(animName, restart);

		var newOffset = animOffsets.get(animName);
		if (animOffsets.exists(animName))
		{
			sprite.offset.set(newOffset[0], newOffset[1]);
		}
		else
		{
			sprite.offset.set(0, 0);
		}
	}

	public override function getAnimation():String
	{
		return this.currentSprite.animation.name;
	}

	public override function getAnimationFrame():Int
	{
		return this.currentSprite.animation.frameIndex;
	}

	public override function isValid():Bool
	{
		return true;
	}
}
