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

/**
 * Monkeypatches the String class to have new advanced methods,
 * such as `startsWith`.
 * @see: https://api.haxe.org/StringTools.html
 */
using StringTools;

/**
 * A static class created to handle annoying math for custom notes.
 */
class CustomNoteUtils {
  /**
   * [Description] Private constructor,
   *   to prevent unintentional initialization.
   */
  function new() {}

  /**
   * Provides values based on the current strumlineSize:
   * [NOTE POSITION, NOTE GRAPHIC SCALE, BASE OFFSET]
   */
  public static final NOTE_GEOMETRY_DATA:Map<Int, Array<Float>> = [
    1 => [160 * 0.7, 0.70, 0],
    2 => [160 * 0.7, 0.70, 0],
    3 => [160 * 0.7, 0.70, 0],
    4 => [160 * 0.7, 0.70, 80], // Base game.
    5 => [160 * 0.7, 0.70, 60], // The fifth note fits fine.
    6 => [160 * 0.7, 0.60, 0], // Six you need to scale down a bit.
    7 => [160 * 0.7, 0.70, 0],
    8 => [160 * 0.7, 0.70, 0],
    9 => [160 * 0.7, 0.70, 0],
  ];

  static final Z = -1; // Invalid/Unused.
  public static final NOTE_DATA_TO_STRUMLINE_MAP:Map<Int, Array<Int>> = [
    // No controls are 9Key
    2 => [Z, 0, 1, Z, Z, 2, 3, Z], // Down/Up.
    3 => [0, Z, 1, 2, 3, Z, 4, 5], // Left/Up/Right
    4 => [0, 1, 2, 3, 4, 5, 6, 7], // Left/Down/Up/Right
    // Some controls are 9Key
    1 => [Z, Z, Z, Z, Z, Z, Z, Z, Z, Z, Z, Z, Z, Z, 0, Z, Z, Z, Z, 1], // Center.
    5 => [0, 1, 3, 4, 5, 6, 8, 9, Z, Z, Z, Z, Z, Z, 2, Z, Z, Z, Z, 7], // Left/Down/Center/Up/Right
    // All controls are 9Key
    6 => [0, 1, 4, 2, 6, 7, 10, 8, Z, Z, 3, Z, Z, 5, Z, 9, Z, Z, 11, Z], // Left/Down/Right ALeft/Up/ARight
    7 => [0, 1, 5, 2, 7, 8, 12, 9, Z, Z, 4, Z, Z, 6, 3, 11, Z, Z, 13, 10], // Left/Down/Right Center ALeft/Up/ARight
    8 => [0, 1, 2, 3, 8, 9, 10, 11, Z, Z, 4, 5, 6, 7, Z, 12, 13, 14, 15, Z], // Left/Down//Up/Right ALeft/ADown/AUp/ARight
    9 => [0, 1, 2, 3, 9, 10, 11, 12, Z, Z, 5, 6, 7, 8, 4, 14, 15, 16, 17, 13], // Copied from vs Shaggy
  ];

  /**
   * Stores which notes to use for the strumline for each strumlineSize value.
   */
  public static final STRUMLINE_DIR_NAMES:Map<Int, Array<String>> = [
    1 => ["Center"],
    2 => ["Down", "Up"],
    3 => ["Left", "Up", "Right"],
    4 => ["Left", "Down", "Up", "Right"],
    5 => ["Left", "Down", "Center", "Up", "Right"],
    6 => ["Left", "Down", "Right", "Left Alt", "Up", "Right Alt"],
    7 => ["Left", "Down", "Right", "Center", "Left Alt", "Up", "Right Alt"],
    8 => ["Left", "Down", "Up", "Right", "Left Alt", "Down Alt", "Up Alt", "Right Alt"],
    9 => [
      "Left",
      "Down",
      "Up",
      "Right",
      "Center",
      "Left Alt",
      "Down Alt",
      "Up Alt",
      "Right Alt"
    ],
  ];

  /**
   * Determine this note is on the player's side of the field.
   * 
   * Note that this 
   * @param rawNoteData The raw note data value (no modulus performed).
   * @param mustHitSection The mustHitSection value from this note's section from the JSON file.
   * @return Whether the note needs to be hit by the player.
   */
  public static function mustHitNote(rawNoteData:Int, mustHitSection:Bool):Bool {
    var baseNoteData = rawNoteData % CustomNotes.NOTE_OFFSET;
    return switch (baseNoteData) {
      // Example, if mustHitSection is true, notes 0/1/2/3 appear on BF's side,
      // but if mustHitSection is false, notes 0/1/2/3 apepar on Dad's side, and 4/5/6/7 appear on BF's side.
      case CustomNotes.NOTE_BASE_LEFT | CustomNotes.NOTE_BASE_DOWN | CustomNotes.NOTE_BASE_UP | CustomNotes.NOTE_BASE_RIGHT:
        mustHitSection;
      case CustomNotes.NOTE_9K_LEFT | CustomNotes.NOTE_9K_DOWN | CustomNotes.NOTE_9K_UP | CustomNotes.NOTE_9K_RIGHT | CustomNotes.NOTE_9K_CENTER:
        mustHitSection;
      case CustomNotes.NOTE_BASE_LEFT_ENEMY | CustomNotes.NOTE_BASE_DOWN_ENEMY | CustomNotes.NOTE_BASE_UP_ENEMY | CustomNotes.NOTE_BASE_RIGHT_ENEMY:
        mustHitSection;
      case CustomNotes.NOTE_9K_LEFT_ENEMY | CustomNotes.NOTE_9K_DOWN_ENEMY | CustomNotes.NOTE_9K_UP_ENEMY | CustomNotes.NOTE_9K_RIGHT_ENEMY | CustomNotes.NOTE_9K_CENTER_ENEMY:
        mustHitSection;
      default:
        mustHitSection;
    }
  }

  /**
   * Fetch a "corrected" note ID that matches its order in the strumline.
   * For example, in 5-note, left returns 0, center returns 2, and right returns 4 (rather than 3).
   *
   * This is needed because otherwise data for different note types would be in very high lane numbers. 
   * TODO: This is done manually with a map but I don't think there's a smarter method.
   * @return Int
   */
  public static function getStrumlineIndex(rawNoteData:Int, strumlineSize:Int = 4):Int {
    var result = NOTE_DATA_TO_STRUMLINE_MAP[strumlineSize][rawNoteData % CustomNotes.NOTE_OFFSET];
    return result;
  }

  /**
   * From a note's direction and the song's strumline size,
   * get the distance to offset by, in pixels.
   * @param rawNoteData 
   * @param strumlineSize 
   */
  public static function getNoteOffset(rawNoteData:Int, strumlineSize:Int = 4):Int {
    var correctedNoteData = getStrumlineIndex(rawNoteData, strumlineSize);
    var strumlineNoteWidth = NOTE_GEOMETRY_DATA[strumlineSize][0];
    return Std.int(correctedNoteData * strumlineNoteWidth);
  }
}
