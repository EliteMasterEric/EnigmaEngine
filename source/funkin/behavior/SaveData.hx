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
 * SaveData.hx
 * A static utility class which handles initializing Flixel save data.
 */
package funkin.behavior;

import tjson.TJSON;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import funkin.behavior.options.CustomControls;
import funkin.behavior.options.Options;
import funkin.behavior.options.PlayerSettings;
import funkin.behavior.play.Conductor;
import openfl.Lib;

class SaveData
{
	// Notes on save data:
	// Structure of FlxG.save.data:
	// - debugLogLevel: Current log level of the debug logger. Defaults to TRACE.
	// - preferences: A map of values stored by the options menu.
	//   - Do NOT access preferences via FlxG directly.
	//   - Instead, statically reference the Options menu option that controls it, like DownscrollOption.get().
	// - binds: A map of keybinds and gamepad binds.
	// - songScores: A String->Int map of song IDs to highscores.
	// - songCombos: A String->String map of song IDs to highest combos.
	// - weekScores: A String->Int map of week IDs to highscores.
	// - weekCombos: A String->String map of week IDs to highest combos.
	// - weeksUnlocked: A String->Bool map of week IDs to whether they are unlocked.
	// - modConfig: A delimited String representing the mod IDs currently loaded and their order.
	// - modData: Save data stored by mods.
	// - autosave: While in the charter, chart data is regularly stored here in case of a crash.

	/**
	 * Retrieve saved data.
	 */
	public static function bindSave()
	{
		// All saves are specific to the game.
		// First argument is the save file ID, used for games that have multiple save slots.
		// Second argument is a relative path, which we override. See https://github.com/HaxeFlixel/flixel/pull/2202
		FlxG.save.bind('funkin', 'ninjamuffin99');
	}

	public static function initSave()
	{
		trace('Checking save data...');

		Option.validatePreferences();

		if (FlxG.save.data.modData == null || FlxG.save.data.modData.get == null)
		{
			var properValue:Map<String, Dynamic> = [];
			FlxG.save.data.modData = properValue;
		}

		// Commit the default values.
		trace('Done checking save data. Flushing...');
		FlxG.save.flush();

		Debug.logInfo('Save data:');
		Debug.logInfo('  ${TJSON.encode(FlxG.save.data, 'fancy')}');

		#if FEATURE_GAMEPAD
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		CustomControls.gamepad = gamepad != null;
		#else
		CustomControls.gamepad = false;
		#end

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		CustomControls.keyCheck();

		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FramerateCapOption.get());
	}
}
