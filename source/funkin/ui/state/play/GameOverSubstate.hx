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
 * GameOverSubstate.hx
 * The substate which overlays the screen when the user loses during a song.
 * The "blue balls" screen.
 */
package funkin.ui.state.play;

import funkin.behavior.options.Options.InstantRespawnOption;
import funkin.util.assets.AudioAssets;
import funkin.util.assets.Paths;
import funkin.ui.state.menu.FreeplayState;
import funkin.ui.state.menu.StoryMenuState;
import funkin.behavior.play.Conductor;
import funkin.ui.component.play.Boyfriend;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var playerChar:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.STAGE.curStage;
		var daBf:String = '';
		switch (PlayState.playerChar.curCharacter)
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;

		playerChar = new Boyfriend(x, y, daBf);
		add(playerChar);

		camFollow = new FlxObject(playerChar.getGraphicMidpoint().x, playerChar.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		playerChar.playAnim('firstDeath');
	}

	var startVibin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			acceptAndContinue();
		}

		if (InstantRespawnOption.get())
		{
			// Create a new PlayState while preserving the values of static variables.
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (controls.BACK)
		{
			AudioAssets.stopMusic();

			if (PlayState.isStoryMode())
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
			PlayState.replayActive = false;
			PlayState.stageTesting = false;
		}

		if (playerChar.getCurAnimation() == 'firstDeath' && playerChar.getCurAnimFrame() == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (playerChar.getCurAnimation() == 'firstDeath' && playerChar.isCurAnimationFinished())
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			startVibin = true;
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (startVibin && !isEnding)
		{
			playerChar.playAnim('deathLoop', true);
		}
		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	/**
	 * Called when the user presses ACCEPT to play the song again.
	 */
	function acceptAndContinue():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			isEnding = true;
			playerChar.playAnim('deathConfirm', true);
			AudioAssets.stopMusic();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					// Recreate the PlayState from scratch. As long as you don't change the static vars
					// in PlayState, you'll return to the same song.
					LoadingState.loadAndSwitchState(new PlayState());
					PlayState.stageTesting = false;
				});
			});
		}
	}
}
