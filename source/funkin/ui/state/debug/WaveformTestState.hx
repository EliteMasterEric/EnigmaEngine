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
