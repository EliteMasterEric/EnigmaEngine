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
 * Song.hx
 * A class used to hold data about a song, including its metadata
 * and its notes.
 */
package funkin.behavior.play;

import funkin.behavior.Debug;
import funkin.behavior.play.Section.SwagSection;
import funkin.behavior.play.Song.SongEvent;
import funkin.behavior.play.TimingStruct;
import funkin.util.assets.DataAssets;
import funkin.util.assets.LibraryAssets;
import funkin.util.assets.Paths;
import funkin.util.assets.SongAssets;
import tjson.TJSON;

using hx.strings.Strings;

class SongEvent
{
	public var name:String;
	public var position:Float;
	public var value:Float;
	public var type:String;

	public function new(name:String, pos:Float, value:Float, type:String)
	{
		this.name = name;
		this.position = pos;
		this.value = value;
		this.type = type;
	}
}

typedef SongData =
{
	@:deprecated
	var ?song:String;

	/**
	 * The readable name of the song, as displayed to the user.
	 * Can be any string.
	 */
	var ?songName:String;

	/**
	 * The internal name of the song, as used in the file system.
	 */
	var ?songId:String;

	/**
	 * The path of the song's instrumental and vocal files.
	 * @default The song ID.
	 */
	var ?songFile:String;

	var chartVersion:String;
	var notes:Array<SwagSection>;
	var eventObjects:Array<SongEvent>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	var ?offset:Int;
	var ?freeplayColor:String;
	var ?noteStyle:String;
	var ?validScore:Bool;
	var ?strumlineSize:Int;
}

typedef SongMeta =
{
	var ?offset:Int;
	var ?name:String;
	var ?freeplayColor:String;
}

class Song
{
	public static var latestChart:String = "KE1";

	public static function loadFromJsonRAW(rawJson:String)
	{
		// Sometimes files will have unknown garbage at the end, this fixes that.
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var jsonData = TJSON.parse(rawJson);
		var songData:SongData = cast jsonData.song;

		return parseJSONData("rawsong", songData, ["name" => jsonData.name]);
	}

	public static function loadFromJson(songId:String, diffSuffix:String):SongData
	{
		var songFile = '$songId/$songId$diffSuffix';

		Debug.logInfo('Loading song JSON: $songFile');

		var rawJson = DataAssets.loadJSON('songs/$songFile');

		var songData:SongData = cast rawJson.song;
		var metaData:SongMeta = loadMetadata(songId);

		return parseJSONData(songId, songData, metaData);
	}

	public static function loadMetadata(songId:String):SongMeta
	{
		var rawMetaJson = null;
		if (LibraryAssets.textExists(Paths.songMeta(songId)))
		{
			rawMetaJson = DataAssets.loadJSON('songs/$songId/_meta');
		}
		else
		{
			Debug.logInfo('Hey, you didn\'t include a _meta.json with your song files (id ${songId}).Won\'t break anything but you should probably add one anyway.');
		}
		if (rawMetaJson == null)
		{
			return null;
		}
		else
		{
			return cast rawMetaJson;
		}
	}

	/**
	 * For a given song, get its proper display name.
	 * This involves either loading the song metadata file or formatting the song ID, if there is none.
	 * @param songId 
	 * @return String
	 */
	public static function getSongName(songId:String):String
	{
		var songMeta = loadMetadata(songId);
		if (songMeta != null && songMeta.name != null && songMeta.name != "")
		{
			// Use the song name from the metadata file.
			return songMeta.name;
		}
		else
		{
			// Deduce the name. If you don't want this name format, specify the name you want in `_meta.json`
			// Example: dad-battle -> Dad Battle
			return songId.split('-').join(' ').toTitle();
		}
	}

	/**
	 * For a given list of song folders, verify that all of them possess the specified difficulty.
	 * Used to ensure a given week can be played.
	 * @param songIds An array of song IDs.
	 * @param curDifficulty A difficulty index to use.
	 * @return Whether all the song IDs can be played on that difficulty.
	 */
	public static function validateSongs(songIds:Array<String>, curDifficulty:String):Bool
	{
		// For each song in the list...
		for (songId in songIds)
		{
			// Get the path of the JSON file for that song ID and the chosen difficulty.
			// If that path doesn't exist, we can't play this week.
			if (!SongAssets.doesSongExist(songId, curDifficulty))
			{
				return false;
			}
		}
		// Validation completed.
		return true;
	}

	public static function conversionChecks(song:SongData):SongData
	{
		var ba = song.bpm;

		var index = 0;
		trace("conversion stuff " + song.songId + " " + song.notes.length);
		var convertedStuff:Array<SongEvent> = [];

		if (song.eventObjects == null)
			song.eventObjects = [new SongEvent("Init BPM", 0, song.bpm, "BPM Change")];

		for (i in song.eventObjects)
		{
			var name = Reflect.field(i, "name");
			var type = Reflect.field(i, "type");
			var pos = Reflect.field(i, "position");
			var value = Reflect.field(i, "value");

			convertedStuff.push(new SongEvent(name, pos, value, type));
		}

		song.eventObjects = convertedStuff;

		if (song.noteStyle == null)
			song.noteStyle = "normal";

		if (song.gfVersion == null)
			song.gfVersion = "gf";

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in song.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				TimingStruct.addTiming(beat, i.value, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
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

		for (i in song.notes)
		{
			if (i.altAnim)
				i.CPUAltAnim = i.altAnim;

			var currentBeat = 4 * index;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				continue;

			var beat:Float = currentSeg.startBeat + (currentBeat - currentSeg.startBeat);

			if (i.changeBPM && i.bpm != ba)
			{
				trace("converting changebpm for section " + index);
				ba = i.bpm;
				song.eventObjects.push(new SongEvent("FNF BPM Change " + index, beat, i.bpm, "BPM Change"));
			}

			for (ii in i.sectionNotes)
			{
				if (song.chartVersion == null)
				{
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

	public static function parseJSONData(songId:String, jsonData:Dynamic, jsonMetaData:Dynamic):SongData
	{
		if (jsonData == null)
			return null;
		var songData:SongData = cast jsonData;

		songData.songId = songId;

		var songMetaData:SongMeta = cast jsonMetaData;

		/**
		 * Default values.
		 */
		if (songData.noteStyle == null)
			songData.noteStyle = "normal";

		if (songData.songFile == null)
		{
			songData.songFile = songId;
		}
		else
		{
			trace('SONG DATA IS ${songData.songFile} BLABLABLA');
		}

		if (songData.strumlineSize == null)
			songData.strumlineSize = 4;

		if (songData.validScore == null)
			songData.validScore = true;

		// Inject info from _meta.json.
		if (songMetaData != null)
		{
			if (songMetaData.name != null)
			{
				songData.songName = songMetaData.name;
			}
			else
			{
				songData.songName = songId.split('-').join(' ').toTitle();
			}

			songData.offset = songMetaData.offset != null ? songMetaData.offset : 0;
			songData.freeplayColor = songMetaData.freeplayColor != null ? songMetaData.freeplayColor : "#9271FD";
		}

		return Song.conversionChecks(songData);
	}
}
