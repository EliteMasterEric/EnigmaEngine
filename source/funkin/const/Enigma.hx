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
 * Enigma.hx
 * A static class which contains compile-time values and other useful info.
 * Check the end of this file for several useful values you can modify to disable game features.
 */
package funkin.const;

import funkin.ui.state.MusicBeatState;
import funkin.util.macro.HaxeCommit;

class Enigma extends MusicBeatState
{
	/**
	 * The git commit of this build, calculated at build time. Powered by a fancy Haxe macro.
	 * No, this line does NOT have an error.
	 */
	@:keep public static var COMMIT_HASH(default, never):String = HaxeCommit.getGitCommitHash();

	/**
	 * enigma balls lol.
	 */
	public static final ENGINE_NAME:String = 'Enigma Engine';

	/**
	 * The suffix applied to the engine version. Make sure to change this with each respective release.
	 */
	// public static final ENGINE_SUFFIX:String = ''; // For RELEASES
	// public static final ENGINE_SUFFIX:String = '-beta1'; // For BETA/PRERELEASE
	public static final ENGINE_SUFFIX:String = '-$COMMIT_HASH'; // For DEVELOP

	/**
	 * The full engine version with -prerelease suffix if applicable.
	 */
	public static final ENGINE_VERSION:String = '0.3.1' + ENGINE_SUFFIX;

	/**
	 * This is the version of Friday Night Funkin' the engine is based on.
	 * The release of Week 8 is going to send a lot of waves through the modding community...
	 */
	public static final GAME_VERSION:String = '0.2.7.1';

	/**
	 * The URL to use for version checks.
	 * Set `ENABLE_VERSION_CHECK` to false instead if you want to turn the feature off entirely.
	 */
	public static final ENGINE_VERSION_URL:String = 'https://raw.githubusercontent.com/EnigmaEngine/EnigmaEngine/stable/version.downloadMe';

	/**
	 * If you want to create a build of Enigma Engine which disables mod support entirely,
	 * flip this lever.
	 */
	public static final ENABLE_MODS:Bool = true;

	/**
	 * If you don't want to check the engine version on GitHub, or display the 'Outdated Version' message,
	 * flip this lever.
	 */
	public static final ENABLE_VERSION_CHECK:Bool = true;

	/**
	 * If you don't want to see the 'Custom Keybinds' option in the menu,
	 * flip this lever.
	 */
	public static final USE_CUSTOM_KEYBINDS = true;

	/**
	 * If you don't want to see certain keybinds in the 'Custom Keybinds' menu,
	 * flip these levers.
	 */
	public static final SHOW_CUSTOM_KEYBINDS:Map<Int, Bool> = [
		0 => true, // Left 9K
		1 => true, // Down 9K
		2 => true, // Up 9K
		3 => true, // Right 9K
		4 => true, // Center
		5 => true, // Left Alt 9K
		6 => true, // Down Alt 9K
		7 => true, // Up Alt 9K
		8 => true, // Right Alt 9K
	];

	/**
	 * If you want to be able to access the buggy charter,
	 * flip this lever.
	 */
	public static final ALLOW_CHARTER = false;

	/**
	 * If you want to bypass all "isWeekUnlocked" logic,
	 * flip this lever.
	 */
	public static final UNLOCK_ALL_WEEKS = false;
}
