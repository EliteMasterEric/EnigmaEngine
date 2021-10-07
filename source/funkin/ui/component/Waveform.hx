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
 * Waveform.hx
 * A Flixel sprite which renders an audio buffer as a waveform.
 * @see https://github.com/gedehari/HaxeFlixel-Waveform-Rendering/blob/master/source/PlayState.hx
 */
package funkin.ui.component;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import openfl.geom.Rectangle;

class Waveform extends FlxSprite
{
	public var buffer:AudioBuffer;
	public var data:Bytes;

	public var length:Int;

	public function new(x:Int, y:Int, audioPath:String, height:Int)
	{
		super(x, y);

		var path = StringTools.replace(audioPath, "songs:", "");

		trace("loading " + path);

		buffer = AudioBuffer.fromFile(path);

		trace("BPS: " + buffer.bitsPerSample + " - Channels: " + buffer.channels);

		data = buffer.data.toBytes();

		var h = 0;

		var trackDurationSeconds = (data.length / (buffer.bitsPerSample / 8) / buffer.channels) / buffer.sampleRate;

		var pixelsPerCollumn:Int = Math.floor(1280 / (trackDurationSeconds / 1000));

		var totalSamples = (data.length / (buffer.bitsPerSample / 8) / buffer.channels);

		h = Math.round(totalSamples / pixelsPerCollumn);

		trace(h + " - calculated height");

		length = h;

		makeGraphic(h, 720, FlxColor.TRANSPARENT);
	}

	public function drawWaveform()
	{
		var index:Int = 0;
		var drawIndex:Int = 0;

		var totalSamples = (data.length / (buffer.bitsPerSample / 8) / buffer.channels);

		var min:Float = 0;
		var max:Float = 0;

		for (index in 0...Math.round(totalSamples))
		{
			var byte:Int = data.getUInt16(index);

			if (byte > 65535 / 2)
				byte -= 65535;

			var sample:Float = (byte / 65535);

			if (sample > 0)
			{
				if (sample > max)
					max = sample;
			}
			else if (sample < 0)
			{
				if (sample < min)
					min = sample;
			}

			trace("sample " + index);

			var pixelsMin:Float = Math.abs(min * 300);
			var pixelsMax:Float = max * 300;

			pixels.fillRect(new Rectangle(drawIndex, 0, 1, 720), 0xFF000000);
			pixels.fillRect(new Rectangle(drawIndex, (FlxG.height / 2) - pixelsMin, 1, pixelsMin + pixelsMax), FlxColor.GRAY);
			pixels.fillRect(new Rectangle(drawIndex, (FlxG.height / 2) - pixelsMin, 1, -(pixelsMin + pixelsMax)), FlxColor.GRAY);
			drawIndex += 1;

			min = 0;
			max = 0;
		}
	}
}
