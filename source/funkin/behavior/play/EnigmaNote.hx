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
 * EnigmaNote.hx
 * Utility class which abstracts the rendering of notes out of PlayState.
 * Designed to make it easy to add custom note types and note styles.
 */
package funkin.behavior.play;

import funkin.ui.component.play.StaticArrow;
import funkin.ui.component.play.Note;
import funkin.util.NoteUtil;
import funkin.util.assets.Paths;
import flixel.tweens.FlxEase;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import funkin.ui.state.play.PlayState;
import funkin.behavior.play.PlayStateChangeables;
import funkin.behavior.options.CustomControls;
import openfl.events.KeyboardEvent;
import funkin.util.assets.GraphicsAssets;

using StringTools;

class EnigmaNote
{
	public static final NOTE_BASE_LEFT:Int = 0;
	public static final NOTE_BASE_DOWN:Int = 1;
	public static final NOTE_BASE_UP:Int = 2;
	public static final NOTE_BASE_RIGHT:Int = 3;
	public static final NOTE_BASE_LEFT_ENEMY:Int = 4;
	public static final NOTE_BASE_DOWN_ENEMY:Int = 5;
	public static final NOTE_BASE_UP_ENEMY:Int = 6;
	public static final NOTE_BASE_RIGHT_ENEMY:Int = 7;

	public static final NOTE_9K_LEFT:Int = 10;
	public static final NOTE_9K_DOWN:Int = 11;
	public static final NOTE_9K_UP:Int = 12;
	public static final NOTE_9K_RIGHT:Int = 13;
	public static final NOTE_9K_CENTER:Int = 14;
	public static final NOTE_9K_LEFT_ENEMY:Int = 15;
	public static final NOTE_9K_DOWN_ENEMY:Int = 16;
	public static final NOTE_9K_UP_ENEMY:Int = 17;
	public static final NOTE_9K_RIGHT_ENEMY:Int = 18;
	public static final NOTE_9K_CENTER_ENEMY:Int = 19;

	/**
	 * The note style used in most songs.
	 */
	static final STYLE_NORMAL = 'normal';

	/**
	 * The note style used in Week 6 - vs Senpai.
	 */
	static final STYLE_PIXEL = 'pixel';

	/**
	 * Pixel notes are 6x bigger than their spritesheet.
	 		* Divide by the base game's note scale. We remultiply later.
	 */
	private static final PIXEL_ZOOM = 6 / 0.7;

	/**
	 * I found that notes were rendering a bit to the left by default.
	 * Not sure if this is the correct solution.
	 */
	public static final NOTE_NUDGE = 2;

	/**
	 * From the raw note data, 
	 * @param rawNoteData 
	 * @param allowAltNames Set this to true to allow 
	 *   Set to false when building sprites for custom note types,
	 *   or when fetching character sing animations when the character doesn't
	 *   have separate animations for 9-key.
	 * @return String
	 */
	public static function getDirectionName(rawNoteData:Int, allowAltNames:Bool):String
	{
		if (!allowAltNames)
		{
			// Don't return 'Alt' direction names.
			var baseNoteData = rawNoteData;
			switch (baseNoteData)
			{
				case NOTE_BASE_LEFT | NOTE_9K_LEFT | NOTE_BASE_LEFT_ENEMY | NOTE_9K_LEFT_ENEMY:
					return "Left";
				case NOTE_BASE_DOWN | NOTE_9K_DOWN | NOTE_BASE_DOWN_ENEMY | NOTE_9K_DOWN_ENEMY:
					return "Down";
				case NOTE_BASE_UP | NOTE_9K_UP | NOTE_BASE_UP_ENEMY | NOTE_9K_UP_ENEMY:
					return "Up";
				case NOTE_BASE_RIGHT | NOTE_9K_RIGHT | NOTE_BASE_RIGHT_ENEMY | NOTE_9K_RIGHT_ENEMY:
					return "Right";
				case NOTE_9K_CENTER | NOTE_9K_CENTER_ENEMY:
					return "Up";
				default:
					trace("Couldn't determine what animation to use for this special note!");
					return 'UNKNOWN';
			}
		}
		else
		{
			// This is a base note type. The result might be 'Alt Down' for example.
			switch (rawNoteData)
			{
				case NOTE_BASE_LEFT | NOTE_BASE_LEFT_ENEMY:
					return "Left";
				case NOTE_9K_LEFT | NOTE_9K_LEFT_ENEMY:
					return "Left Alt";
				case NOTE_BASE_DOWN | NOTE_BASE_DOWN_ENEMY:
					return "Down";
				case NOTE_9K_DOWN | NOTE_9K_DOWN_ENEMY:
					return "Down Alt";
				case NOTE_BASE_UP | NOTE_BASE_UP_ENEMY:
					return "Up";
				case NOTE_9K_UP | NOTE_9K_UP_ENEMY:
					return "Up Alt";
				case NOTE_BASE_RIGHT | NOTE_BASE_RIGHT_ENEMY:
					return "Right";
				case NOTE_9K_RIGHT | NOTE_9K_RIGHT_ENEMY:
					return "Right Alt";
				case NOTE_9K_CENTER | NOTE_9K_CENTER_ENEMY:
					return "Center";
				default:
					trace("Couldn't determine what animation to use for this basic note!");
					return 'UNKNOWN';
			}
		}
	}

	public static function loadNoteSprite(instance:FlxSprite, noteStyle:String, noteType:String, noteData:Int, isSustainNote:Bool, strumlineSize:Int):Void
	{
		instance.frames = GraphicsAssets.loadSparrowAtlas('notes/${noteStyle}/${noteType}Note', 'shared', false);

		// Only add the animation for the note we are using.
		var dirName = getDirectionName(noteData, true);
		instance.animation.addByPrefix(dirName + ' Note', dirName + ' Note'); // Normal notes
		instance.animation.addByPrefix(dirName + ' Sustain', dirName + ' Sustain'); // Hold
		instance.animation.addByPrefix(dirName + ' End', dirName + ' End'); // Tails

		var noteScale = NoteUtil.NOTE_GEOMETRY_DATA[strumlineSize][1];
		switch (noteStyle)
		{
			case 'pixel':
				var widthSize = Std.int(PlayState.Stage.curStage.startsWith('school') ? (instance.width * PlayState.PIXEL_ZOOM_FACTOR) : (isSustainNote ? (instance.width * (PlayState.PIXEL_ZOOM_FACTOR
					- 1.5)) : (instance.width * PlayState.PIXEL_ZOOM_FACTOR)) * noteScale);

				instance.setGraphicSize(widthSize);
				instance.updateHitbox();
			// No anti-aliasing.
			default: // STYLE_NORMAL
				instance.setGraphicSize(Std.int(instance.width * noteScale));
				instance.updateHitbox();
				instance.antialiasing = FlxG.save.data.antialiasing;
		}
	}

	public static function buildStrumlines(isPlayer:Bool, yPos:Float, strumlineSize:Int = 4, noteStyle:String = 'normal', optimize:Bool = false):Void
	{
		if (!NoteUtil.STRUMLINE_DIR_NAMES.exists(strumlineSize))
		{
			trace('Could not build strumline! Invalid size ${strumlineSize}');
			return;
		}

		/**
		 * The note directions to display for this strumline.
		 */
		var strumlineDirs = NoteUtil.STRUMLINE_DIR_NAMES[strumlineSize];

		/**
		 * The offset to use for each strumline arrow.
		 * Setting this value too low will cause arrows to overlap somewhat.
		 */
		var strumlineNoteWidth = NoteUtil.NOTE_GEOMETRY_DATA[strumlineSize][0];

		/**
		 * The size multiplier for each strumline arrow.
		 * Setting this value too high will cause arrows to be too big.
		 */
		var noteGraphicScale = NoteUtil.NOTE_GEOMETRY_DATA[strumlineSize][1];

		/**
		 * The offset position of the strumline.
		 * Needs to be different if the strumline has more notes.
		 * Value is inverted for the Dad player's strumline.
		 */
		var strumlinePos = NoteUtil.NOTE_GEOMETRY_DATA[strumlineSize][2];

		// For each note in the strumline...
		for (i in 0...strumlineDirs.length)
		{
			var arrowDir = strumlineDirs[i];

			// Create a new note.
			var babyArrow:StaticArrow = new StaticArrow(0, yPos);

			// The Optimize setting hides everything but the player's notes.
			// No bf or gf, no stage or enemy notes. Disabled if the song is using a modchart.
			if (PlayStateChangeables.Optimize && !isPlayer)
				continue;

			// Load the spritesheet.
			// With my reworked sprite sheets, the animation names are the same.
			babyArrow.frames = GraphicsAssets.loadSparrowAtlas('notes/${noteStyle}/normalNote', 'shared');

			// Add the proper animations to the strumline item.
			babyArrow.animation.addByPrefix('static', arrowDir + ' Strumline');
			babyArrow.animation.addByPrefix('pressed', arrowDir + ' Press', 24, false);
			babyArrow.animation.addByPrefix('confirm', arrowDir + ' Hit', 24, false);

			// Cleanup the graphic.
			switch (noteStyle)
			{
				case STYLE_PIXEL:
					babyArrow.setGraphicSize(Std.int(babyArrow.width * PIXEL_ZOOM * noteGraphicScale));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;
				default: // STYLE_NORMAL
					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * noteGraphicScale));
			}

			// Further setup.
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.alpha = 0;
			babyArrow.ID = i;
			babyArrow.animation.play("static");

			/**
			 * Logic for positioning the arrows.
			 */

			if (isPlayer)
			{
				// Set the base position to the far right side of the screen,
				babyArrow.x = FlxG.width;
				// then move left based on the full strumline size.
				babyArrow.x -= (strumlineNoteWidth * strumlineSize);
				// It ends up a little to far right unless we do this, for some reason.
				babyArrow.x -= strumlineNoteWidth * 0.1;
			}
			else
			{
				// Set base position to the far left side of the screen.
				babyArrow.x = 0;
			}
			// Based on the full size of the strumline,
			// offset to the left if we are the player and to the right left if we are the CPU.
			babyArrow.x += strumlinePos * (isPlayer ? 1 : -1);
			// Move right based on the strumline position.
			babyArrow.x += strumlineNoteWidth * i;

			if (PlayStateChangeables.Optimize)
			{
				// Move the strumline to the CENTER of the screen.
				// TODO: Calculate the proper offset based on screen width and strumsize.
				// babyArrow.x -= 275;
			}

			// In FreePlay, ease the arrows into frame vertically.
			if (!PlayState.isStoryMode())
			{
				babyArrow.y -= 10;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			// Add the graphic to the strumline.
			if (isPlayer)
			{
				PlayState.playerStrums.add(babyArrow);
			}
			else
			{
				PlayState.cpuStrums.add(babyArrow);
			}
			PlayState.strumLineNotes.add(babyArrow);

			PlayState.cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});
			// ERIC: I think this happens to Player arrows too.
			PlayState.playerStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets();
			});
		}
	}

	/**
	 * Get the animation to play when singing this note.
	 * Used by both BF and Dad (and GF during the tutorial).
	 * @param note The note being hit.
	 * @param strumlineSize The length of this song's strumline.
	 *   Not currently used for the logic.
	 * @param allowAltNames Set this to true if the character has special animations for 9-key.
	 * @return Int
	 */
	public static function getSingAnim(note:Note, strumlineSize:Int = 4, allowAltNames = false):String
	{
		// ERIC: Currently, singing alt left/down/up/right notes uses the same animations,
		// and the center note uses the up animation, on both players.
		// Use this code to override that if needed.
		var directionName = getDirectionName(note.rawNoteData, allowAltNames).toUpperCase();
		return 'sing' + directionName;
	}

	/**
	 * Swap this note from a Player note to an Enemy note or vice versa.
	 * @param rawNoteData 
	 * @return Int
	 */
	public static function swapNote(rawNoteData:Int):Int
	{
		var noteOffset = Math.floor(rawNoteData);
		var baseNoteData = rawNoteData % 100;
		return noteOffset + switch (baseNoteData)
		{
			case NOTE_BASE_LEFT | NOTE_BASE_DOWN | NOTE_BASE_UP | NOTE_BASE_RIGHT: (baseNoteData + 4);
			case NOTE_BASE_LEFT_ENEMY | NOTE_BASE_DOWN_ENEMY | NOTE_BASE_UP_ENEMY | NOTE_BASE_RIGHT_ENEMY: (baseNoteData - 4);
			case NOTE_9K_LEFT | NOTE_9K_DOWN | NOTE_9K_UP | NOTE_9K_RIGHT | NOTE_9K_CENTER: (baseNoteData + 5);
			case NOTE_9K_LEFT_ENEMY | NOTE_9K_DOWN_ENEMY | NOTE_9K_UP_ENEMY | NOTE_9K_RIGHT_ENEMY | NOTE_9K_CENTER_ENEMY: (baseNoteData - 5);
			default: baseNoteData;
		}
	}

	private static function getKeyBinds(strumlineSize:Int = 4):Array<String>
	{
		return switch (strumlineSize)
		{
			case 1:
				// ONE KEY
				// 1-key: Center
				[FlxG.save.data.centerBind];
			case 2:
				// UP AND DOWN
				// 2-key: Down/Up
				[FlxG.save.data.downBind, FlxG.save.data.upBind];
			case 3:
				// NO DOWN ARROW
				// 3-key: Left/Up/Right
				[FlxG.save.data.leftBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
			case 4:
				// VANILLA
				// 4-key: Left/Down/Up/Right
				[
					FlxG.save.data.leftBind,
					FlxG.save.data.downBind,
					FlxG.save.data.upBind,
					FlxG.save.data.rightBind
				];
			case 5:
				// VANILLA PLUS SPACE
				// On 5-keys and lower, use Basic keybinds rather than Custom
				// 5-key: Left/Down/Center/Up/Right
				[
					FlxG.save.data.leftBind,
					FlxG.save.data.downBind,
					FlxG.save.data.centerBind,
					FlxG.save.data.upBind,
					FlxG.save.data.rightBind
				];
			case 6:
				// Super Saiyan Shaggy
				// On 6-keys and higher, use Custom keybinds rather than Basic
				// 6-key: Left/Down/Right/Alt Left/Up/Alt Right
				[
					FlxG.save.data.left9KBind,
					FlxG.save.data.down9KBind,
					FlxG.save.data.right9KBind,
					FlxG.save.data.altLeft9KBind,
					FlxG.save.data.altUp9KBind,
					FlxG.save.data.altRight9KBind
				];
			case 7:
				// Super Saiyan Shaggy Plus Space
				// 7-key: Left/Down/Right/Center/Alt Left/Up/Alt Right
				[
					FlxG.save.data.leftBind,
					FlxG.save.data.downBind,
					FlxG.save.data.rightBind,
					FlxG.save.data.centerBind,
					FlxG.save.data.altLeft9KBind,
					FlxG.save.data.altUp9KBind,
					FlxG.save.data.altRight9KBind
				];
			case 8:
				// God Eater Shaggy Minus Space
				// 8-key: Left/Down/Up/Right/Alt Left/Alt Down/Alt Up/Alt Right
				[
					FlxG.save.data.leftBind,
					FlxG.save.data.downBind,
					FlxG.save.data.upBind,
					FlxG.save.data.rightBind,
					FlxG.save.data.altLeft9KBind,
					FlxG.save.data.altDown9KBind,
					FlxG.save.data.altUp9KBind,
					FlxG.save.data.altRight9KBind
				];
			case 9:
				// God Eater Shaggy
				// 9-key: Left/Down/Right/Center/Alt Left/Up/Alt Right
				[
					FlxG.save.data.left9KBind,
					FlxG.save.data.down9KBind,
					FlxG.save.data.up9KBind,
					FlxG.save.data.right9KBind,
					FlxG.save.data.centerBind,
					FlxG.save.data.altLeft9KBind,
					FlxG.save.data.altDown9KBind,
					FlxG.save.data.altUp9KBind,
					FlxG.save.data.altRight9KBind
				];
			default:
				trace('ERROR: Unknown strumlineSize when polling key binds: ' + strumlineSize);
				return [];
		}
	}

	public static final KEYCODE_DOWN = 37;
	public static final KEYCODE_LEFT = 40;
	public static final KEYCODE_UP = 38;
	public static final KEYCODE_RIGHT = 39;

	private static function handleArrowKeys(keyCode:Int, strumlineSize:Int = 4):Int
	{
		switch (strumlineSize)
		{
			// case 1: No arrow support.
			case 2:
				return switch (keyCode)
				{
					case KEYCODE_DOWN: 0;
					case KEYCODE_UP: 1;
					default: -1;
				};
			case 3:
				return switch (keyCode)
				{
					case KEYCODE_LEFT: 0;
					case KEYCODE_UP: 1;
					case KEYCODE_RIGHT: 2;
					default: -1;
				};
			case 4:
				return switch (keyCode)
				{
					case KEYCODE_LEFT: 0;
					case KEYCODE_DOWN: 1;
					case KEYCODE_UP: 2;
					case KEYCODE_RIGHT: 3;
					default: -1;
				};
			case 5:
				return switch (keyCode)
				{
					case KEYCODE_LEFT: 0;
					case KEYCODE_DOWN: 1;
					// CENTER
					case KEYCODE_UP: 3;
					case KEYCODE_RIGHT: 4;
					default: -1;
				};
			// Exclude 6,7,8,9 key.
			default:
				return -1;
		}
	}

	/**
	 * Given a KeyboardEvent and the strumline size for this song,
	 * return what note index was pressed (or released), if any.
	 * @param event Key that was just pressed or released.
	 * @param strumlineSize Song's strumline size.
	 * @return Int Note index pressed.
	 */
	public static function getKeyNoteData(event:KeyboardEvent, strumlineSize:Int = 4):Int
	{
		var arrowResult = handleArrowKeys(event.keyCode, strumlineSize);
		if (arrowResult != -1)
		{
			return arrowResult;
		}

		var key = FlxKey.toStringMap.get(event.keyCode);
		var binds = getKeyBinds(strumlineSize);

		// Check if proper binds were found for this strumline size.
		if (binds.length == 0)
		{
			return -1;
		}
		for (i in 0...binds.length)
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
			{
				// This was the key pressed!
				return i;
			}
		}
		// No result found.
		return -1;
	}

	private static final CHARTER_COLUMN_MAP:Array<Int> = [
		NOTE_BASE_LEFT, NOTE_BASE_DOWN, NOTE_BASE_UP, NOTE_BASE_RIGHT, NOTE_9K_CENTER, NOTE_9K_LEFT, NOTE_9K_DOWN, NOTE_9K_UP, NOTE_9K_RIGHT,
		NOTE_BASE_LEFT_ENEMY, NOTE_BASE_DOWN_ENEMY, NOTE_BASE_UP_ENEMY, NOTE_BASE_RIGHT_ENEMY, NOTE_9K_CENTER_ENEMY, NOTE_9K_LEFT_ENEMY, NOTE_9K_DOWN_ENEMY,
		NOTE_9K_UP_ENEMY, NOTE_9K_RIGHT_ENEMY
	];

	public static function getNoteDataFromCharterColumn(column:Int)
	{
		// Return -1 if value is invalid.
		if (column >= CHARTER_COLUMN_MAP.length)
			return -1;
		return CHARTER_COLUMN_MAP[column];
	}

	/**
	 * Given a strumline size, outputs data on whether each corresponding key in the strumline is held.
	 */
	public static function getKeyControlData(controls:CustomControls, strumlineSize:Int = 4)
	{
		return switch (strumlineSize)
		{
			case 1: [controls.CENTER_9K];
			case 2: [controls.DOWN, controls.UP];
			case 3: [controls.LEFT, controls.UP, controls.RIGHT];
			case 4: [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			case 5: [controls.LEFT, controls.DOWN, controls.CENTER_9K, controls.UP, controls.RIGHT];
			case 6: [
					    controls.LEFT_9K, controls.DOWN_9K,   controls.RIGHT_9K,
					controls.LEFT_ALT_9K,   controls.UP_9K, controls.RIGHT_ALT_9K
				];
			case 7: [
					controls.LEFT_9K,
					controls.DOWN_9K,
					controls.RIGHT_9K,
					controls.CENTER_9K,
					controls.LEFT_ALT_9K,
					controls.UP_9K,
					controls.RIGHT_ALT_9K
				];
			case 8: [
					    controls.LEFT_9K,     controls.DOWN_9K,     controls.UP_9K,   controls.RIGHT_9K,
					controls.LEFT_ALT_9K, controls.DOWN_ALT_9K, controls.UP_ALT_9K, controls.RIGHT_ALT_9K
				];
			case 9: [
					controls.LEFT_9K,
					controls.DOWN_9K,
					controls.UP_9K,
					controls.RIGHT_9K,
					controls.CENTER_9K,
					controls.LEFT_ALT_9K,
					controls.DOWN_ALT_9K,
					controls.UP_ALT_9K,
					controls.RIGHT_ALT_9K
				];
			// Default to a strumline of 4.
			default: getKeyControlData(controls, 4);
		}
	}
}
