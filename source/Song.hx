import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

class Event {
  public var name:String;
  public var position:Float;
  public var value:Float;
  public var type:String;

  public function new(name:String, pos:Float, value:Float, type:String) {
    this.name = name;
    this.position = pos;
    this.value = value;
    this.type = type;
  }
}

typedef SwagSong = {
  var chartVersion:String;
  var song:String;
  var notes:Array<SwagSection>;
  var eventObjects:Array<Event>;
  var bpm:Float;
  var needsVoices:Bool;
  var speed:Float;

  var player1:String;
  var player2:String;
  var gfVersion:String;
  var stage:String;
  var ?noteStyle:String;
  var ?validScore:Bool;
  var ?strumlineSize:Int;
}

class Song {
  public static var latestChart:String = "KE1";

  public var chartVersion:String;
  public var song:String;
  public var notes:Array<SwagSection>;
  public var bpm:Float;
  public var needsVoices:Bool = true;
  public var eventObjects:Array<Event>;
  public var speed:Float = 1;

  public var player1:String = "bf";
  public var player2:String = "dad";
  public var gfVersion:String = "";
  public var noteStyle:String = "";
  public var stage:String = "";

  public function new(song, notes, bpm) {
    this.song = song;
    this.notes = notes;
    this.bpm = bpm;
  }

  public static function loadFromJsonRAW(rawJson:String) {
    while (!rawJson.endsWith("}")) {
      rawJson = rawJson.substr(0, rawJson.length - 1);
      // LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
    }

    return parseJSONshit(rawJson);
  }

  public static function validateSongs(songFolders:Array<String>, curDifficulty:Int):Bool {
    // For each song in the list...
    for (i in 0...songFolders.length) {
      // Check the song's JSON file exists.
      var songName = StoryMenuState.fixSongName(songFolders[i]);
      if (!validateSong(songName, curDifficulty)) {
        return false;
      }
    }
    // Validation completed.
    return true;
  }

  public static function validateSong(songFolder:String, curDifficulty:Int):Bool {
    var songFolderFormat = StringTools.replace(songFolder, " ", "-");
    var songJsonFile = Highscore.formatSong(songFolderFormat, curDifficulty);

    var songFolderLowercase = songFolderFormat.toLowerCase();

    var songDataPath = Paths.json(songFolderLowercase + "/" + songJsonFile.toLowerCase());

    var songExists = Assets.exists(songDataPath);

    // If any song doesn't exist, return false.
    return songExists;
  }

  public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
    // pre lowercasing the folder name
    var folderLowercase = StringTools.replace(folder, " ", "-").toLowerCase();
    switch (folderLowercase) {
      case "dad-battle":
        folderLowercase = "dadbattle";
      case "philly-nice":
        folderLowercase = "philly";
    }

    trace("loading " + folderLowercase + "/" + jsonInput.toLowerCase());

    try {
      var rawJson = Assets.getText(Paths.json(folderLowercase + "/" + jsonInput.toLowerCase())).trim();

      while (!rawJson.endsWith("}")) {
        rawJson = rawJson.substr(0, rawJson.length - 1);
      }

      return parseJSONshit(rawJson);
    }
    catch (err) {
      trace("ERROR: Couldn't load song!");
      return null;
    }
  }

  public static function conversionChecks(song:SwagSong):SwagSong {
    var ba = song.bpm;

    var index = 0;
    trace("conversion stuff " + song.song + " " + song.notes.length);
    var convertedStuff:Array<Song.Event> = [];

    if (song.eventObjects == null)
      song.eventObjects = [new Song.Event("Init BPM", 0, song.bpm, "BPM Change")];

    for (i in song.eventObjects) {
      var name = Reflect.field(i, "name");
      var type = Reflect.field(i, "type");
      var pos = Reflect.field(i, "position");
      var value = Reflect.field(i, "value");

      convertedStuff.push(new Song.Event(name, pos, value, type));
    }

    song.eventObjects = convertedStuff;

    if (song.noteStyle == null)
      song.noteStyle = "normal";

    if (song.gfVersion == null)
      song.gfVersion = "gf";

    TimingStruct.clearTimings();

    var currentIndex = 0;
    for (i in song.eventObjects) {
      if (i.type == "BPM Change") {
        var beat:Float = i.position;

        var endBeat:Float = Math.POSITIVE_INFINITY;

        TimingStruct.addTiming(beat, i.value, endBeat, 0); // offset in this case = start time since we don't have a offset

        if (currentIndex != 0) {
          var data = TimingStruct.AllTimings[currentIndex - 1];
          data.endBeat = beat;
          data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
          var step = ((60 / data.bpm) * 1000) / 4;
          TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
          TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
        }

        currentIndex++;
      }
    }

    for (i in song.notes) {
      var currentBeat = 4 * index;

      var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

      if (currentSeg == null)
        continue;

      var beat:Float = currentSeg.startBeat + (currentBeat - currentSeg.startBeat);

      if (i.changeBPM && i.bpm != ba) {
        trace("converting changebpm for section " + index);
        ba = i.bpm;
        song.eventObjects.push(new Song.Event("FNF BPM Change " + index, beat, i.bpm, "BPM Change"));
      }

      for (ii in i.sectionNotes) {
        if (song.chartVersion == null) {
          ii[3] = false;
          ii[4] = TimingStruct.getBeatFromTime(ii[0]);
        }

        if (ii[3] == 0)
          ii[3] == false;
      }

      index++;
    }

    song.chartVersion = latestChart;

    return song;
  }

  public static function parseJSONshit(rawJson:String):SwagSong {
    var swagShit:SwagSong = cast Json.parse(rawJson).song;

    /**
     * Default values.
     */

    if (swagShit.noteStyle == null) {
      swagShit.noteStyle = "normal";
    }

    if (swagShit.validScore == null) {
      swagShit.validScore = true;
    }

    if (swagShit.strumlineSize == null) {
      swagShit.strumlineSize = 4;
    }

    // conversion stuff
    for (section in swagShit.notes) {
      if (section.altAnim)
        section.CPUAltAnim = section.altAnim;
    }

    return swagShit;
  }
}
