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
 * Conductor.hx
 * A static class which keeps track of the current position in the song,
 * along with the current BPM.
 */
package funkin.behavior.play;

import flixel.FlxG;
import funkin.behavior.play.Song.SongData;

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	/**
	 * Current position in the current song, in milliseconds.
	 */
  public static var songPosition:Float = 0.0;
  /**
   * The beats per minute of the current song at the current time.
   * Needs to remain a Float.
   */
  public static var bpm:Float = 100;
	/**
   * Duration of one beat of the song.
   * One beat in the song happens every `crochet` milliseconds.
   * From Beats per Min to Millis per Beat.
	 */
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
  /**
   * Duration of one step of the song (one fourth of a beat).
   * One step in the song happens every `stepCrochet` milliseconds.
	 */
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds

  
	public static var lastSongPos:Float;
	public static var offset:Float = 0;



	public static var rawPosition:Float;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000); // is calculated in create(), is safeFrames in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / Scoring.TIMING_WINDOWS[0];

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public function new()
	{
	}

	public static function recalculateTimings()
	{
		Conductor.safeFrames = FlxG.save.data.frames;
		Conductor.safeZoneOffset = Math.floor((Conductor.safeFrames / 60) * 1000);
		Conductor.timeScale = Conductor.safeZoneOffset / Scoring.TIMING_WINDOWS[0];
	}

	public static function mapBPMChanges(song:SongData)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Float, ?recalcLength = true)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}
