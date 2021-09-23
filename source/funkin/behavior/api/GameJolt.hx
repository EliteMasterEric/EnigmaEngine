package funkin.behavior.api;

#if FEATURE_GAMEJOLT
import flixel.addons.api.FlxGameJolt;

/**
 * Adds basic integration with GameJolt. This could be fun...
 * Adds support for unlocking trophies, and retreiving them.
 * GameJolt definitely allows HTML5 builds of FNF mods! 
 */
class GameJolt
{
	public static var initialized = false;

	public static function initAPI(gameId:Int, apiKey:String)
	{
		FlxGameJolt.init(gameId, apiKey, false);
		Debug.logInfo('GameJolt: Initialized integration with game ID ${gameId}.');
	}

	public static function loginUser(username:String, gameToken:String)
	{
		if (FlxGameJolt.initialized)
		{
			FlxGameJolt.authUser(username, gameToken);
			Debug.logInfo('GameJolt: Authenticated as user ${FlxGameJolt.username}.');
		}
	}

	public static function unlockTrophy(trophyId:Int)
	{
		if (FlxGameJolt.initialized)
		{
			if (FlxGameJolt.username != 'No user')
			{
				FlxGameJolt.addTrophy(trophyId);
				Debug.logInfo('GameJolt: Added trophy ID ${trophyId}.');
			}
		}
	}
}
#end
