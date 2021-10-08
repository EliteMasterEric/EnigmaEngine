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
 * GraphicsAssets.hx
 * Contains static utility functions used for interacting with graphics,
 * including images and spritesheets.
 */
package funkin.util.assets;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import funkin.behavior.Debug;
import funkin.ui.state.title.Caching;
import funkin.util.assets.Paths;
import openfl.Assets as OpenFlAssets;

using hx.strings.Strings;

class GraphicsAssets
{
	// TODO: Move the graphics cache from ui.title.Caching to here.

	/**
	 * List all the image files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of image files under that path.
	 */
	public static function listImagesInPath(path:String)
	{
		// We need to query OpenFlAssets, not the file system, because of Polymod.
		var imageAssets = OpenFlAssets.list(IMAGE);

		var queryPath = 'images/${path}';

		var results:Array<String> = [];

		for (image in imageAssets)
		{
			// Parse end-to-beginning to support mods.
			var path = image.split('/');
			if (image.indexOf(queryPath) != -1)
			{
				var suffixPos = image.indexOf(queryPath) + queryPath.length;
				results.push(image.substr(suffixPos).replaceAll('.json', ''));
			}
		}

		return results;
	}

	public static function doesImageExist(key:String, ?library:String):Bool
	{
		return OpenFlAssets.exists(Paths.image(key, library), IMAGE);
	}

	/**
	 * For a given key and library for an image, returns the corresponding BitmapData.
	 * Includes handling for cache and modded content.
	 * @param key 
	 * @param library 
	 * @return FlxGraphic
	 */
	public static function loadImage(key:String, ?library:String):FlxGraphic
	{
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

		if (doesImageExist(key, library))
		{
			trace('Loading image ${library}:${key}');
			var bitmap = OpenFlAssets.getBitmapData(Paths.image(key, library));
			return FlxGraphic.fromBitmapData(bitmap);
		}
		else
		{
			Debug.logWarn('Could not find image at $library:$key');
			return null;
		}
	}

	/**
	 * Loads an image, along with a Sparrow v2 spritesheet file with the matching name,
	 * and uses the spritesheet to split the image into a collection of named frames.
	 * @returns An FlxFramesCollection
	 */
	public static function loadSparrowAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		if (isCharacter)
		{
			return FlxAtlasFrames.fromSparrow(loadImage('characters/$key', library), Paths.file('images/characters/$key.xml', library));
		}
		return FlxAtlasFrames.fromSparrow(loadImage(key, library), Paths.file('images/$key.xml', library));
	}

	/**
	 * Loads an image, along with a Packer spritesheet file with the matching name,
	 * and uses the spritesheet to split the image into a collection of named frames.
	 * Senpai in Thorns uses this instead of Sparrow and IDK why.
	 * @returns An FlxFramesCollection
	 */
	public static inline function loadPackerAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		if (isCharacter)
		{
			return FlxAtlasFrames.fromSpriteSheetPacker(loadImage('characters/$key', library), Paths.file('images/characters/$key.txt', library));
		}
		return FlxAtlasFrames.fromSpriteSheetPacker(loadImage(key, library), Paths.file('images/$key.txt', library));
	}
}
