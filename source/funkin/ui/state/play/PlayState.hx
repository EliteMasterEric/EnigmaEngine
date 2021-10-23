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
 * PlayState.hx
 * The state which contains all the business and rendering logic
 * for actual gameplay, in Free Play and Story Mode.
 */
package funkin.ui.state.play;

import funkin.behavior.play.Scoring;
import funkin.behavior.play.Scoring.SongScore;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import funkin.behavior.play.Week;
import funkin.behavior.play.Song.SongData;
import funkin.behavior.play.Song.SongEvent;
import funkin.util.assets.GraphicsAssets;
import funkin.behavior.Debug;
import funkin.behavior.EtternaFunctions;
import funkin.behavior.media.GlobalVideo;
import funkin.behavior.media.WebmHandler;
import funkin.behavior.options.CustomControls;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.EnigmaNote;
import funkin.behavior.play.Highscore;
import funkin.behavior.play.PlayStateChangeables;
import funkin.behavior.play.Replay;
import funkin.behavior.play.Replay.ReplayNote;
import funkin.behavior.play.Section.SwagSection;
import funkin.behavior.play.Song;
import funkin.behavior.play.TimingStruct;
import funkin.ui.audio.MainMenuMusic;
import funkin.ui.component.Cursor;
import funkin.behavior.play.Difficulty.DifficultyCache;
import funkin.ui.component.play.Boyfriend;
import funkin.ui.component.play.Character;
import funkin.ui.component.play.DialogueBox;
import funkin.ui.component.play.HealthIcon;
import funkin.ui.component.play.Note;
import funkin.ui.component.play.Stage;
import funkin.ui.component.play.StrumlineArrow;
import funkin.ui.state.debug.WaveformTestState;
import funkin.ui.effects.WiggleEffect;
import funkin.ui.effects.WiggleEffect.WiggleEffectType;
import funkin.ui.state.charting.ChartingState;
import funkin.ui.state.debug.AnimationDebug;
import funkin.ui.state.debug.StageDebugState;
import funkin.ui.state.menu.FreeplayState;
import funkin.ui.state.menu.StoryMenuState;
import funkin.ui.state.options.OptionsMenu;
import funkin.ui.state.play.GameOverSubstate;
import funkin.ui.state.play.PauseSubState;
import funkin.util.assets.DataAssets;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;
import funkin.util.Util;
import funkin.util.NoteUtil;
import funkin.util.assets.LibraryAssets;
import haxe.EnumTools;
import haxe.Exception;
import lime.app.Application;
import lime.graphics.Image;
import lime.media.AudioContext;
import lime.media.AudioManager;
import lime.media.openal.AL;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import openfl.geom.Matrix;
import openfl.Lib;
import openfl.media.Sound;
import openfl.ui.Keyboard;
import openfl.ui.KeyLocation;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetManifest;
import openfl.utils.AssetType;
#if FEATURE_LUAMODCHART
import funkin.behavior.modchart.ModchartHandler;
import funkin.behavior.modchart.LuaClass;
import funkin.behavior.modchart.LuaClass.LuaCamera;
import funkin.behavior.modchart.LuaClass.LuaCharacter;
import funkin.behavior.modchart.LuaClass.LuaNote;
#end
#if FEATURE_FILESYSTEM
import sys.io.File;
import Sys;
import sys.FileSystem;
#end
#if FEATURE_WEBM
import webm.WebmPlayer;
#end
#if FEATURE_DISCORD
import funkin.behavior.api.Discord.DiscordClient;
#end

using hx.strings.Strings;

class PlayState extends MusicBeatState
{

  //
  // CONSTANTS
  //
  
	public static final NOTE_TIME_TO_DISTANCE = 0.45;

  // If the Conductor is more than 20ms off, resync the vocals.
  static final MAX_TIME_DESYNC = 20;

  // Every nth beat (default fourth), the camera zooms in a bit.
  static final CAMERA_BEAT_ZOOM_GAME = 0.015;
  // The HUD camera zooms in twice as much.
  static final CAMERA_BEAT_ZOOM_HUD = CAMERA_BEAT_ZOOM_GAME * 2;
  // We only let the camera zoom so much from this effect.
  static final CAMERA_MAX_ZOOM = 1.35;

	//
	// STATE
	//

	/**
	 * Allow any part of the application to statically access the current PlayState, if it exists.
	 */
	public static var instance:PlayState = null;

	/**
	 * The next song to be played.
	 * To queue up a song for the PlayState to use, populate this value,
	 * then switch to the PlayState.
	 */
	public static var SONG:SongData;

	/**
	 * The current STAGE we are on!
   * Should handle all its own graphics, parts, and animations.
	 */
	public static var STAGE:Stage;

	/**
	 * The current story week being used.
	 * Set to null if the level is not in story mode.
	 */
	public static var storyWeek:Null<Week> = null;

	/**
	 * Returns whether the level is being played in story mode.
	 */
	public static function isStoryMode():Bool
	{
		return (storyWeek != null);
	}

	/**
	 * The player's current health. If it reaches `0.0`, it's game over.
	 * A value of `1.0` represents 50% health, and `2.0` represents 100% health.
	 */
	public var health:Float = 1;

	/**
	 * The current position in the story playlist.
	 */
	public static var storyPlaylistPos:Int = 0;

	/**
	 * Get the song ID of the song currently being played.
	 * @return Null<String>
	 */
	public static function getCurrentSongId():Null<String>
	{
		if (storyWeek == null)
			return null;
		return storyWeek.playlist[storyPlaylistPos];
	}

	/**
	 * The current difficulty being used by the Play state.
   * Applies to both Freeplay and Story Mode.
	 */
	public static var songDifficulty:String = 'normal';

	/**
	 * The current song's speed multiplier. Cannot be less than x1.0.
	 * For example, if this value is set to `1.5`, the song will play 50% faster.
	 */
	public static var songMultiplier(default, set):Float = 1.0;

	static function set_songMultiplier(value:Float):Float
	{
    // Make sure the song multiplier is never set to a value lower than 1.
		if (value < 1.0)
			PlayState.songMultiplier = 1.0;
		else
			PlayState.songMultiplier = value;

		return PlayState.songMultiplier;
	}

	/**
	 * Set to true when moving to the `ResultsSubState` to view your score.
	 */
	public var inResults:Bool = false;

  /**
	 * Whether downscroll is currently enabled. Defaults to current user preference,
	 * but may be changed by modcharts.
	 * Forcibly set when loading replays (to match the original user).
	 * @default `FlxG.save.data.downscroll`
	 */
	public static var downscrollActive:Bool = false;

	/**
	 * Whether this PlayState is currently in Bot Play mode.
	 * In this mode, all notes are hit automatically (with a watermark on screen).
	 */
	public static var botPlayActive:Bool = false;

	/**
	 * Whether this PlayState is currently in Replay mode.
	 * In this mode, the inputs from a file are replicated.
	 * This allows easily recording playthroughs without having to run external software.
	 */
	public static var replayActive:Bool = false;

	/**
	 * Whether the PlayState is currently paused and the pause menu is active.
	 */
	private var isPaused:Bool = false;

	/**
	 * This flag is activated when the PlayState is initialized
	 */
	private var startingSong:Bool = false;

	/**
	 * This flag is activated after the countdown completes and the player can press notes.
	 */
	private var songStarted = false;

	/**
	 * Whether the song has completed and we are in the process of cleaning up.
   * Inputs should be disabled, etc.
	 */
	private var endingSong:Bool = false;

	/**
	 * Whether the current song has a modchart.
	 */
	public var modchartActive = false;

  /**
   * Whether the Optimize option has been enabled,
   * which removes the stage, CPU character, and CPU strumline to minimize distraction.
   */
  public var optimizeActive = false;

	/**
	 * Whether there is a WEBM video being rendered on the stage.
	 */
	public var backgroundVideoActive = false;

  /**
   * Whether the background WebM video has been removed from the stage.
   */
  public var backgroundVideoRemoved = false;

  /**
   * The currently running replay.
   * In playback mode, this is the replay being played back,
   * otherwise it's the 
   */
  public static var currentReplay:Replay = null;

	/**
	 * A list of all the keys pressed by the user in the current replay,
   * along with their judgements, timing, and whether they hit the note.
   * The primary information stored in a replay.
	 */
	private var replayNotes:Array<ReplayNote> = [];

  /**
   * Flag that gets set when a character first starts singing.
   * While this is true, the camera will zoom in a bit every few beats.
   * Results in a visual 'unts unts unts' effect.
   */
  private var cameraBeatZooming = false;

  /**
   * While `cameraBeatZooming` is true, 
   * Set this to 0 to disable camera beat zooming,
   * or increase/decrease the value to change the beat zoom rate.
   */
  private var cameraBeatZoomRate = 4;

	/**
	 * The array of keys that are currently being pressed by the user.
   * Enigma Engine supports strumlines up to 9 notes long, and only the first X are used.
	 */
	private var currentKeysPressed:Array<Bool> = [false, false, false, false, false, false, false, false, false];

	#if FEATURE_DISCORD
	// Discord RPC variables
	private var iconRPC:String = '';
	private var detailsText:String = '';
	private var detailsPausedText:String = '';
	#end

	#if FEATURE_LUAMODCHART
  // Lua Modchart variables

	/**
	 * The currently active Lua Modchart.
   * Maintains the state and activates any callbacks, as necessary.
	 */
	public static var luaModchart:ModchartHandler = null;
	#end

	//
	// GRAPHICS
	//

	/**
	 * The sprite of the CPU character.
	 */
	public static var cpuChar:Character;

	/**
	 * The sprite of the background character.
	 */
	public static var gfChar:Character;

	/**
	 * The sprite of the player character.
	 */
	public static var playerChar:Boyfriend;

	/**
   * The health icon for the player character.
   */
  public var healthIconPlayer:HealthIcon;
	/**
   * The health icon for the CPU character.
   */
  public var healthIconCPU:HealthIcon;

	/**
	 * The graphic for the health bar
	 */
	private var healthBar:FlxBar;

	private var healthBarBG:FlxSprite;

	/**
	 * The core strumline. All strumline notes are children of it.
	 */
	public var strumLine:FlxSprite;

	/**
	 * The notes in the strumline.
	 */
	public static var strumLineNotes:FlxTypedGroup<StrumlineArrow> = null;

	/**
	 * The notes in the player's part of the strumline.
	 */
	public static var playerStrums:FlxTypedGroup<StrumlineArrow> = null;

	/**
	 * The notes in the CPU's part of the strumline.
	 */
	public static var cpuStrums:FlxTypedGroup<StrumlineArrow> = null;

	/**
	 * All the notes in play that the player can hit.
   * Notes are FlxSprites with metadata tied to them.
   * TODO: Should all the notes be loaded and processed at once, or should they be added within X seconds of being hit?
	 */
	public var songNotes:NoteGroup;

	/**
	 * The bar which displays the current position in the song.
	 */
	public static var songPosBar:FlxBar;

	// The variable which songPosBar is tied to.
	private var songPositionBar:Float = 0;

	/**
	 * The background for the songPosBar.
	 */
	public static var songPosBG:FlxSprite;

	/**
	 * The text at the bottom of the screen which displays the song name.
	 * In other engines this displays the engine version.
	 */
	private var songNameText:FlxText;

	/**
	 * The text that displays in the middle of the screen, and reads "BOTPLAY" or "REPLAY"
	 */
  private var botPlayState:FlxText;

	/**
	 * The text that displays in the bottom center of the screen, that displays the score, accuracy, and rating.
	 */
	private var scoreTxt:FlxText;

	/**
	 * All the visible combo number popups.
	 */
	public var visibleCombos:Array<FlxSprite> = [];

	

	var songLength:Float = 0;

	private var vocals:FlxSound;

	public var originalX:Float;

	private var unspawnNotes:Array<Note> = [];

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	private var ss:Bool = false;

	private var generatedMusic:Bool = false

	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	private var camGame:FlxCamera;

	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)
	var forcedToIdle:Bool = false; // change if bf and dad are forced to idle to every (idleBeat) beats of the song
	var allowedToHeadbang:Bool = true; // Will decide if gf is allowed to headbang depending on the song
	var allowedToCheer:Bool = false; // Will decide if gf is allowed to cheer depending on the song

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var songName:FlxText;

	var altSuffix:String = "";

	public var currentSection:SwagSection;

	var wiggleEffect:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;

	public var songScore:Int = 0;



	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;

	public static final PIXEL_ZOOM_FACTOR:Float = 6;

	public static var theFunne:Bool = true;

	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var stageTesting:Bool = false;

	var camPos:FlxPoint;


	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text

	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	/**
	 * A publicly accessible method to add a Flixel object to the stage.
	 * @param object The object to add.
	 */
	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	/**
	 * A publicly accessible method to remove a Flixel object from the stage.
	 * @param object The object to remove.
	 */
	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	/**
	 * Called when the PlayState stage is initialized.
	 */
	public override function create()
	{
		Debug.logTrace('Initializing PlayState...');

		// Initialize variables.
		PlayState.instance = this;
		PlayState.downscrollActive = FlxG.save.data.useDownscroll;
    PlayState.botPlayActive = FlxG.save.data.botplay;
		this.inResults = false;
    this.optimizeActive = FlxG.save.data.optimize;

		#if FEATURE_LUAMODCHART
		Debug.logInfo('Searching for mod chart at ${Paths.lua('songs/${PlayState.SONG.songId}/modchart')}...');
		var modchartFound = LibraryAssets.textExists(Paths.lua('songs/${PlayState.SONG.songId}/modchart'));
		if (modchartFound) {
      Debug.logInfo('Found a modchart for this song! Will be using it.');
      this.modchartActive = true;

      // Disable some annoying options that conflict with modcharts. optimize option since this messes with modcharts.
      this.optimizeActive = false;
      PlayState.songMultiplier = 1;
    } else {
      Debug.logInfo('No modchart found for this song.');
    }
		#end
		#if !cpp
    Debug.logTrace('Modcharts are disabled on this platform.');
		this.modchartActive = false; // FORCE disable for non cpp targets
		#end

		// Hide the cursor.
		Cursor.showCursor(false);

		// Set the frame cap for this state.
		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

    // Correct the camera zoom.
    if (FlxG.save.data.zoom < 0.8)
			FlxG.save.data.zoom = 0.8;

    // Correct the camera zoom.
		if (FlxG.save.data.zoom > 1.2)
			FlxG.save.data.zoom = 1.2;

		// Stop existing (i.e. menu) music.
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

    // Start recording a replay.
		if (!PlayState.replayActive)
			PlayState.currentReplay = new Replay("na");

		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		#if FEATURE_DISCORD
		iconRPC = PlayState.SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode())
		{
			detailsText = "Story Mode: " + storyWeek.title;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		Scoring.currentScore = new SongScore(songMultiplier);

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ PlayState.SONG.songName
			+ " ("
			+ PlayState.songDifficulty.toUpperCamel()
			+ ") "
			+ Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()),
			"\nAcc: "
			+ Util.truncateFloat(Scoring.currentScore.getAccuracy(), 2)
			+ "% | Score: "
			+ Scoring.currentScore.getScore()
			+ " | Misses: "
			+ Scoring.currentScore.miss,
			iconRPC);
		#end

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);

    camHUD.setFilters([new ShaderFilter(new CrosshatchShader())]);

		camHUD.zoom = PlayStateChangeables.zoom;

		// You have to do it this way, otherwise you'll break stuff.
		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', '');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		Conductor.bpm = PlayState.SONG.bpm;

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new SongEvent("Init BPM", 0, PlayState.SONG.bpm, "BPM Change")];
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in PlayState.SONG.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				var bpm = i.value;

				TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
				}

				currentIndex++;
			}
		}

		recalculateAllSectionTimes();

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayState.botPlayActive);

		// if the song has dialogue, so we don't accidentally try to load a nonexistant file and crash the game
		if (LibraryAssets.textExists(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue')))
		{
			dialogue = DataAssets.loadLinesFromFile(Paths.txt('data/songs/${PlayState.SONG.songId}/dialogue'));
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		// If the stage is specified in the chart, we use the story week value.
		// If it isn't, it'll display as the default. Make sure to fix it!
		if (SONG.stage != null)
		{
			stageCheck = PlayState.SONG.stage;
		}

		if (isStoryMode())
			songMultiplier = 1;

		// Make sure your song specifies which GF to use! Otherwise it'll revert to default.
		var gfCheck:String = PlayState.SONG.gfVersion != null ? PlayState.SONG.gfVersion : 'gf';

		if (!stageTesting)
		{
			gfChar = new Character(400, 130, gfCheck);
			if (gfChar.frames == null)
			{
				Debug.logWarn(["Couldn't load gf: " + gfCheck + ". Loading default gf"]);
				gfChar = new Character(400, 130, 'gf');
			}
			playerChar = new Boyfriend(770, 450, PlayState.SONG.player1);
			if (playerChar.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load player character: " + PlayState.SONG.player1 + ". Loading default boyfriend"]);
				#end
				playerChar = new Boyfriend(770, 450, 'bf');
			}
			cpuChar = new Character(100, 100, PlayState.SONG.player2);
			if (cpuChar.frames == null)
			{
				#if debug
				FlxG.log.warn(["Couldn't load CPU opponent: " + PlayState.SONG.player2 + ". Loading default dad"]);
				#end
				cpuChar = new Character(100, 100, 'dad');
			}
			STAGE = new Stage(SONG.stage);
		}
		var positions = STAGE.positions[STAGE.curStage];

		if (positions != null && !stageTesting)
		{
			for (char => pos in positions)
				for (person in [playerChar, gfChar, cpuChar])
					if (person.curCharacter == char)
						person.setPosition(pos[0], pos[1]);
		}
		for (i in STAGE.toAdd)
		{
			add(i);
		}
		if (!PlayStateChangeables.Optimize)
			for (index => array in STAGE.layInFront)
			{
				switch (index)
				{
					case 0:
						add(gfChar);
						gfChar.scrollFactor.set(0.95, 0.95);
						for (bg in array)
							add(bg);
					case 1:
						add(cpuChar);
						for (bg in array)
							add(bg);
					case 2:
						add(playerChar);
						for (bg in array)
							add(bg);
				}
			}
		camPos = new FlxPoint(cpuChar.getGraphicMidpoint().x, cpuChar.getGraphicMidpoint().y);
		switch (cpuChar.curCharacter)
		{
			case 'gf':
				if (!stageTesting)
					cpuChar.setPosition(gfChar.x, gfChar.y);
				gfChar.visible = false;
				if (isStoryMode())
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
			case 'senpai':
				camPos.set(cpuChar.getGraphicMidpoint().x + 300, cpuChar.getGraphicMidpoint().y);
			case 'senpai-angry':
				camPos.set(cpuChar.getGraphicMidpoint().x + 300, cpuChar.getGraphicMidpoint().y);
			case 'spirit':
				if (FlxG.save.data.distractions)
				{
					if (!PlayStateChangeables.Optimize)
					{
						var evilTrail = new FlxTrail(cpuChar, null, 4, 24, 0.3, 0.069);

						add(evilTrail);
					}
				}
				camPos.set(cpuChar.getGraphicMidpoint().x + 300, cpuChar.getGraphicMidpoint().y);
		}
		if (replayActive)
		{
			// Override useDownscroll to match the original player.
			PlayState.downscrollActive = PlayState.currentReplay.replay.isDownscroll;

			PlayStateChangeables.safeFrames = PlayState.currentReplay.replay.sf;

			PlayState.botPlayActive = true;
		}
		trace('uh ' + PlayStateChangeables.safeFrames);
		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
		var doof = null;

		if (isStoryMode())
		{
			doof = new DialogueBox(false, dialogue);
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;
		}
		if (!isStoryMode())
		{
			for (index => section in PlayState.SONG.notes)
			{
				if (section.sectionNotes.length > 0)
				{
					if (section.startTime > 5000)
					{
						needSkip = true;
						skipTo = section.startTime - 1000;
					}
					break;
				}
			}
		}

		// Reet the song position.
		Conductor.songPosition = -5000;
		Conductor.rawPosition = Conductor.songPosition;

		// Create the base strumline.
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		// Add notes to the strumline.
		strumLineNotes = new FlxTypedGroup<StrumlineArrow>();
		add(strumLineNotes);
		playerStrums = new FlxTypedGroup<StrumlineArrow>();
		cpuStrums = new FlxTypedGroup<StrumlineArrow>();

		generateStrumlineArrows(false);
		generateStrumlineArrows(true);

		if (SONG.songId == null)
		{
			Debug.logWarn('PlayState.SONG.songId is null!');
		}
		else
		{
			Debug.logTrace('PlayState.SONG.songId is ${SONG.songId}. Looks gucci, that\'s lit, fam.');
		}

		generateSong(SONG.songId);
		#if FEATURE_LUAMODCHART
		if (modchartActive)
		{
			PlayState.luaModchart = ModchartHandler.createModchartHandler(isStoryMode());
			PlayState.luaModchart.executeState('start', [PlayState.SONG.songId]);

			new LuaCamera(camGame, "camGame").Register(ModchartHandler.lua);
			new LuaCamera(camHUD, "camHUD").Register(ModchartHandler.lua);
			new LuaCamera(camSustains, "camSustains").Register(ModchartHandler.lua);
			new LuaCamera(camSustains, "camNotes").Register(ModchartHandler.lua);
			new LuaCharacter(cpuChar, "dad").Register(ModchartHandler.lua);
			new LuaCharacter(gfChar, "gf").Register(ModchartHandler.lua);
			new LuaCharacter(playerChar, "boyfriend").Register(ModchartHandler.lua);
		}
		#end
		var index = 0;

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...songNotes.members.length)
			{
				var dunceNote:Note = songNotes.members[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else
				{
					if (FlxG.save.data.downscroll)
					{
						if (!dunceNote.isCPUNote)
							dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
								2))
								- dunceNote.noteYOff;
						else
							dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
								2))
								- dunceNote.noteYOff;
					}
					else
					{
						if (!dunceNote.isCPUNote)
							dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
								2))
								+ dunceNote.noteYOff;
						else
							dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
								2))
								+ dunceNote.noteYOff;
					}
				}
			}
			for (i in toBeRemoved)
				songNotes.members.remove(i);
		}
		trace('generated');
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		FlxG.camera.zoom = STAGE.camZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;
		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(GraphicsAssets.loadImage('healthBar'));
			if (FlxG.save.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.songId.length * 5), songPosBG.y, 0, PlayState.SONG.songName, 16);

			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(GraphicsAssets.loadImage('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		if (FlxG.save.data.colour)
			healthBar.createFilledBar(cpuChar.barColor, playerChar.barColor);
		else
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);
		// Add song name and engine version
		songNameText = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.songName
			+ (FlxMath.roundDecimal(songMultiplier, 2) != 1.00 ? " (" + FlxMath.roundDecimal(songMultiplier, 2) + "x)" : "")
			+ " - "
			+ PlayState.songDifficulty.toUpperCamel(),
			16);
		songNameText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songNameText.scrollFactor.set();
		add(songNameText);
		if (FlxG.save.data.downscroll)
			songNameText.y = FlxG.height * 0.9 + 45;


		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.screenCenter(X);
		originalX = scoreTxt.x;
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(scoreTxt);

		var botPlayText = '';
		if (PlayState.replayActive)
			botPlayText = 'REPLAY';
		if (PlayState.botPlayActive)
			botPlayText = 'BOTPLAY';

		if (botPlayText != '')
		{
			botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayState.downscrollActive ? 100 : -100), 0, botPlayText,
				20);
			botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botPlayState.borderSize = 4;
			botPlayState.borderQuality = 2;
			botPlayState.scrollFactor.set();
			botPlayState.cameras = [camHUD];
			add(botPlayState);
		}

		this.healthIconPlayer = new HealthIcon(playerChar.curCharacter, true);
		this.healthIconPlayer.y = healthBar.y - (this.healthIconPlayer.height / 2);
		add(this.healthIconPlayer);
		this.healthIconCPU = new HealthIcon(cpuChar.curCharacter, false);
		this.healthIconCPU.y = healthBar.y - (this.healthIconCPU.height / 2);
		add(this.healthIconCPU);
		strumLineNotes.cameras = [camHUD];
		songNotes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		this.healthIconPlayer.cameras = [camHUD];
		this.healthIconCPU.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		if (isStoryMode())
			doof.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		songNameText.cameras = [camHUD];
		startingSong = true;
		trace('starting');
		if (isStoryMode())
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);

					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: STAGE.camZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});

				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					new FlxTimer().start(1, function(timer)
					{
						startCountdown();
					});
			}
		}
		else
		{
			new FlxTimer().start(1, function(timer)
			{
				startCountdown();
			});
		}
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = GraphicsAssets.loadSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (PlayState.SONG.songId == 'roses' || PlayState.SONG.songId == 'thorns')
		{
			remove(black);

			if (PlayState.SONG.songId == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (PlayState.SONG.songId == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];

	/**
	 * Ready... set... GO!
	 */
	function startCountdown():Void
	{
		inCutscene = false;

		appearStrumlineArrows();
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		if (FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		if (vocals != null)
			vocals.stop();

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			// this just based on beatHit stuff but compact
			if (allowedToHeadbang && swagCounter % gfSpeed == 0)
				gfChar.dance();
			if (swagCounter % idleBeat == 0)
			{
				if (idleToBeat && !playerChar.animation.curAnim.name.startsWith("sing"))
					playerChar.dance(forcedToIdle);
				if (idleToBeat && !cpuChar.animation.curAnim.name.startsWith("sing"))
					cpuChar.dance(forcedToIdle);
			}
			else if ((cpuChar.curCharacter == 'spooky' || cpuChar.curCharacter == 'gf') && !cpuChar.animation.curAnim.name.startsWith("sing"))
				cpuChar.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('pixel', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var countdownLibrary:String = null;

			if (SONG.noteStyle == 'pixel')
			{
				introAlts = introAssets.get('pixel');
				altSuffix = '-pixel';
				countdownLibrary = 'week6';
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(GraphicsAssets.loadImage('notes/${SONG.noteStyle}/ready', countdownLibrary));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (SONG.noteStyle == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * PIXEL_ZOOM_FACTOR));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(GraphicsAssets.loadImage('notes/${SONG.noteStyle}/set', countdownLibrary));
					set.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						set.setGraphicSize(Std.int(set.width * PIXEL_ZOOM_FACTOR));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(GraphicsAssets.loadImage('notes/${SONG.noteStyle}/go', countdownLibrary));
					go.scrollFactor.set();

					if (SONG.noteStyle == 'pixel')
						go.setGraphicSize(Std.int(go.width * PIXEL_ZOOM_FACTOR));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
			}

			swagCounter += 1;
		}, 4);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public var closestNotes:Array<Note> = [];

	/**
	 * Handles the keyboard event when a key is released.
	 * @param evt The keyboard event that occurred.
	 */
	private function onKeyUp(evt:KeyboardEvent):Void // handles releases
	{
		if (PlayState.botPlayActive || PlayState.replayActive || this.isPaused)
			return;

		// Get the note data for the key you just pressed.
		var data = EnigmaNote.getKeyNoteData(evt, PlayState.SONG.strumlineSize);

		if (data == -1)
			return;

		if (!currentKeysPressed[data])
		{
			var key = FlxKey.toStringMap.get(evt.keyCode);
			trace("u already released " + key);
			return;
		}

		currentKeysPressed[data] = false;
	}

	/**
	 * Handles the keyboard event when a key is pressed.
	 * @param evt  The keyboard event that occurred.
	 */
	private function onKeyDown(evt:KeyboardEvent):Void
	{
    // End processing if we should ignore user input;
		if (PlayState.botPlayActive || PlayState.replayActive || this.isPaused)
			return;

		// Get the strumline index for the key you just pressed.
		var keyStrumlineIndex = EnigmaNote.getKeyNoteData(evt, PlayState.SONG.strumlineSize);

    // End processing if the key wasn't recognized as belonging to a note.
		if (keyStrumlineIndex == -1)
		{
      Debug.logTrace('Unknown key pressed: ${FlxKey.toStringMap.get(evt.keyCode)}');
			return;
		} else {
      Debug.logTrace('Pressed index ${keyStrumlineIndex}');
    }

		if (currentKeysPressed[keyStrumlineIndex])
		{
			var key = FlxKey.toStringMap.get(evt.keyCode);
			Debug.logTrace('But you are already holding ${FlxKey.toStringMap.get(evt.keyCode)}');
			return;
		}

    // We have pressed the key.
		currentKeysPressed[keyStrumlineIndex] = true;

		var replayInput = new ReplayInput(Conductor.songPosition, null, false, "miss", data);

    // Get all the notes which are close enough to hit.
    var closestNotes = songNotes.filterCanBeHit();

    // Filter further, to only notes in the same strumline as the key pressed.
    var matchingNotes = closestNotes.filter(function(curNote:Note) {
      return (curNote.noteData == keyStrumlineIndex)
        && (!curNote.isSustainNote);
    })

    Debug.logTrace('Pressed ${FlxKey.toStringMap.get(evt.keyCode)}; has ${matchingNotes.length} possible targets.');

    if (matchingNotes.length > 0) {

    } else {
      if ()
    }

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
			{
				coolNote = i;
				break;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && ((note.strumTime - coolNote.strumTime) < 2) && note.noteData == data)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			playerChar.holdTimer = 0;
			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			replayNote.hit = true;
			replayNote.hitJudge = Scoring.judgeNote(noteDiff);
			replayNote.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			replayNote.hit = false;
			replayNote.hitJudge = "shit";
			replayNote.nearestNote = [];
			health -= 0.20;
		}
	}

	public var doAnything = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.music.play();
		vocals.play();

		// have them all dance when the song starts
		if (allowedToHeadbang)
			gfChar.dance();
		if (idleToBeat && !playerChar.animation.curAnim.name.startsWith("sing"))
			playerChar.dance(forcedToIdle);
		if (idleToBeat && !cpuChar.animation.curAnim.name.startsWith("sing"))
			cpuChar.dance(forcedToIdle);

		// Song check real quick
		switch (curSong)
		{
			case 'Bopeebo' | 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog':
				allowedToCheer = true;
			default:
				allowedToCheer = false;
		}

		if (this.backgroundVideoActive)
			GlobalVideo.get().resume();

		#if FEATURE_LUAMODCHART
		if (this.modchartActive)
			luaModchart.executeState("songStart", [null]);
		#end

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ PlayState.SONG.songName
			+ " ("
			+ PlayState.songDifficulty.toUpperCamel()
			+ ") "
			+ Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()),
			"\nAcc: "
			+ Util.truncateFloat(Scoring.currentScore.getAccuracy(), 2)
			+ "% | Score: "
			+ Scoring.currentScore.getScore()
			+ " | Misses: "
			+ Scoring.currentScore.miss,
			iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		if (vocals != null)
			vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		trace("pitched inst and vocals to " + songMultiplier);
		#end

		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
		{
			skipActive = true;
			skipText = new FlxText(healthBarBG.x + 80, healthBarBG.y - 110, 500);
			skipText.text = "Press Space to Skip Intro";
			skipText.size = 30;
			skipText.color = 0xFFADD8E6;
			skipText.cameras = [camHUD];
			skipText.alpha = 0;
			FlxTween.tween(skipText, {alpha: 1}, 0.2);
			add(skipText);
		}
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		var songData = PlayState.SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.songId;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.songId));
		else
			vocals = new FlxSound();

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		if (!this.isPaused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.songId), 1, false);
		}

		FlxG.sound.music.onComplete = endSong;
		FlxG.sound.music.pause();

		if (SONG.needsVoices)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.songId));
		FlxG.sound.cache(Paths.inst(PlayState.SONG.songId));

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length / 1000;

		Conductor.crochet = ((60 / (SONG.bpm) * 1000)) / songMultiplier;
		Conductor.stepCrochet = Conductor.crochet / 4;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(GraphicsAssets.loadImage('healthBar'));
			if (FlxG.save.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 100);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.songName.length * 5), songPosBG.y, 0, PlayState.SONG.songName, 16);
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var newNoteStrumtime:Float = songNotes[0] - FlxG.save.data.offset - PlayState.SONG.offset;
				if (newNoteStrumtime < 0)
					newNoteStrumtime = 0;
				var newNoteRawData:Int = Std.int(songNotes[1]);

				var gottaHitNote:Bool = NoteUtil.mustHitNote(newNoteRawData, section.mustHitSection);

				// Skip this note if we've disabled the enemy strumline.
				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				// Create a note.
				var newNote:Note = new Note(newNoteStrumtime, newNoteRawData, oldNote, gottaHitNote, false, false);
				newNote.isAlt = false;
				newNote.beat = (songNotes[4] == null ? TimingStruct.getBeatFromTime(newNoteStrumtime) : songNotes[4]);
				newNote.sustainLength = songNotes[2];
				newNote.scrollFactor.set(0, 0);
				newNote.isAlt = songNotes[3]
					|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
					|| (section.playerAltAnim && gottaHitNote);

				unspawnNotes.push(newNote);

				var noteSustainLength:Float = newNote.sustainLength / Conductor.stepCrochet;

				if (noteSustainLength > 0)
					newNote.isParent = true;

				NoteUtil.positionNote(newNote, strumLineNotes.members);

				var type = 0;

				// For every second in the sustain note...
				for (susNote in 0...Math.floor(noteSustainLength))
				{
					// Use the previous note as the parent.
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					// Create a sustain note.
					var sustainNote:Note = new Note(newNoteStrumtime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, newNoteRawData, oldNote,
						gottaHitNote, true);
					sustainNote.scrollFactor.set();
					sustainNote.isAlt = songNotes[3]
						|| ((section.altAnim || section.CPUAltAnim) && !gottaHitNote)
						|| (section.playerAltAnim && gottaHitNote);

					sustainNote.parent = newNote;
					newNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;

					// Spawn the note.
					unspawnNotes.push(sustainNote);

					NoteUtil.positionNote(sustainNote, strumLineNotes.members);
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortNotesByStrumtime);

		generatedMusic = true;
	}

	function sortNotesByStrumtime(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStrumlineArrows(isPlayer:Bool):Void
	{
		EnigmaNote.buildStrumlines(isPlayer, strumLine.y, PlayState.SONG.strumlineSize);
	}

	private function appearStrumlineArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode())
				babyArrow.alpha = 1;
		});
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (this.isPaused)
		{
			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
				if (vocals != null)
					if (vocals.playing)
						vocals.pause();
			}

			#if FEATURE_DISCORD
			DiscordClient.changePresence("PAUSED on "
				+ PlayState.SONG.songName
				+ " ("
				+ PlayState.songDifficulty.toUpperCamel()
				+ ") "
				+ Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()),
				"\nAcc: "
				+ Util.truncateFloat(Scoring.currentScore.getAccuracy(), 2)
				+ "% | Score: "
				+ Scoring.currentScore.getScore()
				+ " | Misses: "
				+ Scoring.currentScore.miss,
				iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (this.isPaused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			this.isPaused = false;

			#if FEATURE_DISCORD
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ PlayState.SONG.songName
					+ " ("
					+ PlayState.songDifficulty.toUpperCamel()
					+ ") "
					+ Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()),
					"\nAcc: "
					+ Util.truncateFloat(Scoring.currentScore.getAccuracy(), 2)
					+ "% | Score: "
					+ Scoring.currentScore.getScore()
					+ " | Misses: "
					+ Scoring.currentScore.miss,
					iconRPC, true, songLength
					- Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText,
					SONG.songName
					+ " ("
					+ PlayState.songDifficulty.toUpperCamel()
					+ ") "
					+ Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = FlxG.sound.music.time;
		vocals.play();

		@:privateAccess
		{
			#if desktop
			// The __backend.handle attribute is only available on native.
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			#end
		}

		#if FEATURE_DISCORD
		DiscordClient.changePresence(detailsText
			+ " "
			+ PlayState.SONG.songName
			+ " ("
			+ PlayState.songDifficulty.toUpperCamel()
			+ ") "
			+ Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()),
			"\nAcc: "
			+ Util.truncateFloat(Scoring.currentScore.getAccuracy(), 2)
			+ "% | Score: "
			+ Scoring.currentScore.getScore()
			+ " | Misses: "
			+ Scoring.currentScore.miss,
			iconRPC);
		#end
	}

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var currentBPM = 0;
	public var updateFrame = 0;
	public var pastScrollChanges:Array<SongEvent> = [];

	var currentLuaIndex = 0;

	public override function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		if (!PlayStateChangeables.Optimize)
			STAGE.update(elapsed);

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 14000 * songMultiplier)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				#if FEATURE_LUAMODCHART
				if (this.modchartActive)
				{
					new LuaNote(dunceNote, currentLuaIndex);
					dunceNote.luaID = currentLuaIndex;
				}
				#end

				if (this.modchartActive)
				{
					#if FEATURE_LUAMODCHART
					if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];
					#end
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
				currentLuaIndex++;
			}
		}

		#if cpp
		if (FlxG.sound.music.playing)
			@:privateAccess
		{
			lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
			if (vocals.playing)
				lime.media.openal.AL.sourcef(vocals._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, songMultiplier);
		}
		#end

		if (generatedMusic)
		{
			if (songStarted && !this.endingSong)
			{
				// Song ends abruptly on slow rate even with second condition being deleted,
				// and if it's deleted on songs like cocoa then it would end without finishing instrumental fully,
				// so no reason to delete it at all
				if (unspawnNotes.length == 0 && notes.length == 0)
				{
					this.endingSong = true;
					new FlxTimer().start(2, function(timer)
					{
						endSong();
					});
				}
			}
		}

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in PlayState.SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					var bpm = i.value;

					TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

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

			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;

		if (FlxG.sound.music.playing)
		{
			var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);

			if (timingSeg != null)
			{
				var timingSegBpm = timingSeg.bpm;

				if (timingSegBpm != Conductor.bpm)
				{
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
					Conductor.crochet = ((60 / (timingSegBpm) * 1000)) / songMultiplier;
					Conductor.stepCrochet = Conductor.crochet / 4;
				}
			}

			var newScroll = 1.0;

			for (i in PlayState.SONG.eventObjects)
			{
				switch (i.type)
				{
					case "Scroll Speed Change":
						if (i.position <= curDecimalBeat && !pastScrollChanges.contains(i))
						{
							pastScrollChanges.push(i);
							trace("SCROLL SPEED CHANGE to " + i.value);
							newScroll = i.value;
						}
				}
			}

			if (newScroll != 0)
				PlayStateChangeables.scrollSpeed *= newScroll;
		}

		if (PlayState.botPlayActive && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (this.backgroundVideoActive && GlobalVideo.get() != null && !stopUpdate && GlobalVideo.get().ended)
		{
      removeBackgroundVideo();
		}

		#if FEATURE_LUAMODCHART
		if (this.modchartActive && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', Util.truncateFloat(curDecimalBeat, 3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);

			luaModchart.executeState('update', [elapsed]);

			for (key => value in luaModchart.luaWiggles)
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			FlxG.save.data.downscroll = luaModchart.getVar("downscroll", "bool");

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				songNameText.visible = false;
				healthBar.visible = false;
				this.healthIconPlayer.visible = false;
				this.healthIconCPU.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				songNameText.visible = true;
				healthBar.visible = true;
				this.healthIconPlayer.visible = true;
				this.healthIconCPU.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}

			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
			camSustains.zoom = camHUD.zoom;
			camSustains.x = camHUD.x;
			camSustains.y = camHUD.y;
			camSustains.angle = camHUD.angle;
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
			this.healthIconPlayer.swapOldIcon();

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;

		if (controls.PAUSE && startedCountdown && canPause && !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			this.isPaused = true;

			openSubState(new PauseSubState(playerChar.getScreenPosition().x, playerChar.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.FIVE && songStarted)
		{
      songMultiplier = 1;
      removeBackgroundVideo();
			cannotDie = true;

			FlxG.switchState(new WaveformTestState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			songMultiplier = 1;
      removeBackgroundVideo();
			cannotDie = true;

			FlxG.switchState(new ChartingState());
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		var iconOffset:Int = 26;

		this.healthIconPlayer.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		this.healthIconCPU.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (this.healthIconCPU.width - iconOffset);

		// TODO: Make this dynamic.
		if (health > 2)
			health = 2;

		this.healthIconPlayer.handleHealth(health);
		this.healthIconCPU.handleHealth(health);

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
      removeBackgroundVideo();

			FlxG.switchState(new AnimationDebug(cpuChar.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (!PlayStateChangeables.Optimize)
			if (FlxG.keys.justPressed.EIGHT && songStarted)
			{
				this.isPaused = true;
        removeBackgroundVideo();
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					for (bg in STAGE.toAdd)
					{
						remove(bg);
					}
					for (array in STAGE.layInFront)
					{
						for (bg in array)
							remove(bg);
					}
					for (group in STAGE.swagGroup)
					{
						remove(group);
					}
					remove(playerChar);
					remove(cpuChar);
					remove(gfChar);
				});
				FlxG.switchState(new StageDebugState(STAGE.curStage, gfChar.curCharacter, playerChar.curCharacter, cpuChar.curCharacter));
				clean();
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					luaModchart.die();
					luaModchart = null;
				}
				#end
			}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(playerChar.curCharacter));
			clean();
			PlayState.stageTesting = false;
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.TWO && songStarted)
		{ // Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length)
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime - 500 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					usedTimeTravel = false;
				});
			}
		}
		#end

		if (skipActive && Conductor.songPosition >= skipTo)
		{
			remove(skipText);
			skipActive = false;
		}

		if (FlxG.keys.justPressed.SPACE && skipActive)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			Conductor.songPosition = skipTo;

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			FlxTween.tween(skipText, {alpha: 0}, 0.2, {
				onComplete: function(tw)
				{
					remove(skipText);
				}
			});
			skipActive = false;
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				Conductor.rawPosition = Conductor.songPosition;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * (1000 * songMultiplier);
			Conductor.rawPosition = FlxG.sound.music.time;
			songPositionBar = (Conductor.songPosition - songLength) / 1000;

			currentSection = getSectionByTime(Conductor.songPosition);

			if (!this.isPaused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (generatedMusic && currentSection != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToCheer)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gfChar.animation.curAnim.name == 'danceLeft'
					|| gfChar.animation.curAnim.name == 'danceRight'
					|| gfChar.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly Nice':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gfChar.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gfChar.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'Blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												gfChar.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gfChar.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gfChar.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.setVar("mustHit", currentSection.mustHitSection);
			#end

			if (camFollow.x != cpuChar.getMidpoint().x + 150 && !currentSection.mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(cpuChar.getMidpoint().x + 150 + offsetX, cpuChar.getMidpoint().y - 100 + offsetY);
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end

				switch (cpuChar.curCharacter)
				{
					case 'mom' | 'mom-car':
						camFollow.y = cpuChar.getMidpoint().y;
					case 'senpai' | 'senpai-angry':
						camFollow.y = cpuChar.getMidpoint().y - 430;
						camFollow.x = cpuChar.getMidpoint().x - 100;
				}
			}

			if (currentSection.mustHitSection && camFollow.x != playerChar.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(playerChar.getMidpoint().x - 100 + offsetX, playerChar.getMidpoint().y - 100 + offsetY);

				#if FEATURE_LUAMODCHART
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end
				if (!PlayStateChangeables.Optimize)
					switch (STAGE.curStage)
					{
						case 'limo':
							camFollow.x = playerChar.getMidpoint().x - 300;
						case 'mall':
							camFollow.y = playerChar.getMidpoint().y - 200;
						case 'school':
							camFollow.x = playerChar.getMidpoint().x - 200;
							camFollow.y = playerChar.getMidpoint().y - 200;
						case 'schoolEvil':
							camFollow.x = playerChar.getMidpoint().x - 200;
							camFollow.y = playerChar.getMidpoint().y - 200;
					}
			}
		}



		if (cameraBeatZooming)
		{
      // Linearly interpolate back to the original camera zoom level after zooming in, on beat.
      
      var baseHUDZoom = this.modchartActive ? FlxG.save.data.zoom : 1;

			FlxG.camera.zoom = FlxMath.lerp(STAGE.camZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(baseHUDZoom, camHUD.zoom, 0.95);

			camNotes.zoom = camHUD.zoom;
			camSustains.zoom = camHUD.zoom;

		}

		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("curBeat", curBeat);
		FlxG.watch.addQuick("curStep", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
			}
		}

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel)
			{
				playerChar.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				this.isPaused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(playerChar.getScreenPosition().x, playerChar.getScreenPosition().y));
				}

				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ PlayState.SONG.songName
					+ " ("
					+ PlayState.songDifficulty.toUpperCamel()
					+ ") "
					+ Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()),
					"\nAcc: "
					+ Util.truncateFloat(Scoring.currentScore.getAccuracy(), 2)
					+ "% | Score: "
					+ Scoring.currentScore.getScore()
					+ " | Misses: "
					+ Scoring.currentScore.miss,
					iconRPC);
				#end
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			if (FlxG.keys.justPressed.R)
			{
				playerChar.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				this.isPaused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				if (FlxG.save.data.InstantRespawn)
				{
					FlxG.switchState(new PlayState());
				}
				else
				{
					openSubState(new GameOverSubstate(playerChar.getScreenPosition().x, playerChar.getScreenPosition().y));
				}

				#if FEATURE_DISCORD
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ PlayState.SONG.songName
					+ " ("
					+ PlayState.songDifficulty.toUpperCamel()
					+ ") "
					+ Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()),
					"\nAcc: "
					+ Util.truncateFloat(Scoring.currentScore.getAccuracy(), 2)
					+ "% | Score: "
					+ Scoring.currentScore.getScore()
					+ " | Misses: "
					+ Scoring.currentScore.miss,
					iconRPC);
				#end
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayState.SONG.speed, 2));

			// The speed that the notes scroll at.
			var noteScrollSpeed = FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed, 2);

			notes.forEachAlive(function(daNote:Note)
			{
				// Here is the logic that moves the notes towards the strumline!
				// We set the note's Y position to the strumline, then push it downwards based on the time in the song.
				// Basing it off FlxG.height is for chumps.
				var noteDataValue = Math.floor(Math.abs(daNote.noteData));
				if (!NoteUtil.isValidNoteData(noteDataValue, NoteUtil.fetchStrumlineSize()))
				{
					Debug.logWarn("Note data was impossible for this note! Couldn't generate a Y offset.");
					// Return from this inline lambda function.
					return;
				}
				if (!daNote.modifiedByLua)
				{
					// The position of the strumline.
					var strumlineYPos = strumLineNotes.members[
						NoteUtil.getStrumlineIndex(Math.floor(Math.abs(daNote.noteData)), NoteUtil.fetchStrumlineSize(), !daNote.isCPUNote)
					].y;
					var noteTime = (Conductor.songPosition - daNote.strumTime) / songMultiplier * noteScrollSpeed;
					var noteDistance = (FlxG.save.data.downscroll ? 1 : -1) * NOTE_TIME_TO_DISTANCE * noteTime;
					daNote.y = strumlineYPos + noteDistance - daNote.noteYOff;
					if (FlxG.save.data.downscroll)
					{
						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null)
							{
								daNote.y += daNote.prevNote.height;
							}
							else
							{
								daNote.y += daNote.height / 2;
							}
							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (PlayState.botPlayActive
								|| (daNote.isCPUNote
									|| daNote.wasGoodHit
									|| daNote.prevNote.wasGoodHit
									|| holdArray[Math.floor(Math.abs(daNote.noteData))])
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;
							if (!PlayState.botPlayActive)
							{
								if ((daNote.isCPUNote
									|| daNote.wasGoodHit
									|| daNote.prevNote.wasGoodHit
									|| holdArray[Math.floor(Math.abs(daNote.noteData))])
									&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;
									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (daNote.isCPUNote && Conductor.songPosition >= daNote.strumTime)
				{
					if (SONG.songId != 'tutorial')
						cameraBeatZooming = true;

					var altAnim:String = "";

					if (daNote.isAlt)
					{
						altAnim = '-alt';
					}

					// Accessing the animation name directly to play it
					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							var singAnimation = EnigmaNote.getSingAnim(daNote, PlayState.SONG.strumlineSize);
							cpuChar.playAnim(singAnimation + altAnim, true);

							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:StrumlineArrow)
								{
									pressArrow(spr, spr.ID, daNote);
								});
							}

							#if FEATURE_LUAMODCHART
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.rawNoteData), Conductor.songPosition]);
							#end

							cpuChar.holdTimer = 0;

							if (SONG.needsVoices)
								vocals.volume = 1;
						}
					}
					else
					{
						var singAnimation = EnigmaNote.getSingAnim(daNote, PlayState.SONG.strumlineSize);
						cpuChar.playAnim(singAnimation + altAnim, true);

						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach(function(spr:StrumlineArrow)
							{
								pressArrow(spr, spr.ID, daNote);
							});
						}

						#if FEATURE_LUAMODCHART
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.rawNoteData), Conductor.songPosition]);
						#end

						cpuChar.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;
					}
					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (!daNote.modifiedByLua)
				{
					NoteUtil.positionNote(daNote, strumLineNotes.members);
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (SONG.noteStyle == 'pixel')
						daNote.x -= 11;
				}

				// WIP interpolation shit? Need to fix the pause issue

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				else if ((!daNote.isCPUNote && !FlxG.save.data.downscroll || !daNote.isCPUNote && FlxG.save.data.downscroll)
					&& !daNote.isCPUNote
					&& daNote.strumTime / songMultiplier - Conductor.songPosition / songMultiplier < -(Scoring.TIMING_WINDOWS[0] * Conductor.timeScale)
					&& songStarted)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
					}
					else
					{
						if (PlayState.replayActive && daNote.isSustainNote)
						{
							// im tired and lazy this sucks I know i'm dumb
							if (findByTime(daNote.strumTime) != null) {
                // totalNotesHit += 1;
              } else
							{
								vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
								{
									noteMiss(daNote.noteData, daNote);
								}
								if (daNote.isParent)
								{
									health -= 0.15; // give a health punishment for failing a LN
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										// health -= 0.05; // give a health punishment for failing a LN
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										// TODO: MISS?
										if (daNote.parent.wasGoodHit)
											// misses++;
											updateAccuracy();
									}
									else if (!daNote.wasGoodHit && !daNote.isSustainNote)
									{
										health -= 0.15;
									}
								}
							}
						}
						else
						{
							vocals.volume = 0;
							if (theFunne && !daNote.isSustainNote)
							{
								if (PlayState.botPlayActive)
								{
									daNote.rating = "bad";
									goodNoteHit(daNote);
								}
								else
									noteMiss(daNote.noteData, daNote);
							}

							if (daNote.isParent && daNote.visible)
							{
								health -= 0.15; // give a health punishment for failing a LN
								trace("hold fell over at the start");
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
								}
							}
							else
							{
								if (!daNote.wasGoodHit
									&& daNote.isSustainNote
									&& daNote.sustainActive
									&& daNote.spotInLine != daNote.parent.children.length)
								{
									// health -= 0.05; // give a health punishment for failing a LN
									trace("hold fell over at " + daNote.spotInLine);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
									// TODO: MISS?
									if (daNote.parent.wasGoodHit)
										// misses++;
										updateAccuracy();
								}
								else if (!daNote.wasGoodHit && !daNote.isSustainNote)
								{
									health -= 0.15;
								}
							}
						}
					}

					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:StrumlineArrow)
			{
				if (spr.animation.finished)
				{
					spr.playAnim('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		super.update(elapsed);
	}

	function positionNote(note:Note)
	{
		// return [
		// 	NoteUtil.getStrumlineIndex(Math.floor(Math.abs(noteData)), PlayState.SONG.strumlineSize, mustPress)
		// ];
	}

	public function getSectionByTime(ms:Float):SwagSection
	{
		for (i in PlayState.SONG.notes)
		{
			var start = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.startTime)));
			var end = TimingStruct.getTimeFromBeat((TimingStruct.getBeatFromTime(i.endTime)));

			if (ms >= start && ms < end)
			{
				return i;
			}
		}

		return null;
	}

	function recalculateAllSectionTimes()
	{
		trace("RECALCULATING SECTION TIMES");

		for (i in 0...SONG.notes.length) // loops through sections
		{
			var section = PlayState.SONG.notes[i];

			var currentBeat = 4 * i;

			var currentSeg = TimingStruct.getTimingAtBeat(currentBeat);

			if (currentSeg == null)
				return;

			var start:Float = (currentBeat - currentSeg.startBeat) / ((currentSeg.bpm) / 60);

			section.startTime = (currentSeg.startTime + start) * 1000;

			if (i != 0)
				SONG.notes[i - 1].endTime = section.startTime;
			section.endTime = Math.POSITIVE_INFINITY;
		}
	}

	function endSong():Void
	{
		this.endingSong = true;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);

		if (this.backgroundVideoActive)
		{
			GlobalVideo.get().stop();
			FlxG.stage.window.onFocusOut.remove(focusOut);
			FlxG.stage.window.onFocusIn.remove(focusIn);
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		if (PlayState.replayActive) {
      // Clean up after playing the replay.
      PlayState.replayActive = false;
      PlayStateChangeables.scrollSpeed = 1;
    } else {
      // Save the replay we generated from this song.
      PlayState.currentReplay.SaveReplay(saveNotes, saveJudge, replayNotes);
    }

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if FEATURE_LUAMODCHART
    // End the current modchart.
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.stop();
		vocals.stop();
		if (SONG.validScore)
		{
			Highscore.saveScore(PlayState.SONG.songId, Math.round(Scoring.currentScore.getScore()), PlayState.songDifficulty);
			Highscore.saveCombo(PlayState.SONG.songId, Scoring.generateLetterRank(Scoring.currentScore.getAccuracy()), PlayState.songDifficulty);
		}

		if (offsetTesting)
		{
			MainMenuMusic.playMenuMusic();
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			clean();
			FlxG.save.data.offset = offsetTest;
		}
		else if (stageTesting)
		{
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				for (bg in STAGE.toAdd)
				{
					remove(bg);
				}
				for (array in STAGE.layInFront)
				{
					for (bg in array)
						remove(bg);
				}
				remove(playerChar);
				remove(cpuChar);
				remove(gfChar);
			});
			FlxG.switchState(new StageDebugState(STAGE.curStage));
		}
		else
		{
			if (isStoryMode())
			{
				// Time to move to the next song!

				// Add the song score to the week score.
				Scoring.weekScore.combineScore(Scoring.currentScore);

				Scoring.currentScore = new SongScore(songMultiplier);

				// Move to the next song in the playlist.
				storyPlaylistPos += 1;

				if (storyPlaylistPos <= storyWeek.playlist.length)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					this.isPaused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					if (FlxG.save.data.scoreScreen)
					{
						openSubState(new ResultsSubState());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
					}
					else
					{
						MainMenuMusic.playMenuMusic();
						FlxG.switchState(new StoryMenuState());
						clean();
					}

					#if FEATURE_LUAMODCHART
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek.id, Scoring.weekScore.getScore(), PlayState.songDifficulty);
						Highscore.saveWeekCombo(storyWeek.id, Scoring.generateLetterRank(Scoring.weekScore.getAccuracy()), PlayState.PlayState.songDifficulty);
					}

					StoryMenuState.unlockWeek(storyWeek.id);
				}
				else
				{
					var diffSuffix = DifficultyCache.getSuffix(PlayState.songDifficulty);

					Debug.logInfo('Loading next song in Story playlist  (${PlayState.storyWeek.playlist[storyPlaylistPos]}${diffSuffix})');

					// TODO: Unhardcode the transition to winter-horrorland.
					if (PlayState.storyWeek.playlist[storyPlaylistPos] == 'eggnog')
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyWeek.playlist[storyPlaylistPos], diffSuffix);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
					clean();
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				this.isPaused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (FlxG.save.data.scoreScreen)
				{
					openSubState(new ResultsSubState());
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						inResults = true;
					});
				}
				else
				{
					FlxG.switchState(new FreeplayState());
					clean();
				}
			}
		}
	}

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	/**
	 * Alongside the judgement is the indicator of your note diff in ms.
	 */
	var currentNoteTiming:FlxText = null;

	/**
	 * How long the `currentNoteTiming` has been on screen.
	 */
	var currentNoteTimingDur = 0;

	private function popUpScore(curNote:Note):Void
	{
		var noteDiff:Float;
		if (curNote != null)
			noteDiff = -(curNote.strumTime - Conductor.songPosition);
		else
			noteDiff = Conductor.safeZoneOffset; // Assumed SHIT if no note was given

		vocals.volume = 1;

		var comboText:FlxText = new FlxText(0, 0, 0, Std.string(Scoring.currentScore.currentCombo), 32);
		comboText.screenCenter();
		comboText.x = FlxG.width * 0.55;
		comboText.y -= 350;
		comboText.cameras = [camHUD];

		var judgementSprite:FlxSprite = new FlxSprite();

		var noteJudgement = Scoring.currentScore.judge(noteDiff);

		// C
		switch (noteJudgement)
		{
			case Miss:
				health -= 0.1;
			case Shit:
				health -= 0.1;
			case Bad:
				health -= 0.06;
			case Good:
			// health += 0
			case Sick:
				if (health < 2)
					health += 0.04;
		}

		if (noteJudgement != Shit || noteJudgement != Bad)
		{
			judgementSprite.loadGraphic(GraphicsAssets.loadImage('notes/${SONG.noteStyle}/${noteJudgement}'));
			judgementSprite.screenCenter();
			judgementSprite.y -= 50;
			judgementSprite.x = judgementSprite.x - 125;

			if (FlxG.save.data.changedHit)
			{
				judgementSprite.x = FlxG.save.data.changedHitX;
				judgementSprite.y = FlxG.save.data.changedHitY;
			}
			judgementSprite.acceleration.y = 550;
			judgementSprite.velocity.y -= FlxG.random.int(140, 175);
			judgementSprite.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = Util.truncateFloat(noteDiff / songMultiplier, 3);
			if (PlayState.botPlayActive && !replayActive)
				msTiming = 0;

			if (replayActive)
				msTiming = Util.truncateFloat(findByTime(curNote.strumTime)[3], 3);

			if (currentNoteTiming != null)
				remove(currentNoteTiming);

			currentNoteTiming = new FlxText(0, 0, 0, "0ms");
			currentNoteTimingDur = 0;
			switch (noteJudgement)
			{
				case Shit | Bad | Miss:
					currentNoteTiming.color = FlxColor.RED;
				case Good:
					currentNoteTiming.color = FlxColor.GREEN;
				case Sick:
					currentNoteTiming.color = FlxColor.CYAN;
			}
			currentNoteTiming.borderStyle = OUTLINE;
			currentNoteTiming.borderSize = 1;
			currentNoteTiming.borderColor = FlxColor.BLACK;
			currentNoteTiming.text = msTiming + "ms";
			currentNoteTiming.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = Util.truncateFloat(total / hits.length, 2);
			}

			if (currentNoteTiming.alpha != 1)
				currentNoteTiming.alpha = 1;

			if (!PlayState.botPlayActive || replayActive)
				add(currentNoteTiming);

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(GraphicsAssets.loadImage('notes/${SONG.noteStyle}/combo'));
			comboSpr.screenCenter();
			comboSpr.x = judgementSprite.x;
			comboSpr.y = judgementSprite.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentNoteTiming.screenCenter();
			currentNoteTiming.x = comboSpr.x + 100;
			currentNoteTiming.y = judgementSprite.y + 100;
			currentNoteTiming.acceleration.y = 600;
			currentNoteTiming.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentNoteTiming.velocity.x += comboSpr.velocity.x;

			add(judgementSprite);

			if (SONG.noteStyle != 'pixel')
			{
				judgementSprite.setGraphicSize(Std.int(judgementSprite.width * 0.7));
				judgementSprite.antialiasing = FlxG.save.data.antialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				judgementSprite.setGraphicSize(Std.int(judgementSprite.width * PIXEL_ZOOM_FACTOR * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * PIXEL_ZOOM_FACTOR * 0.7));
			}

			currentNoteTiming.updateHitbox();
			comboSpr.updateHitbox();
			judgementSprite.updateHitbox();

			currentNoteTiming.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			judgementSprite.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = '${Scoring.currentScore.currentCombo}'.split('');

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				// An individual number in the score.
				var numScore:FlxSprite = new FlxSprite().loadGraphic(GraphicsAssets.loadImage('notes/${SONG.noteStyle}/num${Std.int(i)}'));
				numScore.screenCenter();
				numScore.x = judgementSprite.x + (43 * daLoop) - 50;
				numScore.y = judgementSprite.y + 100;
				numScore.cameras = [camHUD];

				if (SONG.noteStyle != 'pixel')
				{
					numScore.antialiasing = FlxG.save.data.antialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * PIXEL_ZOOM_FACTOR));
				}
				numScore.updateHitbox();

				// The numebers move downward at a random speed.
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				visibleCombos.push(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						visibleCombos.remove(numScore);
						numScore.destroy();
					},
					onUpdate: function(tween:FlxTween)
					{
						if (!visibleCombos.contains(numScore))
						{
							tween.cancel();
							numScore.destroy();
						}
					},
					startDelay: Conductor.crochet * 0.002
				});

				if (visibleCombos.length > seperatedScore.length + 20)
				{
					for (i in 0...seperatedScore.length - 1)
					{
						visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
					}
				}

				daLoop++;
			}

			comboText.text = Std.string(seperatedScore);

			FlxTween.tween(judgementSprite, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentNoteTiming != null)
						currentNoteTiming.alpha -= 0.02;
					currentNoteTimingDur++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					comboText.destroy();
					comboSpr.destroy();
					if (currentNoteTiming != null && currentNoteTimingDur >= 20)
					{
						remove(currentNoteTiming);
						currentNoteTiming = null;
					}
					judgementSprite.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void
	{
		var holdArray:Array<Bool> = [
			controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT, controls.LEFT_9K, controls.LEFT_9K, controls.LEFT_9K, controls.LEFT_9K,
			controls.CENTER_9K, controls.LEFT_ALT_9K, controls.DOWN_ALT_9K, controls.UP_ALT_9K, controls.RIGHT_ALT_9K,
		];
		var pressArray:Array<Bool> = [
			controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P, controls.LEFT_9K, controls.LEFT_9K, controls.LEFT_9K, controls.LEFT_9K,
			controls.CENTER_9K, controls.LEFT_ALT_9K, controls.DOWN_ALT_9K, controls.UP_ALT_9K, controls.RIGHT_ALT_9K,
		];
		var releaseArray:Array<Bool> = [
			controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R, controls.LEFT_9K, controls.LEFT_9K, controls.LEFT_9K, controls.LEFT_9K,
			controls.CENTER_9K, controls.LEFT_ALT_9K, controls.DOWN_ALT_9K, controls.UP_ALT_9K, controls.RIGHT_ALT_9K,
		];
		var keynameArray:Array<String> = [
			'left', 'down', 'up', 'right', 'left9k', 'down9k', 'up9k', 'right9k', 'center9k', 'leftalt9k', 'downalt9k', 'upalt9k', 'rightalt9k'
		];
		#if FEATURE_LUAMODCHART
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayState.botPlayActive)
		{
			holdArray = [false, false, false, false, false, false, false, false, false];
			pressArray = [false, false, false, false, false, false, false, false, false];
			releaseArray = [false, false, false, false, false, false, false, false, false];
		}

		var replayNotes:Array<ReplayNote> = [null, null, null, null, null, null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				replayNotes[i] = new ReplayNote(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && !daNote.isCPUNote && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					goodNoteHit(daNote);
				}
			});
		}

		if ((CustomControls.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				playerChar.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				// we don't want to do judgments for more than one presses
				var directionsAccounted:Array<Bool> = [false, false, false, false, false, false, false, false, false];

				notes.forEachAlive(function(daNote:Note)
				{
					// Fetch the corrected ID.
					// This is needed because otherwise data for different note types would be in very high lane numbers.
					var correctedNoteData = NoteUtil.getStrumlineIndex(daNote.noteData);

					if (daNote.canBeHit && !daNote.isCPUNote && !daNote.wasGoodHit && !directionsAccounted[correctedNoteData])
					{
						if (directionList.contains(correctedNoteData))
						{
							directionsAccounted[correctedNoteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[correctedNoteData] = true;
							possibleNotes.push(daNote);
							directionList.push(correctedNoteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							if (mashViolations != 0)
								mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							replayNotes[coolNote.noteData].hit = true;
							replayNotes[coolNote.noteData].hitJudge = Scoring.judgeNote(noteDiff);
							replayNotes[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};

				if (playerChar.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayState.botPlayActive))
				{
					if (playerChar.animation.curAnim.name.startsWith('sing') && !playerChar.animation.curAnim.name.endsWith('miss'))
						playerChar.dance();
				}
				else if (!FlxG.save.data.ghost)
				{
					for (i in 0...pressArray.length)
						if (pressArray[i])
							noteMiss(i, null);
				}
			}

			if (!replayActive)
				for (i in replayNotes)
					if (i != null)
						replayNotes.push(i); // put em all there
		}
		if (PlayState.botPlayActive)
			notes.forEachAlive(function(daNote:Note)
			{
				if (!daNote.isCPUNote && Conductor.songPosition >= daNote.strumTime)
				{
					// Force good note hit regardless if it's too late to hit it or not as a fail safe
					if (replayActive)
					{
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							playerChar.holdTimer = 0;
						}
					}
					else
					{
						goodNoteHit(daNote);
						playerChar.holdTimer = 0;
					}
				}
			});

		if (playerChar.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayState.botPlayActive))
		{
			if (playerChar.animation.curAnim.name.startsWith('sing')
				&& !playerChar.animation.curAnim.name.endsWith('miss')
				&& (playerChar.animation.curAnim.curFrame >= 10 || playerChar.animation.curAnim.finished))
				playerChar.dance();
		}

		playerStrums.forEach(function(spr:StrumlineArrow)
		{
			if (!PlayState.botPlayActive)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed'
					&& !spr.animation.curAnim.name.startsWith('dirCon'))
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			}
			else if (FlxG.save.data.cpuStrums)
			{
				if (spr.animation.finished)
					spr.playAnim('static');
			}
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in PlayState.currentReplay.replay.songNotes)
		{
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...PlayState.currentReplay.replay.songNotes.length)
		{
			if (PlayState.currentReplay.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public var fuckingVolume:Float = 1;

	public static var webmHandler:WebmHandler;

	public var videoSprite:FlxSprite;

	public function focusOut()
	{
		if (this.isPaused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		this.isPaused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(playerChar.getScreenPosition().x, playerChar.getScreenPosition().y));
	}

	public function focusIn()
	{
		// nada
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!playerChar.stunned)
		{
			if (Scoring.currentScore.currentCombo > 5 && gfChar.animOffsets.exists('sad'))
			{
				gfChar.playAnim('sad');
			}
			if (Scoring.currentScore.currentCombo != 0)
			{
				// combo = 0;
				popUpScore(null);
			}
			// misses++;

			if (daNote != null)
			{
				if (!replayActive)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						-(Scoring.TIMING_WINDOWS[0] * Math.floor((PlayState.currentReplay.replay.sf / 60) * 1000) / Scoring.TIMING_WINDOWS[0])
					]);
					saveJudge.push("miss");
				}
			}
			else if (!replayActive)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					-(Scoring.TIMING_WINDOWS[0] * Math.floor((PlayState.currentReplay.replay.sf / 60) * 1000) / Scoring.TIMING_WINDOWS[0])
				]);
				saveJudge.push("miss");
			}

			// if (FlxG.save.data.accuracyMod == 1)
				// totalNotesHit -= 1;

      // TODO: Fix this.
			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;

			if (FlxG.save.data.missSounds)
			{
				FlxG.sound.play(Paths.soundRandom('missnote' + altSuffix, 1, 3), FlxG.random.float(0.1, 0.2));
			}

			// Hole switch statement replaced with a single line :)
			var singAnimation = EnigmaNote.getSingAnim(daNote, PlayState.SONG.strumlineSize);
			playerChar.playAnim(singAnimation + 'miss', true);

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [Math.abs(daNote.rawNoteData), Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	function updateAccuracy()
	{
		scoreTxt.text = Scoring.calculateRanking(Scoring.currentScore.getScore(), nps, maxNPS, Scoring.currentScore.getAccuracy());
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && !daNote.isCPUNote)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;
	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Scoring.judgeNote(noteDiff);

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (replayActive)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = PlayState.currentReplay.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Scoring.judgeNote(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				// combo += 1;
				popUpScore(note);
			}

			var altAnim:String = "";
			if (note.isAlt)
			{
				altAnim = '-alt';
				trace("Alt note on BF");
			}

			var singAnimation = EnigmaNote.getSingAnim(note, PlayState.SONG.strumlineSize);
			playerChar.playAnim(singAnimation + altAnim, true);

			#if FEATURE_LUAMODCHART
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [Math.abs(note.rawNoteData), Conductor.songPosition]);
			#end

			if (!replayActive && !note.isCPUNote)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (!PlayState.botPlayActive || FlxG.save.data.cpuStrums)
			{
				playerStrums.forEach(function(spr:StrumlineArrow)
				{
					pressArrow(spr, spr.ID, note);
				});
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
			{
				note.wasGoodHit = true;
			}
			if (!note.isSustainNote)
				updateAccuracy();
		}
	}

	function pressArrow(spr:StrumlineArrow, idCheck:Int, daNote:Note)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				spr.playAnim('confirm', true);
			}
			else
			{
				spr.playAnim('dirCon' + daNote.originColor, true);
				spr.localAngle = daNote.originAngle;
			}
		}
	}

	var danced:Bool = false;

	/**
	 * Called every step in the song, four times per beat.
	 */
	override function stepHit()
	{
		super.stepHit();

    // Syncronize the Conductor.
    var tooLate = FlxG.sound.music.time > Conductor.songPosition + MAX_TIME_DESYNC;
    var tooEarly = FlxG.sound.music.time < Conductor.songPosition - MAX_TIME_DESYNC;
		if (tooLate || tooEarly)
			resyncVocals();

    // Update the modchart and trigger the stepHit hook.
		#if FEATURE_LUAMODCHART
		if (this.modchartActive && PlayState.luaModchart != null)
		{
			PlayState.luaModchart.setVar('curStep', curStep);
			PlayState.luaModchart.executeState('stepHit', [curStep]);
		}
		#end
	}

	/**
	 * Called every beat in the song, once every four steps, four times every section.
	 */
	override function beatHit()
	{
		super.beatHit();

    // Update the modchart and trigger the beatHit hook.
		#if FEATURE_LUAMODCHART
		if (this.modchartActive && PlayState.luaModchart != null)
		{
			PlayState.luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

    // Camera zoom every n beats. We zoom in at onBeat and zoom back out in onUpdate.
    // Creates an 'unts unts unts' effect.
    var onBeat = cameraBeatZoomRate <= 0 ? false : (curBeat % cameraBeatZoomRate == 0);
    // In the song MILF, there is a section which zooms every beat.
    // TODO: Un-hardcode this and make this a song event.
		if (PlayState.SONG.songId == 'milf' && curBeat >= 168 && curBeat < 200)
		{
			onBeat = true;
		}
    if (FlxG.save.data.camzoom) {
      // Zoom the camera in.
      if (onBeat && cameraBeatZooming && FlxG.camera.zoom < CAMERA_MAX_ZOOM) {
				FlxG.camera.zoom += CAMERA_BEAT_ZOOM_GAME / songMultiplier;
				camHUD.zoom += CAMERA_BEAT_ZOOM_HUD / songMultiplier;
      }

      // Zoom the health icon in.
      if (onBeat && cameraBeatZooming) {
			  this.healthIconPlayer.setGraphicSize(Std.int(this.healthIconPlayer.width + 30));
			  this.healthIconCPU.setGraphicSize(Std.int(this.healthIconCPU.width + 30));

			  this.healthIconPlayer.updateHitbox();
			  this.healthIconCPU.updateHitbox();
      }
    }

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		if (currentSection != null)
		{
			if (curBeat % idleBeat == 0)
			{
				if (idleToBeat && !cpuChar.animation.curAnim.name.startsWith('sing'))
					cpuChar.dance(forcedToIdle, currentSection.CPUAltAnim);
				if (idleToBeat && !playerChar.animation.curAnim.name.startsWith('sing'))
					playerChar.dance(forcedToIdle, currentSection.playerAltAnim);
			}
			else if (cpuChar.curCharacter == 'spooky' || cpuChar.curCharacter == 'gf')
				cpuChar.dance(forcedToIdle, currentSection.CPUAltAnim);
		}
		wiggleEffect.update(Conductor.crochet);

		if (!this.endingSong && currentSection != null)
		{
			if (allowedToHeadbang && curBeat % gfSpeed == 0)
			{
				gfChar.dance();
			}

			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			{
				playerChar.playAnim('hey', true);
			}

			if (curBeat % 16 == 15 && PlayState.SONG.songId == 'tutorial' && cpuChar.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				playerChar.playAnim('hey', true);
				cpuChar.playAnim('cheer', true);
			}

			if (PlayStateChangeables.Optimize)
				if (vocals.volume == 0 && !currentSection.mustHitSection)
					vocals.volume = 1;
		}
	}

	public var cleanedSong:SongData;

	function poggers(?cleanTheSong = false)
	{
		var notes = [];

		if (cleanTheSong)
		{
			cleanedSong = PlayState.SONG;

			for (section in cleanedSong.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in cleanedSong.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
		else
		{
			for (section in PlayState.SONG.notes)
			{
				var removed = [];

				for (note in section.sectionNotes)
				{
					// commit suicide
					var old = note[0];
					if (note[0] < section.startTime)
					{
						notes.push(note);
						removed.push(note);
					}
					if (note[0] > section.endTime)
					{
						notes.push(note);
						removed.push(note);
					}
				}

				for (i in removed)
				{
					section.sectionNotes.remove(i);
				}
			}

			for (section in PlayState.SONG.notes)
			{
				var saveRemove = [];

				for (i in notes)
				{
					if (i[0] >= section.startTime && i[0] < section.endTime)
					{
						saveRemove.push(i);
						section.sectionNotes.push(i);
					}
				}

				for (i in saveRemove)
					notes.remove(i);
			}

			trace("FUCK YOU BITCH FUCKER CUCK SUCK BITCH " + cleanedSong.notes.length);

			SONG = cleanedSong;
		}
	}

	/**
	 * Allows rendering a WEBM video in the background of the stage.
   * Currently UNUSED but we can readd it at some point.
	 * @param source 
	 * @return
	 */
	public function addBackgroundVideo(source:String) // for background videos
	{
		#if FEATURE_WEBM
		this.backgroundVideoActive = true;

		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		// WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gfChar);
		remove(playerChar);
		remove(cpuChar);
		add(videoSprite);
		add(gfChar);
		add(playerChar);
		add(cpuChar);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

  /**
   * If there is an existing background video which is currently displayed,
   * stop the video and remove the sprite.
   */
  public function removeBackgroundVideo() {
    if (this.backgroundVideoActive && !this.backgroundVideoRemoved)
		{
      GlobalVideo.get().stop();
			remove(videoSprite);
			FlxG.stage.window.onFocusOut.remove(focusOut);
			FlxG.stage.window.onFocusIn.remove(focusIn);
			this.backgroundVideoRemoved = true;
		}
  }
}
