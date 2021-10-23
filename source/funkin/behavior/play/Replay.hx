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
 * Replay.hx
 * Code used for replays. Pretty sure this is completely unused right now, will probably cut it.
 */
package funkin.behavior.play;

import funkin.behavior.options.Controls.Control;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import funkin.ui.state.play.PlayState;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import openfl.utils.Dictionary;
#if FEATURE_FILESYSTEM
import sys.io.File;
#end
import tjson.TJSON;

/**
 * An object representing a press made by the player,
 * along with their judgements, timing, and whether they hit the note.
 * This is saved during a replay and will be performed during replay playback.
 */
class ReplayInput
{
	/**
	 * The position in the song at which the key was pressed was hit.
	 */
	public var hitTime:Float;
	/**
	 * The 
	 */
	public var nearestNote:Array<Dynamic>;
	public var hit:Bool;
	public var hitJudge:String;
	public var key:Int;

	public function new(_hitTime:Float, _nearestNote:Array<Dynamic>, _hit:Bool, _hitJudge:String, _key:Int)
	{
		hitTime = _hitTime;
		nearestNote = _nearestNote;
		hit = _hit;
		hitJudge = _hitJudge;
		key = _key;
	}
}

typedef ReplayJSON =
{
	public var replayGameVer:String;
	public var timestamp:Date;
	public var songName:String;
  public var songId:String;
	public var songDifficulty:String;
	public var songNotes:Array<Dynamic>;
	public var songJudgements:Array<String>;
	public var noteSpeed:Float;
	public var chartPath:String;
	public var downscrollActive:Bool;
	public var safeFrames:Int;
	public var replayInputs:Array<ReplayInput>;
}

class Replay
{
	/**
	 * The version number included in each replay.
	 */
	public static final VERSION:String = "2.0";

	/**
	 * The path this replay is stored at.
	 */
	public var path:String = "";
  
	/**
	 * The JSON data contained in this replay.
	 */
	public var replay:ReplayJSON;

	public function new(path:String)
	{
		this.path = path;
    this.replay = generateStubReplay();
	}

  static function generateStubReplay() {
    return {
			replayGameVer: version,
			timestamp: Date.now(),
			songName: "No Song Found",
      songId: 'no-song',
			songDifficulty: 'normal',
			songNotes: [],
			songJudgements: [],
			noteSpeed: 1.5,
			chartPath: "",
			downscrollActive: false,
			safeFrames: Conductor.safeFrames,
			replayInputs: [],
		};
  }

	public static function LoadReplay(path:String):Replay
	{
		var rep:Replay = new Replay(path);

		rep.LoadFromJSON();

		trace('basic replay data:\nSong Name: ' + rep.replay.songName + '\nSong Diff: ' + rep.replay.songDiff);

		return rep;
	}

	public function SaveReplay(songNotes:Array<Dynamic>, songJudgements:Array<String>, replayInputs:Array<ReplayInput>)
	{
    // Skip this function entirely if we can't write to the filesystem.
    #if !FEATURE_FILESYSTEM
    return;
    #else
    // Write the chart as a file.

    // Encode as JSON.
    var noteSpeed = (FlxG.save.data.scrollSpeed > 1 ? FlxG.save.data.scrollSpeed : PlayState.SONG.speed);
		var json:ReplayJSON = {
			replayGameVer: version,
			timestamp: Date.now(),
			songName: PlayState.SONG.songName,
			songId: PlayState.SONG.songId,
			songDifficulty: PlayState.songDifficulty,
			songNotes: songNotes,
			songJudgements: songJudgements,
			noteSpeed: noteSpeed,
			chartPath: '', // Don't write the chart path.
			downscrollActive: FlxG.save.data.downscroll,
			safeFrames: Conductor.safeFrames,
			replayInputs: replayInputs
		};

		var data:String = TJSON.encode(json, "fancy");

		var time = Date.now().getTime();
		File.saveContent("replays/replay-" + PlayState.SONG.songId + "-time" + time + ".enigmaReplay", data);
		path = "replay-" + PlayState.SONG.songId + "-time" + time + ".enigmaReplay";

		LoadFromJSON();

		replay.replayInputs = replayInputs;
		#end
	}

	public function LoadFromJSON()
	{
		#if FEATURE_FILESYSTEM
		trace('loading ' + Sys.getCwd() + 'replays/' + path + ' replay...');
		try
		{
			var repl:ReplayJSON = cast TJSON.parse(File.getContent(Sys.getCwd() + "replays/" + path));
			replay = repl;
		}
		catch (e)
		{
			trace('failed!\n' + e.message);
		}
		#end
	}
}
