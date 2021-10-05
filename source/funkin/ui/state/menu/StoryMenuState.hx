package funkin.ui.state.menu;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.assets.menu.WeekData;
import funkin.assets.Paths;
import funkin.assets.play.Song;
import funkin.behavior.Debug;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.Highscore;
import funkin.const.Enigma;
import funkin.ui.audio.MainMenuMusic;
import funkin.ui.component.menu.MenuCharacter;
import funkin.ui.component.menu.StoryWeekDifficultyItem;
import funkin.ui.component.menu.StoryWeekMenuItem;
import funkin.ui.state.play.PlayState;
import funkin.util.Util;
#if FEATURE_DISCORD
import funkin.behavior.api.Discord.DiscordClient;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	/**
	 * The index of the current highlighted week.
	 */
	var curWeekIndex:Int = 0;

	/**
	 * The current value displayed by the score text.
	 * When scrolling between difficulties or weeks, this will scroll up to
	 * linearly approach the intended score value
	 */
	var lerpScore:Int = 0;

	/**
	 * The actual high score that the Story menu wants to display.
	 */
	var intendedScore:Int = 0;

	/**
	 * The user has left the menu, so we should disable interaction.
	 */
	var leavingMenu:Bool = false;

	/**
	 * The user has selected a week, so we should disable interaction.
	 */
	var selectedWeek:Bool = false;

	/**
	 * The week title/flavor text.
	 */
	var txtWeekTitle:FlxText;

	/**
	 * The UI element displaying the current high score.
	 */
	var scoreText:FlxText;

	/**
	 * The UI element displaying the list of songs in the week.
	 */
	var txtTracklist:FlxText;

	/**
	 * The menu items in the week list.
	 */
	var grpWeekText:FlxTypedGroup<StoryWeekMenuItem>;

	/**
	 * The character icons that appear above the week list.
	 */
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	/**
	 * The sprites that display as padlocks next to locked weeks in the week list.
	 */
	var grpLocks:FlxTypedGroup<FlxSprite>;

	/**
	 * A sprite group containing all the UI elements for the difficulty selector.
	 */
	var difficultySelectors:FlxGroup;

	/**
	 * The background behind the characters. In Vanilla this is just solid yellow.
	 * The size of this sprite is 1280x400.
	 */
	var characterBG:FlxSprite;

	/**
	 * The sprite displaying the current difficulty.
	 */
	var difficultyItem:StoryWeekDifficultyItem;

	/**
	 * The left arrow next to the difficulty.
	 */
	var leftArrow:FlxSprite;

	/**
	 * The right arrow next to the difficulty.
	 */
	var rightArrow:FlxSprite;

	/**
	 * An ordered list of the weeks to display in the menu.
	 */
	var orderedWeekIds:Array<String> = [];

	/**
	 * `orderedWeekIds` but with hidden weeks filtered out.
	 */
	var filteredWeekIds:Array<String> = [];

	var weekData:Map<String, WeekData> = [];

	override function create()
	{
		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		// Load the week list.
		orderedWeekList = Util.loadLinesFromFile(Paths.txt('data/weekOrder'));
		for (weekId in orderedWeekList)
		{
			var weekDataElement = WeekData.fetchWeekData(weekId);
			if (weekDataElement.isWeekUnlocked())
				filteredWeekIds.push(weekId);
			weekData.set(weekId, WeekData.fetchWeekData(weekId));
		}

		// Make sure the diamond fade in is used.
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// Make sure freaky music is playing.
		MainMenuMusic.playMenuMusic();

		// Make sure this state draws and updates even if other substates overlay it.
		persistentUpdate = persistentDraw = true;

		// Initialize the high score text.
		scoreText = new FlxText(10, 10, 0, "SCORE: 0", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		// Initialize the week name.
		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		grpWeekText = new FlxTypedGroup<StoryWeekMenuItem>();
		add(grpWeekText);

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		// Black bar along the top.
		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		for (weekIndex in 0...filteredWeekIds.length)
		{
			var weekDataEntry = weekData.get(filteredWeekIds[i]);

			var weekMenuItem:StoryWeekMenuItem = new StoryWeekMenuItem(0, characterBG.y + characterBG.height + 10, weekDataEntry);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = FlxG.save.data.antialiasing;

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				trace('locking week ' + i);
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = FlxG.save.data.antialiasing;
				grpLocks.add(lock);
			}
		}

		grpWeekCharacters.add(new MenuCharacter(0, 100, ""));
		grpWeekCharacters.add(new MenuCharacter(450, 25, "gf"));
		grpWeekCharacters.add(new MenuCharacter(850, 100, "bf"));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		// TODO: Make this a spritesheet so press graphic works.
		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.loadGraphic(Paths.image('storymenu/ArrowLeft'));
		leftArrow.animation.addByPrefix('idle', "idle");
		leftArrow.animation.addByPrefix('press', "press");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(leftArrow);

		difficultyItem = new DifficultyItem(leftArrow.x + 130, leftArrow.y);
		difficultyItem.antialiasing = FlxG.save.data.antialiasing;
		changeDifficulty();

		difficultySelectors.add(difficultyItem);

		// TODO: Make this a spritesheet so press graphic works.
		rightArrow = new FlxSprite(difficultyItem.x + difficultyItem.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(rightArrow);

		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, characterBG.x + characterBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		// Guess this fades weeks that are before and after the current week?
		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		super.create();
	}

	/**
	 * Edit the player's save data to indicate they have unlocked the given week.
	 * @param weekId The week ID.
	 */
	public static function unlockWeek(weekId:String)
	{
		if (FlxG.save.data.weeksUnlocked == null)
		{
			FlxG.save.data.weeksUnlocked = [weekId => true];
		}
		else
		{
			FlxG.save.data.weeksUnlocked[weekId] = true;
		}
	}

	/**
	 * We have selected a week to play! Load it, add the songs to the playlist,
	 * and start the PlayState.
	 * @param weekId The string identifier of the week to play.
	 */
	public static function playWeek(weekId:String)
	{
		// TODO: Implement this.
	}

	override function update(elapsed:Float)
	{
		// Scroll the score until it matches the actual score value.
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));
		// Update the score text.
		scoreText.text = "WEEK SCORE:" + lerpScore;

		// Update the week name text.
		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		// Align the text to the right side.
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// Only show the difficulty selector UI (left and right arrow) if the current week is unlocked.
		difficultySelectors.visible = weekUnlocked[curWeek];

		// Move the week list lock sprites into position next to the text.
		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		// Pressed cancel/ESC to move back to main menu.
		if (controls.BACK && !leavingMenu && !selectedWeek)
		{
			// Play a sound and switch state.
			FlxG.sound.play(Paths.sound('cancelMenu'));
			leavingMenu = true;
			FlxG.switchState(new MainMenuState());
		}

		if (!leavingMenu)
		{
			// Pressed okay/ENTER to start the week.
			if (controls.ACCEPT)
			{
				selectWeek();
			}

			if (!selectedWeek)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					if (gamepad.justPressed.DPAD_UP)
					{
						changeWeek(-1);
					}
					if (gamepad.justPressed.DPAD_DOWN)
					{
						changeWeek(1);
					}

					if (gamepad.pressed.DPAD_RIGHT)
						rightArrow.animation.play('press')
					else
						rightArrow.animation.play('idle');
					if (gamepad.pressed.DPAD_LEFT)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');

					if (gamepad.justPressed.DPAD_RIGHT)
					{
						changeDifficulty(1);
					}
					if (gamepad.justPressed.DPAD_LEFT)
					{
						changeDifficulty(-1);
					}
				}

				if (FlxG.keys.justPressed.UP)
				{
					changeWeek(-1);
				}

				if (FlxG.keys.justPressed.DOWN)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}
		}

		// Re-sync the Conductor.
		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		super.update(elapsed);
	}

	function selectWeek()
	{
		if (!Song.validateSongs(weekData()[curWeek], difficultyItem.currentDifficulty))
		{
			// If any song doesn't exist, stop loading the week.
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Debug.logError('CANCELLED loading week: one or more songs are missing on this difficulty!');
			return;
		}

		if (weekUnlocked[curWeek])
		{
			if (!selectedWeek)
			{
				// Play a sound.
				FlxG.sound.play(Paths.sound('confirmMenu'));
				// Play the animation on the menu option.
				grpWeekText.members[curWeek].startFlashing();
				//
				grpWeekCharacters.members[1].animation.play('bfConfirm');
				selectedWeek = true;
			}

			PlayState.storyPlaylist = weekData()[curWeek];
			PlayState.isStoryMode = true;
			PlayState.songMultiplier = 1;

			PlayState.isSM = false;

			PlayState.storyDifficulty = difficultyItem.currentDifficultyId;

			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			var diffSuffix = StoryModeDifficultyItem.getDifficultySuffix(PlayState.storyDifficulty);
			PlayState.SONG = Song.conversionChecks(Song.loadFromJson(PlayState.storyPlaylist[0], diffSuffix));
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	// Pressed left or right to change the difficulty.
	function changeDifficulty(change:Int = 0):Void
	{
		difficultyItem.changeDifficulty(change);

		difficultyItem.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		difficultyItem.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, difficultyItem.currentDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, difficultyItem.currentDifficulty);
		#end

		FlxTween.tween(difficultyItem, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	// Pressed up or down to change thw eek.
	function changeWeek(change:Int = 0):Void
	{
		// Increment or decrement.
		curWeek += change;

		// Loop around when you reach either end.
		if (curWeek >= orderedWeekList.length)
		{
			curWeek = 0;
		}
		if (curWeek < 0)
		{
			curWeek = orderedWeekList.length - 1;
		}

		// Some weird fading logic. Disable and see what happens?
		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		// Scroll in the menu.
		FlxG.sound.play(Paths.sound('scrollMenu'));

		var curWeekData = getCurrentWeekData();

		updateText();
	}

	function getCurrentWeekData():WeekData
	{
		return weekData.get(filteredWeekIds[curWeekIndex]);
	}

	/**
	 * Set the text of the track list, reset the intended score,
	 * and
	 * 
	 * Called once on init and once every time the weeks change.
	 */
	function updateText()
	{
		// Update character background
		remove(characterBG);
		characterBG = getCurrentWeekData().createBackgroundSprite();
		characterBG.y = 56;
		add(characterBG);

		// Update characters.
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		// Update track list.
		txtTracklist.text = "Tracks\n";
		var trackIds:Array<String> = curWeekData.songs;

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		intendedScore = Highscore.getWeekScore(curWeek, difficultyItem.currentDifficulty);
	}

	/**
	 * Called based on the current song's BPM.
	 * Used to make menu characters play their animations.
	 */
	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 2 == 0)
		{
			grpWeekCharacters.members[0].bopHead();
			grpWeekCharacters.members[1].bopHead();
		}
		else if (weekCharacters[curWeek][0] == 'spooky' || weekCharacters[curWeek][0] == 'gf')
			grpWeekCharacters.members[0].bopHead();

		if (weekCharacters[curWeek][2] == 'spooky' || weekCharacters[curWeek][2] == 'gf')
			grpWeekCharacters.members[2].bopHead();
	}
}
