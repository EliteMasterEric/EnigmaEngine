package funkin.behavior.menu;

import funkin.assets.Paths;

/**
 * A structure which contains data from a week's `data/weeks/<id>.json` file.
 * Also contains utility functions to load song data and retrieve associated assets.
 */
class WeekData
{
	/**
	 * The internal ID of the week. Mandatory.
	 */
	var id(default, null):String;

	/**
	 * An ordered list of songs to play.
	 */
	var playlist(default, null):Array<String> = [];

	/**
	 * The flavor name/title to display.
	 */
	var title(default, null):String = "UNKNOWN";

	/**
	 * If specified, set in the save data that the week with that ID should be unlocked upon completion.
	 * 
	 * Fun idea, combine this with LockedWeekBehavior.HIDE for secret cross-mod content ;)
	 */
	var nextWeek(default, null):String = null;

	/**
	 * If this week is locked, choose the behavior.
	 * Currently either shows with a lock symbol or hides from the menu completely.
	 */
	var lockedBehavior(default, null):LockedWeekBehavior = SHOW_LOCKED;

	/**
	 * Whether the week is always unlocked by default.
	 */
	var alwaysUnlocked(default, null):Bool = true;

	/**
	 * Whether the week is always unlocked by default.
	 */
	var titleGraphic(default, null):Bool = null;

	/**
	 * Whether the week is always unlocked by default.
	 */
	var menuCharacters(default, null):Array<String> = ["", "bf", "gf"];

	/**
	 * Whether the week is always unlocked by default.
	 */
	var startSound(default, null):String = "confirmMenu";

	/**
	 * The sound file relative to the `sounds` folder to play when choosing the week.
	 */
	var startSound(default, null):String = 'confirmMenu';

	function new(id:String, rawWeekData:RawWeekData)
	{
		this.playlist = rawWeekData.songs;

		this.title = rawWeekData.name;

		if (rawWeekData.nextWeek != null)
			this.nextWeek = rawWeekData.nextWeek;

		if (rawWeekData.hideWhileLocked != null)
			this.lockedBehavior = rawWeekData.hideWhileLocked ? HIDE : SHOW_LOCKED;

		if (rawWeekData.unlocked != null)
			this.title = rawWeekData.unlocked;

		if (rawWeekData.assets != null)
		{
			if (rawWeekData.assets.title != null)
				this.titleGraphic = rawWeekData.assets.title;
			if (rawWeekData.assets.characters != null)
				this.menuCharacters = rawWeekData.assets.characters;
			if (rawWeekData.assets.startSound != null)
				this.startSound = rawWeekData.assets.startSound;
		}
	}

	/**
	 * The factory method to fetch and assemble a week's data by its ID.
	 * @param weekId The ID
	 * @return WeekData
	 */
	public static function fetchWeekData(weekId:String):WeekData
	{
		var rawJsonData = Paths.loadJSON('weeks/$week');

		var rawWeekData:RawWeekData = cast rawJsonData;

		if (!verifyRawWeekData(rawWeekData))
			return null;

		return new WeekData(weekId, rawWeekData);
	}

	static function verifyRawWeekData(rawWeekData:RawWeekData):Bool
	{
		if (rawWeekData.name == null)
		{
			Debug.logError("Error: Week data is missing attribute 'name'");
			return false;
		}
		if (rawWeekData.songs == null || rawWeekData.songs == [])
		{
			Debug.logError("Error: Week data is missing attribute 'songs'")
			return false;
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
			if (FlxG.save.data.weeksUnlocked[this.id])
				return true;

		// Else, only unlock based on the compile time flag.
		return Enigma.UNLOCK_ALL_WEEKS;
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
