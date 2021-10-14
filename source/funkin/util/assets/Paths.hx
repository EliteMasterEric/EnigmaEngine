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
 * Paths.hx
 * Contains simple static utility functions used to retrieve the full path of an asset.
 */
package funkin.util.assets;

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
	/**
	 * The sound extension used on this platform.
	 */
	public static inline var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	/**
	 * Set the current level. Assets will be checked for in this library first,
	 * then fall back to the 'shared' library, then fall back to 'preload'/default.
	 * @param name 
	 */
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
			if (LibraryAssets.assetExists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (LibraryAssets.assetExists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static function getLibraryPath(file:String, library = "preload")
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
	 * Assumes the path is a subpath of the `data/` folder.
	 * Assumes the extension is `json`.
	 */
	public static inline function songMeta(key:String, ?library:String)
	{
		return getPath('data/songs/$key/_meta.json', TEXT, library);
	}

	/**
	 * Retrieve the path of an audio asset in a given `library` with a given `key`.
	 * Assumes the path is a subpath of the `sounds/` folder.
	 * Assumes the extension is `ogg` or `mp3` based on the platform.
	 */
	public static function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	public static inline function musicBank(key:String, ?library:String)
	{
		return getPath('music/$key.bank', BINARY, library);
	}

	public static inline function soundBank(key:String, ?library:String)
	{
		return getPath('sounds/$key.bank', BINARY, library);
	}

	/**
	 * Retrieve a sound file suffixed with a random int from `min` to `max`.
	 * For example, `soundRandom('hello', 1, 3)` might return the full path to `hello3.mp3`.
	 */
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
		var result = 'songs:assets/songs/${song}/Voices.$SOUND_EXT';
		// Return null if the file does not exist.
		return LibraryAssets.soundExists(result) ? result : null;
	}

	public static inline function inst(song:String)
	{
		// Return null if the file does not exist.
		var result = 'songs:assets/songs/${song}/Inst.$SOUND_EXT';
		return LibraryAssets.soundExists(result) ? result : null;
	}

	public static inline function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	public static inline function font(key:String)
	{
		return 'assets/fonts/$key';
	}
}
