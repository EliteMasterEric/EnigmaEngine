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
 * Scoring.hx
 * Utility functions to calculate ratings based on individual note offset,
 * and overall song accuracy. It also handles storing high scores,
 * and, if you're in a song, it'll keep track of your current score and judgements.
 */
package funkin.behavior.play;

import funkin.behavior.options.Options;
import funkin.behavior.options.Options.NPSDisplayOption;
import flixel.FlxG;
import funkin.behavior.EtternaFunctions;
import funkin.behavior.play.Conductor;
import funkin.ui.state.play.PlayState;
import funkin.util.Util;

enum abstract Judgement(String) to String
{
	var Miss = 'miss';
	var Shit = 'shit';
	var Bad = 'bad';
	var Good = 'good';
	var Sick = 'sick';
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
	public static final BAD_ACCURACY = 0.5;
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
	 * Use this for Replays since you know the judgement already.
	 */
	public function addReplayJudgement(js:String)
	{
		switch (js)
		{
			case 'miss':
				miss++;
				currentCombo = 0;
			case 'shit':
				shit++;
				currentCombo = 0;
			case 'bad':
				bad++;
				currentCombo++;
			case 'good':
				good++;
				currentCombo++;
			case 'sick':
				sick++;
				currentCombo++;
		}

		if (currentCombo > highestCombo)
			highestCombo = currentCombo;
	}

	/**
	 * Use this for Anti-Mash since it isn't associated with a note.
	 */
	public function judgeAntiMash()
	{
		miss++;
		currentCombo = 0;
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

	inline function getBaseNotesHit():Float
	{
		return (MISS_ACCURACY * miss) + (SHIT_ACCURACY * shit) + (BAD_ACCURACY * bad) + (GOOD_ACCURACY * good) + (SICK_ACCURACY * sick);
	}

	public inline function getNotesHit():Float
	{
		return WIFE3AccuracyOption.get() ? wifeNotesHit : getBaseNotesHit();
	}

	/**
	 * Returns a value from 0-100%.
	 */
	public inline function getAccuracy():Float
	{
		return Math.max(0, getNotesHit() / totalNotes * 100);
	}

	/**
	 * I made this a piecewise function because decimal accuracy only matters to those who get high numbers.
	 * 0.75243 -> 75%
	 * 0.95866 -> 95.8%
	 * 0.99986 -> 99.986%
	 */
	public inline function getAccuracyStr():String
	{
		return formatAccuracyStr(getAccuracy());
	}

	public static function formatAccuracyStr(value:Float):String
	{
		if (value < 95)
			return Util.truncateFloat(value, 0) + '%';
		else if (value < 98)
			return Util.truncateFloat(value, 1) + '%';
		else
			return Util.truncateFloat(value, 3) + '%';
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
		if (BotPlayOption.get())
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
		if (BotPlayOption.get())
			ranking = "(BOT)";

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
			// Full Combo (100% notes Hit)
			ranking = "(FC)";
		}
		else if (Scoring.currentScore.shit < 10)
		{
			// Single Digit Combo Breaks (< 10 notes Missed)
			ranking = "(SDCB)";
		}
		else
		{
			// Cleared without losing.
			ranking = "(Clear)";
		}

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
	public static function calculateRanking(score:Int, nps:Int, maxNPS:Int, accuracy:Float):String
	{
		var rankingText = '';

		if (NPSDisplayOption.get())
		{
			rankingText += 'NPS: ${nps} (Max ${maxNPS})';
			if (!BotPlayOption.get())
			{
				rankingText += ' | ';
			}
		}

		if (!BotPlayOption.get())
		{
			rankingText += 'Score: $score';

			if (ShowAccuracyOption.get())
			{
				rankingText += ' | Combo Breaks: ${Scoring.currentScore.miss}';
				rankingText += ' | Accuracy: ';
				rankingText += BotPlayOption.get() ? 'N/A' : '${Util.truncateFloat(accuracy, 3)}%';
				rankingText += ' ${generateLetterRank(accuracy)}';
			}
		}

		return rankingText;
	}
}
