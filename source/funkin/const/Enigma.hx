package funkin.const;

import funkin.ui.state.MusicBeatState;

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

	/**
	 * If you don't want to see the "Custom Keybinds" option in the menu,
	 * flip this lever.
	 */
	public static final USE_CUSTOM_KEYBINDS = true;

	/**
	 * If you don't want to see certain keybinds in the "Custom Keybinds" menu,
	 * flip these levers.
	 */
	public static final SHOW_CUSTOM_KEYBINDS:Map<Int, Bool> = [
		0 => true, // Left 9K
		1 => false, // Down 9K
		2 => true, // Up 9K
		3 => true, // Right 9K
		4 => false, // Center
		5 => true, // Alt Left 9K
		6 => false, // Alt Down 9K
		7 => true, // Alt Up 9K
		8 => true, // Alt Right 9K
	];

	/**
	 * If you don't want to have a double-wide charter for placing 9-key notes,
	 * flip this lever.
	 */
	public static final USE_CUSTOM_CHARTER = true;

	/**
	 * If you don't want to have to deal with locked default weeks,
	 * flip this lever.
	 */
	public static final UNLOCK_DEFAULT_WEEKS = true;
}
