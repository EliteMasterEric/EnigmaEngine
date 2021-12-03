package funkin.behavior.data;

import funkin.behavior.data.Section.SwagSection;

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
