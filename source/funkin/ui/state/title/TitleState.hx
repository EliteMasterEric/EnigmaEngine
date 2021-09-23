package;

import haxe.extern.EitherType;
#if FEATURE_STEPMANIA
import stepmania.SMFile;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
#if FEATURE_DISCORD
import Discord.DiscordClient;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	/**
	 * Whether the state transition animation has been initialized.
	 * We only need to do this once for the life of the application.
	 */
	static var initialized:Bool = false;

	/**
	 * Whether we are transitioning from the title screen to the main menu.
	 */
	var transitioning:Bool = false;

	/**
	 * Whether the procedure to skip the intro credits has already started.
	 */
	var skippedIntro:Bool = false;

	/**
	 * The data powering the title screen, retrieved from `data/titleScreen.json`.
	 * You can change song BPM, background image, credits text, and more by editing that file.
	 */
	var titleScreenData:TitleScreenData;

	// Graphics used by title credits.

	/**
	 * The background of the intro credits.
	 * Defaults to black but configurable in `data/titleScreen.json`.
	 */
	var creditsBackground:FlxSprite;

	/**
	 * Sprite group containing all the parts of the intro credits.
	 		* Makes the logic for skipping the title screen easy.
	 */
	var creditsGroup:FlxGroup;

	/**
	 * The credits graphic currently being displayed.
	 * Set by `setGraphic` action, value is `null` most of the time.
	 */
	var creditsGraphic:FlxSprite;

	/**
	 * The current offset of the credits text.
	 * Set with the `setTextOffset` action.
	 */
	var creditsTextOffset:Float = 0;

	/**
	 * Sprite group containing all the lines of text in the intro credits.
	 */
	var creditsTextGroup:FlxGroup;

	// Graphics used by intro screen (with logo and GF).

	/**
	 * The background of the title screen.
	 * Defaults to black but configurable in `titleScreen.json`.
	 */
	var titleBackground:FlxSprite;

	/**
	 * The animated Friday Night Funkin' logo.
	 * Customize this by replacing `images/logoBumpin.png` and the associated XML.
	 */
	var logoBumpin:FlxSprite;

	/**
	 * GF vibing on the speaker by the FNF logo.
	 * Customize this by replacing `images/gfDanceTitle.png` and the associated XML.
	 * If she's dancing too slow because you replaced the music, change `bpm` in 
	 */
	var gfDance:FlxSprite;

	/**
	 * Text that reads "Press ENTER to Start".
	 		* Customize this by replacing `images/titleEnter.png` and the associated XML.
	 */
	var titleText:FlxSprite;

	/**
	 * The currently selected wacky random text, chosen at random from `introText.txt`.
	 * If you modify `titleScreen.json` you can use more than two lines.
	 * You can replace this with the `reloadWackyText` action.
	 */
	var currentWackyText:Array<String> = [];

	/**
	 * Keeps track of how GF is dancing.
	 */
	var danceLeft:Bool = false;

	var creditsGraphicCache:Map<String, FlxSprite>;

	override public function create():Void
	{
		// TODO: Refactor this to use OpenFlAssets for compatibility with ModCore.
		#if FEATURE_FILESYSTEM
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end

		@:privateAccess
		{
			Debug.logTrace("OpenFL loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets into the default library");
		}

		// This line only runs if we didn't run the Caching state (i.e. on HTML5 platforms).
		#if !FEATURE_FILESYSTEM
		// Load the save file.
		FlxG.save.bind('funkin', 'ninjamuffin99');

		// Initialize the player settings.
		PlayerSettings.init();

		// Load the player's save data.
		SaveData.initSave();
		#end

		// Load the high score data.
		Highscore.load();

		// Load the title screen procedure from the titleScreen.json data file.
		var titleScreenRaw = Paths.loadJSON('titleScreen');
		titleScreenData = cast titleScreenRaw;

		reloadWackyText();

		super.create();

		#if !cpp
		// I guess on some platforms you have to wait a second?
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#else
		startIntro();
		#end

		Debug.logTrace('Initialized TitleState...');
	}

	/**
	 * Initializes all the title screen graphics and sprite groups.
	 */
	function startIntro()
	{
		persistentUpdate = true;

		// Background graphic. Currently a black sprite.
		// TODO: Add the ability to override this (either an asset or a color).
		if (titleScreenData.titleBackground != null && titleScreenData.titleBackground.startsWith("#"))
		{
			titleBackground = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromString(titleScreenData.titleBackground));
		}
		else
		{
			// TODO: Implement this.
			Debug.logWarn("HEY! Using custom images for the title background isn't supported right now. Falling back to BLACK.");
			Debug.logWarn("Go to the Enigma Engine Github page and create an issue about this.");
			titleBackground = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}
		add(titleBackground);

		if (titleScreenData.gf != null)
		{
			gfDance = new FlxSprite(titleScreenData.gf.x, titleScreenData.gf.y);
			gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
			// Make the gfDance always work regardless of the number of frames in the animation,
			// by scaling the frame rate to match.
			var frameArrays = buildDanceFrameArrays(gfDance.frames.numFrames);
			Debug.logTrace('GF dance frames: ' + frameArrays[0] + ' : ' + Math.round(24 / 16 * gfDance.frames.numFrames / 2));
			Debug.logTrace('GF dance frames: ' + frameArrays[1] + ' : ' + Math.round(24 / 15 * gfDance.frames.numFrames / 2));
			gfDance.animation.addByIndices('danceLeft', 'gfDance', frameArrays[0], "", Math.round(24 / 16 * gfDance.frames.numFrames / 2), false);
			gfDance.animation.addByIndices('danceRight', 'gfDance', frameArrays[1], "", Math.round(24 / 15 * gfDance.frames.numFrames / 2), false);
			gfDance.setGraphicSize(Std.int(gfDance.width * titleScreenData.gf.scale));
		}
		else
		{
			Debug.logWarn('Could not load title screen data for GF sprite...');
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
			gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
			gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}
		gfDance.antialiasing = FlxG.save.data.antialiasing;

		add(gfDance);

		if (titleScreenData.logo != null)
		{
			logoBumpin = new FlxSprite(titleScreenData.logo.x, titleScreenData.logo.y);
			logoBumpin.frames = Paths.getSparrowAtlas('logoBumpin');
			logoBumpin.antialiasing = FlxG.save.data.antialiasing;
			logoBumpin.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBumpin.setGraphicSize(Std.int(logoBumpin.width * titleScreenData.logo.scale));
			logoBumpin.updateHitbox();
		}
		else
		{
			Debug.logWarn('Could not load title screen data for logo sprite...');
			logoBumpin = new FlxSprite(-150, -100);
			logoBumpin.frames = Paths.getSparrowAtlas('logoBumpin');
			logoBumpin.antialiasing = FlxG.save.data.antialiasing;
			logoBumpin.animation.addByPrefix('bump', 'logo bumpin', 24, false);
			logoBumpin.updateHitbox();
		}

		add(logoBumpin);

		// Add the title text.
		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = FlxG.save.data.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		// Init the credits text groups.
		creditsGroup = new FlxGroup();
		add(creditsGroup);
		creditsTextGroup = new FlxGroup();

		// Make the background of the credits black.
		if (titleScreenData.creditsBackground != null && titleScreenData.creditsBackground.startsWith("#"))
		{
			creditsBackground = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromString(titleScreenData.creditsBackground));
		}
		else
		{
			// TODO: Implement this.
			Debug.logWarn("HEY! Using custom images for the credits background isn't supported right now. Falling back to BLACK.");
			Debug.logWarn("Go to the Enigma Engine Github page and create an issue about this.");
			creditsBackground = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}
		creditsGroup.add(creditsBackground);

		// We initialize all the FlxSprites at the start so the credits don't lag.
		creditsGraphicCache = new Map<String, FlxSprite>();
		for (creditsGraphicPath in listAllCreditsGraphics())
		{
			var sprite = new FlxSprite(0, 0).loadGraphic(Paths.loadImage(creditsGraphicPath));
			sprite.animation.addByPrefix('Animation', 'Animation', 30, true, false, false);
			creditsGraphicCache.set(creditsGraphicPath, sprite);
		}

		// TODO: Unused animation. Maybe we can make the credits text bounce to the beat?
		// FlxTween.tween(creditsTextGroup, {y: creditsTextGroup.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		// Prevent playing the diamond twice if playIntro gets called twice.
		if (initialized)
		{
			skipIntro();
		}
		else
		{
			// Play a fancy titled diamond animation when transitioning into and out of ANY state..
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			// We're setting the DEFAULT transition here.
			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// Play the title music. Gettin' freaky on a friday night!
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			// Music fades in.
			FlxG.sound.music.fadeIn(4, 0, 0.7);

			// Load the BPM from the JSON file if possible.
			if (titleScreenData != null)
			{
				Conductor.changeBPM(titleScreenData.bpm);
			}
			else
			{
				Conductor.changeBPM(102);
			}

			initialized = true;
		}
	}

	/**
	 * Calculates the frame arrays from the GF animation.
	 * You don't need to match the number of frames in the original gfDance animation
	 * in order for the title animation to dance on beat, thanks to this code.
	 * Just replace or merge the titleScreen.json.
	 * @param frameCount The number of frames in the animation.
	 * @return The ranges of frames for the danceLeft and danceRight animations.
	 */
	static function buildDanceFrameArrays(frameCount:Int):Array<Array<Int>>
	{
		var lastFrame:Int = frameCount - 1;
		var halfway:Int = Math.ceil(lastFrame / 2);

		var left = [];
		for (i in 0...halfway)
			left.push(i);

		var right = [];
		for (i in (halfway + 1)...lastFrame)
			right.push(i);

		return [left, right];
	}

	/**
	 * This function runs every frame.
	 * @param elapsed The time in seconds that passed since the last frame.
	 */
	override function update(elapsed:Float)
	{
		// Keep the Conductor in sync.
		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		// Called when pressing ENTER, to either skip the intro or enter the main menu.
		var pressedEnter:Bool = controls.ACCEPT;

		// Also skip the intro when tapping on the screen.
		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		// If we've already skipped the intro...
		if (pressedEnter && !transitioning && skippedIntro)
		{
			// Move to the main menu.

			// Play the flashing animation on the title text.
			if (FlxG.save.data.flashing)
			{
				titleText.animation.play('press');
			}

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			MainMenuState.firstStart = true;
			MainMenuState.finishedFunnyMove = false;

			// 2 seconds after we start flashing, move to the main menu.
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Version check.

				if (Enigma.ENABLE_VERSION_CHECK)
				{
					Debug.logTrace('Preparing to perform an engine version check.');

					var http = new haxe.Http(Enigma.ENGINE_VERSION_URL);
					var returnedData:Array<String> = [];

					http.onData = function(data:String)
					{
						returnedData[0] = data.substring(0, data.indexOf(';'));
						returnedData[1] = data.substring(data.indexOf('-'), data.length);
						if (!Enigma.ENGINE_VERSION.contains(returnedData[0].trim()) && !OutdatedSubState.leftState)
						{
							Debug.logTrace('Your game version is outdated! ${returnedData[0]} != ${Enigma.ENGINE_VERSION}');
							OutdatedSubState.needVer = returnedData[0];
							OutdatedSubState.currChanges = returnedData[1];
							FlxG.switchState(new OutdatedSubState());
							clean();
						}
						else
						{
							Debug.logTrace('Your game version is up to date! Have a nice day ;)');
							FlxG.switchState(new MainMenuState());
							clean();
						}
					}

					http.onError = function(error)
					{
						Debug.logTrace('An error occurred checking for engine updates: $error');
						Debug.logTrace('Eh, who cares. Got to the title screen anyway.');
						FlxG.switchState(new MainMenuState());
						clean();
					}

					http.request();
				}
				else
				{
					Debug.logInfo('Version checks for this build of Enigma Engine were disabled at compile time.');
				}
			});
		}

		// Else, if we haven't skipped the intro yet, do that.
		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	/**
	 * Add credits text to the screen.
	 * @param text The text to add.
	 */
	function addCreditsText(text:String)
	{
		// We do credits text as individual lines because centering doesn't work with newlines.
		var creditsTextLine:Alphabet = new Alphabet(0, 0, text, true, false);
		creditsTextLine.screenCenter(X);
		creditsTextLine.y += creditsTextOffset;
		creditsTextLine.y += (creditsTextGroup.length * 60) + 200;
		creditsGroup.add(creditsTextLine);
		creditsTextGroup.add(creditsTextLine);
	}

	/**
	 * Remove all credits text from the screen.
	 */
	function clearCreditsText()
	{
		while (creditsTextGroup.members.length > 0)
		{
			creditsGroup.remove(creditsTextGroup.members[0], true);
			creditsTextGroup.remove(creditsTextGroup.members[0], true);
		}
	}

	/**
	 * Display a credits graphic.
	 */
	function showCreditsGraphic(assetName:String)
	{
		creditsGraphic = creditsGraphicCache.get(assetName);
		if (creditsGraphic != null)
		{
			creditsGroup.add(creditsGraphic);

			// This value will be null if the animation can't be initialized.
			if (creditsGraphic.animation.getByName('Animation') != null)
			{
				creditsGraphic.animation.play('Animation');
			}
		}
		else
		{
			Debug.logWarn('Oh no! Could not find credits graphic by name "${assetName}"');
		}
	}

	/**
	 * Clear the current credits graphic.
	 */
	function clearCreditsGraphic()
	{
		creditsGroup.remove(creditsGraphic);
		creditsGraphic = null;
	}

	/**
	 * Parses the introText.txt file and reloads the wacky text from
	 * the list of all possible wacky text entries.
	 */
	function reloadWackyText():Void
	{
		var wackyText:String = Assets.getText(Paths.txt('data/introText'));

		var wackyTextLines:Array<String> = wackyText.split('\n');
		var wackyTextEntries:Array<Array<String>> = [];

		for (i in wackyTextLines)
		{
			wackyTextEntries.push(i.split('--'));
		}

		// Choose a random entry from the introText.txt data file.
		currentWackyText = FlxG.random.getObject(wackyTextEntries);
	}

	override function beatHit()
	{
		super.beatHit();

		// Every beat, we play the logo animation...
		logoBumpin.animation.play('bump', true);
		// ...and we switch GF from dancing left to dancing right.
		danceLeft = !danceLeft;
		if (danceLeft)
		{
			gfDance.animation.play('danceRight');
		}
		else
		{
			gfDance.animation.play('danceLeft');
		}

		// Remember that weird case structure

		if (titleScreenData == null || titleScreenData.credits == null || titleScreenData.credits.length == 0)
		{
			Debug.logTrace('Title screen data was null or credits were empty. Skipping to the title screen...');
			skipIntro();
		}
		else
		{
			if (curBeat < titleScreenData.credits.length && !skippedIntro)
			{
				var creditsEntry = titleScreenData.credits[curBeat];

				if (Std.isOfType(creditsEntry, Array))
				{
					var creditsEntryList:Array<TitleScreenCreditsEntry> = cast creditsEntry;
					Debug.logTrace('Multiple credits actions this beat.');
					for (creditsSubEntry in creditsEntryList)
					{
						performCreditsAction(creditsSubEntry);
					}
				}
				else
				{
					var creditsEntryValue:TitleScreenCreditsEntry = cast creditsEntry;
					// Debug.logTrace('Credits action single.');
					performCreditsAction(creditsEntryValue);
				}
			}
			else
			{
				if (!skippedIntro)
				{
					skipIntro();
				}
			}
		}
	}

	/**
	 * If you're wondering where the case structure is, IT'S GONE!
	 * I made it data driven so that mods can override it.
	 * 
	 * Check out `data/titleScreen.json`.
	 * 
	 * @param creditsEntry 
	 */
	function performCreditsAction(creditsEntry:TitleScreenCreditsEntry)
	{
		Debug.logTrace('Credits action: ${creditsEntry.action} : ${creditsEntry.value} : ${creditsEntry.values}');
		switch (creditsEntry.action)
		{
			case 'addText':
				Debug.logTrace('Adding text...');
				if (creditsEntry.values != null || creditsEntry.values.length != 0)
				{
					for (entryLine in creditsEntry.values)
					{
						addCreditsText(entryLine);
					}
				}
				else
				{
					Debug.logWarn('NO VALUE FOUND, skipping...');
				}
			case 'clearText':
				Debug.logTrace('Clearing text...');
				clearCreditsText();
			case 'addWackyText':
				Debug.logTrace('Adding wacky text...');
				if (creditsEntry.values != null || creditsEntry.values.length != 0)
				{
					for (entryIndex in creditsEntry.values)
					{
						if (currentWackyText.length < entryIndex || currentWackyText[entryIndex] == null)
						{
							Debug.logWarn('NO VALUE FOUND for index, skipping...');
						}
						else
						{
							addCreditsText(currentWackyText[entryIndex]);
						}
					}
				}
				else
				{
					Debug.logWarn('NO INDEX FOUND, skipping...');
				}
			case 'setTextOffset':
				Debug.logTrace('Setting text offset...');
				if (creditsEntry.value != null)
				{
					creditsTextOffset = creditsEntry.value;
				}
				else
				{
					Debug.logWarn('NO VALUE FOUND, skipping...');
				}
			case 'reloadWackyText':
				// You still have to call clearText and addText yourself.
				Debug.logTrace('Reloading wacky text...');
				reloadWackyText();
			case 'setGraphic':
				Debug.logTrace('Setting credits graphic...');
				if (creditsEntry.value != null)
				{
					showCreditsGraphic(creditsEntry.value);
				}
				else
				{
					Debug.logWarn("Couldn't find a 'value' attribute for addGraphic.");
				}
			case 'clearGraphic':
				Debug.logTrace('Clearing credits graphic...');
				clearCreditsGraphic();
			case 'setBackground':
				Debug.logTrace('Setting credits background...');
				if (creditsEntry.value != null && creditsEntry.value.startsWith("#"))
				{
					creditsBackground = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromString(creditsEntry.value));
				}
				else
				{
					// TODO: Fix this.
					Debug.logWarn("HEY! Using custom images for the credits background isn't supported right now. Falling back to BLACK.");
					Debug.logWarn("Go to the Enigma Engine Github page and create an issue about this.");
					creditsBackground = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				}
			case 'wait':
			// Do nothing. Zilch.
			default:
				Debug.logWarn('Credits action UNKNOWN!');
		}
	}

	/**
	 * Iterates through each credits action or action group, finds instances of setGraphic,
	 * and returns all the graphics used. We use this for pre-caching.
	 * @return An array of paths.
	 */
	function listAllCreditsGraphics():Array<String>
	{
		var results:Array<String> = [];
		if (titleScreenData != null && titleScreenData.credits != null && titleScreenData.credits.length > 0)
		{
			for (creditsEntry in titleScreenData.credits)
			{
				if (Std.isOfType(creditsEntry, Array))
				{
					var creditsEntryList:Array<TitleScreenCreditsEntry> = cast creditsEntry;
					for (creditsSubEntry in creditsEntryList)
					{
						if (creditsSubEntry.action == "setGraphic")
						{
							Debug.logTrace('Found graphic to preload in credits group: ${creditsSubEntry.value}');
							results.push(creditsSubEntry.value);
						}
					}
				}
				else
				{
					var creditsEntryValue:TitleScreenCreditsEntry = cast creditsEntry;
					if (creditsEntryValue.action == "setGraphic")
					{
						Debug.logTrace('Found graphic to preload in credits group: ${creditsEntryValue.value}');
						results.push(creditsEntryValue.value);
					}
				}
			}
		}
		return results;
	}

	/**
	 * Called when pressing ENTER to skip the intro.
	 * Also gets called when the intro credits naturally end or if we are coming back to the title screen from the main menu.
	 */
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			Debug.logInfo("Skipping intro...");

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(creditsGroup);

			// Ease in the logo from the top.
			FlxTween.tween(logoBumpin, {y: -100}, 1.4, {ease: FlxEase.expoInOut});

			// Rotate the angle over time.
			var baseAngle:Float = 4;
			var baseDuration:Float = 4;
			if (titleScreenData != null && titleScreenData.logo != null)
			{
				baseAngle = titleScreenData.logo.angle;
				baseDuration = titleScreenData.logo.duration;
			}

			logoBumpin.angle = -1 * baseAngle;
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if (logoBumpin.angle == -4)
				{
					FlxTween.angle(logoBumpin, logoBumpin.angle, baseAngle, baseDuration, {ease: FlxEase.quartInOut});
				}
				if (logoBumpin.angle == 4)
				{
					FlxTween.angle(logoBumpin, logoBumpin.angle, -1 * baseAngle, baseDuration, {ease: FlxEase.quartInOut});
				}
			}, 0);

			// It always bugged me that it didn't do this before.
			// Skip ahead in the song to the drop.
			if (titleScreenData != null)
			{
				FlxG.sound.music.time = titleScreenData.beatDropMs;
			}

			skippedIntro = true;
		}
	}
}

typedef TitleScreenCreditsEntry =
{
	/**
	 * Can be one of:
	 * add, delete, addWacky, endIntro
	 */
	var action:String;

	// Can be a string or int.
	var ?value:Dynamic;
	// Can be an array of ints or an array of strings.
	var ?values:Array<Dynamic>;
}

typedef TitleScreenGraphic =
{
	var x:Float;
	var y:Float;
	var scale:Float;
}

typedef TitleScreenLogo =
{
	> TitleScreenGraphic,
	var angle:Float;
	var duration:Float;
}

typedef TitleScreenData =
{
	var gf:TitleScreenGraphic;
	var logo:TitleScreenLogo;
	// A floating point value.
	var bpm:Float;
	// An integer value.
	var beatDropMs:Int;
	// Either a string hex code or an image path.
	var creditsBackground:String;
	var titleBackground:String;
	// Keys are integer values for beat numbers.
	var credits:Array<EitherType<TitleScreenCreditsEntry, Array<TitleScreenCreditsEntry>>>;
}
