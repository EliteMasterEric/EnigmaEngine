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
 * WeekData.hx
 * A type definition for week data stored in the JSON asset files.
 * Also includes a class of static utilities for managing and caching data.
 */
package funkin.data;

import funkin.util.assets.Paths;
import flixel.util.FlxColor;
import funkin.util.concurrency.ThreadUtil;
import funkin.const.Enigma;
import funkin.util.assets.DataAssets;
import flixel.FlxSprite;

using hx.strings.Strings;

class WeekDataHandler
{
	/**
	 * Contains all the week data elements.
	 * Caching this during the title screen saves a lot of time.
	 */
	static var cache(default, null):Map<String, WeekData> = new Map<String, WeekData>();

	/**
	 * Contains a list of all valid character IDs.
	 */
	public static var weekIds(default, null):Array<String> = [];

	/**
	 * Load the character data directly from JSON.
	 * @param id 
	 * @return CharacterData
	 */
	static function loadWeekData(id:String):Null<WeekData>
	{
		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData = DataAssets.loadJSON('storymenu/weeks/$id');
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for week ${id}');
			return null;
		}

		return new WeekData(id, jsonData);
	}

	/**
	 * Loads weeks data from disk and caches it.
	 * If the ID is already cached, it will be overwritten.
	 * @param id The ID to fetch.
	 */
	static function cacheWeek(id:String):WeekData
	{
		var weekData:WeekData = loadWeekData(id);

		if (weekData == null)
		{
			Debug.logError('Failed to load week data for ${id}');
			return null;
		}

		cache.set(id, weekData);

		return weekData;
	}

	/**
	 * Gets all week IDs and loads all their data.
	 * @param progressCb A callback to use for progress bars.
	 * 	Provides the number of weeks loaded and the total number of weeks.
	 */
	public static function cacheWithProgress(progressCb:(Int, Int) -> Void)
	{
		var allWeeks = WeekDataHandler.listIds();
		weekIds = allWeeks;

		for (weekIndex in 0...allWeeks.length)
		{
			cacheWeek(allWeeks[weekIndex]);
			progressCb(weekIndex, allWeeks.length);
		}
		progressCb(allWeeks.length, allWeeks.length);

		Debug.logInfo('Loaded ${allWeeks.length} weeks into cache.');
	}

	/**
	 * Gets all character IDs and loads all their data.
	 * 
	 * Call this early in the program to store all character JSON in memory,
	 * improving load times while neglegibly increasing memory usage.
	 */
	public static function cacheSync()
	{
		cacheWithProgress(function(i1, i2)
		{
			return;
		});
	}

	/**
	 * Starts a thread to load all character data.
	 */
	public static function cacheAsync()
	{
		ThreadUtil.doInBackground(cacheSync);
	}

	/**
	 * Attempt to load the week directly from the cache.
	 * If the week data isn't cached, read it synchronously from the data assets.
	 * If data isn't there, return null.
	 * @param weekId 
	 */
	public static function fetch(weekId:String)
	{
		if (cache.exists(weekId))
		{
			return cache.get(weekId);
		}
		else
		{
			var weekData = cacheWeek(weekId);

			if (weekData != null)
			{
				return weekData;
			}
			else
			{
				return null;
			}
		}
	}

	public static function listIds():Array<String>
	{
		return DataAssets.listJSONsInPath('storymenu/weeks/');
	}

	public static function getByIndex(index:Int):WeekData
	{
		return fetch(weekIds[index]);
	}

	public static function generateStub():WeekData
	{
		return new WeekData('unknown', {
			name: "UNKNOWN",
			unlocked: true,
			songs: ["tutorial"],
			assets: {
				characters: ["", "gf", "bf"],
				title: "storymenu/weeks/week0"
			}
		});
	}

	public static function clearCache()
	{
		weekIds = [];

		cache.clear();
	}
}

class WeekData
{
	/**
	 * The internal ID of the week. Mandatory.
	 */
	public var id(default, null):String;

	/**
	 * An ordered list of songs to play.
	 */
	public var playlist(default, null):Array<String> = [];

	/**
	 * The flavor name/title to display.
	 */
	public var title(default, null):String = "UNKNOWN";

	/**
	 * If specified, set in the save data that the week with that ID should be unlocked upon completion.
	 * 
	 * Fun idea, combine this with LockedWeekBehavior.HIDE for secret cross-mod content ;)
	 */
	public var nextWeek(default, null):String = null;

	/**
	 * If this week is locked, choose the behavior.
	 * Currently either shows with a lock symbol or hides from the menu completely.
	 */
	public var lockedBehavior(default, null):LockedWeekBehavior = SHOW_LOCKED;

	/**
	 * Whether the week is always unlocked by default.
	 */
	var alwaysUnlocked(default, null):Bool = true;

	/**
	 * The graphic to display on the menu item.
	 */
	public var titleGraphic(default, null):String = null;

	/**
	 * The character graphics to display.
	 */
	public var menuCharacters(default, null):Array<String> = ["", "bf", "gf"];

	/**
	 * The sound file relative to the `sounds` folder to play when choosing the week.
	 */
	public var startSound(default, null):String = 'confirmMenu';

	/**
	 * This string value will determine what the background for the characters is.
	 * The value is either an asset path, or a hex color code starting in `#`.
	 * Defaults to the yellow color from the base game.
	 */
	public var backgroundGraphic(default, null):String = "#F9CF51";

	public function new(id:String, data:Dynamic)
	{
		this.id = id;
		this.playlist = data.songs;
		this.title = data.name;

		if (data.nextWeek != null)
			this.nextWeek = data.nextWeek;

		if (data.hideWhileLocked != null)
			this.lockedBehavior = data.hideWhileLocked ? HIDE : SHOW_LOCKED;

		if (data.unlocked != null)
			this.alwaysUnlocked = data.unlocked;

		if (data.assets != null)
		{
			if (data.assets.title != null)
				this.titleGraphic = data.assets.title;
			if (data.assets.characters != null)
				this.menuCharacters = data.assets.characters;
			if (data.assets.startSound != null)
				this.startSound = data.assets.startSound;
			if (data.assets.background != null)
				this.backgroundGraphic = data.assets.background;
		}
	}

	public function createBackgroundSprite():FlxSprite
	{
		if (this.backgroundGraphic.startsWith('#'))
		{
			// A color was used.
			return new FlxSprite(0, 0).makeGraphic(1280, 400, FlxColor.fromString(this.backgroundGraphic));
		}
		else
		{
			// An asset path was used.
			return new FlxSprite(0, 0).loadGraphic(Paths.image(this.backgroundGraphic));
		}
	}

	/**
	 * Check the player's save data to see if they have unlocked the associated week
	 * @param weekId The ID to fetch.
	 * @returns Whether that week is unlocked.
	 */
	public function isUnlocked()
	{
		// Is unlocked in metadata?
		if (this.alwaysUnlocked)
			return true;

		// Is unlocked in save data?
		if (FlxG.save.data.weeksUnlocked != null)
		{
			if (FlxG.save.data.weeksUnlocked.get(this.id))
				return true;
		}

		// Else, only unlock based on the compile time flag.
		return Enigma.UNLOCK_ALL_WEEKS;
	}

	public function isHidden()
	{
		return !isUnlocked() && this.lockedBehavior == HIDE;
	}
}

enum LockedWeekBehavior
{
	/**
	 * The week should display in the Story Menu with a lock icon.
	 */
	SHOW_LOCKED;

	/**
	 * The week should be hidden until unlocked.
	 */
	HIDE;
}
