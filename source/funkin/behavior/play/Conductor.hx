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
 * Conductor.hx
 * A static class which keeps track of the current position in the song,
 * along with the current BPM.
 */
package funkin.behavior.play;

import funkin.behavior.options.Options.SafeFramesOption;
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
	 * Length of the current song, in milliseconds.
	 * Based not on the length of the audio track, but on the time of the last note.
	 */
	public static var songLength:Float = 0.0;

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
		Conductor.safeFrames = SafeFramesOption.get();
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
