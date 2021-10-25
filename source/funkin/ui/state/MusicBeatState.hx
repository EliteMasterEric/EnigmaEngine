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
 * MusicBeatState.hx
 * An extension of FlxState which includes handling to perform actions
 * based on the BPM of the current song.
 */
package funkin.ui.state;

import funkin.ui.component.input.InteractableUIState;
import funkin.behavior.play.TimingStruct;
import funkin.behavior.options.PlayerSettings;
import funkin.behavior.play.Conductor;
import funkin.behavior.options.Controls;
import funkin.behavior.options.CustomControls;
import flixel.addons.ui.FlxUIState;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxColor;
#if FEATURE_DISCORD
import funkin.behavior.api.Discord.DiscordClient;
#end
import funkin.behavior.play.Conductor.BPMChangeEvent;
import openfl.Lib;

class MusicBeatState extends FlxUIState // InteractableUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curDecimalBeat:Float = 0;
	private var controls(get, never):CustomControls;

  private var gameInput:GameInput;

	inline function get_controls():CustomControls
	{
		return PlayerSettings.player1 == null ? null : PlayerSettings.player1.controls;
	}

	private var assets:Array<FlxBasic> = [];

	override function add(Object:flixel.FlxBasic):flixel.FlxBasic
	{
		if (FlxG.save.data.optimize)
			assets.push(Object);
		return super.add(Object);
	}

	public function clean()
	{
		if (FlxG.save.data.optimize)
		{
			for (i in assets)
			{
				remove(i);
			}
		}
	}

	override function create()
	{
		TimingStruct.clearTimings();
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

    gameInput = new GameInput();

    gameInput.addEventListener(GameInputDevice.DEVICE_ADDED, function(event:GameInputEvent) {
      Debug.logTrace('New device connected: ${event.device.name} (${event.device.numControls} controls)');
      onGamepadAdded(event);
    });

    gameInput.addEventListener(GameInputDevice.DEVICE_ADDED, function(event:GameInputEvent) {
      Debug.logTrace('New device connected: ${event.device.name} (${event.device.numControls} controls)');
      onGamepadRemoved(event);
    });

		super.create();
	}

  /**
   * Override me!
   */
  function onGamepadAdded(event:GameInputEvent) {
    return;
  }

  /**
   * Override me!
   * @param event 
   */
  function onGamepadRemoved(event:GameInputEvent) {
    return;
  }

	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0, 0)
	];

	var skippedFrames = 0;

	override function update(elapsed:Float)
	{
		// You can now press F11 on most screens to move to fullscreen, not just the title.
		if (controls != null && controls.FULLSCREEN)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if (Conductor.songPosition < 0)
		{
			curDecimalBeat = 0;
		}
		else
		{
			if (TimingStruct.AllTimings.length > 1)
			{
				var data = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

				FlxG.watch.addQuick("Current Conductor Timing Seg", data.bpm);

				Conductor.crochet = ((60 / data.bpm) * 1000);

				var step = ((60 / data.bpm) * 1000) / 4;
				var startInMS = (data.startTime * 1000);

				curDecimalBeat = data.startBeat + ((((Conductor.songPosition / 1000)) - data.startTime) * (data.bpm / 60));
				var ste:Int = Math.floor(data.startStep + ((Conductor.songPosition) - startInMS) / step);
				if (ste >= 0)
				{
					if (ste > curStep)
					{
						for (i in curStep...ste)
						{
							curStep++;
							updateBeat();
							stepHit();
						}
					}
					else if (ste < curStep)
					{
						trace("reset steps for some reason?? at " + Conductor.songPosition);
						// Song reset?
						curStep = ste;
						updateBeat();
						stepHit();
					}
				}
			}
			else
			{
				curDecimalBeat = (((Conductor.songPosition / 1000))) * (Conductor.bpm / 60);
				var nextStep:Int = Math.floor((Conductor.songPosition) / Conductor.stepCrochet);
				if (nextStep >= 0)
				{
					if (nextStep > curStep)
					{
						for (i in curStep...nextStep)
						{
							curStep++;
							updateBeat();
							stepHit();
						}
					}
					else if (nextStep < curStep)
					{
						// Song reset?
						trace("(no bpm change) reset steps for some reason?? at " + Conductor.songPosition);
						curStep = nextStep;
						updateBeat();
						stepHit();
					}
				}
				Conductor.crochet = ((60 / Conductor.bpm) * 1000);
			}
		}

		if (FlxG.save.data.fpsRain && skippedFrames >= 6)
		{
			if (currentColor >= array.length)
				currentColor = 0;
			(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
			currentColor++;
			skippedFrames = 0;
		}
		else
			skippedFrames++;

		if ((cast(Lib.current.getChildAt(0), Main)).getFPSCap != FlxG.save.data.fpsCap && FlxG.save.data.fpsCap <= 340)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curBeat;
		curBeat = Math.floor(curStep / 4);
	}

	public static var currentColor = 0;

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	/**
	 * Function called during the song four times every beat, sixteen times a section.
	 */
	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	/**
	 * Function called during the song once every beat, four times a section.
	 */
	public function beatHit():Void
	{
	}
}
