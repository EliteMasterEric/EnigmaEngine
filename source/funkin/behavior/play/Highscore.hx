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
 * Highscore.hx
 * Contains static functions to save and load player highscores for songs.
 */
package funkin.behavior.play;

import funkin.data.DifficultyData.DifficultyDataHandler;
import funkin.data.DifficultyData.DifficultyDataHandler;
import funkin.behavior.options.Options;
import flixel.FlxG;

using hx.strings.Strings;

class Highscore
{
	public static var songScores:Map<String, Int> = new Map();
	public static var songCombos:Map<String, String> = new Map();
	public static var songAccuracy:Map<String, Float> = new Map();
	public static var weekScores:Map<String, Int> = new Map();
	public static var weekCombos:Map<String, String> = new Map();
	public static var weekAccuracy:Map<String, Float> = new Map();

	public static function saveScore(song:String, score:Int = 0, ?diffId:String = 'normal'):Void
	{
		if (!BotPlayOption.get())
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
		if (!BotPlayOption.get())
		{
			var daSong:String = formatSong(song, diffId);
			var finalCombo:String = combo.split(')')[0].replaceAll('(', '');
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

	public static function saveAccuracy(song:String, accuracy:Float, ?diffId:String = 'normal'):Void
	{
		if (!BotPlayOption.get())
		{
			var daSong:String = formatSong(song, diffId);
			if (!songAccuracy.exists(daSong) || (songAccuracy.exists(daSong) && songAccuracy.get(daSong) < accuracy))
			{
				setSongAccuracy(daSong, accuracy);
			}
		}
	}

	public static function saveWeekScore(week:String = 'unknown', score:Int = 0, ?diffId:String = 'normal'):Void
	{
		if (!BotPlayOption.get())
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
		if (!BotPlayOption.get())
		{
			var daWeek:String = formatSong(week, diffId);
			var finalCombo:String = combo.split(')')[0].replaceAll('(', '');

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

	public static function saveWeekAccuracy(week:String, accuracy:Float, ?diffId:String = 'normal'):Void
	{
		if (!BotPlayOption.get())
		{
			var daWeek:String = formatSong(week, diffId);

			if (!weekAccuracy.exists(daWeek) || (weekAccuracy.exists(daWeek) && weekAccuracy.get(daWeek) < accuracy))
			{
				setWeekAccuracy(daWeek, accuracy);
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

	static function setSongAccuracy(song:String, accuracy:Float):Void
	{
		songAccuracy.set(song, accuracy);
		FlxG.save.data.songAccuracy = songAccuracy;
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

	static function setWeekAccuracy(week:String, accuracy:Float):Void
	{
		weekAccuracy.set(week, accuracy);
		FlxG.save.data.weekAccuracy = weekAccuracy;
		FlxG.save.flush();
	}

	public static function clearScores()
	{
		for (key in songScores.keys())
		{
			setSongScore(key, 0);
		}

		for (key in songCombos.keys())
		{
			setSongCombo(key, '');
		}

		for (key in songAccuracy.keys())
		{
			setSongAccuracy(key, 0);
		}

		for (key in weekScores.keys())
		{
			setWeekScore(key, 0);
		}

		for (key in weekCombos.keys())
		{
			setWeekCombo(key, '');
		}

		for (key in weekAccuracy.keys())
		{
			setWeekAccuracy(key, 0);
		}

		FlxG.save.flush();
	}

	public static function formatSong(song:String, diffId:String):String
	{
		return '$song${DifficultyDataHandler.fetch(diffId).songSuffix}';
	}

	static function getComboInt(combo:String):Int
	{
		switch (combo)
		{
			case 'SDCB': // Single Digit Combo Breaks
				return 1;
			case 'FC': // Full Clear (Bad Full Clear)
				return 2;
			case 'GFC': // Good Full Clear
				return 3;
			case 'SFC': // Sick Full Clear
				return 4;
			default: // None
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

	public static function getSongAccuracy(song:String, diffId:String):Float
	{
		if (!songAccuracy.exists(formatSong(song, diffId)))
			setSongAccuracy(formatSong(song, diffId), 0);

		return songAccuracy.get(formatSong(song, diffId));
	}

	public static function getWeekScore(week:String, diffId:String):Int
	{
		if (!weekScores.exists(formatSong(week, diffId)))
			setWeekScore(formatSong(week, diffId), 0);

		return weekScores.get(formatSong(week, diffId));
	}

	public static function getWeekAccuracy(week:String, diffId:String):Float
	{
		if (!weekAccuracy.exists(formatSong(week, diffId)))
			setWeekAccuracy(formatSong(week, diffId), 0);

		return weekAccuracy.get(formatSong(week, diffId));
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
		if (FlxG.save.data.songAccuracy != null)
		{
			songAccuracy = FlxG.save.data.songAccuracy;
		}
		if (FlxG.save.data.songCombos != null)
		{
			songCombos = FlxG.save.data.songCombos;
		}
		if (FlxG.save.data.weekScores != null)
		{
			weekScores = FlxG.save.data.weekScores;
		}
		if (FlxG.save.data.weekAccuracy != null)
		{
			weekAccuracy = FlxG.save.data.weekAccuracy;
		}
		if (FlxG.save.data.weekCombos != null)
		{
			weekCombos = FlxG.save.data.weekCombos;
		}
	}
}
