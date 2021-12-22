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
 * LoadingState.hx
 * A state used for loading screens.
 * On the desktop platform, all libraries are preloaded and this state does nothing.
 * On web platforms, the game waits until a song loads, then uses this state to load graphics from the relevant libraries,
 * including `shared` and `song`.
 */
package funkin.ui.state;

import funkin.util.assets.AudioAssets;
import funkin.behavior.options.Options.AntiAliasingOption;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import funkin.util.assets.Paths;
import funkin.ui.state.play.PlayState;
import haxe.io.Path;
import lime.app.Future;
import lime.app.Promise;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFlAssets;
import funkin.util.assets.GraphicsAssets;

class LoadingState extends MusicBeatState
{
	static inline var MIN_TIME = 1.0;

	var target:FlxState;
	var stopMusic = false;
	var callbacks:MultiCallback;

	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft = false;

	function new(target:FlxState, stopMusic:Bool)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
	}

	override function create()
	{
		logo = new FlxSprite(-150, -100);
		logo.frames = GraphicsAssets.loadSparrowAtlas('logoBumpin');
		logo.antialiasing = AntiAliasingOption.get();
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.animation.play('bump');
		logo.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = GraphicsAssets.loadSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = AntiAliasingOption.get();
		add(gfDance);
		add(logo);

		initSongsManifest().onComplete(function(lib)
		{
			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");
			checkLoadSong(getSongPath());
			checkLoadSong(getVocalPath());
			checkLibrary("shared");
			checkLibrary(PlayState.storyWeek.id);

			var fadeTime = 0.5;
			FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
			new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
		});
	}

	function checkLoadSong(path:String)
	{
		if (!OpenFlAssets.cache.hasSound(path))
		{
			var library = OpenFlAssets.getLibrary("songs");
			final symbolPath = path.split(":").pop();
			var callback = callbacks.add("song:" + path);
			OpenFlAssets.loadSound(path).onComplete(function(_)
			{
				callback();
			});
		}
	}

	function checkLibrary(library:String)
	{
		trace(OpenFlAssets.hasLibrary(library));
		if (OpenFlAssets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
			{
				trace("Missing library: " + library);
			}

			var callback = callbacks.add("library:" + library);
			OpenFlAssets.loadLibrary(library).onComplete(function(_)
			{
				callback();
			});
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logo.animation.play('bump');
		danceLeft = !danceLeft;

		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		#if debug
		if (FlxG.keys.justPressed.SPACE)
			trace('fired: ' + callbacks.getFired() + " unfired:" + callbacks.getUnfired());
		#end
	}

	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			AudioAssets.stopMusic();

		FlxG.switchState(target);
	}

	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.songFile);
	}

	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.songFile);
	}

	public static inline function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		FlxG.switchState(getNextState(target, stopMusic));
	}

	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		Paths.setCurrentLevel("week" + PlayState.storyWeek);
		#if NO_PRELOAD_ALL
		var loaded = isSoundLoaded(getSongPath()) && isSoundLoaded(getVocalPath()) && isLibraryLoaded("shared");

		if (!loaded)
			return new LoadingState(target, stopMusic);
		#end
		if (stopMusic && FlxG.sound.music != null)
			AudioAssets.stopMusic();

		return target;
	}

	#if NO_PRELOAD_ALL
	static function isSoundLoaded(path:String):Bool
	{
		return OpenFlAssets.cache.hasSound(path);
	}

	static function isLibraryLoaded(library:String):Bool
	{
		return OpenFlAssets.getLibrary(library) != null;
	}
	#end

	override function destroy()
	{
		super.destroy();

		callbacks = null;
	}

	static function initSongsManifest()
	{
		// TODO: Hey, wait, does this break PolymodHandler?

		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = OpenFlAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
				promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;

	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();

	public function new(callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}

	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;

				if (logId != null)
					log('fired $id, $numRemaining remaining');

				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}

	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}

	public function getFired()
		return fired.copy();

	public function getUnfired()
		return [for (id in unfired.keys()) id];
}
