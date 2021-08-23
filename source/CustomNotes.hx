/**
 * A static class created to handle custom notes.
 */

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
   */
  private static final PIXEL_ZOOM = 6;

  private static final STRUMLINE_POS_WIDTH:Float = 160 * 0.7;

  /**
   * Stores which notes to use for the strumline for each strumlineSize value.
   */
  private static final STRUMLINE_DIR_NAMES:Map<Int, Array<String>> = [
    1 => ["Center"],
    4 => ["Left", "Down", "Up", "Right"],
    5 => ["Left", "Down", "Center", "Up", "Right"],
    6 => ["Left", "Down", "Right", "Left Alt", "Up", "Right Alt"],
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

  public static function getDirectionName(rawNoteData:Int):String {
    if (rawNoteData >= NOTE_OFFSET) {
      // This is a custom note type. Don't return 'Alt' direction names.
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
          trace("You tried to use a special note in the center lane! Custom animations need to be added for that.");
          return "Center";
        default:
          trace("Couldn't determine what animation to use for this special note!");
          return 'UNKNOWN';
      }
    } else {
      // This is a base note type. The result might be 'Alt Down' for example.
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

  public static function loadNoteSprite(instance:FlxSprite, noteStyle:String, noteData:Int, isSustainNote:Bool):Void {
    switch (noteStyle) {
      case STYLE_PIXEL:
        instance.frames = Paths.getSparrowAtlas('notes/Pixel9KNote', 'shared');
      default: // STYLE_NORMAL
        instance.frames = Paths.getSparrowAtlas('notes/9KNote', 'shared');
    }

    // Only add the animation for the note we are using.
    instance.animation.addByPrefix(getDirectionName(noteData) + ' Note', getDirectionName(noteData) + ' Note'); // Normal notes
    instance.animation.addByPrefix(getDirectionName(noteData) + ' Sustain', getDirectionName(noteData) + ' Sustain'); // Hold
    instance.animation.addByPrefix(getDirectionName(noteData) + ' End', getDirectionName(noteData) + ' End'); // Tails

    switch (noteStyle) {
      case STYLE_PIXEL:
        var widthSize = Std.int(PlayState.Stage.curStage.startsWith('school') ? (instance.width * PlayState.daPixelZoom) : (isSustainNote ? (instance.width * (PlayState.daPixelZoom
          - 1.5)) : (instance.width * PlayState.daPixelZoom)));

        instance.setGraphicSize(widthSize);
        instance.updateHitbox();
      // No anti-aliasing.
      default: // STYLE_NORMAL
        instance.setGraphicSize(Std.int(instance.width * 0.7));
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
      babyArrow.x += STRUMLINE_POS_WIDTH * i;

      // Cleanup the graphic.
      switch (noteStyle) {
        case STYLE_PIXEL:
          babyArrow.setGraphicSize(Std.int(babyArrow.width * PIXEL_ZOOM));
          babyArrow.updateHitbox();
          babyArrow.antialiasing = false;
        default: // STYLE_NORMAL
          babyArrow.antialiasing = FlxG.save.data.antialiasing;
          babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
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
}
