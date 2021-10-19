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

class Ana
{
	public var hitTime:Float;
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

class Analysis
{
	public var anaArray:Array<Ana>;

	public function new()
	{
		anaArray = [];
	}
}

typedef ReplayJSON =
{
	public var replayGameVer:String;
	public var timestamp:Date;
	public var songName:String;
	public var songDiff:String;
	public var songNotes:Array<Dynamic>;
	public var songJudgements:Array<String>;
	public var noteSpeed:Float;
	public var chartPath:String;
	public var isDownscroll:Bool;
	public var sf:Int;
	public var sm:Bool;
	public var ana:Analysis;
}

class Replay
{
	public static var version:String = "1.2"; // replay file version

	public var path:String = "";
	public var replay:ReplayJSON;

	public function new(path:String)
	{
		this.path = path;
		replay = {
			songName: "No Song Found",
			songDiff: 'normal',
			noteSpeed: 1.5,
			isDownscroll: false,
			songNotes: [],
			replayGameVer: version,
			chartPath: "",
			sm: false,
			timestamp: Date.now(),
			sf: Conductor.safeFrames,
			ana: new Analysis(),
			songJudgements: []
		};
	}

	public static function LoadReplay(path:String):Replay
	{
		var rep:Replay = new Replay(path);

		rep.LoadFromJSON();

		trace('basic replay data:\nSong Name: ' + rep.replay.songName + '\nSong Diff: ' + rep.replay.songDiff);

		return rep;
	}

	public function SaveReplay(notearray:Array<Dynamic>, judge:Array<String>, ana:Analysis)
	{
		var chartPath = "";

		var json = {
			"songName": PlayState.SONG.songName,
			"songId": PlayState.SONG.songId,
			"songDiff": PlayState.storyDifficulty,
			"chartPath": chartPath,
			"timestamp": Date.now(),
			"replayGameVer": version,
			"sf": Conductor.safeFrames,
			"noteSpeed": (FlxG.save.data.scrollSpeed > 1 ? FlxG.save.data.scrollSpeed : PlayState.SONG.speed),
			"isDownscroll": FlxG.save.data.downscroll,
			"songNotes": notearray,
			"songJudgements": judge,
			"ana": ana
		};

		var data:String = TJSON.encode(json, "fancy");

		var time = Date.now().getTime();

		#if FEATURE_FILESYSTEM
		File.saveContent("assets/replays/replay-" + PlayState.SONG.songId + "-time" + time + ".enigmaReplay", data);

		path = "replay-" + PlayState.SONG.songId + "-time" + time + ".enigmaReplay";

		LoadFromJSON();

		replay.ana = ana;
		#end
	}

	public function LoadFromJSON()
	{
		#if FEATURE_FILESYSTEM
		trace('loading ' + Sys.getCwd() + 'assets/replays/' + path + ' replay...');
		try
		{
			var repl:ReplayJSON = cast TJSON.parse(File.getContent(Sys.getCwd() + "assets/replays/" + path));
			replay = repl;
		}
		catch (e)
		{
			trace('failed!\n' + e.message);
		}
		#end
	}
}
