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
 * Scoring.hx
 * Utility functions to calculate ratings based on individual note offset,
 * and overall song accuracy. It also handles storing high scores,
 * and, if you're in a song, it'll keep track of your current score and judgements.
 */
package funkin.behavior.play;

import funkin.behavior.EtternaFunctions;
import funkin.behavior.play.Conductor;
import flixel.FlxG;
import funkin.util.Util;
import funkin.ui.state.play.PlayState;

enum abstract Judgement(String) to String
{
	var Miss; // = 'miss'
	var Shit; // = 'shit'
	var Bad; // = 'bad'
	var Good; // = 'good'
	var Sick; // = 'sick'
}

/**
 * Data structure that represents a user's current score, over a single song or a full week.
 */
class SongScore
{
	// Counts for each judgement.
	public var miss:Int = 0;
	public var shit:Int = 0;
	public var bad:Int = 0;
	public var good:Int = 0;
	public var sick:Int = 0;

	// The highest combo you've gotten during this song or campaign.
	public var highestCombo(default, null):Int = 0;

	public var currentCombo(default, null):Int = 0;

	// The contribution of each judgement to the score.
	public static final MISS_SCORE = -300;
	public static final SHIT_SCORE = -300;
	public static final BAD_SCORE = 0;
	public static final GOOD_SCORE = 200;
	public static final SICK_SCORE = 350;
	// The contribution of each judgement to accuracy if WIFE accuracy is off.
	public static final MISS_ACCURACY = -1.0;
	public static final SHIT_ACCURACY = -1.0;
	public static final BAD_SACCURACY = 0.5;
	public static final GOOD_ACCURACY = 0.75;
	public static final SICK_ACCURACY = 1.0;

	// The speed multiplier of this song.
	var songMultiplier:Float = 1;

	/**
	 * Number of notes hit, multiplied by their WIFE score.
	 */
	var wifeNotesHit:Float = 0;

	var totalNotes:Int = 0;

	public function new(songMulti:Float)
	{
		this.songMultiplier = songMulti;
	}

	/**
	 * Call when you hit a note.
	 * @param noteDiff The difference between the 
	 */
	public function judge(noteDiff:Null<Float>):Judgement
	{
		var j:Judgement = Miss;
		if (noteDiff != null)
		{
			j = Scoring.judgeNote(noteDiff);
			wifeNotesHit += EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		}

		switch (j)
		{
			case Miss:
				miss++;
				currentCombo = 0;
			case Shit:
				shit++;
				currentCombo = 0;
			case Bad:
				bad++;
				currentCombo++;
			case Good:
				good++;
				currentCombo++;
			case Sick:
				sick++;
				currentCombo++;
		}

		if (currentCombo > highestCombo)
			highestCombo = currentCombo;

		return j;
	}

	/**
	 * Call when you miss a note.
	 */
	public function onMiss()
	{
	}

	public function combineScore(that:SongScore)
	{
		this.miss += that.miss;
		this.shit += that.shit;
		this.bad += that.bad;
		this.good += that.good;
		this.sick += that.sick;

		this.wifeNotesHit += that.wifeNotesHit;
		this.totalNotes += that.totalNotes;

		if (that.highestCombo > this.highestCombo)
			this.highestCombo = that.highestCombo;
	}

	/**
	 * The current score. Calculate it as a derived value rather than incrementing it.
	 * Probably would have to rewrite this if you wanted to add a combo multiplier.
	 * (i.e. your fifth SICK in a row is worth more than your first)
	 */
	public function getScore():Int
	{
		var result:Float = (MISS_SCORE * miss) + (SHIT_SCORE * shit) + (BAD_SCORE * bad) + (GOOD_SCORE * good) + (SICK_SCORE * sick);
		result = (songMultiplier > 1) ? getRatesScore(result) : result;
		return Math.round(result);
	}

	function getBaseNotesHit():Float
	{
		return (MISS_ACCURACY * miss) + (SHIT_ACCURACY * shit) + (BAD_SACCURACY * bad) + (GOOD_ACCURACY * good) + (SICK_ACCURACY * sick);
	}

	public function getNotesHit():Float
	{
		return switch (FlxG.save.data.accuracyMod)
		{
			case 1:
				wifeNotesHit;
			case 0:
				getBaseNotesHit();
			default:
				getBaseNotesHit();
		}
	}

	public function getAccuracy():Float
	{
		return Math.max(0, getNotesHit() / totalNotes * 100);
	}

	/**
	 * Based on the `songMultiplier`, calculate the score for this note.
	 * Ported from Kade Engine, I have NO IDEA how this works or how it was designed.
	 * For each +0.05 in the song speed, the score is multiplied by x0.022?
	 * Anyway, getRatesScore(a+b+c) seems to equal score(a)+score(b)+score(c)
	 * so I'll just leave it.
	 * @param baseScore The base value.
	 * @return The result value.
	 */
	function getRatesScore(score:Float):Float
	{
		var rateX:Float = 1;
		var lastScore:Float = score;
		var pr = songMultiplier - 0.05;
		if (pr < 1.00)
			pr = 1;

		while (rateX <= pr)
		{
			if (rateX > pr)
				break;
			lastScore = score + ((lastScore * rateX) * 0.022);
			rateX += 0.05;
		}

		var actualScore = Math.round(score + (Math.floor((lastScore * pr)) * 0.022));

		return actualScore;
	}

	public function getLetterRank()
	{
		var ranking = 'N/A';
		if (FlxG.save.data.botplay)
			ranking = 'BotPlay';

		return ranking;
	}
}

class Scoring
{
	public static var currentScore:SongScore;
	public static var weekScore:SongScore;

	/**
	 * Convert an accuracy into a letter ranking.
	 * Based on the WIFE3 algorithm from Etterna.
	 * @param accuracy A number from 0 to 100.0.
	 */
	public static function generateLetterRank(accuracy:Float) // generate a letter ranking
	{
		var ranking:String = "N/A";
		if (FlxG.save.data.botplay)
			ranking = "BotPlay";

		// Check for full combos.

		if (Scoring.currentScore.shit == 0 && Scoring.currentScore.bad == 0 && Scoring.currentScore.good == 0)
		{
			// Sick Full Combo (100% Sicks)
			ranking = "(SFC)";
		}
		else if (Scoring.currentScore.shit == 0 && Scoring.currentScore.bad == 0 && Scoring.currentScore.good >= 1)
		{
			// Good Full Combo (100% Good or Better, No Misses)
			ranking = "(GFC)";
		}
		else if (Scoring.currentScore.shit == 0)
		{
			//
			ranking = "(FC)";
		}
		else if (Scoring.currentScore.shit < 10) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for (i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch (i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		if (accuracy == 0)
			ranking = "N/A";

		return ranking;
	}

	/**
	 * The timing windows!
	 * This important array is used to determine note judgements.
	 * If you hit the note between 166 and 135 ms off, you get a 'shit' judgement,
	 * less than 45 ms and you get a 'sick' judgement.
	 */
	public static var TIMING_WINDOWS = [166.0, 135.0, 90.0, 45.0];

	/**
	 * Based on the difference between the user input and the note strumtime,
	 * determine the proper judgement.
	 * @param noteDiff The difference.
	 * @return The user's rating for this note.
	 */
	public static function judgeNote(noteDiff:Float):Judgement
	{
		var diff = Math.abs(noteDiff) / (PlayState.songMultiplier >= 1 ? PlayState.songMultiplier : 1);
		for (index in 0...TIMING_WINDOWS.length) // based on 4 timing windows, will break with anything else
		{
			var time = TIMING_WINDOWS[index] * Conductor.timeScale;
			var nextTime = index + 1 > TIMING_WINDOWS.length - 1 ? 0 : TIMING_WINDOWS[index + 1];
			if (diff < time && diff >= nextTime * Conductor.timeScale)
			{
				switch (index)
				{
					case 0: // shit
						return Shit;
					case 1: // bad
						return Bad;
					case 2: // good
						return Good;
					case 3: // sick
						return Sick;
				}
			}
		}
		// return Miss;
		return Good;
	}

	/**
	 * Build the score and ranking display used at the bottom of the screen.
	 * Logic has been reworked to be more maintainable.
	 * @param score 
	 * @param scoreDef 
	 * @param nps 
	 * @param maxNPS 
	 * @param accuracy 
	 * @return String
	 */
	public static function calculateRanking(score:Int, scoreDef:Int, nps:Int, maxNPS:Int, accuracy:Float):String
	{
		var rankingText = '';

		if (FlxG.save.data.npsDisplay)
		{
			rankingText += 'NPS: ${nps} (Max ${maxNPS})';
			if (!FlxG.save.data.botplay)
			{
				rankingText += ' | ';
			}
		}

		if (!FlxG.save.data.botplay)
		{
			rankingText += 'Score: $score';
			if (Conductor.safeFrames != 10)
			{
				rankingText += ' ($scoreDef)';
			}

			if (FlxG.save.data.accuracyDisplay)
			{
				rankingText += ' | Combo Breaks: ${Scoring.currentScore.miss}';
				rankingText += ' | Accuracy: ';
				rankingText += FlxG.save.data.botplay ? 'N/A' : '${Util.truncateFloat(accuracy, 3)}%';
				rankingText += ' ${generateLetterRank(accuracy)}';
			}
		}

		return rankingText;
	}
}
