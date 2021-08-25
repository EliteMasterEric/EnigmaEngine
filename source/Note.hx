import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
#if polymod
#end

using StringTools;

class Note extends FlxSprite {
  public var strumTime:Float = 0;
  public var baseStrum:Float = 0;

  public var charterSelected:Bool = false;

  public var rStrumTime:Float = 0;

  public var mustPress:Bool = false;
  public var noteData:Int = 0;
  public var rawNoteData:Int = 0;
  public var canBeHit:Bool = false;
  public var tooLate:Bool = false;
  public var wasGoodHit:Bool = false;
  public var prevNote:Note;
  public var modifiedByLua:Bool = false;
  public var sustainLength:Float = 0;
  public var isSustainNote:Bool = false;
  public var originColor:Int = 0; // The sustain note's original note's color
  public var noteSection:Int = 0;

  public var luaID:Int = 0;

  public var isAlt:Bool = false;

  public var noteCharterObject:FlxSprite;

  public var noteScore:Float = 1;

  public var noteYOff:Int = 0;

  public var beat:Float = 0;

  public static var swagWidth:Float = 160 * 0.7;
  public static var PURP_NOTE:Int = 0;
  public static var GREEN_NOTE:Int = 2;
  public static var BLUE_NOTE:Int = 1;
  public static var RED_NOTE:Int = 3;

  public var rating:String = "shit";

  public var modAngle:Float = 0; // The angle set by modcharts
  public var localAngle:Float = 0; // The angle to be edited inside Note.hx
  public var originAngle:Float = 0; // The angle the OG note of the sus note had (?)

  public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
  public var quantityColor:Array<Int> = [RED_NOTE, 2, BLUE_NOTE, 2, PURP_NOTE, 2, GREEN_NOTE, 2];
  public var arrowAngles:Array<Int> = [180, 90, 270, 0];

  public var isParent:Bool = false;
  public var parent:Note = null;
  public var spotInLine:Int = 0;
  public var sustainActive:Bool = true;

  public var children:Array<Note> = [];

  public function new(strumTime:Float, rawNoteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, ?isAlt:Bool = false,
      ?bet:Float = 0) {
    super();

    if (prevNote == null) {
      prevNote = this;
    }

    beat = bet;

    this.isAlt = isAlt;

    this.prevNote = prevNote;
    isSustainNote = sustainNote;

    x += 50;
    // MAKE SURE ITS DEFINITELY OFF SCREEN?
    y -= 2000;

    if (inCharter) {
      this.strumTime = strumTime;
      rStrumTime = strumTime;
    } else {
      this.strumTime = strumTime;
      #if sys
      if (PlayState.isSM) {
        rStrumTime = strumTime;
      } else {
        rStrumTime = strumTime;
      }
      #else
      rStrumTime = strumTime;
      #end
    }

    if (this.strumTime < 0) {
      this.strumTime = 0;
    }

    if (!inCharter) {
      y += FlxG.save.data.offset + PlayState.songOffset;
    }

    this.rawNoteData = rawNoteData;
    this.noteData = CustomNoteUtils.getStrumlineIndex(rawNoteData, PlayState.SONG.strumlineSize);

    // defaults if no noteStyle was found in chart
    var noteTypeCheck:String = 'normal';

    if (inCharter) {
      // We are in the Song Editor tool!

      // Add special handling to get the current note type from there.
      if (ChartingState._song != null) {
        noteTypeCheck = ChartingState._song.noteStyle;
      }
    } else {
      if (PlayState.SONG.noteStyle == null) {
        switch (PlayState.storyWeek) {
          case 6:
            noteTypeCheck = 'pixel';
        }
      } else {
        noteTypeCheck = PlayState.SONG.noteStyle;
      }
    }

    // All the code that was in here has been moved to a different file.
    // That makes it really easy for me to add new notes.
    CustomNotes.loadNoteSprite(this, noteTypeCheck, this.rawNoteData, isSustainNote, PlayState.SONG.strumlineSize);

    x += CustomNoteUtils.getNoteOffset(this.noteData, PlayState.SONG.strumlineSize);

    animation.play(CustomNotes.getDirectionName(this.rawNoteData, true) + ' Note');
    originColor = this.rawNoteData; // The note's origin color will be checked by its sustain notes

    if (FlxG.save.data.stepMania && !isSustainNote && !PlayState.instance.executeModchart) {
      var col:Int = 0;

      var beatRow = Math.round(beat * 48);

      // STOLEN ETTERNA CODE (IN 2002)

      if (beatRow % (192 / 4) == 0)
        col = quantityColor[0];
      else if (beatRow % (192 / 8) == 0)
        col = quantityColor[2];
      else if (beatRow % (192 / 12) == 0)
        col = quantityColor[4];
      else if (beatRow % (192 / 16) == 0)
        col = quantityColor[6];
      else if (beatRow % (192 / 24) == 0)
        col = quantityColor[4];
      else if (beatRow % (192 / 32) == 0)
        col = quantityColor[4];

      animation.play(CustomNotes.getDirectionName(col, true) + ' Note');
      localAngle -= arrowAngles[col];
      localAngle += arrowAngles[noteData];
      originAngle = localAngle;
      originColor = col;
    }

    // we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
    // and flip it so it doesn't look weird.
    // THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
    // then what is this lol
    // BRO IT LITERALLY SAYS IT FLIPS IF ITS A TRAIL AND ITS DOWNSCROLL
    if (FlxG.save.data.downscroll && sustainNote)
      flipY = true;

    var stepHeight = (((0.45 * Conductor.stepCrochet)) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
      2));

    // we can't divide step height cuz if we do uh it'll fucking lag the shit out of the game

    if (isSustainNote && prevNote != null) {
      noteScore * 0.2;
      alpha = 0.6;

      x += width / 2;

      originColor = prevNote.originColor;
      originAngle = prevNote.originAngle;

      // This works both for normal colors and quantization colors
      animation.play(CustomNotes.getDirectionName(originColor, true) + ' End');
      updateHitbox();

      x -= width / 2;

      // if (noteTypeCheck == 'pixel')
      //	x += 30;
      if (inCharter)
        x += 30;

      if (prevNote.isSustainNote) {
        prevNote.animation.play(CustomNotes.getDirectionName(prevNote.originColor, true) + ' Sustain');
        prevNote.updateHitbox();

        prevNote.scale.y *= (stepHeight + 1) / prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
        prevNote.updateHitbox();
        prevNote.noteYOff = Math.round(-prevNote.offset.y);

        // prevNote.setGraphicSize();

        noteYOff = Math.round(-offset.y);
      }
    }
  }

  override function update(elapsed:Float) {
    super.update(elapsed);
    if (!modifiedByLua)
      angle = modAngle + localAngle;
    else
      angle = modAngle;

    if (!modifiedByLua) {
      if (!sustainActive) {
        alpha = 0.3;
      }
    }

    // ERIC: Every frame, each note tracks if it is in range of the strumline.
    // This is done by song position. Did you really think it was based on sprite position?
    // This also means that you don't need special handling to make moving the strumline
    // with modcharts work properly.

    // If the note is on our side of the board...
    if (mustPress) {
      // If it's a sustain note...
      if (isSustainNote) {
        // Check the strumtime. If it's close enough ahead or behind...
        // There's slightly different logic for the sustain notes...
        if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1) * 0.5))
          && strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1)))) {
          // ...we can hit this note.
          canBeHit = true;
        } else {
          // ...we can't hit this note.
          canBeHit = false;
        }
      } else {
        // Check the strumtime. If it's close enough ahead or behind...
        if (strumTime - Conductor.songPosition <= (((166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1)))
          && strumTime - Conductor.songPosition >= (((-166 * Conductor.timeScale) / (PlayState.songMultiplier < 1 ? PlayState.songMultiplier : 1)))) {
          // ...we can hit this note.
          canBeHit = true;
        } else {
          // ...we can't hit this note.
          canBeHit = false;
        }
      }
      /*if (strumTime - Conductor.songPosition < (-166 * Conductor.timeScale) && !wasGoodHit)
        tooLate = true; */
    } else {
      canBeHit = false;

      if (strumTime <= Conductor.songPosition) {
        wasGoodHit = true;
      }
    }

    if (tooLate && !wasGoodHit) {
      if (alpha > 0.3) {
        alpha = 0.3;
      }
    }
  }
}
