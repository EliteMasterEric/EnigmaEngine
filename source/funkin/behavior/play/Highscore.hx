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
	public static var weekScores:Map<String, Int> = new Map();
	public static var weekCombos:Map<String, String> = new Map();

	public static function saveScore(song:String, score:Int = 0, ?diffId:String = 'normal'):Void
	{
		if (!FlxG.save.data.botplay)
		{
			var daSong:String = formatSong(song, diffId);
			if (songScores.exists(daSong))
			{
				if (songScores.get(daSong) < score)
				{
					setSongScore(daSong, score);
				}
			}
			else
			{
				setSongScore(daSong, score);
			}
		}
		else
		{
			trace('BotPlay detected. Score saving is disabled.');
		}
	}

	public static function saveCombo(song:String, combo:String, ?diffId:String = 'normal'):Void
	{
		if (!FlxG.save.data.botplay)
		{
			var daSong:String = formatSong(song, diffId);
			var finalCombo:String = combo.split(')')[0].replace('(', '');
			if (songCombos.exists(daSong))
			{
				if (getComboInt(songCombos.get(daSong)) < getComboInt(finalCombo))
				{
					setSongCombo(daSong, finalCombo);
				}
			}
			else
			{
				setSongCombo(daSong, finalCombo);
			}
		}
	}

	public static function saveWeekScore(week:String = 'unknown', score:Int = 0, ?diffId:String = 'normal'):Void
	{
		if (!FlxG.save.data.botplay)
		{
			var daWeek:String = formatSong(week, diffId);

			if (weekScores.exists(daWeek))
			{
				if (weekScores.get(daWeek) < score)
					setWeekScore(daWeek, score);
			}
			else
				setWeekScore(daWeek, score);
		}
		else
			trace('BotPlay detected. Score saving is disabled.');
	}

	public static function saveWeekCombo(week:String, combo:String, ?diffId:String = 'normal'):Void
	{
		if (!FlxG.save.data.botplay)
		{
			var daWeek:String = formatSong(week, diffId);
			var finalCombo:String = combo.split(')')[0].replace('(', '');

			if (weekCombos.exists(daWeek))
			{
				if (getComboInt(songCombos.get(daWeek)) < getComboInt(finalCombo))
					setSongCombo(daWeek, finalCombo);
			}
			else
			{
				setSongCombo(daWeek, finalCombo);
			}
		}
	}

	static function setSongScore(song:String, score:Int):Void
	{
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setSongCombo(song:String, combo:String):Void
	{
		songCombos.set(song, combo);
		FlxG.save.data.songCombos = songCombos;
		FlxG.save.flush();
	}

	static function setWeekScore(week:String, score:Int):Void
	{
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setWeekCombo(week:String, combo:String):Void
	{
		weekCombos.set(week, combo);
		FlxG.save.data.weekCombos = weekCombos;
		FlxG.save.flush();
	}

  public static function clearScores() {
    for (key in FlxG.save.data.songScores) {
      setSongScore(key, 0);
    }

    for (key in FlxG.save.data.songCombos) {
      setSongCombo(key, '');
    }

    for (key in FlxG.save.data.weekScores) {
      setWeekScore(key, 0);
    }

    for (key in FlxG.save.data.weekCombos) {
      setWeekCombo(key, '')
    }

    FlxG.save.flush();
  }

	public static function formatSong(song:String, diffId:String):String
	{
		var diffSuffix = DifficultyCache.getSuffix(diffId);

		return '$song$diffSuffix';
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
			case 'SFC':
				return 4;
			default:
				return 0;
		}
	}

	public static function getSongScore(song:String, diffId:String):Int
	{
		if (!songScores.exists(formatSong(song, diffId)))
			setSongScore(formatSong(song, diffId), 0);

		return songScores.get(formatSong(song, diffId));
	}

	public static function getSongCombo(song:String, diffId:String):String
	{
		if (!songCombos.exists(formatSong(song, diffId)))
			setSongCombo(formatSong(song, diffId), '');

		return songCombos.get(formatSong(song, diffId));
	}

	public static function getWeekScore(week:String, diffId:String):Int
	{
		if (!weekScores.exists(formatSong(week, diffId)))
			setWeekScore(formatSong(week, diffId), 0);

		return weekScores.get(formatSong(week, diffId));
	}

	public static function getWeekCombo(week:String, diffId:String):String
	{
		if (!weekCombos.exists(formatSong(week, diffId)))
			setWeekCombo(formatSong(week, diffId), '');

		return weekCombos.get(formatSong(week, diffId));
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
		if (FlxG.save.data.weekScores != null)
		{
			weekScores = FlxG.save.data.weekScores;
		}
		if (FlxG.save.data.weekCombos != null)
		{
			weekCombos = FlxG.save.data.weekCombos;
		}
	}
}
