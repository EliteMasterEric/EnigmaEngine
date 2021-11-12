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
 * ResultsScreen.hx
 * The substate which overlays the screen at the end of a song,
 * to provide detailed stats on the player's performance.
 */
package funkin.ui.state.play;

import funkin.behavior.play.Scoring;
import funkin.ui.audio.MainMenuMusic;
import funkin.util.Util;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxInput;
import flixel.input.FlxKeyManager;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import funkin.util.assets.Paths;
import funkin.behavior.options.CustomControls;
import funkin.behavior.options.Options;
import funkin.behavior.options.PlayerSettings;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.Highscore;
import funkin.ui.component.OFLSprite;
import funkin.ui.component.play.HitGraph;
import funkin.ui.state.menu.FreeplayState;
import funkin.ui.state.menu.MainMenuState;
import funkin.util.Util;
import funkin.util.Util;
import haxe.Exception;
import lime.app.Application;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

using hx.strings.Strings;
using hx.strings.Strings;

class ResultsSubState extends FlxSubState
{
	public var headerText:FlxText;
	public var fullBackground:FlxSprite;

	public var graphBackground:FlxSprite;
	public var hitGraph:HitGraph;
	public var hitGraphSprite:OFLSprite;

	public var resultsText:FlxText;
	public var continueText:FlxText;
	public var settingsText:FlxText;

	public var music:FlxSound;

	public var graphData:BitmapData;

	public var ranking:String;
	public var accuracy:String;

	override function create()
	{
		fullBackground = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		fullBackground.scrollFactor.set();
		add(fullBackground);

		if (!PlayState.instance.inResults)
		{
			music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
			music.volume = 0;
			music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));
			FlxG.sound.list.add(music);
		}

		fullBackground.alpha = 0;

		headerText = new FlxText(20, -55, 0, PlayState.isStoryMode() ? "Week Cleared!" : "Song Cleared!");
		headerText.size = 34;
		headerText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		headerText.color = FlxColor.WHITE;
		headerText.scrollFactor.set();
		add(headerText);

		var score = PlayState.isStoryMode() ? Scoring.weekScore.getScore() : Scoring.currentScore.getScore();
		var sicks = PlayState.isStoryMode() ? Scoring.weekScore.sick : Scoring.currentScore.sick;
		var goods = PlayState.isStoryMode() ? Scoring.weekScore.good : Scoring.currentScore.good;
		var bads = PlayState.isStoryMode() ? Scoring.weekScore.bad : Scoring.currentScore.bad;
		var shits = PlayState.isStoryMode() ? Scoring.weekScore.shit : Scoring.currentScore.shit;
		var misses = PlayState.isStoryMode() ? Scoring.weekScore.miss : Scoring.currentScore.miss;
		var highestCombo = PlayState.isStoryMode() ? Scoring.weekScore.highestCombo : Scoring.currentScore.highestCombo;
		var accuracy = PlayState.isStoryMode() ? Scoring.weekScore.getAccuracy() : Scoring.currentScore.getAccuracy();

		var resultsTextStr = 'Judgements:\n';

		resultsTextStr += 'Sicks - ${sicks}\n';
		resultsTextStr += 'Goods - ${goods}\n';
		resultsTextStr += 'Bads - ${bads}\n';
		resultsTextStr += 'Shits - ${shits}\n';
		resultsTextStr += 'Misses - ${misses}\n\n';

		// In Story mode, these are the values for the whole week combined.
		resultsTextStr += 'Highest Combo - ${highestCombo}\n';
		resultsTextStr += 'Score - ${score}\n';
		resultsTextStr += 'Accuracy - ${Util.truncateFloat(accuracy, 2)}%\n\n';
		resultsTextStr += '${Scoring.generateLetterRank(accuracy)}\n';
		resultsTextStr += 'Rate: ${PlayState.songMultiplier}x\n\n';

		resultsTextStr += 'F1 - Play again';

		resultsText = new FlxText(20, -75, 0, resultsTextStr);
		resultsText.size = 28;
		resultsText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		resultsText.color = FlxColor.WHITE;
		resultsText.scrollFactor.set();
		add(resultsText);

		continueText = new FlxText(FlxG.width - 475, FlxG.height + 50, 0, 'Press ${CustomControls.gamepad ? 'A' : 'ENTER'} to continue.');
		continueText.size = 28;
		continueText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		continueText.color = FlxColor.WHITE;
		continueText.scrollFactor.set();
		add(continueText);

		graphBackground = new FlxSprite(FlxG.width - 500, 45).makeGraphic(450, 240, FlxColor.BLACK);
		graphBackground.scrollFactor.set();
		graphBackground.alpha = 0;
		add(graphBackground);

		hitGraph = new HitGraph(FlxG.width - 500, 45, 495, 240);
		hitGraph.alpha = 0;
		hitGraphSprite = new OFLSprite(FlxG.width - 510, 45, 460, 240, hitGraph);
		hitGraphSprite.scrollFactor.set();
		hitGraphSprite.alpha = 0;
		add(hitGraphSprite);

		var sickRatio = Util.truncateFloat(sicks / goods, 1);
		var goodRatio = Util.truncateFloat(goods / bads, 1);

		if (sickRatio == Math.POSITIVE_INFINITY)
			sicks = 0;
		if (goodRatio == Math.POSITIVE_INFINITY)
			goods = 0;

		var mean:Float = 0;

		for (i in 0...PlayState.currentReplay.replay.songNotes.length)
		{
			// 0 = time
			// 1 = length
			// 2 = type
			// 3 = diff
			var obj = PlayState.currentReplay.replay.songNotes[i];
			// judgement
			var obj2 = PlayState.currentReplay.replay.songJudgements[i];

			var obj3 = obj[0];

			var diff = obj[3];
			var judge = obj2;
			if (diff != (Scoring.TIMING_WINDOWS[0] * Math.floor((PlayState.currentReplay.replay.safeFrames / 60) * 1000) / Scoring.TIMING_WINDOWS[0]))
				mean += diff;
			if (obj[1] != -1)
				hitGraph.addToHistory(diff / PlayState.songMultiplier, judge, obj3 / PlayState.songMultiplier);
		}

		if (sicks == Math.POSITIVE_INFINITY || sicks == Math.NaN)
			sicks = 0;
		if (goods == Math.POSITIVE_INFINITY || goods == Math.NaN)
			goods = 0;

		hitGraph.update();

		mean = Util.truncateFloat(mean / PlayState.currentReplay.replay.songNotes.length, 2);

		settingsText = new FlxText(20, FlxG.height + 50, 0,
			'SF: ${PlayState.currentReplay.replay.safeFrames} | Ratio (SA/GA): ${Math.round(sickRatio)}:1 ${Math.round(goodRatio)}:1 | Mean: ${mean}ms | Played on ${PlayState.SONG.songName} ${PlayState.songDifficulty.toUpperCamel()}');
		settingsText.size = 16;
		settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		settingsText.color = FlxColor.WHITE;
		settingsText.scrollFactor.set();
		add(settingsText);

		FlxTween.tween(fullBackground, {alpha: 0.5}, 0.5);
		FlxTween.tween(headerText, {y: 20}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(resultsText, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(continueText, {y: FlxG.height - 45}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(settingsText, {y: FlxG.height - 35}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(graphBackground, {alpha: 0.6}, 0.5, {
			onUpdate: function(tween:FlxTween)
			{
				hitGraph.alpha = FlxMath.lerp(0, 1, tween.percent);
				hitGraphSprite.alpha = FlxMath.lerp(0, 1, tween.percent);
			}
		});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	var frames = 0;

	override function update(elapsed:Float)
	{
		if (music != null && music.volume < 0.5)
			music.volume += 0.01 * elapsed;

		// keybinds

		if (PlayerSettings.player1.controls.ACCEPT)
		{
			music.fadeOut(0.3);

			PlayState.replayActive = false;
			PlayState.stageTesting = false;
			PlayState.currentReplay = null;

			// Save your song score.
			Highscore.saveScore(PlayState.SONG.songId, Scoring.currentScore.getScore(), PlayState.songDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()), PlayState.songDifficulty);

			if (PlayState.isStoryMode())
			{
				// Move back to the main menu after completing a story week.
				MainMenuMusic.stopMenuMusic();
				MainMenuMusic.playMenuMusic();
				FlxG.switchState(new MainMenuState());
			}
			else
			{
				// Move back to the freeplay menu after completing a song.
				FlxG.switchState(new FreeplayState());
			}
			PlayState.instance.clean();
		}

		if (FlxG.keys.justPressed.F1 && !PlayState.replayActive)
		{
			PlayState.currentReplay = null;

			PlayState.replayActive = false;
			PlayState.stageTesting = false;

			// Save your song score.
			Highscore.saveScore(PlayState.SONG.songId, Scoring.currentScore.getScore(), PlayState.songDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()), PlayState.songDifficulty);

			if (music != null)
				music.fadeOut(0.3);

			// Yes, hello, I was wondering if you could play that song again.
			// The one that goes Bee-boo-boo-bop, boo-boo-beep.
			PlayState.storyWeek = null;
			LoadingState.loadAndSwitchState(new PlayState());
			PlayState.instance.clean();
		}

		super.update(elapsed);
	}
}
