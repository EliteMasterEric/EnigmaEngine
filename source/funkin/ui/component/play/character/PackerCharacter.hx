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
 * PackerCharacter.hx
 * A Packer character uses a Packer spritesheet to render the character.
 * This is a rendering type used by the vanilla game, but only for the Spirit character, for some reason.
 */
package funkin.ui.component.play.character;

import funkin.util.assets.GraphicsAssets;
import flixel.graphics.frames.FlxFramesCollection;
import funkin.behavior.options.Options.AntiAliasingOption;
import flixel.FlxSprite;
import funkin.data.CharacterData;

using hx.strings.Strings;

class PackerCharacter extends BaseCharacter
{
	public var baseSprite:FlxSprite;

	var animOffsets:Map<String, Array<Int>> = new Map<String, Array<Int>>();

	public function new(charData:CharacterData)
	{
		super(charData);

		loadSpritesheet(charData);
		loadAnimations(charData);

		playAnimation(charData.startingAnim);
	}

	function loadSpritesheet(charData:CharacterData)
	{
		this.baseSprite = new FlxSprite(0, 0);
		add(this.baseSprite);

		var tex:FlxFramesCollection = GraphicsAssets.loadPackerAtlas(charData.asset, 'shared', true);
		if (tex == null)
		{
			Debug.logError('Could not load Packer sprite: ${charData.asset}');
			return;
		}

		this.baseSprite.frames = tex;

		if (charData.isPixel)
		{
			this.baseSprite.antialiasing = false;
		}
		else
		{
			this.baseSprite.antialiasing = AntiAliasingOption.get();
		}

		if (charData.scale != null)
		{
			setGraphicSize(Std.int(this.width * charData.scale));
			updateHitbox();
		}
	}

	function loadAnimations(charData:CharacterData)
	{
		for (anim in charData.animations)
		{
			var frameRate = anim.frameRate == null ? 24 : anim.frameRate;
			var looped = anim.looped == null ? false : anim.looped;
			var flipX = anim.flipX == null ? false : anim.flipX;
			var flipY = anim.flipY == null ? false : anim.flipY;

			if (anim.frameIndices != null)
			{
				this.baseSprite.animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", frameRate, looped, flipX, flipY);
			}
			else
			{
				this.baseSprite.animation.addByPrefix(anim.name, anim.prefix, frameRate, looped, flipX, flipY);
			}

			animOffsets[anim.name] = anim.offsets == null ? [0, 0] : anim.offsets;
		}
	}

	public override function hasAnimation(animName:String)
	{
		return this.baseSprite.animation.getByName(animName) != null;
	}

	public override function playAnimation(animName:String, ?restart:Bool = false):Void
	{
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

		this.baseSprite.animation.play(animName, restart);

		var newOffset = animOffsets.get(animName);
		if (animOffsets.exists(animName))
		{
			this.baseSprite.offset.set(newOffset[0], newOffset[1]);
		}
		else
		{
			this.baseSprite.offset.set(0, 0);
		}
	}

	public override function isValid():Bool
	{
		return this.baseSprite != null && this.baseSprite.frames != null;
	}

	public override function setVisible(visible:Bool):Void
	{
		this.baseSprite.visible = visible;
	}

	public override function getAnimationOffsets(name:String):Array<Int>
	{
		return animOffsets.get(name);
	}

	public override function setAnimationOffsets(name:String, value:Array<Int>):Void
	{
		animOffsets.set(name, value);
	}

	public override function getAnimations():Array<String>
	{
		var result = [];
		for (key in animOffsets.keys())
		{
			result.push(key);
		}
		return result;
	}

	public override function setScrollFactor(x:Float = 1, y:Float = 1):Void
	{
		this.baseSprite.scrollFactor.x = x;
		this.baseSprite.scrollFactor.y = y;
	}

	public override function toString():String
	{
		return 'Character[${characterId}][Packer]';
	}
}
