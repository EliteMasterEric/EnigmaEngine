package funkin.ui.state.menu;

import funkin.ui.audio.MainMenuMusic;
import flixel.FlxCamera;
import funkin.ui.state.charting.ChartingState;
import flash.text.TextField;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.assets.Paths;
import funkin.behavior.Debug;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.DiffCalc;
import funkin.behavior.play.Highscore;
import funkin.util.Util;
#if FEATURE_DISCORD
import funkin.behavior.api.Discord.DiscordClient;
#end
import funkin.assets.play.Song;
import funkin.assets.play.Song.SongData;
#if FEATURE_STEPMANIA
import funkin.behavior.stepmania.SMFile;
#end
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

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var previewtext:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var openedPreview = false;

	/**
	 * The list of all the data for all the songs. Used to calculate difficulty.
	 		* Replace Array with Map<Int> to fix custom difficulty stuff.
	 */
	public static var songData:Map<String, Map<Int, SongData>> = [];

	public static function loadDiff(diff:Int, format:String, array:Map<Int, SongData>)
	{
		var diffName:String = ["-easy", "", "-hard"][diff];
		var curSongData = Song.loadFromJson(format, diffName);
		if (curSongData == null)
		{
			Debug.logError('ERROR in Freeplay trying to load song data: ${format}');
		}
		array.set(diff, curSongData);
	}

	override function create()
	{
		clean();

		populateSongData();

		trace("tryin to load sm files");

		#if FEATURE_STEPMANIA
		// TODO: Refactor this to use OpenFlAssets.
		for (i in FileSystem.readDirectory("assets/sm/"))
		{
			trace(i);
			if (FileSystem.isDirectory("assets/sm/" + i))
			{
				trace("Reading SM file dir " + i);
				for (file in FileSystem.readDirectory("assets/sm/" + i))
				{
					if (file.contains(" "))
						FileSystem.rename("assets/sm/" + i + "/" + file, "assets/sm/" + i + "/" + file.replace(" ", "_"));
					if (file.endsWith(".sm") && !FileSystem.exists("assets/sm/" + i + "/converted.json"))
					{
						trace("reading " + file);
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new FreeplaySongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(data);
						songData.set(file.header.TITLE, [0 => song, 1 => song, 2 => song]);
					}
					else if (FileSystem.exists("assets/sm/" + i + "/converted.json") && file.endsWith(".sm"))
					{
						trace("reading " + file);
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ", "_"));
						trace("Converting " + file.header.TITLE);
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new FreeplaySongMetadata(file.header.TITLE, 0, "sm", file, "assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(File.getContent("assets/sm/" + i + "/converted.json"));
						trace("got content lol");
						songData.set(file.header.TITLE, [0 => song, 1 => song, 2 => song]);
					}
				}
			}
		}
		#end

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

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('menuBGBlue'));
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
		var initSonglist = Util.loadLinesFromFile(Paths.txt('data/freeplaySonglist'));

		songData = [];
		songs = [];

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			var songId = data[0];
			var meta = new FreeplaySongMetadata(songId, Std.parseInt(data[2]), data[1]);

			var diffs:Map<Int, SongData> = [];
			var diffsThatExist:Array<String> = [];

			#if FEATURE_FILESYSTEM
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-hard')))
				diffsThatExist.push("Hard");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId-easy')))
				diffsThatExist.push("Easy");
			if (Paths.doesTextAssetExist(Paths.json('songs/$songId/$songId')))
				diffsThatExist.push("Normal");

			if (diffsThatExist.length == 0)
			{
				Debug.displayAlert(meta.songName + " Chart", "No difficulties found for chart, skipping.");
				continue;
			}
			#else
			diffsThatExist = ["Easy", "Normal", "Hard"];
			#end
			if (diffsThatExist.contains("Easy"))
				FreeplayState.loadDiff(0, songId, diffs);
			if (diffsThatExist.contains("Normal"))
				FreeplayState.loadDiff(1, songId, diffs);
			if (diffsThatExist.contains("Hard"))
				FreeplayState.loadDiff(2, songId, diffs);

			meta.diffs = diffsThatExist;

			if (diffsThatExist.length != 3)
				trace("I ONLY FOUND " + diffsThatExist);

			FreeplayState.songData.set(songId, diffs);
			trace('loaded diffs for ' + songId);
			FreeplayState.songs.push(meta);
		}
		trace('Loaded diffs for ${FreeplayState.songs.length} songs.');
	}

	public function addSong(songId:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new FreeplaySongMetadata(songId, weekNum, songCharacter));
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
			loadSong();
		else if (charting)
			loadSong(true);

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
		var curSongId = songs[curSelected].songId;
		var curSongData = songData.get(curSongId);
		var curSongCurDiff = curSongData[curDifficulty];
		if (curSongCurDiff != null)
		{
			diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(curSongCurDiff)}';
			diffText.text = Util.difficultyFromInt(curDifficulty).toUpperCase();
		}
		else
		{
			Debug.logWarn('Song ${songs[curSelected].songName} (${songs[curSelected].songId}) has no difficulty ${curDifficulty}, is this intended?');
			diffCalcText.text = 'RATING: N/A';
			diffText.text = '${Util.difficultyFromInt(curDifficulty).toUpperCase()} (NOT AVAILABLE)';
		}
	}

	function loadAnimDebug(dad:Bool = true)
	{
		// First, get the song data.
		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm == null)
				return;
		}
		catch (ex)
		{
			return;
		}
		PlayState.SONG = Song.conversionChecks(hmm);

		var character = dad ? PlayState.SONG.player2 : PlayState.SONG.player1;

		LoadingState.loadAndSwitchState(new AnimationDebug(character));
	}

	function loadSong(isCharting:Bool = false)
	{
		loadSongInFreePlay(songs[curSelected].songName, curDifficulty, isCharting);

		clean();
	}

	/**
	 * Load into a song in free play, by name.
	 * This is a static function, so you can call it anywhere.
	 * @param songId The id of the song to load. Use the internal ID, with dashes.
	 * @param isCharting If true, load into the Chart Editor instead.
	 */
	// TODO: Fix references
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
			currentSongData = songData.get(songId)[difficulty];
			if (songData.get(songId)[difficulty] == null)
				return;
		}
		catch (ex)
		{
			return;
		}

		PlayState.SONG = Song.conversionChecks(currentSongData);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = difficultyId;
		PlayState.storyWeek = songs[curSelected].week;
		Debug.logInfo('Loading song ${PlayState.SONG.songId} from week ${PlayState.storyWeek} into Free Play...');
		#if FEATURE_STEPMANIA
		if (songs[curSelected].songCharacter == "sm")
		{
			Debug.logInfo('Song is a StepMania song!');
			PlayState.isSM = true;
			PlayState.sm = songs[curSelected].sm;
			PlayState.pathToSm = songs[curSelected].path;
		}
		else
			PlayState.isSM = false;
		#else
		PlayState.isSM = false;
		#end

		PlayState.songMultiplier = rate;

		if (isCharting)
			LoadingState.loadAndSwitchState(new ChartingState(reloadSong));
		else
			LoadingState.loadAndSwitchState(new PlayState());
	}

	function changeDiff(change:Int = 0)
	{
		if (!songs[curSelected].diffs.contains(Util.difficultyFromInt(curDifficulty + change)))
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		updateDifficultyText();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (songs[curSelected].diffs.length != 3)
		{
			switch (songs[curSelected].diffs[0])
			{
				case "Easy":
					curDifficulty = 0;
				case "Normal":
					curDifficulty = 1;
				case "Hard":
					curDifficulty = 2;
			}
		}

		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
			case 'M.I.L.F':
				songHighscore = 'Milf';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end

		updateDifficultyText();

		#if PRELOAD_ALL
		if (songs[curSelected].songCharacter == "sm")
		{
			var data = songs[curSelected];
			trace("Loading " + data.path + "/" + data.sm.header.MUSIC);
			var bytes = File.getBytes(data.path + "/" + data.sm.header.MUSIC);
			var sound = new Sound();
			sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
			FlxG.sound.playMusic(sound);
		}
		else
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songId), 0);
		#end

		try
		{
			var songDataCurrentDiff = songData.get(songs[curSelected].songId)[curDifficulty];
			if (songDataCurrentDiff != null)
			{
				Conductor.changeBPM(songDataCurrentDiff.bpm);
			}
		}
		catch (ex)
		{
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

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
	public var week:Int = 0;
	#if FEATURE_STEPMANIA
	public var sm:SMFile;
	public var path:String;
	#end
	public var songCharacter:String = "";

	public var diffs = [];

	#if FEATURE_STEPMANIA
	public function new(song:String, week:Int, songCharacter:String, ?sm:SMFile = null, ?path:String = "")
	{
		this.songId = song;
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songId = song;
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
	#end
}
