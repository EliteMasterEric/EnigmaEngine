/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * SaveData.hx
 * A static utility class which handles initializing Flixel save data.
 */
package funkin.behavior;

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
  // - binds: A map of values stored by the options menu, limited to keybinds.
  // - songScores: A String->Int map of song IDs to highscores.
  // - songCombos: A String->String map of song IDs to highest combos.
  // - weekScores: A String->Int map of week IDs to highscores.
  // - weekCombos: A String->String map of week IDs to highest combos.
  // - weeksUnlocked: A String->Bool map of week IDs to whether they are unlocked.
  // - modConfig: A delimited String representing the mod IDs currently loaded and their order.

  /**
   * Retrieve saved data.
   */
  public static function bindSave() {
    // All saves are specific to the game.
    // First argument is the save file ID, used for games that have multiple save slots.
    // Second argument is a relative path, which we override. See https://github.com/HaxeFlixel/flixel/pull/2202
    FlxG.save.bind('funkin', 'ninjamuffin99');
  }

	public static function initSave()
	{
		trace('Checking save data...');

    Option.validatePreferences();

		if (FlxG.save.data.weeksUnlocked == null || FlxG.save.data.weeksUnlocked.get == null)
		{
			var properValue:Map<String, Bool> = ['tutorial' => true];
			FlxG.save.data.weeksUnlocked = properValue;
		}

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		// Commit the default values.
		trace('Done checking save data. Flushing...');
		FlxG.save.flush();

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		CustomControls.gamepad = gamepad != null;

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		CustomControls.keyCheck();

		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FramerateCapOption.get());
	}
}
