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
 * CachingState.hx
 * On platforms where pre-caching of assets is performed,
 * this state displays the initial loading screen.
 */
package funkin.ui.state.title;

import funkin.data.WeekData.WeekDataHandler;
import funkin.data.CharacterData;
import funkin.data.DifficultyData;
import flixel.math.FlxMath;
import funkin.behavior.options.Options.CharacterPreloadOption;
import funkin.behavior.options.Options.StagePreloadOption;
import funkin.behavior.options.Options.AntiAliasingOption;
import funkin.ui.component.play.character.OldCharacter;
import funkin.ui.component.play.character.CharacterFactory;
import funkin.util.assets.LibraryAssets;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;
import funkin.util.assets.AudioAssets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.util.assets.Paths;
import funkin.util.assets.GraphicsAssets;
import funkin.behavior.options.PlayerSettings;
import funkin.util.WindowUtil;
import funkin.behavior.SaveData;
import funkin.ui.component.Cursor;
import funkin.util.concurrency.TaskWorker;
import funkin.util.concurrency.ThreadUtil;
import funkin.util.Util;
import funkin.util.assets.SongAssets;
import haxe.Exception;
import lime.app.Application;
import openfl.display.BitmapData;
import openfl.utils.Assets as OpenFlAssets;
#if FEATURE_DISCORD
import funkin.behavior.api.Discord.DiscordClient;
#end
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;

using hx.strings.Strings;

class CachingState extends MusicBeatState
{
	/**
	 * The onscreen text, such as "Loading..."
	 */
	var text:FlxText;

	/**
	 * The engine logo graphic.
	 */
	var gameLogo:FlxSprite;

	/**
	 * A list of images that need to be cached.
	 */
	var toCacheImages:Array<String> = [];

	/**
	 * A list of songs that needs to be cached.
	 */
	var toCacheMusic:Array<String> = [];

	final LOGO_Y_OFFSET = -100;

	final PROGRESS_BAR_Y_OFFSET = 100;
	final PROGRESS_BAR_WIDTH = 400;
	final PROGRESS_BAR_HEIGHT = 60;
	final PROGRESS_BAR_PAD = 4;

	final FADE_DURATION = 3.0;

	var progressDone:Int = 0;
	var progressTotal:Int = 1;

	override function create()
	{
		Debug.logTrace('Initializing CachingState...');

		// Load the save file.
		SaveData.bindSave();

		// Initialize the player settings.
		PlayerSettings.init();

		// Load the player's save data.
		SaveData.initSave();

		// Disable the cursor for this scene.
		Cursor.showCursor(false);

		FlxG.worldBounds.set(0, 0);
		FlxGraphic.defaultPersist = false;

		if (CharacterPreloadOption.get())
		{
			Debug.logTrace("Planning to cache character graphics...");
			// Preload folder. Used for icons.
			for (path in LibraryAssets.listImagesInPath('characters'))
			{
				toCacheImages.push(Paths.image(path));
			}
			// Shared library.
			for (path in LibraryAssets.listImagesInPath('characters', 'shared'))
			{
				toCacheImages.push(Paths.image(path, 'shared'));
			}
		}

		if (StagePreloadOption.get())
		{
			Debug.logTrace("Planning to cache stage graphics...");
			// Shared library.
			for (path in LibraryAssets.listImagesInPath('stages', 'shared'))
			{
				toCacheImages.push(Paths.image(path, 'shared'));
			}
		}

		Debug.logTrace("Planning to cache song audio files...");
		toCacheMusic = SongAssets.listMusicFilesToCache();

		// Game engine logo.
		gameLogo = new FlxSprite(0, 0).loadGraphic(GraphicsAssets.loadImage('logo'));
		gameLogo.alpha = 0;
		gameLogo.setGraphicSize(Std.int(gameLogo.width * 0.6));
		gameLogo.x = FlxG.width / 2 - gameLogo.width / 2;
		gameLogo.y = FlxG.height / 2 - gameLogo.height / 2 + LOGO_Y_OFFSET;
		gameLogo.antialiasing = AntiAliasingOption.get();
		add(gameLogo);

		// Loading text.
		text = new FlxText(0, FlxG.height / 2 + 300, FlxG.width, "Loading...");
		text.alpha = 1;
		text.size = 34;
		text.y = FlxG.height / 2 + 130;
		text.alignment = FlxTextAlign.CENTER;
		add(text);

		var progressBar = new FlxBar(0, 0, FlxBarFillDirection.LEFT_TO_RIGHT, PROGRESS_BAR_WIDTH, PROGRESS_BAR_HEIGHT, null, "progressDone", 0, progressTotal);
		progressBar.x = FlxG.width / 2 - progressBar.width / 2;
		progressBar.y = text.y + PROGRESS_BAR_Y_OFFSET;
		progressBar.color = FlxColor.RED;
		add(progressBar);

		var progressBarBg = new FlxSprite(0,
			0).makeGraphic(PROGRESS_BAR_WIDTH + (2 * PROGRESS_BAR_PAD), PROGRESS_BAR_HEIGHT + (2 * PROGRESS_BAR_PAD), FlxColor.WHITE);
		progressBarBg.x = progressBar.x - PROGRESS_BAR_PAD;
		progressBarBg.y = progressBar.y - PROGRESS_BAR_PAD;

		Debug.logTrace('Begin caching...');
		cacheSync();
		// We need to do this in a separate thread, to allow the UI thread to run.
		ThreadUtil.doInBackground(cache);

		super.create();
	}

	// All these variables and logic are tied to making the loading text animate.
	var loadingDone:Bool = false;
	var textPrefix:String = "Loading";
	var textSuffix:String = "";
	var dotCount:Int = 3;
	var dotElapsed:Float = 0;
	final LOADING_COOLDOWN = 600;

	override function update(elapsed)
	{
		super.update(elapsed);

		// Fade the engine logo in over 3 seconds.
		gameLogo.alpha = FlxMath.lerp(0.1, 1, gameLogo.alpha + (elapsed / FADE_DURATION));

		// Update the text every 0.5 seconds, animating the numer of dots.
		dotElapsed += elapsed;

		if (loadingDone)
		{
			this.text.text = 'Loading complete!';
		}
		else
		{
			if (dotElapsed > 0.5 && !loadingDone)
			{
				dotCount++;
				if (dotCount > 3)
					dotCount = 1;

				dotElapsed = 0;
			}
			this.text.text = textPrefix + ".".repeat(dotCount) + textSuffix;
		}
	}

	function cache()
	{
		Debug.logTrace("Cache thread initialized.");

		Debug.logTrace('Caching graphics...');
		textPrefix = 'Loading graphics';
		textSuffix = ' (0/${toCacheImages.length})';
		progressTotal = toCacheImages.length;
		for (index in 0...toCacheImages.length)
		{
			var path = toCacheImages[index];

			if (!OpenFlAssets.exists(path))
			{
				Debug.logWarn('  HEY, what gives? Graphic ($path) does not exist.');
				continue;
			}
			Debug.logTrace('Caching graphic ($path)...');
			var data = OpenFlAssets.getBitmapData(path, true);
			var graph = FlxGraphic.fromBitmapData(data);
			GraphicsAssets.cacheImage(path, graph);

			textSuffix = ' ($index/${toCacheImages.length})';
			progressDone = index;
		}

		Debug.logTrace('Caching songs...');
		textPrefix = 'Loading songs';
		textSuffix = ' (0/${toCacheMusic.length})';
		progressTotal = toCacheMusic.length;
		for (index in 0...toCacheMusic.length)
		{
			var songName = toCacheMusic[index];

			Debug.logTrace('Caching song ($songName)...');
			var inst = Paths.inst(songName);
			if (LibraryAssets.soundExists(inst))
			{
				// Audio caching is handled by Flixel.
				FlxG.sound.cache(inst);
				Debug.logTrace('  Cached inst for song ($songName');
			}

			var voices = Paths.voices(songName);
			if (LibraryAssets.soundExists(voices))
			{
				// Audio caching is handled by Flixel.
				FlxG.sound.cache(voices);
				Debug.logTrace('  Cached voices for song ($songName)');
			}

			textSuffix = ' ($index/${toCacheMusic.length})';
			progressDone = index;
		}

		Debug.logTrace('Caching weeks...');
		textPrefix = 'Loading weeks';
		WeekDataHandler.cacheWithProgress(function(weekDone:Int, weekTotal:Int)
		{
			Debug.logTrace('Caching week data ($weekDone/$weekTotal)...');
			textSuffix = ' ($weekDone/$weekTotal)';
			progressDone = weekDone;
			progressTotal = weekTotal;
		});

		// Debug.logTrace('Caching difficulties...');
		// textPrefix = 'Loading difficulties';
		// textSuffix = '';
		// DifficultyDataHandler.cacheSync();

		// Debug.logTrace('Caching characters...');
		// CharacterDataHandler.cacheWithProgress(function(charDone, charTotal)
		// {
		// 	Debug.logTrace('Caching character data ($charDone/$charTotal)...');
		//
		// 	textSuffix = ' ($charDone/${charTotal})';
		// 	progressDone = charDone;
		// 	progressTotal = charTotal;
		// });

		Debug.logTrace("Finished caching.");

		loadingDone = true;

		TaskWorker.performTaskWithDelay(moveToTitle, LOADING_COOLDOWN);
	}

	function cacheSync()
	{
		// Something is buggy with one or both of these loading functions.
	}

	function moveToTitle()
	{
		FlxG.switchState(new TitleState());
	}
}
#end
