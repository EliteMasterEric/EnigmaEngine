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
 * CharacterData.hx
 * A type definition for difficulty data stored in the TXT asset file.
 * Also includes a class of static utilities for managing and caching data.
 */
package funkin.data;

import funkin.util.concurrency.TaskWorker;
import funkin.util.assets.DataAssets;
import flixel.graphics.FlxGraphic;
import funkin.util.assets.Paths;
import funkin.util.assets.GraphicsAssets;

class DifficultyDataHandler
{
	/**
	 * The ID of the default difficulty to use.
	 * If this ID does not exist (due to the song not having it or the difficulty being removed),
	 * the first available difficulty will be used instead.
	 */
	public static final defaultDifficulty = "normal";

	/**
	 * Contains all the difficulty data elements.
	 * Caching this during the title screen saves a lot of time.
	 */
	static var cache(default, null):Map<String, DifficultyData> = new Map<String, DifficultyData>();

	/**
	 * Contains a list of all valid difficulty IDs.
	 */
	public static var difficultyIds(default, null):Array<String> = [];

	/**
	 * Load the character data directly from JSON.
	 * @param line A line from the `difficulties.txt` file.
	 */
	static function cacheDifficulty(line:String):Void
	{
		// Load the data from the text file
		var lineItems = line.split(":");

		var difficultyId = lineItems[0];
		var difficultySuffix = lineItems[1];

		var difficultyData = new DifficultyData(difficultyId, difficultySuffix);

		difficultyIds.push(difficultyId);
		cache.set(difficultyId, difficultyData);
	}

	/**
	 * Gets all character IDs and loads all their data.
	 * 
	 * Call this early in the program to store all character JSON in memory,
	 * improving load times while neglegibly increasing memory usage.
	 */
	public static function cacheSync()
	{
		var difficultyLines:Array<String> = DataAssets.loadLinesFromFile(Paths.txt("data/difficulties"));

		for (line in difficultyLines)
		{
			cacheDifficulty(line);
		}

		Debug.logInfo('Loaded ${difficultyIds.length} difficulties into cache.');
	}

	/**
	 * Starts a thread to load all character data.
	 */
	public static function cacheAsync()
	{
		TaskWorker.performTask(cacheSync);
	}

	/**
	 * Attempt to load the character directly from the cache.
	 * If the character data isn't cached, read it synchronously from the data assets.
	 * If data isn't there, return null.
	 * @param charId 
	 */
	public static function fetch(difficulty:String)
	{
		if (cache.exists(difficulty))
		{
			return cache.get(difficulty);
		}
		else
		{
			Debug.logWarn('Could not find difficulty data for ${difficulty}, reloading cache...');

			clearCache();
			cacheSync();

			if (cache.exists(difficulty))
			{
				return cache.get(difficulty);
			}
			else
			{
				Debug.logWarn('Could not load difficulty data for ${difficulty}');
				return null;
			}
		}
	}

	public static function getByIndex(index:Int):DifficultyData
	{
		return cache.get(difficultyIds[index]);
	}

	public static function indexOfId(id:String):Int
	{
		return difficultyIds.indexOf(id);
	}

	public static function indexOf(difficulty:DifficultyData):Int
	{
		return difficultyIds.indexOf(difficulty.id);
	}

	public static function getFallback():DifficultyData
	{
		var result = cache.get(defaultDifficulty);
		return result == null ? getByIndex(0) : result;
	}

	public static function clearCache()
	{
		difficultyIds = [];

		cache.clear();
	}
}

class DifficultyData
{
	/**
	 * The internal ID for the difficulty.
	 */
	public var id:String;

	/**
	 * The song data file suffix for this difficulty.
	 */
	public var songSuffix:String;

	/**
	 * The FlxGraphic to display in the difficulty selection part of the story menu.
	 */
	public var graphic:FlxGraphic;

	public function new(id:String, songSuffix:String)
	{
		this.id = id;
		this.songSuffix = songSuffix;

		this.graphic = GraphicsAssets.loadImage('storymenu/difficulty/${id}', null, true);

		if (this.graphic == null)
		{
			Debug.logWarn('Could not load difficulty graphic for ${id}');
		}
	}
}
