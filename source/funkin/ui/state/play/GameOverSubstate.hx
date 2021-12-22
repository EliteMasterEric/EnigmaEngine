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
 * GameOverSubstate.hx
 * The substate which overlays the screen when the user loses during a song.
 * The "blue balls" screen.
 */
package funkin.ui.state.play;

import funkin.ui.component.play.character.BaseCharacter;
import funkin.ui.component.play.character.CharacterFactory;
import funkin.behavior.options.Options.InstantRespawnOption;
import funkin.util.assets.AudioAssets;
import funkin.util.assets.Paths;
import funkin.ui.state.menu.FreeplayState;
import funkin.ui.state.menu.StoryMenuState;
import funkin.behavior.play.Conductor;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var playerChar:BaseCharacter;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float)
	{
		super();

		Conductor.songPosition = 0;

		playerChar = CharacterFactory.buildCharacter(PlayState.playerChar.characterId);
		playerChar.x = x;
		playerChar.y = y;
		add(playerChar);

		camFollow = new FlxObject(playerChar.getGraphicMidpoint().x, playerChar.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		playerChar.playAnimation('firstDeath');
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

		// TODO: Unhardcode this logic.
		if (playerChar.getAnimation() == 'firstDeath' && playerChar.getAnimationFrame() == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (playerChar.getAnimation() == 'firstDeath' && playerChar.isAnimationFinished())
		{
			AudioAssets.playMusic(Paths.music('gameOver$stageSuffix'), true, true, 1);
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
			// Force?
			playerChar.playAnimation('deathLoop');
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
			// Force?
			playerChar.playAnimation('deathConfirm');
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
