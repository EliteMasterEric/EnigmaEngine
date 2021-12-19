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

import funkin.behavior.options.Options.CharacterPreloadOption;
import funkin.behavior.options.Options.AntiAliasingOption;
import funkin.ui.component.play.Character;
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
import funkin.util.ThreadUtil;
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
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxText;
	var gameLogo:FlxSprite;

	var images:Array<String> = [];
	var music:Array<String> = [];
	var charts:Array<String> = [];

	override function create()
	{
		// Load the save file.
		SaveData.bindSave();

		// Initialize the player settings.
		PlayerSettings.init();

		// Load the list of characters for the Charter.
		Character.initCharacterList();

		// Load the player's save data.
		SaveData.initSave();

		Cursor.showCursor(false);

		FlxG.worldBounds.set(0, 0);

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300, 0, "Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		text.alpha = 1;

		gameLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(GraphicsAssets.loadImage('logo'));
		gameLogo.x -= gameLogo.width / 2;
		gameLogo.y -= gameLogo.height / 2 + 100;
		text.y -= gameLogo.height / 2 - 125;
		text.x -= 170;
		gameLogo.setGraphicSize(Std.int(gameLogo.width * 0.6));
		if (AntiAliasingOption.get() != null)
			gameLogo.antialiasing = AntiAliasingOption.get();
		else
			gameLogo.antialiasing = true;

		gameLogo.alpha = 0;

		FlxGraphic.defaultPersist = CharacterPreloadOption.get();

		#if FEATURE_FILESYSTEM
		Debug.logTrace("Planning to cache graphics...");
		if (CharacterPreloadOption.get())
		{
			Debug.logTrace("Planning to cache character graphics...");
			images = GraphicsAssets.listImageFilesToCache(['characters']);
		}

		Debug.logTrace("Planning to cache music files...");

		music = SongAssets.listMusicFilesToCache();
		#end

		toBeDone = Lambda.count(images) + Lambda.count(music);

		if (toBeDone == 0)
		{
			Debug.logTrace("WARNING: No files to cache.");
			done = toBeDone;
			loaded = true;
		}
		else
		{
			var bar = new FlxBar(10, FlxG.height - 50, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 40, null, "done", 0, toBeDone);
			bar.color = FlxColor.PURPLE;
			add(bar);
		}

		add(gameLogo);
		add(text);

		Debug.logTrace('Begin caching..');

		#if FEATURE_MULTITHREADING
		ThreadUtil.doInBackground(cache);
		#end

		Debug.logTrace('Created cache thread.');
		super.create();
	}

	var calledDone = false;

	override function update(elapsed)
	{
		super.update(elapsed);

		// Update the loading text. This should be done in the main UI thread.
		var alpha = Util.truncateFloat(toBeDone == 0 ? 0.5 : (done / toBeDone * 100), 2) / 100;
		gameLogo.alpha = alpha;
		text.text = "Loading... (" + done + "/" + toBeDone + ")";
	}

	function cache()
	{
		#if FEATURE_FILESYSTEM
		Debug.logTrace("Cache thread initialized. Caching " + toBeDone + " items...");

		for (i in images)
		{
			var replaced = i.replaceAll(".png", "");

			var imagePath = Paths.image(replaced, 'shared');
			Debug.logTrace('Caching character graphic $i ($imagePath)...');
			var data = OpenFlAssets.getBitmapData(imagePath);
			var graph = FlxGraphic.fromBitmapData(data);

			GraphicsAssets.cacheImage(replaced, graph);
			done++;
		}

		for (i in music)
		{
			Debug.logTrace('Caching song "$i"...');
			var inst = Paths.inst(i);
			if (LibraryAssets.soundExists(inst))
			{
				// Audio caching is handled by Flixel.
				FlxG.sound.cache(inst);
				Debug.logTrace('  Cached inst for song "$i"');
			}

			var voices = Paths.voices(i);
			if (LibraryAssets.soundExists(voices))
			{
				// Audio caching is handled by Flixel.
				FlxG.sound.cache(voices);
				Debug.logTrace('  Cached voices for song "$i"');
			}

			done++;
		}

		Debug.logTrace("Finished caching...");

		loaded = true;
		#end

		// If the file system is supported, move to the title state after caching is done.
		// If the file system isn't supported, move to the title state immediately.
		FlxG.switchState(new TitleState());
	}
}
#end
