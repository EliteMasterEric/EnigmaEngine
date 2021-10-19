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
 * Highscore.hx
 * Contains static functions to save and load player highscores for songs.
 */
package funkin.behavior.play;

import flixel.FlxG;
import funkin.behavior.play.Difficulty.DifficultyCache;

using StringTools;

class Highscore
{
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();

	public static function saveScore(song:String, score:Int = 0, ?diffId:String = 'normal'):Void
	{
		var daSong:String = formatSong(song, diffId);

		if (!FlxG.save.data.botplay)
		{
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score)
					setScore(daSong, score);
			}
			else
				setScore(daSong, score);
		}
		else
			trace('BotPlay detected. Score saving is disabled.');
	}

	public static function saveCombo(song:String, combo:String, ?diffId:String = 'normal'):Void
	{
		var daSong:String = formatSong(song, diffId);
		var finalCombo:String = combo.split(')')[0].replace('(', '');

		if (!FlxG.save.data.botplay)
		{
			if (songCombos.exists(daSong))
			{
				if (getComboInt(songCombos.get(daSong)) < getComboInt(finalCombo))
					setCombo(daSong, finalCombo);
			}
			else
				setCombo(daSong, finalCombo);
		}
	}

	public static function saveWeekScore(weekId:String = 'unknown', score:Int = 0, ?diffId:String = 'normal'):Void
	{
		if (!FlxG.save.data.botplay)
		{
			var daWeek:String = formatSong(weekId, diffId);

			if (songScores.exists(daWeek))
			{
				if (songScores.get(daWeek) < score)
					setScore(daWeek, score);
			}
			else
				setScore(daWeek, score);
		}
		else
			trace('BotPlay detected. Score saving is disabled.');
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setCombo(song:String, combo:String):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songCombos.set(song, combo);
		FlxG.save.data.songCombos = songCombos;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diffId:String):String
	{
		var diffSuffix = DifficultyCache.getSuffix(diffId);

		return song + diffSuffix;
	}

	static function getComboInt(combo:String):Int
	{
		switch (combo)
		{
			case 'SDCB':
				return 1;
			case 'FC':
				return 2;
			case 'GFC':
				return 3;
			case 'MFC':
				return 4;
			default:
				return 0;
		}
	}

	public static function getScore(song:String, diffId:String):Int
	{
		if (!songScores.exists(formatSong(song, diffId)))
			setScore(formatSong(song, diffId), 0);

		return songScores.get(formatSong(song, diffId));
	}

	public static function getCombo(song:String, diffId:String):String
	{
		if (!songCombos.exists(formatSong(song, diffId)))
			setCombo(formatSong(song, diffId), '');

		return songCombos.get(formatSong(song, diffId));
	}

	public static function getWeekScore(weekId:String, diffId:String):Int
	{
		if (!songScores.exists(formatSong(weekId, diffId)))
			setScore(formatSong(weekId, diffId), 0);

		return songScores.get(formatSong(weekId, diffId));
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
		if (FlxG.save.data.songCombos != null)
		{
			songCombos = FlxG.save.data.songCombos;
		}
	}
}
