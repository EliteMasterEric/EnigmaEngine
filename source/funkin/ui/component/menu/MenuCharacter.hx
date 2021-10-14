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
 * MenuCharacter.hx
 * Contains logic for the black and white line drawings of characters in the Story menu.
 * Handles loading the graphic, as well as playing the confirm animation when a week is chosen.
 */
package funkin.ui.component.menu;

import funkin.behavior.Debug;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import funkin.util.assets.Paths;
import funkin.util.assets.DataAssets;
import funkin.util.assets.GraphicsAssets;

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

	private static var menuCharCache = new Map<String, FlxFramesCollection>();

	var baseX:Float;
	var baseY:Float;
	var frameRate:Int;

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

		var jsonData = DataAssets.loadJSON('storymenu/${this.charId}');
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
		}
		else
		{
			Debug.logError('Could not load settings for storymenu character ${this.charId}! They will probably look weird.');
		}
	}

	function loadCharacterGraphic():FlxFramesCollection
	{
		if (menuCharCache.get(this.charId) == null)
		{
			var frameCollection = GraphicsAssets.loadSparrowAtlas('storymenu/characters/${this.charId}');
			menuCharCache.set(this.charId, frameCollection);
			return frameCollection;
		}
		else
		{
			return menuCharCache.get(this.charId);
		}
	}

	function buildCharacter()
	{
		// Load character settings.
		frames = loadCharacterGraphic();
		animation.addByPrefix("idle", "idle", this.frameRate, true, false, false);
		// This will silently fail if the animation is missing.
		animation.addByPrefix("confirm", "confirm", this.frameRate, false, false, false);
		antialiasing = FlxG.save.data.antialiasing;

		setGraphicSize(Std.int(width * scale.x), Std.int(height * scale.y));
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
