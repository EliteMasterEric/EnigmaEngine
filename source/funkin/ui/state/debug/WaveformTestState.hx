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
 * WaveformTestState.hx
 * A test state used to preview the waveform of a StepMania file?
 */
package funkin.ui.state.debug;

import funkin.ui.state.play.PlayState;
import funkin.util.assets.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxStrip;
import flixel.util.FlxColor;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import lime.media.vorbis.VorbisFile;
import funkin.ui.component.Waveform;
import openfl.geom.Rectangle;
import openfl.media.Sound;

class WaveformTestState extends FlxState
{
	var waveform:Waveform;

	public override function create()
	{
		super.create();

		// fuckin stupid ass bitch ass fucking waveform

		waveform = new Waveform(0, 0, Paths.voices(PlayState.SONG.songFile), 720);
		// waveform = new Waveform(0, 0, Paths.inst(PlayState.SONG.songFile), 720);
		waveform.drawWaveform();
		add(waveform);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.pressed.W)
			FlxG.camera.y += 1;
		if (FlxG.keys.pressed.S)
			FlxG.camera.y -= 1;
		if (FlxG.keys.pressed.A)
			FlxG.camera.x += 1;
		if (FlxG.keys.pressed.D)
			FlxG.camera.x -= 1;
	}
}
