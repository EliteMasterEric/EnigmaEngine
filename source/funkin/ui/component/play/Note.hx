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
 * Note.hx
 * A sprite for a note in the Play state.
 * Keeps track of its own distance from the strumline to determine if it is valid to hit,
 * among other important logic.
 */
package funkin.ui.component.play;

import flixel.FlxG;
import flixel.FlxStrip;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import funkin.behavior.options.Options;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.EnigmaNote;
import funkin.behavior.play.PlayStateChangeables;
import funkin.behavior.play.Scoring;
import funkin.ui.state.charting.ChartingState;
import funkin.ui.state.play.PlayState;
import funkin.util.assets.Paths;
import funkin.util.NoteUtil;

using hx.strings.Strings;

class Note extends FlxSprite
{
	/**
	 * The note type, such as `normal` or `hazard`.
	 * Note type should determine the GAMEPLAY of the note,
	 * such as whether it should be hit or avoided,
	 * and what happens if it isn't.
	 */
	public var noteType(default, set):String = "normal";

	function set_noteType(newValue:String):String
	{
		this.noteType = newValue;
		// Changing the note type triggers a re-render.
		buildNoteGraphic();
		return this.noteType;
	}

	/**
	 * The note style, such as `normal` or `pixel`.
	 * Should only determine the APPEARANCE of the note.
	 */
	public var noteStyle(default, set):String = 'normal';

	function set_noteStyle(newValue:String):String
	{
		this.noteStyle = newValue;
		// Changing the note style triggers a re-render.
		buildNoteGraphic();
		return this.noteStyle;
	}

	/**
	 * The corrected note data value.
	 		* Strumline size and mustHit are negated in the calculation.
	 * strumline.members[index] will point to the parent strumline.
	 */
	public var noteData:Int = 0;

	/**
	 * The RAW, unmodified note data value in the charter.
	 * Value jumps around a lot because reasons.
	 */
	public var rawNoteData:Int = 0;

	/**
	 * The time in the song, in seconds, at which the note should be played.
	 */
	public var strumTime:Float = 0;

	/**
	 * The previous sustain note. Refers to itself if it's not a sustain note.
	 */
	public var prevNote:Note;

	/**
	 * If false, the note is on the player's side of the field.
	 * If true, the note is on the CPU's side of the field (it will always be hit, etc).
	 */
	public var isCPUNote:Bool = false;

	/**
	 * Each frame, each note measures how long it'll be until it can be hit.
	 * When the note is within the timing window, this value is true.
	 */
	public var canBeHit:Bool = false;

	/**
	 * Will be true if the strumTime is in the past and outside the timing window.
	 */
	public var tooLateToHit:Bool = false;

	/**
	 * Will be true if the note was hit within the timing window.
	 */
	public var wasGoodHit:Bool = false;

	/**
	 * Flag which is enabled if a Lua Modchart has manually modified the position of this note.
	 */
	public var luaModifiedPos:Bool = false;

	/**
	 * Held notes, known in code as "sustain notes", are made by placing several notes,
	 * one for the head and one for each segment of the tail.
	 * One note is placed every step after the sustain starts,
	 * and reskinned to look like a bar rather than an arrow.
	 * 
	 * If this flag is true, this note is one of the bar/tail segments.
	 */
	public var isSustainNote:Bool = false;

	/**
	 * Flag which is enabled if this note is the parent note of one or more sustain notes.
	 * If this flag is true, the note is a held note that is tied to several child "segment" notes,
	 * and has a non-zero `sustainLength` value.
	 * Should not be enabled if `isSustainNote` is true.
	 */
	public var isParent:Bool = false;

	/**
	 * If this note is a sustain note, this is a reference to the note's parent.
	 */
	public var parent:Note = null;

	/**
	 * If this note is a parent to several sustain notes, this will contain a reference to all its children.
	 */
	public var children:Array<Note> = [];

	/**
	 * If this note is a sustain note, this is the index of the note in the parent's children[] array.
	 */
	public var childIndex:Int = 0;

	/**
	 * Flag which is disabled if any of the previous notes in this sustain are missed.
	 */
	public var sustainActive:Bool = true;

	/**
	 * The duration this note should be sustained for, in milliseconds.
	 * Should only be set on parent notes.
	 */
	public var sustainLength:Float = 0;

	/**
	 * Flag which is set to true if the note is specified as an alt note in the charter.
	 		* If true, the character will render different when played.
	 		* TODO: Make this able to be a string for more flexiblity.
	 */
	public var isAlt:Bool = false;

	/**
	 * Flag set to true if this note is in the charter.
	 */
	public var inCharter:Bool = false;

	/**
	 * Flag set to true if this note is in the charter,
	 		* and it has been selected by clicking or through the drag selection box.
	 */
	public var charterSelected:Bool = false;

	/**
	 * The current judgement assigned to this note.
	 */
	public var rating:String = "shit";

	/**
	 * The angle set by modcharts.
	 */
	public var modAngle:Float = 0; // The angle set by modcharts

	/**
	 * The angle edited within Note.
	 */
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx

	/**
	 * The original angle of the Note.
	 * Will be 0 in most circumstances but different if Note Quantization is on.
	 */
	public var originAngle:Float = 0; // The angle the OG note of the sus note had (?)

	/**
	 * The Y-offset of this note.
	 */
	public var noteYOffset:Int = 0;

	public var baseStrum:Float = 0;
	public var rStrumTime:Float = 0;

	public var originColor:Int = 0; // The sustain note's original note's color
	public var noteSection:Int = 0;
	public var luaID:Int = 0;

	public var noteCharterObject:FlxSprite;
	public var noteScore:Float = 1;
	public var beat:Float = 0;

	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var quantityColor:Array<Int> = [RED_NOTE, 2, BLUE_NOTE, 2, PURP_NOTE, 2, GREEN_NOTE, 2];
	public var arrowAngles:Array<Int> = [180, 90, 270, 0];

	/**
	 * Instantiate a Note sprite. Also includes logic to determine if it is in range of the strumline.
	 * 
	 * @param strumTime The time in seconds at which this note should appear in the song.
	 * @param noteData The note data (used to determine the direction of the note).
	 * @param prevNote A reference to the note before this in the song.
	 * @param mustPress Whether the current section is on the player's side. (Not related to whether the note is a hazard).
	 * @param sustainNote Whether this note is a held note.
	 * @param inCharter Whether this note is being created for use in `ChartingState`.
	 * @param noteType The type of note this is, such as normal or hazard.
	 */
	public function new(strumTime:Float, rawNoteData:Int, ?prevNote:Note, ?mustPress:Bool = false, ?sustainNote:Bool = false, ?inCharter:Bool = false,
			?noteType:String = "normal")
	{
		// Refactored to only include values required to build the note initially.
		// Values like `isAlt` and `beat` are helpful but should be set later to de-clutter the constructor.

		// Initialize the FlxSprite.
		super();

		// The raw note data is the original value specified by the charter.
		this.rawNoteData = rawNoteData;

		// The note data is the position in the strumline.
		// The utility function accounts for strumline size and what side the note is on.
		noteData = NoteUtil.getStrumlineIndex(rawNoteData, NoteUtil.fetchStrumlineSize(), mustPress);

		// If the strumline is in the first half (the player notes), return false.
		// If the strumline is in the second half (the CPU notes), return true.
		// Use >= because note data is base-0.
		this.isCPUNote = this.noteData >= NoteUtil.fetchStrumlineSize();

		trace('Translated $rawNoteData to $noteData ($strumTime/$mustPress)'); // Previous note is part of the logic used by sustain notes.

		// Set the note type.
		this.noteType = noteType;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		this.inCharter = inCharter;

		isSustainNote = sustainNote;

		// x += 50;
		// Ensure the note is definitely off-screen while initializing.
		y -= 2000;

		if (this.inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}

		if (this.strumTime < 0)
			this.strumTime = 0;

		// If we are in the charter, we will position
		if (!this.inCharter)
			y += FlxG.save.data.offset + PlayState.songOffset;

		// Default if no noteStyle was found in chart
		this.noteStyle = 'normal';

		if (inCharter)
		{
			// We are in the Song Editor tool!
			// Add special handling to get the current note type from there.
			if (ChartingState._song != null)
			{
				this.noteStyle = ChartingState._song.noteStyle;
			}
		}
		else
		{
			// Get the note style from the song.
			if (PlayState.SONG.noteStyle != null)
			{
				this.noteStyle = PlayState.SONG.noteStyle;
			}
			// Else, we default to 'normal'.
		}

		buildNoteGraphic();
	}

	function buildNoteGraphic()
	{
		// All the code that builds a note sprite that was in here has been moved to a different file.
		// That makes it really easy for me to add new notes.
		EnigmaNote.loadNoteSprite(this, this.noteStyle, this.noteType, this.rawNoteData, isSustainNote, NoteUtil.fetchStrumlineSize());

		// Play the proper animation for this note based on its direction.
		animation.play(EnigmaNote.getDirectionName(this.rawNoteData, true) + ' Note');

		// The note's origin color will be checked by its sustain notes
		originColor = this.rawNoteData;

		// TODO: Code for note quantization. Redo this.
		// Choose what direction to use based on the beat the note is on, rather than the direction.
		// Since the note will be in the wrong direction, we have to rotate it to compensate.
		if (FlxG.save.data.stepMania && !isSustainNote && !PlayState.instance.modchartActive)
		{
			var col:Int = 0;

			var beatRow = Math.round(beat * 48);

			// STOLEN ETTERNA CODE (IN 2002)

			if (beatRow % (192 / 4) == 0)
				col = quantityColor[0];
			else if (beatRow % (192 / 8) == 0)
				col = quantityColor[2];
			else if (beatRow % (192 / 12) == 0)
				col = quantityColor[4];
			else if (beatRow % (192 / 16) == 0)
				col = quantityColor[6];
			else if (beatRow % (192 / 24) == 0)
				col = quantityColor[4];
			else if (beatRow % (192 / 32) == 0)
				col = quantityColor[4];

			animation.play(EnigmaNote.getDirectionName(col, true) + ' Note');
			localAngle -= arrowAngles[col];
			localAngle += arrowAngles[noteData];
			originAngle = localAngle;
			originColor = col;
		}

		// ERIC: TODO Figure out what this fixes/breaks.
		// if (DownscrollOption.get() && this.isSustainNote)
		// 	flipY = true;

		// If this is a sustain note...
		if (isSustainNote && prevNote != null)
		{
			var stepHeight = -(PlayState.NOTE_TIME_TO_DISTANCE) * Conductor.stepCrochet / PlayState.songMultiplier * PlayState.getScrollSpeed();

			noteYOffset = Math.round(stepHeight);
			noteYOffset += Math.round(NoteUtil.getNoteWidth() * 0.5);

			alpha = 0.6;

			originColor = prevNote.originColor;
			originAngle = prevNote.originAngle;

			// This works both for normal colors and quantization colors
			animation.play(EnigmaNote.getDirectionName(originColor, true) + ' End');

			if (this.inCharter)
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(EnigmaNote.getDirectionName(prevNote.originColor, true) + ' Sustain');
				prevNote.updateHitbox();

				prevNote.scale.y *= (stepHeight) / prevNote.height;
				prevNote.updateHitbox();
			}
			updateHitbox();
		}
		else
		{
			// Ensure the hitbox and offsets are correct. This is to ensure the note is positioned properly.
			updateHitbox();
			centerOffsets();
		}
	}

	/**
	 * Test1
	 * @test Test2
	 * @return Test3
	 */
	public function isEndNote()
	{
		return childIndex == parent.children.length - 1;
	}

	/**
	 * Called each frame of the game.
	 * Checks whether the note is "in range" to be played or not.
	 * @param elapsed 
	 */
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		angle = modAngle + (luaModifiedPos ? 0 : localAngle);

		if (!luaModifiedPos && !sustainActive)
		{
			alpha = 0.3;
		}

		// Do canBeHit calculation.
		// Set to true if this note's strumtime is within the largest timing window.
		if (isCPUNote)
		{
			// Don't calculate for CPU notes.
			canBeHit = false;
		}
		else
		{
			// This code makes DRASTICALLY more sense now that everything is labelled.
			// Creating a named variable is a microscopic performance hit that the compiler should optimize away.

			// Difference between the current time and the strumtime.
			var timeToNote = strumTime - Conductor.songPosition;
			// The farthest timing window, taking into account song speed.
			var timingWindow = Scoring.TIMING_WINDOWS[0] * Conductor.timeScale / PlayState.songMultiplier;

			// The farthest timing window, BEFORE the note.
			var earlyTimingWindow = timingWindow;
			// The farthest timing window, AFTER the note.
			var lateTimingWindow = -1 * timingWindow;

			// Sustain notes have an early hit window of half size.
			if (isSustainNote)
				earlyTimingWindow *= 0.5;

			// Actual logic here.
			if (timeToNote <= earlyTimingWindow)
			{
				if (timeToNote >= 0)
				{
					// We can hit the note (early)!
					this.canBeHit = true;
				}
				else if (timeToNote >= lateTimingWindow)
				{
					// We can hit the note (late)!
					this.canBeHit = true;
				}
				else
				{
					// Too late to hit this note!
					this.canBeHit = false;
					this.tooLateToHit = true;
				}
			}
			else
			{
				// Too early to hit this note!
				this.canBeHit = false;
			}
		}

		// Fade the note if it was too late to hit and we missed it.
		if (tooLateToHit && !wasGoodHit)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	public override function toString()
	{
		// If a number, it's the parent. If true, it's the child.
		var sustain:String = isParent ? '$sustainLength' : isSustainNote ? 'true' : 'false';
		return '(Note | noteData:$noteData | rawNoteData:$rawNoteData | strumTime:$strumTime | cpu:$isCPUNote | sustain:$sustain )';
	}
}
