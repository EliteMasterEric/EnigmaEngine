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

/**
 * Week.hx
 * A structure which contains data from a week's `data/storymenu/weeks/<id>.json` file.
 * Also contains utility functions to load song data and retrieve associated assets.
 */
package funkin.behavior.play;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import funkin.behavior.Debug;
import funkin.const.Enigma;
import funkin.util.assets.DataAssets;
import funkin.util.assets.Paths;
import tjson.TJSON;

using hx.strings.Strings;

class Week
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

	function new(id:String, rawWeekData:RawWeekData)
	{
		this.id = id;
		this.playlist = rawWeekData.songs;
		this.title = rawWeekData.name;

		if (rawWeekData.nextWeek != null)
			this.nextWeek = rawWeekData.nextWeek;

		if (rawWeekData.hideWhileLocked != null)
			this.lockedBehavior = rawWeekData.hideWhileLocked ? HIDE : SHOW_LOCKED;

		if (rawWeekData.unlocked != null)
			this.alwaysUnlocked = rawWeekData.unlocked;

		if (rawWeekData.assets != null)
		{
			if (rawWeekData.assets.title != null)
				this.titleGraphic = rawWeekData.assets.title;
			if (rawWeekData.assets.characters != null)
				this.menuCharacters = rawWeekData.assets.characters;
			if (rawWeekData.assets.startSound != null)
				this.startSound = rawWeekData.assets.startSound;
			if (rawWeekData.assets.background != null)
				this.backgroundGraphic = rawWeekData.assets.background;
		}
	}

	public static function generateStub():Week
	{
		return new Week('unknown', {
			name: "UNKNOWN",
			unlocked: true,
			songs: ["tutorial"],
			assets: {
				characters: ["", "gf", "bf"],
				title: "storymenu/weeks/week0"
			}
		});
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
	public function isWeekUnlocked()
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

	public function toString()
	{
		return TJSON.encode(this);
	}
}

class WeekCache
{
	static var elements:Map<String, Week> = [];

	public static function get(weekId:String):Null<Week>
	{
		if (weekId == null)
		{
			Debug.logError('Tried to fetch a null week.');
			return null;
		}

		if (elements.exists(weekId))
		{
			return elements.get(weekId);
		}
		else
		{
			// Attempt to fetch it from disk.
			var weekDataElement = fetchWeek(weekId);
			elements.set(weekId, weekDataElement);
			return weekDataElement;
		}
	}

	public static function set(weekId:String, value:Week)
	{
		return elements.set(weekId, value);
	}

	/**
	 * The factory method to fetch and assemble a week's data by its ID.
	 * @param weekId The ID
	 * @return Week
	 */
	static function fetchWeek(weekId:String):Week
	{
		Debug.logTrace('Fetching week data for ${weekId}');
		var rawJsonData = DataAssets.loadJSON('storymenu/weeks/$weekId');

		var rawWeekData:RawWeekData = cast rawJsonData;

		if (!verifyRawWeekData(rawWeekData))
			return null;

		@:privateAccess
		return new Week(weekId, rawWeekData);
	}

	public static function isWeekUnlocked(weekId:String)
	{
		var week = get(weekId);
		return week != null ? week.isWeekUnlocked() : false;
	}

	public static function isWeekHidden(weekId:String)
	{
		var week = get(weekId);
		if (week == null)
			return true;

		return !week.isWeekUnlocked() && week.lockedBehavior == HIDE;
	}

	static function verifyRawWeekData(rawWeekData:RawWeekData):Bool
	{
		if (rawWeekData == null)
		{
			Debug.logError("Error: Week data is empty! Was it read correctly?");
			return false;
		}

		if (rawWeekData.name == null)
		{
			Debug.logError("Error: Week data is missing attribute 'name'");
			return false;
		}
		if (rawWeekData.songs == null || rawWeekData.songs == [])
		{
			Debug.logError("Error: Week data is missing attribute 'songs'");
			return false;
		}

		// No problems here!
		return true;
	}
}

typedef RawWeekAssets =
{
	/**
	 * This should be three elements long, containing the ID of the menu characters
	 * to display at the left, center, and right.
	 */
	characters:Array<String>,

	/**
	 * This is the name of the file in `images/storyweeks` to use when displaying the menu item.
	 */
	title:String,

	/**
	 * This is either a color in hex starting with `#`, or an asset path to a 1280x400 image.
	 * @default The yellow color from the vanilla Story menu.
	 */
	?background:String,
	/**
	 * The sound to play when starting the week.
	 * @default confirmMenu
	 */
	?startSound:String,
};

typedef RawWeekData =
{
	/**
	 * The title/flavor text of the week as displayed at the top right.
	 */
	name:String,

	/**
	 * The assets to use for this week. See RawWeekAssets.
	 */
	assets:RawWeekAssets,

	/**
	 * Whether the week is always unlocked. Set to false to require completing the previous week to complete.
	 * @default true
	 */
	?unlocked:Bool,
	/**
	 * When you complete this story week at any difficulty, the story week with this ID will be unlocked.
	 */
	?nextWeek:String,

	/**
	 * An array of song IDs to play when actually playing this story week.
	 * Order matters, you can have less than or more than three entries if you like.
	 */
	songs:Array<String>,

	/**
	 * If set to true, and if this week is currently locked, it won't show in the list at all.
	 * Cool if you want to make unlockable content secret.
	 * @default false
	 */
	?hideWhileLocked:Bool,
};

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
