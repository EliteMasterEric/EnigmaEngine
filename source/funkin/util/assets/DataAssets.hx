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
 * DataAssets.hx
 * Contains static utility functions used for interacting with either
 * JSON data or line text files.
 */
package funkin.util.assets;

import funkin.util.assets.Paths;
import funkin.behavior.Debug;
import openfl.Assets as OpenFlAssets;
import tjson.TJSON;

using hx.strings.Strings;

class DataAssets
{
	/**
	 * Given a text file path, load the file, clean it up, and split it into individual lines.
	 * @param path The text file path to load.
	 * @return A list of lines from that file.
	 */
	public static function loadLinesFromFile(path:String):Array<String>
	{
		if (!LibraryAssets.textExists(path))
		{
			Debug.logError('Could not load data from non-existant file ${path}');
			return [];
		}
		var rawText:String = OpenFlAssets.getText(path);
		var result:Array<String> = rawText.trim().split('\n');

		for (i in 0...result.length)
		{
			result[i] = result[i].trim();
		}

		return result;
	}

	/**
	 * List all the data JSON files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of JSON files under that path.
	 */
	public static function listJSONsInPath(path:String)
	{
		// We need to query OpenFlAssets, not the file system, because of Polymod.
		var dataAssets = OpenFlAssets.list(TEXT);

		var queryPath = 'data/${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			// Parse end-to-beginning to support mods.
			var path = data.split('/');
			if (data.indexOf(queryPath) != -1)
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replaceAll('.json', ''));
			}
		}

		return results;
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
}
