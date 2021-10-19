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
 * Note.hx
 * A sprite for a note in the Play state.
 * Keeps track of its own distance from the strumline to determine if it is valid to hit,
 * among other important logic.
 */
package funkin.ui.component.play;

import funkin.ui.state.charting.ChartingState;
import funkin.util.NoteUtil;
import funkin.behavior.play.EnigmaNote;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import funkin.util.assets.Paths;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.PlayStateChangeables;
import funkin.ui.state.play.PlayState;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;

	public var charterSelected:Bool = false;

	public var rStrumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var originColor:Int = 0; // The sustain note's original note's color
	public var noteSection:Int = 0;

	public var luaID:Int = 0;

	public var isAlt:Bool = false;

	public var noteCharterObject:FlxSprite;

	public var noteScore:Float = 1;

	public var noteYOff:Int = 0;

	public var beat:Float = 0;

	public var noteType(default, set):String = "normal";

	function set_noteType(newValue:String):String
	{
		this.noteType = newValue;
		// Changing the note style triggers a re-render.
		buildNoteGraphic();
		return this.noteType;
	}

	public var noteStyle(default, set):String = 'normal';

	function set_noteStyle(newValue:String):String
	{
		this.noteStyle = newValue;
		// Changing the note style triggers a re-render.
		buildNoteGraphic();
		return this.noteStyle;
	}

	public var inCharter:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx
	public var originAngle:Float = 0; // The angle the OG note of the sus note had (?)

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var quantityColor:Array<Int> = [RED_NOTE, 2, BLUE_NOTE, 2, PURP_NOTE, 2, GREEN_NOTE, 2];
	public var arrowAngles:Array<Int> = [180, 90, 270, 0];

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	/**
	 * Instantiate a Note sprite. Also includes logic to determine if it is in range of the strumline.
	 * 
	 * @param strumTime The time in seconds at which this note should appear in the song.
	 * @param noteData The note data (used to determine the direction of the note).
	 * @param prevNote A reference to the note before this in the song.
	 * @param sustainNote Whether this note is a held note.
	 * @param inCharter Whether this note is being created for use in `ChartingState`.
	 */
	public function new(strumTime:Float, rawNoteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, ?noteType:String = "normal")
	{
		// Refactored to only include values required to build the note initially.
		// Values like `isAlt` and `beat` are helpful but should be set later to de-clutter the constructor.

		super();

		// Previous note is part of the logic used by sustain notes.
		if (prevNote == null)
			prevNote = this;

		this.noteType = noteType;

		this.prevNote = prevNote;
		this.inCharter = inCharter;

		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
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

		if (!this.inCharter)
			y += FlxG.save.data.offset + PlayState.songOffset;

		this.rawNoteData = rawNoteData;
		this.noteData = NoteUtil.getStrumlineIndex(rawNoteData, NoteUtil.fetchStrumlineSize());

		// defaults if no noteStyle was found in chart
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

		x += NoteUtil.getNoteOffset(this.noteData, NoteUtil.fetchStrumlineSize());

		animation.play(EnigmaNote.getDirectionName(this.rawNoteData, true) + ' Note');
		originColor = this.rawNoteData; // The note's origin color will be checked by its sustain notes

		if (FlxG.save.data.stepMania && !isSustainNote && !PlayState.instance.executeModchart)
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

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		// then what is this lol
		// BRO IT LITERALLY SAYS IT FLIPS IF ITS A TRAIL AND ITS DOWNSCROLL
		if (FlxG.save.data.downscroll && this.isSustainNote)
			flipY = true;

		var stepHeight = (((0.45 * Conductor.stepCrochet) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1)) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
			2));

		if (isSustainNote && prevNote != null)
		{
			noteYOff = Math.round(-stepHeight + swagWidth * 0.5);

			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			originColor = prevNote.originColor;
			originAngle = prevNote.originAngle;

			// This works both for normal colors and quantization colors
			animation.play(EnigmaNote.getDirectionName(originColor, true) + ' End');
			updateHitbox();

			x -= width / 2;

			if (this.inCharter)
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(EnigmaNote.getDirectionName(prevNote.originColor, true) + ' Sustain');
				prevNote.updateHitbox();

				prevNote.scale.y *= stepHeight / prevNote.height;
				prevNote.updateHitbox();

				if (antialiasing)
					prevNote.scale.y *= 1.0 + (1.0 / prevNote.frameHeight);
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!modifiedByLua)
			angle = modAngle + localAngle;
		else
			angle = modAngle;

		if (!modifiedByLua)
		{
			if (!sustainActive)
			{
				alpha = 0.3;
			}
		}

		if (mustPress)
		{
			if (isSustainNote)
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1) * 0.5))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1)))
					&& strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1))))
					canBeHit = true;
				else
					canBeHit = false;
			}
		}
		else
		{
			canBeHit = false;
		}

		if (tooLate && !wasGoodHit)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
