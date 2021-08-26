/**
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

import haxe.PosInfos;
import haxe.Log;
import flixel.system.debug.log.LogStyle;
import flixel.FlxG;

/**
 * Global static configuration and basic utilities.
 */
class Enigma {
  /**
   * [Description] Private constructor,
   *   to prevent unintentional initialization.
   */
  function new() {}

  /**
   * Change this to false to hide the "Custom Keybinds"
   * option from the start menu.
   */
  public static final USE_CUSTOM_KEYBINDS = true;

  /**
   * Change these options to hide individual keybinds
   * from the "Custom Keybinds" menu.
   */
  public static final SHOW_CUSTOM_KEYBINDS:Map<Int, Bool> = [
    0 => true, // Left 9K
    1 => true, // Down 9K
    2 => true, // Up 9K
    3 => true, // Right 9K
    4 => true, // Center
    5 => true, // Alt Left 9K
    6 => true, // Alt Down 9K
    7 => true, // Alt Up 9K
    8 => true, // Alt Right 9K
  ];

  /**
   * Change this to true to use the 18-note layout in the Charter.
   */
  public static final USE_CUSTOM_CHARTER = true;

  static final LOG_STYLE_WARN:LogStyle = new LogStyle('[WARN ] ', 'D9F85C', 12, true, false, false, 'flixel/sounds/beep', true);

  /**
   * Log an warning message to the game's console.
   * Plays a beep to the user and forces the console open.
   * @param input The message to display.
   */
  public static function logWarn(input:Dynamic):Void {
    FlxG.log.advanced(input, LogStyle.WARNING);
  }

  static final LOG_STYLE_ERROR:LogStyle = new LogStyle('[ERROR] ', 'FF8888', 12, true, false, false, 'flixel/sounds/beep', true);

  /**
   * Log an error message to the game's console.
   * Plays a beep to the user and forces the console open.
   * @param input The message to display.
   */
  public static function logError(input:Dynamic):Void {
    FlxG.log.advanced(input, LogStyle.ERROR);
  }

  static final LOG_STYLE_INFO:LogStyle = new LogStyle('[INFO ] ', '5CF878', 12, false);

  /**
   * Log an info message to the game's console.
   * @param input The message to display.
   */
  public static function logInfo(input:Dynamic):Void {
    FlxG.log.advanced(input, LogStyle.CONSOLE);
  }

  static final LOG_STYLE_TRACE:LogStyle = new LogStyle('[TRACE] ', '5CF878', 12, false);

  /**
   * Log a debug message to the game's console.
   * @param input The message to display.
   */
  public static function logTrace(input:Dynamic):Void {
    FlxG.log.advanced(input, LOG_STYLE_TRACE);
  }

  static function handleTrace(data:Dynamic, ?info:PosInfos):Void {
    var paramArray:Array<Dynamic> = [data];

    if (info.customParams != null) {
      for (i in info.customParams) {
        paramArray.push(i);
      }
    }

    logTrace(paramArray);
  }

  /**
   * The game runs this function when it starts. Use it to initialize stuff.
   */
  public static function onGameStart() {
    // Override trace() calls to use the custom console.
    Log.trace = handleTrace;

    // Add the mouse position to the debug Watch window.
    FlxG.watch.addMouse();
  }

  /**
   * Continously display the value of a particular field of a given object
   * in the Debug watch window, labelled with the specified name.
   * @param object 
   * @param field 
   * @param name
   */
  public static function watchVariable(object:Dynamic, field:String, name):Void {
    #if debug
    if (name == null) {
      // Default to naming after the field.
      name = field;
    }
    FlxG.watch.add(object, field, name);
    #end
    // Else, do nothing outside of debug mode.
  }

  /**
   * Adds a command to the Flixel console, that can be run at any time.
   * This can be REALLY useful if you add enough features to it.
   */
  public static function registerConsoleCommand():Void {
    FlxG.console.
  }
}
