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

import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * Monkeypatches the String class to have new advanced methods,
 * such as `startsWith`.
 * @see: https://api.haxe.org/StringTools.html
 */
using StringTools;

/**
 * A static class created to handle custom notes.
 */
class CustomNotes {
  /**
   * [Description] Private constructor,
   *   to prevent unintentional initialization.
   */
  private function new() {}

  private static final NOTE_BASE_LEFT:Int = 0;
  private static final NOTE_BASE_DOWN:Int = 1;
  private static final NOTE_BASE_UP:Int = 2;
  private static final NOTE_BASE_RIGHT:Int = 3;
  private static final NOTE_BASE_LEFT_ENEMY:Int = 4;
  private static final NOTE_BASE_DOWN_ENEMY:Int = 5;
  private static final NOTE_BASE_UP_ENEMY:Int = 6;
  private static final NOTE_BASE_RIGHT_ENEMY:Int = 7;

  private static final NOTE_9K_LEFT:Int = 10;
  private static final NOTE_9K_DOWN:Int = 11;
  private static final NOTE_9K_UP:Int = 12;
  private static final NOTE_9K_RIGHT:Int = 13;
  private static final NOTE_9K_CENTER:Int = 14;
  private static final NOTE_9K_LEFT_ENEMY:Int = 15;
  private static final NOTE_9K_DOWN_ENEMY:Int = 16;
  private static final NOTE_9K_UP_ENEMY:Int = 17;
  private static final NOTE_9K_RIGHT_ENEMY:Int = 18;
  private static final NOTE_9K_CENTER_ENEMY:Int = 19;

  /**
   * Note offsets allow for using custom note types in particular lanes easily.
   * For example, 19 will spawn a normal note in the enemy center lane.
   * 119 will use a Fire note, 219 will use a Dark Halo, 319 will use a Ebola, etc.
   */
  private static final NOTE_OFFSET = 100;

  // 100: Fire notes.
  private static final NOTE_FIRE_OFFSET:Int = 0 + NOTE_OFFSET;
  // 200: Dark Halo notes.
  private static final NOTE_DARKHALO_OFFSET:Int = NOTE_FIRE_OFFSET + NOTE_OFFSET;
  // 300: Ebola notes.
  private static final NOTE_EBOLA_OFFSET:Int = NOTE_DARKHALO_OFFSET + NOTE_OFFSET;
  // 400: Ice notes.
  private static final NOTE_ICE_OFFSET:Int = NOTE_EBOLA_OFFSET + NOTE_OFFSET;
  // 500: Warning notes.
  private static final NOTE_WARNING_OFFSET:Int = NOTE_ICE_OFFSET + NOTE_OFFSET;

  /**
   * The note style used in most songs.
   */
  private static final STYLE_NORMAL = "normal";

  /**
   * The note style used in Week 6 - vs Senpai.
   */
  private static final STYLE_PIXEL = "pixel";

  /**
   * Pixel notes are 6x bigger than their spritesheet.
   * Divide by the base game's note scale.
   */
  private static final PIXEL_ZOOM = 6 / 0.7;

  /**
   * Provides values based on the current strumlineSize:
   * [NOTE POSITION, NOTE SCALE, BASE OFFSET]
   */
  private static final NOTE_GEOMETRY_DATA:Map<Int, Array<Float>> = [
    1 => [160 * 0.7, 0.70, 0],
    2 => [160 * 0.7, 0.70, 0],
    3 => [160 * 0.7, 0.70, 0],
    4 => [160 * 0.7, 0.70, 0], // Base game.
    5 => [160 * 0.6, 0.60, 0],
    6 => [120 * 0.7, 0.60, 0], // Copied from vs Shaggy
    7 => [120 * 0.7, 0.60, 0],
    8 => [120 * 0.7, 0.60, 30],
    9 => [90 * 0.7, 0.46, 30], // Copied from vs Shaggy
  ];

  /**
   * TODO: This seems clumsy.
   */
  private static final NOTE_DATA_TO_STRUMLINE_MAP:Map<Int, Array<Int>> = [
    // No controls are 9Key
    2 => [0,0,1,0, 0,0,0,0], // Down/Up.
    3 => [0,0,1,2, 0,0,0,0], // Left/Up/Right
    4 => [0,1,2,3, 0,0,0,0], // Left/Down/Up/Right
    // Some controls are 9Key
    1 => [0,0,0,0, 0,0,0,0, 0,0, 0,0,0,0, 0, 0,0,0,0, 0], // Center.
    5 => [0,1,3,4, 0,0,0,0, 0,0, 0,0,0,0, 2, 0,0,0,0, 0], // Left/Down/Center/Up/Right
    // All controls are 9Key
    6 => [0,1,4,2, 0,0,0,0, 0,0, 3,0,0,5, 0, 0,0,0,0, 0], // Left/Down/Right ALeft/Up/ARight
    7 => [0,1,5,2, 0,0,0,0, 0,0, 0,0,0,0, 3, 0,0,0,0, 0],
    8 => [0,0,0,0, 0,0,0,0, 0,0, 0,0,0,0, 0, 0,0,0,0, 0],
    9 => [0,1,2,3, 0,0,0,0, 0,0, 5,6,7,8, 4, 0,0,0,0, 0], // Copied from vs Shaggy
  ];

  /**
   * Stores which notes to use for the strumline for each strumlineSize value.
   */
  private static final STRUMLINE_DIR_NAMES:Map<Int, Array<String>> = [
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
   * Determine this note is mandatory to hit.
   * @param rawNoteData The raw note data value (no modulus performed).
   * @param mustHitSection The mustHitSection value from this note's section.
   * @return Whether the note needs to be hit by the player.
   */
  public static function mustHitNote(rawNoteData:Int, mustHitSection:Bool):Bool {
    var baseNoteData = rawNoteData % NOTE_OFFSET;
    switch (baseNoteData) {
      case NOTE_BASE_LEFT | NOTE_BASE_DOWN | NOTE_BASE_UP | NOTE_BASE_RIGHT:
        return mustHitSection;
      case NOTE_BASE_LEFT_ENEMY | NOTE_BASE_DOWN_ENEMY | NOTE_BASE_UP_ENEMY | NOTE_BASE_RIGHT_ENEMY:
        return !mustHitSection;
      default:
        return mustHitSection;
    }
  }

  public static function getDirectionName(rawNoteData:Int, allowAltNames:Bool):String {
    var isCustomNoteType = rawNoteData >= NOTE_OFFSET;
    if (!allowAltNames || isCustomNoteType) {
      // Don't return 'Alt' direction names.
      var baseNoteData = rawNoteData % NOTE_OFFSET;
      switch (baseNoteData) {
        case NOTE_BASE_LEFT | NOTE_9K_LEFT | NOTE_BASE_LEFT_ENEMY | NOTE_9K_LEFT_ENEMY:
          return "Left";
        case NOTE_BASE_DOWN | NOTE_9K_DOWN | NOTE_BASE_DOWN_ENEMY | NOTE_9K_DOWN_ENEMY:
          return "Down";
        case NOTE_BASE_UP | NOTE_9K_UP | NOTE_BASE_UP_ENEMY | NOTE_9K_UP_ENEMY:
          return "Up";
        case NOTE_BASE_RIGHT | NOTE_9K_RIGHT | NOTE_BASE_RIGHT_ENEMY | NOTE_9K_RIGHT_ENEMY:
          return "Right";
        case NOTE_9K_CENTER:
          // Use the up animation for the center note.
          return "Up";
        default:
          trace("Couldn't determine what animation to use for this special note!");
          return 'UNKNOWN';
      }
    } else {
      // This is a base note type. The result might be 'Alt Down' for example.
      // Used only for building 9K notes and the strumline.
      switch (rawNoteData) {
        case NOTE_BASE_LEFT | NOTE_BASE_LEFT_ENEMY:
          return "Left";
        case NOTE_9K_LEFT | NOTE_9K_LEFT_ENEMY:
          return "Left Alt";
        case NOTE_BASE_DOWN | NOTE_BASE_DOWN_ENEMY:
          return "Down";
        case NOTE_9K_DOWN | NOTE_9K_DOWN_ENEMY:
          return "Down Alt";
        case NOTE_BASE_UP | NOTE_BASE_UP_ENEMY:
          return "Up";
        case NOTE_9K_UP | NOTE_9K_UP_ENEMY:
          return "Up Alt";
        case NOTE_BASE_RIGHT | NOTE_BASE_RIGHT_ENEMY:
          return "Right";
        case NOTE_9K_RIGHT | NOTE_9K_RIGHT_ENEMY:
          return "Right Alt";
        case NOTE_9K_CENTER:
          return "Center";
        default:
          trace("Couldn't determine what animation to use for this basic note!");
          return 'UNKNOWN';
      }
    }
  }

  public static function loadNoteSprite(instance:FlxSprite, noteStyle:String, noteData:Int, isSustainNote:Bool, strumlineSize:Int):Void {
    switch (noteStyle) {
      case STYLE_PIXEL:
        instance.frames = Paths.getSparrowAtlas('notes/Pixel9KNote', 'shared');
      default: // STYLE_NORMAL
        instance.frames = Paths.getSparrowAtlas('notes/9KNote', 'shared');
    }

    // Only add the animation for the note we are using.
    var dirName = getDirectionName(noteData, true);
    instance.animation.addByPrefix(dirName + ' Note', dirName + ' Note'); // Normal notes
    instance.animation.addByPrefix(dirName + ' Sustain', dirName + ' Sustain'); // Hold
    instance.animation.addByPrefix(dirName + ' End', dirName + ' End'); // Tails

    var noteScale = NOTE_GEOMETRY_DATA[strumlineSize][1];
    switch (noteStyle) {
      case STYLE_PIXEL:
        var widthSize = Std.int(PlayState.Stage.curStage.startsWith('school') ? (instance.width * PlayState.daPixelZoom) : (isSustainNote ? (instance.width * (PlayState.daPixelZoom
          - 1.5)) : (instance.width * PlayState.daPixelZoom)) * noteScale);

        instance.setGraphicSize(widthSize);
        instance.updateHitbox();
      // No anti-aliasing.
      default: // STYLE_NORMAL
        instance.setGraphicSize(Std.int(instance.width * noteScale));
        instance.updateHitbox();
        instance.antialiasing = FlxG.save.data.antialiasing;
    }
  }

  public static function buildStrumlines(isPlayer:Bool, yPos:Float, strumlineSize:Int = 4, noteStyle:String = 'normal'):Void {
    if (!STRUMLINE_DIR_NAMES.exists(strumlineSize)) {
      trace('Could not build strumline! Invalid size ' + strumlineSize);
      return;
    }

    var strumlineDirs = STRUMLINE_DIR_NAMES[strumlineSize];
    var strumlinePos = NOTE_GEOMETRY_DATA[strumlineSize][2];
    var strumlineNoteWidth = NOTE_GEOMETRY_DATA[strumlineSize][0];
    var noteScale = NOTE_GEOMETRY_DATA[strumlineSize][1];

    // For each note in the strumline...
    for (i in 0...strumlineDirs.length) {
      var arrowDir = strumlineDirs[i];

      // Create a new note.
      var babyArrow:StaticArrow = new StaticArrow(0, yPos);

      // What is this for?
      if (PlayStateChangeables.Optimize && !isPlayer)
        continue;

      // Load the spritesheet.
      // With my reworked sprite sheets, the animation names are the same.
      switch (noteStyle) {
        case STYLE_PIXEL:
          babyArrow.frames = Paths.getSparrowAtlas('notes/Pixel9KNote', 'shared');
        default: // STYLE_NORMAL
          babyArrow.frames = Paths.getSparrowAtlas('notes/9KNote', 'shared');
      }

      // Add the proper animations to the strumline item.
      babyArrow.animation.addByPrefix('static', arrowDir + ' Strumline');
      babyArrow.animation.addByPrefix('pressed', arrowDir + ' Press', 24, false);
      babyArrow.animation.addByPrefix('confirm', arrowDir + ' Hit', 24, false);

      // Position the arrow properly. Should be the same for all note styles?
      babyArrow.x += strumlineNoteWidth * i;

      // Cleanup the graphic.
      switch (noteStyle) {
        case STYLE_PIXEL:
          babyArrow.setGraphicSize(Std.int(babyArrow.width * PIXEL_ZOOM * noteScale));
          babyArrow.updateHitbox();
          babyArrow.antialiasing = false;
        default: // STYLE_NORMAL
          babyArrow.antialiasing = FlxG.save.data.antialiasing;
          babyArrow.setGraphicSize(Std.int(babyArrow.width * noteScale));
      }

      // Further setup.
      babyArrow.updateHitbox();
      babyArrow.scrollFactor.set();
      babyArrow.alpha = 0;
      babyArrow.ID = i;
      babyArrow.animation.play('static');
      babyArrow.x += 50;
      babyArrow.x += ((FlxG.width / 2) * (isPlayer ? 1 : 0));
      if (PlayStateChangeables.Optimize) {
        babyArrow.x -= 275;
      }

      // Base offset for longer strumlines.
      babyArrow.x -= strumlinePos;

      // In FreePlay, ease the arrows into frame.
      if (!PlayState.isStoryMode) {
        babyArrow.y -= 10;
        FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
      }

      // Add the graphic to the strumline.
      if (isPlayer) {
        PlayState.playerStrums.add(babyArrow);
      } else {
        PlayState.cpuStrums.add(babyArrow);
      }
      PlayState.strumLineNotes.add(babyArrow);

      PlayState.cpuStrums.forEach(function(spr:FlxSprite) {
        spr.centerOffsets(); // CPU arrows start out slightly off-center
      });
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
  public static function getCorrectedNoteData(rawNoteData:Int, strumlineSize:Int = 4):Int {
    var result = NOTE_DATA_TO_STRUMLINE_MAP[strumlineSize][rawNoteData % NOTE_OFFSET];
    return result;
  }

  /**
   * Get the animation to play when singing this note.
   * Used by both BF and Dad (and GF during the tutorial).
   * @param note 
   * @param strumlineSize 
   * @return Int
   */
  public static function getSingAnim(note:Note, strumlineSize:Int = 4):String {
    // ERIC: Currently, singing alt left/down/up/right notes uses the same animations,
    // and the center note uses the up animation, on both players.
    // Use this code to override that if needed.
    var directionName = getDirectionName(note.rawNoteData, false).toUpperCase();
    return 'sing' + directionName;
  }

  /**
   * From a note's direction and the song's strumline size,
   * get the distance to offset by, in notes.
   * @param rawNoteData 
   * @param strumlineSize 
   */
  public static function getNoteOffset(rawNoteData:Int, strumlineSize:Int = 4):Int {
    var correctedNoteData = getCorrectedNoteData(rawNoteData, strumlineSize);
    var strumlineNoteWidth = NOTE_GEOMETRY_DATA[strumlineSize][0];
    return Std.int(correctedNoteData * strumlineNoteWidth);
  }

  private static function getKeyBinds(strumlineSize:Int = 4):Array<String> {
    return switch (strumlineSize) {
      case 1:
        // ONE KEY
        // 1-key: Center
        [FlxG.save.data.centerBind];
      case 2:
        // UP AND DOWN
        // 2-key: Down/Up
        [FlxG.save.data.downBind, FlxG.save.data.upBind];
      case 3:
        // NO DOWN ARROW
        // 3-key: Left/Up/Right
        [FlxG.save.data.leftBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];
      case 4:
        // VANILLA
        // 4-key: Left/Down/Up/Right
        [
          FlxG.save.data.leftBind,
          FlxG.save.data.downBind,
          FlxG.save.data.upBind,
          FlxG.save.data.rightBind
        ];
      case 5:
        // VANILLA PLUS SPACE
        // On 5-keys and lower, use Basic keybinds rather than Custom
        // 5-key: Left/Down/Center/Up/Right
        [
          FlxG.save.data.leftBind,
          FlxG.save.data.downBind,
          FlxG.save.data.centerBind,
          FlxG.save.data.upBind,
          FlxG.save.data.rightBind
        ];
      case 6:
        // Super Saiyan Shaggy
        // On 6-keys and higher, use Custom keybinds rather than Basic
        // 6-key: Left/Down/Right/Alt Left/Up/Alt Right
        [
          FlxG.save.data.left9KBind,
          FlxG.save.data.down9KBind,
          FlxG.save.data.right9KBind,
          FlxG.save.data.altLeft9KBind,
          FlxG.save.data.altUp9KBind,
          FlxG.save.data.altRight9KBind
        ];
      case 7:
        // Super Saiyan Shaggy Plus Space
        // 7-key: Left/Down/Right/Center/Alt Left/Up/Alt Right
        [
          FlxG.save.data.leftBind,
          FlxG.save.data.downBind,
          FlxG.save.data.rightBind,
          FlxG.save.data.centerBind,
          FlxG.save.data.altLeft9KBind,
          FlxG.save.data.altUp9KBind,
          FlxG.save.data.altRight9KBind
        ];
      case 8:
        // God Eater Shaggy Minus Space
        // 8-key: Left/Down/Up/Right/Alt Left/Alt Down/Alt Up/Alt Right
        [
          FlxG.save.data.leftBind,
          FlxG.save.data.downBind,
          FlxG.save.data.upBind,
          FlxG.save.data.rightBind,
          FlxG.save.data.altLeft9KBind,
          FlxG.save.data.altDown9KBind,
          FlxG.save.data.altUp9KBind,
          FlxG.save.data.altRight9KBind
        ];
      case 9:
        // God Eater Shaggy
        // 9-key: Left/Down/Right/Center/Alt Left/Up/Alt Right
        [
          FlxG.save.data.left9KBind,
          FlxG.save.data.down9KBind,
          FlxG.save.data.up9KBind,
          FlxG.save.data.right9KBind,
          FlxG.save.data.centerBind,
          FlxG.save.data.altLeft9KBind,
          FlxG.save.data.altDown9KBind,
          FlxG.save.data.altUp9KBind,
          FlxG.save.data.altRight9KBind
        ];
      default:
        trace('ERROR: Unknown strumlineSize when polling key binds: ' + strumlineSize);
        return [];
    }
  }

  public static final KEYCODE_DOWN = 37;
  public static final KEYCODE_LEFT = 40;
  public static final KEYCODE_UP = 38;
  public static final KEYCODE_RIGHT = 39;

  private static function handleArrowKeys(keyCode:Int, strumlineSize:Int = 4):Int {
    switch (strumlineSize) {
      // case 1: No arrow support.
      case 2:
        return switch (keyCode) {
          case KEYCODE_DOWN: 0;
          case KEYCODE_UP: 1;
          default: -1;
        };
      case 3:
        return switch (keyCode) {
          case KEYCODE_LEFT: 0;
          case KEYCODE_UP: 1;
          case KEYCODE_RIGHT: 2;
          default: -1;
        };
      case 4:
        return switch (keyCode) {
          case KEYCODE_LEFT: 0;
          case KEYCODE_DOWN: 1;
          case KEYCODE_UP: 2;
          case KEYCODE_RIGHT: 3;
          default: -1;
        };
      case 5:
        return switch (keyCode) {
          case KEYCODE_LEFT: 0;
          case KEYCODE_DOWN: 1;
          // CENTER
          case KEYCODE_UP: 3;
          case KEYCODE_RIGHT: 4;
          default: -1;
        };
      // Exclude 6,7,8,9 key.
      default:
        return -1;
    }
  }

  /**
   * [Description] Given a KeyboardEvent and the strumline size for this song,
   * return what note index was pressed (or released), if any.
   * @param event Key that was just pressed or released.
   * @param strumlineSize Song's strumline size.
   * @return Int Note index pressed.
   */
  public static function getKeyNoteData(event:KeyboardEvent, strumlineSize:Int = 4):Int {
    var arrowResult = handleArrowKeys(event.keyCode, strumlineSize);
    if (arrowResult != -1) {
      return arrowResult;
    }

    var key = FlxKey.toStringMap.get(event.keyCode);
    var binds = getKeyBinds(strumlineSize);

    // Check if proper binds were found for this strumline size.
    if (binds.length == 0) {
      return -1;
    }
    for (i in 0...binds.length) {
      if (binds[i].toLowerCase() == key.toLowerCase()) {
        // This was the key pressed!
        return i;
      }
    }
    // No result found.
    return -1;
  }

  private static final CHARTER_COLUMN_MAP:Array<Int> = [
    NOTE_BASE_LEFT, NOTE_BASE_DOWN, NOTE_BASE_UP, NOTE_BASE_RIGHT,
    NOTE_9K_CENTER,
    NOTE_9K_LEFT, NOTE_9K_DOWN, NOTE_9K_UP, NOTE_9K_RIGHT,
    NOTE_BASE_LEFT_ENEMY, NOTE_BASE_DOWN_ENEMY, NOTE_BASE_UP_ENEMY, NOTE_BASE_RIGHT_ENEMY,
    NOTE_9K_CENTER_ENEMY,
    NOTE_9K_LEFT_ENEMY, NOTE_9K_DOWN_ENEMY, NOTE_9K_UP_ENEMY, NOTE_9K_RIGHT_ENEMY
  ];
  public static function getNoteDataFromCharterColumn(column:Int) {
    // Return -1 if value is invalid.
    if (column >= CHARTER_COLUMN_MAP.length) return -1;
    return CHARTER_COLUMN_MAP[column];
  }

  /**
   * Given a strumline size, outputs data on whether each corresponding key in the strumline is held.
   */
  public static function getKeyControlData(controls:CustomControls, strumlineSize:Int = 4) {
    return switch (strumlineSize) {
      case 1: [controls.CENTER_9K];
      case 2: [controls.DOWN, controls.UP];
      case 3: [controls.LEFT, controls.UP, controls.RIGHT];
      case 4: [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
      case 5: [controls.LEFT, controls.DOWN, controls.CENTER_9K, controls.UP, controls.RIGHT];
      case 6: [
              controls.LEFT_9K, controls.DOWN_9K,   controls.RIGHT_9K,
          controls.LEFT_ALT_9K,   controls.UP_9K, controls.RIGHT_ALT_9K
        ];
      case 7: [
          controls.LEFT_9K,
          controls.DOWN_9K,
          controls.RIGHT_9K,
          controls.CENTER_9K,
          controls.LEFT_ALT_9K,
          controls.UP_9K,
          controls.RIGHT_ALT_9K
        ];
      case 8: [
              controls.LEFT_9K,     controls.DOWN_9K,     controls.UP_9K,   controls.RIGHT_9K,
          controls.LEFT_ALT_9K, controls.DOWN_ALT_9K, controls.UP_ALT_9K, controls.RIGHT_ALT_9K
        ];
      case 9: [
          controls.LEFT_9K,
          controls.DOWN_9K,
          controls.UP_9K,
          controls.RIGHT_9K,
          controls.CENTER_9K,
          controls.LEFT_ALT_9K,
          controls.DOWN_ALT_9K,
          controls.UP_ALT_9K,
          controls.RIGHT_ALT_9K
        ];
      // Default to a strumline of 4.
      default: getKeyControlData(controls, 4);
    }
  }
}
