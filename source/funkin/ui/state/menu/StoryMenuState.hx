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
 * StoryMenuState.hx
 * The state containing the menu which lists the story weeks and allows you to
 * start a playlist of songs at a given difficulty.
 */
package funkin.ui.state.menu;

import funkin.util.assets.GraphicsAssets;
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
import funkin.behavior.play.Difficulty.DifficultyCache;
import flixel.util.FlxTimer;
import funkin.behavior.play.Week;
import funkin.util.assets.Paths;
import funkin.behavior.play.Song;
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
import funkin.util.assets.DataAssets;
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
	 * `data/weekOrder.txt` but with hidden weeks filtered out.
	 */
	var weekIds:Array<String> = [];

	override function create()
	{
		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		// Load the filtered week list.
		weekIds = DataAssets.loadLinesFromFile(Paths.txt('data/weekOrder')).filter(function(weekId)
		{
			// Filter by whether the week is currently hidden.
			return !WeekCache.isWeekHidden(weekId);
		});

		if (weekIds.length == 0)
		{
			Debug.logError('WARNING: There are no story weeks available!');
			Debug.logError('Check your configuration!');
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

		Debug.logInfo('Displaying entries for ${weekIds.length} week IDs.');

		for (i in 0...weekIds.length)
		{
			Debug.logTrace('Rendering entry for week ${weekIds[i]}');

			var weekDataEntry:Week = WeekCache.get(weekIds[i]);

			var weekMenuItem:StoryWeekMenuItem = new StoryWeekMenuItem(0, 56 + 400 + 10, weekDataEntry);
			weekMenuItem.y += ((weekMenuItem.height + 20) * i);
			weekMenuItem.targetY = i;
			grpWeekText.add(weekMenuItem);

			weekMenuItem.screenCenter(X);
			weekMenuItem.antialiasing = FlxG.save.data.antialiasing;

			// Needs an offset thingie
			if (!weekDataEntry.isWeekUnlocked())
			{
				trace('Locking week ${weekIds[i]}');
				var lock:FlxSprite = new FlxSprite(weekMenuItem.width + 10 + weekMenuItem.x);
				lock.loadGraphic(Paths.image('storymenu/lock'));
				lock.ID = i;
				lock.antialiasing = FlxG.save.data.antialiasing;
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
			if (item.targetY == Std.int(0) && getCurrentWeek().isWeekUnlocked())
				item.alpha = 1;
			else
				item.alpha = 0.6;
			curWeekTextMember++;
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 20);
		leftArrow.frames = GraphicsAssets.loadSparrowAtlas('storymenu/arrowLeft');
		leftArrow.animation.addByPrefix('idle', 'idle');
		leftArrow.animation.addByPrefix('press', 'press');
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(leftArrow);

		difficultyItem = new StoryWeekDifficultyItem(0, 0);
		difficultyItem.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(difficultyItem);
		changeDifficulty();

		rightArrow = new FlxSprite(difficultyItem.x + difficultyItem.width + 10, leftArrow.y);
		rightArrow.frames = GraphicsAssets.loadSparrowAtlas('storymenu/arrowRight');
		rightArrow.animation.addByPrefix('idle', 'idle');
		rightArrow.animation.addByPrefix('press', 'press', 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = FlxG.save.data.antialiasing;
		difficultySelectors.add(rightArrow);

		// Trigger an update to stuff that wasn't initialized above.
		changeWeek(0);

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
			FlxG.save.data.weeksUnlocked.set(weekId, true);
		}
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
		var chosenWeek = WeekCache.get(weekId);

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
			Debug.logError('CANCELLED loading week (${weekId}): one or more songs are missing on this difficulty!');
			return false;
		}

		if (chosenWeek.isWeekUnlocked())
		{
			PlayState.storyPlaylist = chosenWeek.playlist;
			PlayState.isStoryMode = true;
			PlayState.songMultiplier = 1;

			PlayState.storyDifficulty = difficultyId;

			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			var diffSuffix = DifficultyCache.getSuffix(PlayState.storyDifficulty);
			PlayState.SONG = Song.conversionChecks(Song.loadFromJson(PlayState.storyPlaylist[0], diffSuffix));
			PlayState.storyWeek = chosenWeek;
			PlayState.campaignScore = 0;
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
				else
				{
					// Play a sound.
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
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

	// Pressed left or right to change the difficulty.
	function changeDifficulty(change:Int = 0):Void
	{
		difficultyItem.changeDifficulty(change);

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
			if (item.targetY == Std.int(0) && getCurrentWeek().isWeekUnlocked())
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
		difficultySelectors.visible = getCurrentWeek().isWeekUnlocked();

		// Scroll in the menu.
		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function getCurrentWeek():Week
	{
		return WeekCache.get(weekIds[curWeekIndex]);
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
