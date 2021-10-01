package funkin.assets;

import funkin.behavior.Debug;
import funkin.ui.state.title.Caching;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetType;
import tjson.TJSON;

using StringTools;

class Paths
{
	public static inline var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	public static function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	/**
	 * For a given key and library for an image, returns the corresponding BitmapData.
	 		* We can probably move the cache handling here.
	 * @param key 
	 * @param library 
	 * @return BitmapData
	 */
	public static function loadImage(key:String, ?library:String):FlxGraphic
	{
		var path = image(key, library);

		#if FEATURE_FILESYSTEM
		if (Caching.bitmapData != null)
		{
			if (Caching.bitmapData.exists(key))
			{
				Debug.logTrace('Loading image from bitmap cache: $key');
				// Get data from cache.
				return Caching.bitmapData.get(key);
			}
		}
		#end

		if (OpenFlAssets.exists(path, IMAGE))
		{
			var bitmap = OpenFlAssets.getBitmapData(path);
			return FlxGraphic.fromBitmapData(bitmap);
		}
		else
		{
			Debug.logWarn('Could not find image at path $path');
			return null;
		}
	}

	public static function loadJSON(key:String, ?library:String):Dynamic
	{
		var rawJson:String = null;
		try
		{
			rawJson = OpenFlAssets.getText(Paths.json(key, library)).trim();
		}
		catch (e)
		{
			Debug.logError('AN ERROR OCCURRED trying to read a JSON file (${library}:${key}). It probably does not exist.');
			Debug.logError(e.message);
			return null;
		}

		// Perform cleanup on files that have bad data at the end.
		while (rawJson != null && rawJson.length > 0 && !rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		try
		{
			// Attempt to parse and return the JSON data.
			// Use TJSON, which is much more flexible (allows comments and missing commas).
			return TJSON.parse(rawJson);
		}
		catch (e)
		{
			Debug.logError('AN ERROR OCCURRED parsing a JSON file (${library}:${key}).');
			Debug.logError(e.message);

			// Return null.
			return null;
		}
	}

	public static function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	static inline function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	static inline function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	public static inline function file(file:String, ?library:String, type:AssetType = TEXT)
	{
		return getPath(file, type, library);
	}

	public static inline function lua(key:String, ?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	public static inline function luaImage(key:String, ?library:String)
	{
		return getPath('data/$key.png', IMAGE, library);
	}

	public static inline function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	public static inline function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	/**
	 * Retrieve the path of a JSON asset in a given `library` with a given `key`.
	 * Assumes the path is a subpath of the `data/` folder.
	 * Assumes the extension is `json`.
	 */
	public static inline function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	/**
	 * Retrieve the path of a JSON asset in a given `library` with a given `key`.
	 * Assumes the path is a subpath of the `sounds/` folder.
	 * Assumes the extension is `ogg` or `mp3` based on the platform.
	 */
	public static function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	public static inline function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	public static inline function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	public static inline function voices(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
			case 'm.i.l.f':
				songLowercase = 'milf';
		}
		var result = 'songs:assets/songs/${songLowercase}/Voices.$SOUND_EXT';
		// Return null if the file does not exist.
		return doesSoundAssetExist(result) ? result : null;
	}

	public static inline function inst(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
			case 'm.i.l.f':
				songLowercase = 'milf';
		}
		return 'songs:assets/songs/${songLowercase}/Inst.$SOUND_EXT';
	}

	/**
	 * List all the music files in the `songs` folder, so we can precache them all.
	 */
	public static function listSongsToCache()
	{
		// We need to query OpenFlAssets, not the file system, because of Polymod.
		var soundAssets = OpenFlAssets.list(AssetType.MUSIC).concat(OpenFlAssets.list(AssetType.SOUND));

		// TODO: Maybe rework this to pull from a text file rather than scan the list of assets.
		var songNames = [];

		for (sound in soundAssets)
		{
			// Parse end-to-beginning to support mods.
			var path = sound.split('/');
			path.reverse();

			var fileName = path[0];
			var songName = path[1];

			if (path[2] != 'songs')
				continue;

			// Remove duplicates.
			if (songNames.indexOf(songName) != -1)
				continue;

			songNames.push(songName);
		}

		return songNames;
	}

	/**
	 * List all the data JSON files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of JSON files under that path.
	 */
	public static function listJSONsInPath(path:String)
	{
		// We need to query OpenFlAssets, not the file system, because of Polymod.
		var dataAssets = OpenFlAssets.list(AssetType.TEXT);

		var queryPath = 'data/${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			// Parse end-to-beginning to support mods.
			var path = data.split('/');
			if (data.indexOf(queryPath) != -1)
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replace('.json', ''));
			}
		}

		return results;
	}

	public static function doesSoundAssetExist(path:String)
	{
		if (path == null || path == "")
			return false;
		return OpenFlAssets.exists(path, AssetType.SOUND) || OpenFlAssets.exists(path, AssetType.MUSIC);
	}

	public static inline function doesTextAssetExist(path:String)
	{
		return OpenFlAssets.exists(path, AssetType.TEXT);
	}

	public static inline function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	public static inline function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	public static function getSparrowAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		if (isCharacter)
		{
			return FlxAtlasFrames.fromSparrow(loadImage('characters/$key', library), file('images/characters/$key.xml', library));
		}
		return FlxAtlasFrames.fromSparrow(loadImage(key, library), file('images/$key.xml', library));
	}

	/**
	 * Senpai in Thorns uses this instead of Sparrow and IDK why.
	 */
	public static inline function getPackerAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		if (isCharacter)
		{
			return FlxAtlasFrames.fromSpriteSheetPacker(loadImage('characters/$key', library), file('images/characters/$key.txt', library));
		}
		return FlxAtlasFrames.fromSpriteSheetPacker(loadImage(key, library), file('images/$key.txt', library));
	}
}
