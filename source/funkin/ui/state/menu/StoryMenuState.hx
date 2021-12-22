/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * StoryMenuState.hx
 * The state containing the menu which lists the story weeks and allows you to
 * start a playlist of songs at a given difficulty.
 */
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
import funkin.behavior.options.Options.AntiAliasingOption;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.Highscore;
import funkin.behavior.play.Scoring;
import funkin.behavior.play.Scoring.SongScore;
import funkin.behavior.play.Song;
import funkin.const.Enigma;
import funkin.data.DifficultyData.DifficultyDataHandler;
import funkin.data.WeekData;
import funkin.ui.component.menu.MenuCharacter;
import funkin.ui.component.menu.StoryWeekDifficultyItem;
import funkin.ui.component.menu.StoryWeekMenuItem;
import funkin.ui.state.play.PlayState;
import funkin.util.assets.AudioAssets;
import funkin.util.assets.DataAssets;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;
import funkin.util.Util;
#if FEATURE_DISCORD
import funkin.behavior.api.Discord.DiscordClient;
#end

using hx.strings.Strings;

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
	 * `data/weekOrder.txt` but with hidden weeks filtered out.
	 */
	var weekIds:Array<String> = [];

	override function create()
	{
		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		weekIds = WeekDataHandler.storyWeekIds;

		if (weekIds.length == 0)
		{
			Debug.logError('WARNING: There are no story weeks available!');
			Debug.logError('Check your configuration!');
		}

		// Make sure the diamond fade in is used.
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

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

		Debug.logInfo('Displaying entries for ${weekIds.length} week IDs.');

		for (i in 0...weekIds.length)
		{
			var weekDataEntry:WeekData = WeekDataHandler.fetch(weekIds[i]);
			if (weekDataEntry.isHidden())
			{
				Debug.logInfo('Skipping hidden week ${weekDataEntry.id}');
				continue;
			}

			Debug.logTrace('Rendering entry for week ${weekIds[i]}');

			var weekMenuItem:StoryWeekMenuItem = new StoryWeekMenuItem(0, 56 + 400 + 10, weekDataEntry);
			weekMenuItem.y += ((weekMenuItem.height + 20) * i);
			weekMenuItem.targetY = i;
			grpWeekText.add(weekMenuItem);

			weekMenuItem.screenCenter(X);
			weekMenuItem.antialiasing = AntiAliasingOption.get();

			// Needs an offset thingie
			if (!weekDataEntry.isUnlocked())
			{
				trace('Locking week ${weekIds[i]}');
				var lock:FlxSprite = new FlxSprite(weekMenuItem.width + 10 + weekMenuItem.x);
				lock.loadGraphic(Paths.image('storymenu/lock'));
				lock.ID = i;
				lock.antialiasing = AntiAliasingOption.get();
				grpLocks.add(lock);
			}
		}

		// Build and display the week background (yellow square in vanilla).
		characterBG = getCurrentWeek().createBackgroundSprite();
		characterBG.y = 56;
		add(characterBG);

		grpWeekCharacters.add(new MenuCharacter(0, 100, ""));
		grpWeekCharacters.add(new MenuCharacter(450, 25, "gf"));
		grpWeekCharacters.add(new MenuCharacter(850, 100, "bf"));
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.075, 56 + 400 + 30, 0, 'UNKNOWN', 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		var curWeekTextMember:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = curWeekTextMember - curWeekIndex;
			if (item.targetY == Std.int(0) && getCurrentWeek().isUnlocked())
				item.alpha = 1;
			else
				item.alpha = 0.6;
			curWeekTextMember++;
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width, grpWeekText.members[0].y + 20);
		leftArrow.frames = GraphicsAssets.loadSparrowAtlas('storymenu/arrowLeft');
		leftArrow.animation.addByPrefix('idle', 'idle');
		leftArrow.animation.addByPrefix('press', 'press');
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = AntiAliasingOption.get();
		difficultySelectors.add(leftArrow);

		difficultyItem = new StoryWeekDifficultyItem(0, 0);
		difficultyItem.antialiasing = AntiAliasingOption.get();
		difficultySelectors.add(difficultyItem);
		changeDifficulty();

		rightArrow = new FlxSprite(difficultyItem.x + difficultyItem.width, leftArrow.y);
		rightArrow.frames = GraphicsAssets.loadSparrowAtlas('storymenu/arrowRight');
		rightArrow.animation.addByPrefix('idle', 'idle');
		rightArrow.animation.addByPrefix('press', 'press', 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = AntiAliasingOption.get();
		difficultySelectors.add(rightArrow);

		// Trigger an update to stuff that wasn't initialized above.
		changeWeek(0);

		super.create();
	}

	/**
	 * We have selected a week to play! Load it, add the songs to the playlist,
	 * and start the PlayState.
	 * @param weekId The string identifier of the week to play.
	 * @param difficultyId The string identifier of the difficulty.
	 * @returns Whether we successfully started loading it.
	 */
	public static function playWeek(weekId:String, difficultyId:String):Bool
	{
		var chosenWeek = WeekDataHandler.fetch(weekId);

		if (chosenWeek == null)
		{
			// If week data couldn't be loaded, cancel loading the week.
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Debug.logError('CANCELLED loading week (${weekId}): week data has not been loaded');
			return false;
		}

		if (!Song.validateSongs(chosenWeek.playlist, difficultyId))
		{
			// If any song doesn't exist, stop loading the week.
			FlxG.sound.play(Paths.sound('cancelMenu'));
			Debug.logError('CANCELLED loading week (${weekId}): one or more songs are missing on this difficulty ($difficultyId)!');
			return false;
		}

		if (chosenWeek.isUnlocked())
		{
			PlayState.storyPlaylistPos = 0;
			PlayState.storyWeek = chosenWeek;
			PlayState.songMultiplier = 1;
			PlayState.songDifficulty = difficultyId;

			var diffSuffix = DifficultyDataHandler.fetch(PlayState.songDifficulty).songSuffix;
			PlayState.SONG = Song.conversionChecks(Song.loadFromJson(PlayState.storyWeek.playlist[PlayState.storyPlaylistPos], diffSuffix));

			// Reset the score.
			Scoring.currentScore = new SongScore(PlayState.songMultiplier);
			Scoring.weekScore = new SongScore(PlayState.songMultiplier);

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
			return true;
		}
		else
		{
			return false;
		}
	}

	override function update(elapsed:Float)
	{
		// Scroll the score until it matches the actual score value.
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));
		// Update the score text.
		scoreText.text = "WEEK SCORE:" + lerpScore;

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
			if (controls.ACCEPT && !selectedWeek)
			{
				trace('Attempting to load week (${getCurrentWeek().id}) (${difficultyItem.curDifficultyId})');
				var didStart = playWeek(getCurrentWeek().id, difficultyItem.curDifficultyId);
				if (didStart)
				{
					// Play a sound.
					FlxG.sound.play(Paths.sound('confirmMenu'));
					// Play the animation on the menu option.
					grpWeekText.members[curWeekIndex].startFlashing();
					// Play HEY! animation on ALL characters if available.
					grpWeekCharacters.members[0].playConfirm();
					grpWeekCharacters.members[1].playConfirm();
					grpWeekCharacters.members[2].playConfirm();
					selectedWeek = true;
				}
			}

			if (!selectedWeek)
			{
				#if FEATURE_GAMEPAD
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
				#end

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

	// Pressed left or right to change the difficulty.
	function changeDifficulty(change:Int = 0):Void
	{
		difficultyItem.changeDifficulty(change);

		// This is not a valid week/difficulty combo, skip it.
		if (!Song.validateSongs(getCurrentWeek().playlist, difficultyItem.curDifficultyId))
		{
			changeDifficulty(change);
		}

		difficultyItem.alpha = 0;

		// For some reason we have to fix the position here.

		// Prevent floating upwards.
		difficultyItem.y = leftArrow.y - 15;
		// Enforce centering.
		difficultyItem.x = leftArrow.x + 200 - (difficultyItem.width / 2);

		intendedScore = Highscore.getWeekScore(getCurrentWeek().id, difficultyItem.curDifficultyId);

		// Do a little bounce, that takes like a 20th of a second.
		FlxTween.tween(difficultyItem, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	// Pressed up or down to change thw eek.
	function changeWeek(change:Int = 0):Void
	{
		// Increment or decrement.
		curWeekIndex += change;

		// Loop around when you reach either end.
		if (curWeekIndex >= weekIds.length)
		{
			curWeekIndex = 0;
		}
		if (curWeekIndex < 0)
		{
			curWeekIndex = weekIds.length - 1;
		}

		// Some weird fading logic. Disable and see what happens?
		var curWeekTextMember:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = curWeekTextMember - curWeekIndex;
			if (item.targetY == Std.int(0) && getCurrentWeek().isUnlocked())
				item.alpha = 1;
			else
				item.alpha = 0.6;
			curWeekTextMember++;
		}

		// Update the week name text.
		txtWeekTitle.text = getCurrentWeek().title;
		// Align the text to the right side.
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// Only show the difficulty selector UI (left and right arrow) if the current week is unlocked.
		difficultySelectors.visible = getCurrentWeek().isUnlocked();

		// Scroll in the menu.
		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function getCurrentWeek():WeekData
	{
		return WeekDataHandler.fetch(weekIds[curWeekIndex]);
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
		characterBG = getCurrentWeek().createBackgroundSprite();
		characterBG.y = 56;
		add(characterBG);

		// Update characters.
		grpWeekCharacters.members[0].setCharacter(getCurrentWeek().menuCharacters[0]);
		grpWeekCharacters.members[1].setCharacter(getCurrentWeek().menuCharacters[1]);
		grpWeekCharacters.members[2].setCharacter(getCurrentWeek().menuCharacters[2]);

		// Update track list.
		txtTracklist.text = "TRACKS\n";
		var trackIds:Array<String> = getCurrentWeek().playlist;

		for (i in trackIds)
		{
			txtTracklist.text += "\n" + Song.getSongName(i);
		}

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		intendedScore = Highscore.getWeekScore(getCurrentWeek().id, difficultyItem.curDifficultyId);
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
			// grpWeekCharacters.members[0].playIdle();
			// grpWeekCharacters.members[1].playIdle();
			// grpWeekCharacters.members[2].playIdle();
		}
	}
}
