package funkin.behavior.api;

#if FEATURE_KONGREGATE
import flixel.addons.api.FlxKongregate;

/**
 * Adds basic integration with Kongregate. This could be fun...
 * Adds support for submitting scores, and... saving and loading shared content? Could we load mods with this?
 * IDK if Kongregate would allow FNF mods...
 */
class Kongregate
{
	public static var initialized = false;

	public static function initAPI(gameId:Int, apiKey:String)
	{
		// TODO
	}

	public static function loginUser(username:String, gameToken:String)
	{
		// TODO
	}

	public static function unlockAchievement(trophyId:Int)
	{
		// TODO
	}
}
#end
