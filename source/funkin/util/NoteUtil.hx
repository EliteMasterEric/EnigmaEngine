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
 * NoteUtil.hx
 * Contains static utility functions to handle note offsets and rendering.
 * Useful for handling annoying math with custom notes.
 */
package funkin.util;

import funkin.behavior.Debug;
import funkin.ui.component.play.Note;
import funkin.ui.component.play.StrumlineArrow;
import flixel.FlxG;
import funkin.ui.state.play.PlayState;
import funkin.behavior.play.EnigmaNote;

using hx.strings.Strings;

class NoteUtil
{
	/**
	 * Provides values based on the current strumlineSize:
	 		* [NOTE POSITION, NOTE GRAPHIC SCALE, BASE OFFSET, OPTIMIZE OFFSET]
	 		* - Distance between origin of each note (112 = 160 * 0.7)
	 		* - Size of the note graphic (will have to shrink for larger strumlines)
	 		* - Move over this amount to give space to the edge of the screen.
	 */
	public static final NOTE_GEOMETRY_DATA:Map<Int, Array<Float>> = [
		1 => [160, 1.00, 0],
		2 => [112, 0.70, 0],
		3 => [112, 0.70, 0],
		4 => [112, 0.70, -80], // Base game.
		5 => [112, 0.70, -60], // The fifth note fits fine without scaling.
		6 => [112, 0.60, 0], // Six you need to scale down a bit.
		7 => [88, 0.55, 0],
		8 => [88, 0.55, 0],
		9 => [64, 0.45, 0], // Nine is very cramped.
	];

	static final Z = -1; // Invalid/Unused.

	/**
	 * Maps note data from the chart to an index in the strumline, starting with the CPU.
	 */
	public static final NOTE_DATA_TO_STRUMLINE_MAP:Map<Int, Array<Int>> = [
		// No controls are 9Key
		2 => [Z, 0, 1, Z, Z, 2, 3, Z], // Down/Up.
		3 => [0, Z, 1, 2, 3, Z, 4, 5], // Left/Up/Right
		4 => [0, 1, 2, 3, 4, 5, 6, 7], // Left/Down/Up/Right
		// Some controls are 9Key
		1 => [Z, Z, Z, Z, Z, Z, Z, Z, Z, Z, Z, Z, Z, Z, 0, Z, Z, Z, Z, 1], // Center.
		5 => [0, 1, 3, 4, 5, 6, 8, 9, Z, Z, Z, Z, Z, Z, 2, Z, Z, Z, Z, 7], // Left/Down/Center/Up/Right
		// All controls are 9Key
		6 => [0, 1, 4, 2, 6, 7, 10, 8, Z, Z, 3, Z, Z, 5, Z, 9, Z, Z, 11, Z], // Left/Down/Right ALeft/Up/ARight
		7 => [0, 1, 5, 2, 7, 8, 12, 9, Z, Z, 4, Z, Z, 6, 3, 11, Z, Z, 13, 10], // Left/Down/Right Center ALeft/Up/ARight
		8 => [0, 1, 2, 3, 8, 9, 10, 11, Z, Z, 4, 5, 6, 7, Z, 12, 13, 14, 15, Z], // Left/Down//Up/Right ALeft/ADown/AUp/ARight
		9 => [0, 1, 2, 3, 9, 10, 11, 12, Z, Z, 5, 6, 7, 8, 4, 14, 15, 16, 17, 13], // Copied from vs Shaggy
	];

	/**
	 * Stores which notes to use for the strumline for each strumlineSize value.
	 */
	public static final STRUMLINE_DIR_NAMES:Map<Int, Array<String>> = [
		1 => ["Center"],
		2 => ["Down", "Up"],
		3 => ["Left", "Up", "Right"],
		4 => ["Left", "Down", "Up", "Right"],
		5 => ["Left", "Down", "Center", "Up", "Right"],
		6 => ["Left", "Down", "Right", "Left Alt", "Up", "Right Alt"],
		7 => ["Left", "Down", "Right", "Center", "Left Alt", "Up", "Right Alt"],
		8 => ["Left", "Down", "Up", "Right", "Left Alt", "Down Alt", "Up Alt", "Right Alt"],
		9 => [
			"Left",
			"Down",
			"Up",
			"Right",
			"Center",
			"Left Alt",
			"Down Alt",
			"Up Alt",
			"Right Alt"
		],
	];

	/**
	 * Determine this note is on the player's side of the field.
	 * 
	 * @param rawNoteData The raw note data value (no modulus performed).
	 * @param mustHitSection The mustHitSection value from this note's section from the JSON file.
	 * @return Whether the note needs to be hit by the player.
	 */
	public static function isPlayerNote(rawNoteData:Int, mustHitSection:Bool):Bool
	{
		return switch (rawNoteData)
		{
			// Example, if mustHitSection is true, notes 0/1/2/3 appear on BF's side,
			// but if mustHitSection is false, notes 0/1/2/3 apepar on Dad's side, and 4/5/6/7 appear on BF's side.
			case EnigmaNote.NOTE_BASE_LEFT | EnigmaNote.NOTE_BASE_DOWN | EnigmaNote.NOTE_BASE_UP | EnigmaNote.NOTE_BASE_RIGHT:
				mustHitSection;
			case EnigmaNote.NOTE_9K_LEFT | EnigmaNote.NOTE_9K_DOWN | EnigmaNote.NOTE_9K_UP | EnigmaNote.NOTE_9K_RIGHT | EnigmaNote.NOTE_9K_CENTER:
				mustHitSection;
			case EnigmaNote.NOTE_BASE_LEFT_ENEMY | EnigmaNote.NOTE_BASE_DOWN_ENEMY | EnigmaNote.NOTE_BASE_UP_ENEMY | EnigmaNote.NOTE_BASE_RIGHT_ENEMY:
				!mustHitSection;
			case EnigmaNote.NOTE_9K_LEFT_ENEMY | EnigmaNote.NOTE_9K_DOWN_ENEMY | EnigmaNote.NOTE_9K_UP_ENEMY | EnigmaNote.NOTE_9K_RIGHT_ENEMY | EnigmaNote.NOTE_9K_CENTER_ENEMY:
				!mustHitSection;
			default:
				mustHitSection;
		}
	}

	/**
	 * Whether this note's strumline data is valid for this song. Throw an error if it returns false.
	 * @param rawNoteData 
	 * @param strumlineSize 
	 * @return Bool
	 */
	public static function isValidNoteData(rawNoteData:Int, strumlineSize:Int = 4):Bool
	{
		return NOTE_DATA_TO_STRUMLINE_MAP[strumlineSize][getStrumlineIndex(rawNoteData, strumlineSize, false)] != -1;
	}

	public static inline function fetchStrumlineSize()
	{
		return PlayState.SONG != null ? PlayState.SONG.strumlineSize : null;
	}

	/**
	 * Fetch a "corrected" note ID that matches its order in the strumline.
	 * For example, in 5-note, left returns 0, center returns 2, and right returns 4 (rather than 3).
	 * @return Int
	 */
	public static function getStrumlineIndex(noteData:Int, strumlineSize:Int = 4, mustHitNote:Bool = false):Int
	{
		// If mustHitNote is false, ids 0-3 correspond to the CPU strumline, not ours.
		// We have to swap those notes around.
		// Only applies to IDs 0-7, note IDs don't switch sides based on mustHitNote for 9K songs.
		if (!mustHitNote)
			noteData = EnigmaNote.swapNote(noteData);
		var result = NOTE_DATA_TO_STRUMLINE_MAP[strumlineSize][noteData];
		return result;
	}

	/**
	 * Get the base width of a full-size note, in pixels.
	 * Based on the current strumline size.
	 */
	public static function getNoteWidth()
	{
		return NoteUtil.NOTE_GEOMETRY_DATA[NoteUtil.fetchStrumlineSize()][0];
	}

	/**
	 * From a note's direction and the song's strumline size,
	 * get the distance to offset by, in pixels.
	 * @param rawNoteData 
	 * @param strumlineSize 
	 */
	public static function positionNote(note:Note, strumline:Array<StrumlineArrow>)
	{
		var strumlineNote = strumline[note.noteData];

		if (strumlineNote == null)
		{
			Debug.logError('Could not get parent strumline note when positioning note: ${note.noteData}');
		}

		// Visibility should match. Used by modcharts.
		note.visible = strumlineNote.visible;
		note.alpha = strumlineNote.alpha;
		// Angle of the note should match. Defined by modcharts.
		note.modAngle = strumlineNote.modAngle;

		// Position of the note should line up.
		note.x = strumlineNote.x;

		// Recenter sustain notes relative to their parent.
		if (note.isSustainNote)
		{
			note.x += note.parent.width / 2;
			note.x -= note.width / 2;
			//			switch (note.noteStyle)
			//			{
			//				case 'pixel':
			//					note.x += 9;
			//				default:
			//					note.x += 20;
			//			}
		}
	}
}
