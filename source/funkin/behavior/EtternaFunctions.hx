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
 * EtternaFunctions.hx
 * Functionality ripped from the Etterna engine for StepMania, including the WIFE3 rating system.
 */
package funkin.behavior;

import funkin.behavior.play.Scoring;
import funkin.behavior.play.Song.SongData;
import funkin.ui.state.play.PlayState;

class EtternaFunctions
{
	// erf constants
	public static var a1 = 0.254829592;
	public static var a2 = -0.284496736;
	public static var a3 = 1.421413741;
	public static var a4 = -1.453152027;
	public static var a5 = 1.061405429;
	public static var p = 0.3275911;

	public static function erf(x:Float):Float
	{
		// Save the sign of x
		var sign = 1;
		if (x < 0)
			sign = -1;
		x = Math.abs(x);

		// A&S formula 7.1.26
		var t = 1.0 / (1.0 + p * x);
		var y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);

		return sign * y;
	}

	/**
	 * Returns the quantity of tap notes in the given song.
	 * @return The number of tap notes in this song.
	 */
	public static function getNotes(?songData:SongData):Int
	{
		if (songData == null)
		{
			songData = PlayState.SONG;
		}
		var notes:Int = 0;
		for (i in 0...songData.notes.length)
		{
			for (ii in 0...songData.notes[i].sectionNotes.length)
			{
				var n = songData.notes[i].sectionNotes[ii];
				if (n[1] <= 0)
					notes++;
			}
		}
		return notes;
	}

	/**
	 * Returns the quantity of hold notes in the given song.
	 * @return The number of hold notes in this song.
	 */
	public static function getHolds(?songData:SongData):Int
	{
		if (songData == null)
		{
			songData = PlayState.SONG;
		}
		var notes:Int = 0;
		for (i in 0...songData.notes.length)
		{
			trace(songData.notes[i]);
			for (ii in 0...songData.notes[i].sectionNotes.length)
			{
				var n = songData.notes[i].sectionNotes[ii];
				trace(n);
				if (n[1] > 0)
					notes++;
			}
		}
		return notes;
	}

	/**
	 * Determine the maximum score possible for this song, based on the number of notes in the song.
	 * @return The maximum possible score.
	 */
	public static function getMapMaxScore():Int
	{
		// TODO: This excludes hold notes and custom note types?
		return (getNotes() * 350);
	}

	/**
	 * Perform WIFE3 calculation for a note diff.
	 */
	public static function wife3(maxms:Float, ts:Float)
	{
		var max_points = 1.0;
		var miss_weight = -5.5;
		var ridic = 5 * ts;
		var max_boo_weight = Scoring.TIMING_WINDOWS[0] * (ts / PlayState.songMultiplier);
		var ts_pow = 0.75;
		var zero = 65 * (Math.pow(ts, ts_pow));
		var power = 2.5;
		var dev = 22.7 * (Math.pow(ts, ts_pow));

		if (maxms <= ridic) // anything below this (judge scaled) threshold is counted as full pts
			return max_points;
		else if (maxms <= zero) // ma/pa region, exponential
			return max_points * erf((zero - maxms) / dev);
		else if (maxms <= max_boo_weight) // cb region, linear
			return (maxms - zero) * miss_weight / (max_boo_weight - zero);
		else
			return miss_weight;
	}
}
