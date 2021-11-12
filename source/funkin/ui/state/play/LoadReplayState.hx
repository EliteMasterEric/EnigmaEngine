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
 * LoadReplayState.hx
 * A state which initializes and prepares a Replay to be viewed.
 * Replays themselves are performed in PlayState.
 */
package funkin.ui.state.play;

import funkin.behavior.options.Options.AntiAliasingOption;
import funkin.behavior.play.Song;
import funkin.ui.state.options.OptionsMenu;
import funkin.behavior.play.Replay;
import funkin.behavior.play.Difficulty.DifficultyCache;
import funkin.util.Util;
import funkin.util.assets.Paths;
import flash.text.TextField;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.util.assets.GraphicsAssets;
import funkin.behavior.options.Controls.Control;
import funkin.behavior.options.Controls.KeyboardScheme;
import funkin.ui.component.Alphabet;
import funkin.ui.state.menu.FreeplayState;
import funkin.ui.state.menu.FreeplayState.FreeplaySongMetadata;
import haxe.Exception;
import lime.app.Application;
#if FEATURE_FILESYSTEM
import sys.FileSystem;
import sys.io.File;
#end

class LoadReplayState extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var songs:Array<FreeplaySongMetadata> = [];

	var controlsStrings:Array<String> = [];
	var actualNames:Array<String> = [];

	private var grpControls:FlxTypedGroup<Alphabet>;
	var versionText:FlxText;
	var poggerDetails:FlxText;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(GraphicsAssets.loadImage('menuBackground'));
		// TODO: Refactor this to use OpenFlAssets.
		#if FEATURE_FILESYSTEM
		controlsStrings = [];
		#end
		trace(controlsStrings);

		controlsStrings.sort(sortByDate);

		// TODO: What is this? De-hardcode it?
		addWeek(['Bopeebo', 'Fresh', 'Dadbattle'], 1, ['dad']);
		addWeek(['Spookeez', 'South', 'Monster'], 2, ['spooky']);
		addWeek(['Pico', 'Philly', 'Blammed'], 3, ['pico']);

		addWeek(['Satin-Panties', 'High', 'Milf'], 4, ['mom']);
		addWeek(['Cocoa', 'Eggnog', 'Winter-Horrorland'], 5, ['parents-christmas', 'parents-christmas', 'monster-christmas']);

		addWeek(['Senpai', 'Roses', 'Thorns'], 6, ['senpai', 'senpai', 'spirit']);

		for (i in 0...controlsStrings.length)
		{
			var string:String = controlsStrings[i];
			actualNames[i] = string;
			var rep:Replay = Replay.loadReplay(string);
			controlsStrings[i] = string.split("time")[0] + " " + rep.replay.songDifficulty.toUpperCase();
		}

		if (controlsStrings.length == 0)
			controlsStrings.push("No Replays...");

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = AntiAliasingOption.get();
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		versionText = new FlxText(5, FlxG.height - 34, 0,
			"Replay Loader (ESCAPE TO GO BACK)\nNOTICE!!!! Replays are in a beta stage, and they are probably not 100% correct. expect misses and other stuff that isn't there!\n",
			12);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionText);

		poggerDetails = new FlxText(5, 34, 0, "Replay Details - \nnone", 12);
		poggerDetails.scrollFactor.set();
		poggerDetails.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(poggerDetails);

		changeSelection(0);

		super.create();
	}

	function sortByDate(a:String, b:String)
	{
		var aTime = Std.parseFloat(a.split("time")[1]) / 1000;
		var bTime = Std.parseFloat(b.split("time")[1]) / 1000;

		return Std.int(bTime - aTime); // Newest first
	}

	public function getWeekNumbFromSong(songName:String):Int
	{
		var week:Int = 0;
		for (i in 0...songs.length)
		{
			var pog:FreeplaySongMetadata = songs[i];
			if (pog.songName == songName)
				week = pog.week;
		}
		return week;
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new FreeplaySongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
			FlxG.switchState(new OptionsMenu());
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if (controls.ACCEPT && grpControls.members[curSelected].text != "No Replays...")
		{
			trace('loading ' + actualNames[curSelected]);
			PlayState.currentReplay = Replay.loadReplay(actualNames[curSelected]);

			PlayState.replayActive = true;

			if (PlayState.currentReplay.replay.replayGameVer == Replay.VERSION)
			{
				// adjusting the song name to be compatible
				var songFormat = StringTools.replace(PlayState.currentReplay.replay.songName, " ", "-");
				switch (songFormat)
				{
					// Support non-Enigma replays.

					case 'Dad-Battle':
						songFormat = 'dadbattle';
					case 'Philly-Nice':
						songFormat = 'philly';
					case 'M.I.L.F':
						songFormat = 'milf';
					// Replay v1.0 support
					case 'dad-battle':
						songFormat = 'dadbattle';
					case 'philly-nice':
						songFormat = 'philly';
					case 'm.i.l.f':
						songFormat = 'milf';
				}

				var songPath = "";

				try
				{
					var diffSuffix = DifficultyCache.getSuffix(PlayState.currentReplay.replay.songDifficulty);
					PlayState.SONG = Song.loadFromJson(PlayState.currentReplay.replay.songName, diffSuffix);
				}
				catch (e:Exception)
				{
					Application.current.window.alert("Failed to load the song! Does the JSON exist?", "Replays");
					return;
				}
				PlayState.storyWeek = null;
				PlayState.songDifficulty = PlayState.currentReplay.replay.songDifficulty;
				LoadingState.loadAndSwitchState(new PlayState());
			}
			else
			{
				PlayState.currentReplay = null;
				PlayState.replayActive = false;
			}
		}
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var rep:Replay = Replay.loadReplay(actualNames[curSelected]);

		poggerDetails.text = "Replay Details - \nDate Created: "
			+ rep.replay.timestamp
			+ "\nSong: "
			+ rep.replay.songName
			+ "\nReplay Version: "
			+ rep.replay.replayGameVer
			+ ' ('
			+ (rep.replay.replayGameVer != Replay.VERSION ? "OUTDATED not useable!" : "Latest")
			+ ')\n';

		var curControlsMember:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = curControlsMember - curSelected;
			curControlsMember++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
