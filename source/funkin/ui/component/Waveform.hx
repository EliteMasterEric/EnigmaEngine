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
