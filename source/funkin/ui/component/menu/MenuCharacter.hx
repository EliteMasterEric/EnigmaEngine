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
 * MenuCharacter.hx
 * Contains logic for the black and white line drawings of characters in the Story menu.
 * Handles loading the graphic, as well as playing the confirm animation when a week is chosen.
 */
package funkin.ui.component.menu;

import funkin.behavior.options.Options.AntiAliasingOption;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import funkin.behavior.Debug;
import funkin.util.assets.DataAssets;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;

typedef CharacterSetting =
{
	var ?x:Int;
	var ?y:Int;

	/**
	 * @default 1
	 */
	var ?scale:Float;

	/**
	 * @default 24
	 */
	var ?frameRate:Int;

	/**
	 * @default false
	 */
	var ?flipped:Bool;
}

class MenuCharacter extends FlxSprite
{
	private var danceLeft:Bool = false;
	private var charId:String = '';
	private var charSettings:CharacterSetting = null;

	var baseX:Float = 0.0;
	var baseY:Float = 0.0;
	var frameRate:Int = 24;
	var charScale:Float = 1.0;

	public function new(baseX, baseY, menuCharId:String)
	{
		super(0, 0);

		this.baseX = baseX;
		this.baseY = baseY;

		setCharacter(menuCharId);
	}

	function loadCharacterSettings()
	{
		if (this.charId == '')
			return;

		var jsonData = DataAssets.loadJSON('storymenu/characters/${this.charId}');
		this.charSettings = cast jsonData;

		// Validation.
		if (this.charSettings != null)
		{
			this.x = this.baseX;
			if (this.charSettings.x != null)
			{
				this.x += this.charSettings.x;
			}

			this.y = baseY;
			if (this.charSettings.y != null)
			{
				this.y += this.charSettings.y;
			}

			// Fallback to default values if null.
			this.flipX = this.charSettings.flipped != null ? this.charSettings.flipped : false;
			this.frameRate = this.charSettings.frameRate != null ? this.charSettings.frameRate : 24;
			this.charScale = this.charSettings.scale != null ? this.charSettings.scale : 1.0;
		}
		else
		{
			Debug.logError('Could not load settings for storymenu character ${this.charId}! They will probably look weird.');
		}
	}

	function loadCharacterGraphic():FlxFramesCollection
	{
		// The animation should cache itself so it can be reused.
		return GraphicsAssets.loadSparrowAtlas('storymenu/characters/${this.charId}', null, true);
	}

	function buildCharacter()
	{
		// Load character settings.
		frames = loadCharacterGraphic();
		animation.addByPrefix("idle", "idle", this.frameRate, true, false, false);
		// This will silently fail if the animation is missing.
		animation.addByPrefix("confirm", "confirm", this.frameRate, false, false, false);
		antialiasing = AntiAliasingOption.get();

		setGraphicSize(Std.int(width * this.charScale), Std.int(height * this.charScale));
		updateHitbox();
	}

	public function setCharacter(id:String):Void
	{
		var sameCharacter:Bool = id == this.charId;
		this.charId = id;

		// Make invisible and show no anims if character is blank.
		this.visible = this.charId != '';
		if (!this.visible)
			return;

		if (!sameCharacter)
		{
			loadCharacterSettings();
			buildCharacter();

			playIdle();
		}
	}

	public function playIdle():Void
	{
		if (animation.getByName("idle") != null)
		{
			animation.play("idle", true);
		}
	}

	public function playConfirm():Void
	{
		if (animation.getByName("confirm") != null)
		{
			animation.play("confirm", false);
		}
	}
}
