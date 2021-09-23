/**
 * Static class which contains compiler flags and other useful info.
 */
class Enigma extends MusicBeatState
{
	/**
	 * enigma balls lol.
	 */
	public static var ENGINE_NAME:String = "Enigma Engine";

	/**
	 * Set this to `-prerelease` on the `develop` branch please.
	 */
	public static var ENGINE_SUFFIX:String = "-prerelease";

	/**
	 * The full engine version with -prerelease suffix if applicable.
	 */
	public static var ENGINE_VERSION:String = "0.2.0" + ENGINE_SUFFIX;

	/**
	 * This is the version of Friday Night Funkin' the engine is based on.
	 * The release of Week 8 is going to send a lot of waves through the modding community...
	 */
	public static var GAME_VERSION:String = "0.2.7.1";

	/**
	 * The URL to use for version checks.
	 		* Set `ENABLE_VERSION_CHECK` to false instead if you want to turn the feature off entirely.
	 */
	public static final ENGINE_VERSION_URL:String = "https://raw.githubusercontent.com/EnigmaEngine/EnigmaEngine/stable/version.downloadMe";

	/**
	 * If you want to create a build of Enigma Engine which disables mod support entirely,
	 * flip this lever.
	 */
	public static final ENABLE_MODS:Bool = true;

	/**
	 * If you don't want to check the engine version on GitHub, or display the "Outdated Version" message,
	 * flip this lever.
	 */
	public static final ENABLE_VERSION_CHECK:Bool = true;
}
