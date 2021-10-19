package funkin.ui.state.menu;

import funkin.behavior.play.Difficulty;
import flash.text.TextField;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.behavior.Debug;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.DiffCalc;
import funkin.behavior.play.Difficulty.DifficultyCache;
import funkin.behavior.play.Highscore;
import funkin.ui.audio.MainMenuMusic;
import funkin.ui.state.charting.ChartingState;
import funkin.util.assets.DataAssets;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;
import funkin.util.assets.SongAssets;
import funkin.util.Util;
import hx.strings.collection.StringArray;
#if FEATURE_DISCORD
import funkin.behavior.api.Discord.DiscordClient;
#end
import funkin.behavior.play.Song;
import funkin.behavior.play.Song.SongData;
import funkin.ui.component.Alphabet;
import funkin.ui.component.play.HealthIcon;
import funkin.ui.state.debug.AnimationDebug;
import funkin.ui.state.play.PlayState;
import openfl.media.Sound;
import openfl.utils.Future;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<FreeplaySongMetadata> = [];

	var selector:FlxText;

	public static var rate:Float = 1.0;

	public static var curSongIndex:Int = 0;
	public static var curDiffIndex:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var previewtext:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	var bg:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var openedPreview = false;

	/**
	 * The list of all the data for all the songs. Used to calculate difficulty.
	 * Replace Array with Map<String> to fix custom difficulty stuff.
	 */
	public static var songData:Map<String, Map<String, SongData>> = [];

	public static function loadDiff(diff:String, format:String, array:Map<String, SongData>)
	{
		var curSongData = Song.loadFromJson(format, DifficultyCache.getSuffix(diff));
		if (curSongData == null)
		{
			Debug.logError('ERROR in Freeplay trying to load song data: ${format} : ${diff}');
		}
		array.set(diff, curSongData);
	}

	override function create()
	{
		clean();

		populateSongData();

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(GraphicsAssets.loadImage('menuBackground'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 135, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		previewtext = new FlxText(scoreText.x, scoreText.y + 94, 0, "Rate: " + FlxMath.roundDecimal(rate, 2) + "x", 24);
		previewtext.font = scoreText.font;
		add(previewtext);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		add(scoreText);

		changeSelection();
		changeDiff();

		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	/**
	 * Load song data from the data files.
	 */
	static function populateSongData()
	{
		var initSonglist = DataAssets.loadLinesFromFile(Paths.txt('data/freeplaySonglist'));

		songData = [];
		songs = [];

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			var songId = data[0];

			var diffs:Map<String, SongData> = [];
			var diffsThatExist:Array<String> = [];

			// Scan for valid difficulties for this song.
			if (SongAssets.doesSongExist(songId, ''))
				diffsThatExist.push(DifficultyCache.defaultDifficulty);
			diffsThatExist = diffsThatExist.concat(SongAssets.listDifficultiesForSong(songId));

			// If none exist, display a popup (VERY high priority notification).
			if (diffsThatExist.length == 0)
			{
				Debug.displayAlert('${songId} Chart', "No difficulties found for chart, skipping.");
				continue;
			}

			// For each difficulty, load the SongData into the `diffs` array.
			for (diffThatExists in diffsThatExist)
			{
				FreeplayState.loadDiff(diffThatExists, songId, diffs);
			}

			var validDiff:SongData = diffs.get(diffs.keys().next());
			var meta = new FreeplaySongMetadata(songId, Std.parseInt(data[2]), data[1], validDiff.freeplayColor);

			meta.diffs = diffsThatExist;
			meta.songName = validDiff.songName;

			// Store the `diffs` array in the `songData` map.
			FreeplayState.songData.set(songId, diffs);
			trace('loaded ${meta.diffs.length} diffs for $songId');
			FreeplayState.songs.push(meta);
		}
		trace('Loaded diffs for ${FreeplayState.songs.length} songs.');
	}

	public function addSong(songId:String, weekNum:Int, songCharacter:String, color:String = "#9271FD")
	{
		songs.push(new FreeplaySongMetadata(songId, weekNum, songCharacter, color));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = FlxG.keys.justPressed.ENTER;
		var dadDebug = FlxG.keys.justPressed.SIX;
		var charting = FlxG.keys.justPressed.SEVEN;
		var bfDebug = FlxG.keys.justPressed.ZERO;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				changeSelection(1);
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				changeDiff(-1);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				changeDiff(1);
			}
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (FlxG.keys.pressed.SHIFT)
		{
			if (FlxG.keys.justPressed.LEFT)
			{
				rate -= 0.05;
				updateDifficultyText();
			}
			if (FlxG.keys.justPressed.RIGHT)
			{
				rate += 0.05;
				updateDifficultyText();
			}

			if (rate > 3)
			{
				rate = 3;
				updateDifficultyText();
			}
			else if (rate < 0.5)
			{
				rate = 0.5;
				updateDifficultyText();
			}

			previewtext.text = "Rate: " + FlxMath.roundDecimal(rate, 2) + "x";
		}
		else
		{
			if (FlxG.keys.justPressed.LEFT)
				changeDiff(-1);
			if (FlxG.keys.justPressed.RIGHT)
				changeDiff(1);
		}

		#if cpp
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, rate);
		}
		#end

		if (controls.BACK)
		{
			MainMenuMusic.playMenuMusic();
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			trace('Attempting to load current song...');
			loadSong();
		}
		else if (charting)
		{
			trace('Attempting to chart current song...');
			loadSong(true);
		}

		// AnimationDebug and StageDebug are only enabled in debug builds.
		#if debug
		if (dadDebug)
		{
			loadAnimDebug(true);
		}
		if (bfDebug)
		{
			loadAnimDebug(false);
		}
		#end
	}

	function updateDifficultyText()
	{
		var curSongId = songs[curSongIndex].songId;
		var curSongData = songData.get(curSongId);
		var curDiffData = DifficultyCache.getByIndex(curDiffIndex);
		var curSongCurDiff = curSongData.get(curDiffData.id);
		if (curSongCurDiff != null)
		{
			diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(curSongCurDiff)}';
			diffText.text = curDiffData.id;
		}
		else
		{
			Debug.logWarn('Song ${songs[curSongIndex].songName} (${songs[curSongIndex].songId}) has no difficulty ${curDiffIndex}, is this intended?');
			diffCalcText.text = 'RATING: N/A';
			diffText.text = '${DifficultyCache.getByIndex(curDiffIndex).id.toUpperCase()} (NOT AVAILABLE)';
		}
	}

	function loadAnimDebug(dad:Bool = true)
	{
		try
		{
			// First, get the song data.
			var curDiffData = DifficultyCache.getByIndex(curDiffIndex);
			var currentSongData = songData.get(songs[curSongIndex].songName).get(curDiffData.id);
			if (currentSongData == null)
				return;

			PlayState.SONG = Song.conversionChecks(currentSongData);

			var character = dad ? PlayState.SONG.player2 : PlayState.SONG.player1;

			LoadingState.loadAndSwitchState(new AnimationDebug(character));
		}
		catch (ex)
		{
			// Skip if we weren't able to retrieve the song data.
			return;
		}
	}

	function loadSong(isCharting:Bool = false)
	{
		loadSongInFreePlay(songs[curSongIndex].songId, DifficultyCache.getByIndex(curDiffIndex).id, isCharting);

		clean();
	}

	/**
	 * Load into a song in free play, by name.
	 * This is a static function, so you can call it anywhere.
	 * @param songId The id of the song to load. Use the internal ID, with dashes.
	 * @param isCharting If true, load into the Chart Editor instead.
	 */
	public static function loadSongInFreePlay(songId:String, difficultyId:String, isCharting:Bool, reloadSong:Bool = false)
	{
		// Make sure song data is initialized first.
		if (songData == null || Lambda.count(songData) == 0)
			populateSongData();

		var currentSongData;
		try
		{
			if (songData.get(songId) == null)
				return;
			currentSongData = songData.get(songId)[difficultyId];
			if (songData.get(songId).get(difficultyId) == null)
				return;
		}
		catch (ex)
		{
			return;
		}

		PlayState.SONG = Song.conversionChecks(currentSongData);
		PlayState.storyWeek = null;
		PlayState.storyDifficulty = difficultyId;
		Debug.logInfo('Loading song ${PlayState.SONG.songId} from week ${PlayState.storyWeek} into Free Play...');

		PlayState.songMultiplier = rate;

		if (isCharting)
			LoadingState.loadAndSwitchState(new ChartingState(reloadSong));
		else
			LoadingState.loadAndSwitchState(new PlayState());
	}

	function changeDiff(change:Int = 0)
	{
		curDiffIndex += change;

		if (curDiffIndex < 0)
			curDiffIndex = DifficultyCache.difficultyList.length - 1;
		if (curDiffIndex > (DifficultyCache.difficultyList.length - 1))
			curDiffIndex = 0;

		// Only allow VALID difficulties. We may need to skip again.
		if (!songs[curSongIndex].diffs.contains(DifficultyCache.getByIndex(curDiffIndex).id))
		{
			if (change != 0)
			{
				changeDiff(change);
			}
			return;
		}

		intendedScore = Highscore.getScore(songs[curSongIndex].songId, DifficultyCache.getByIndex(curDiffIndex).id);
		combo = Highscore.getCombo(songs[curSongIndex].songId, DifficultyCache.getByIndex(curDiffIndex).id);
		updateDifficultyText();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSongIndex += change;

		if (curSongIndex < 0)
			curSongIndex = songs.length - 1;
		if (curSongIndex >= songs.length)
			curSongIndex = 0;

		var curDiffId = DifficultyCache.getByIndex(curDiffIndex).id;

		// Does existing difficulty count?
		if (songs[curSongIndex] != null && !songs[curSongIndex].diffs.contains(curDiffId))
		{
			curDiffIndex = DifficultyCache.indexOfId(songs[curSongIndex].diffs[0]);
		}

		// Recolor the background.
		this.bg.color = songs[curSongIndex].color;

		intendedScore = Highscore.getScore(songs[curSongIndex].songId, curDiffId);
		combo = Highscore.getCombo(songs[curSongIndex].songId, curDiffId);

		updateDifficultyText();

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSongIndex].songId), 0);
		#end

		try
		{
			var curDiffId = DifficultyCache.getByIndex(curDiffIndex).id;
			var songDataCurrentDiff = songData.get(songs[curSongIndex].songId).get(curDiffId);
			if (songDataCurrentDiff != null)
			{
				Conductor.changeBPM(songDataCurrentDiff.bpm);
			}
		}
		catch (ex)
		{
		}

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSongIndex].alpha = 1;

		var memberSongIndex:Int = 0;
		for (item in grpSongs.members)
		{
			item.targetY = memberSongIndex - curSongIndex;
			memberSongIndex++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}

class FreeplaySongMetadata
{
	public var songName:String = "";
	public var songId:String = "";
	public var color:FlxColor;
	public var week:Int = 0;
	public var songCharacter:String = "";

	public var diffs:Array<String> = [];

	public function new(song:String, week:Int, songCharacter:String, ?color = "#9271FD")
	{
		this.songId = song;
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = FlxColor.fromString(color);
	}
}
