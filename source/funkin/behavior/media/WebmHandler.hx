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
 * WebmHandler.hx
 * A utility class which loads and plays WebM files.
 * Doesn't work with sound... yet.
 */
package funkin.behavior.media;

import flixel.FlxG;
import openfl.display.Sprite;
#if FEATURE_WEBM
import webm.*;
#end

class WebmHandler
{
	#if FEATURE_WEBM
	public var webm:WebmPlayer;
	public var vidPath:String = "";
	public var io:WebmIo;
	public var initialized:Bool = false;

	public function new()
	{
	}

	public function source(?vPath:String):Void
	{
		if (vPath != null && vPath.length > 0)
		{
			vidPath = vPath;
		}
	}

	public function makePlayer():Void
	{
		io = new WebmIoFile(vidPath);
		webm = new WebmPlayer();
		webm.fuck(io, false);
		webm.addEventListener(WebmEvent.PLAY, function(e)
		{
			onPlay();
		});
		webm.addEventListener(WebmEvent.COMPLETE, function(e)
		{
			onEnd();
		});
		webm.addEventListener(WebmEvent.STOP, function(e)
		{
			onStop();
		});
		webm.addEventListener(WebmEvent.RESTART, function(e)
		{
			onRestart();
		});
		webm.visible = false;
		initialized = true;
	}

	public function updatePlayer():Void
	{
		io = new WebmIoFile(vidPath);
		webm.fuck(io, false);
	}

	public function play():Void
	{
		if (initialized)
		{
			webm.play();
		}
	}

	public function stop():Void
	{
		if (initialized)
		{
			webm.stop();
		}
	}

	public function restart():Void
	{
		if (initialized)
		{
			webm.restart();
		}
	}

	public function update(elapsed:Float)
	{
		webm.x = GlobalVideo.calc(0);
		webm.y = GlobalVideo.calc(1);
		webm.width = GlobalVideo.calc(2);
		webm.height = GlobalVideo.calc(3);
	}

	public var stopped:Bool = false;
	public var restarted:Bool = false;
	public var played:Bool = false;
	public var ended:Bool = false;
	public var paused:Bool = false;

	public function pause():Void
	{
		webm.changePlaying(false);
		paused = true;
	}

	public function resume():Void
	{
		webm.changePlaying(true);
		paused = false;
	}

	public function togglePause():Void
	{
		if (paused)
		{
			resume();
		}
		else
		{
			pause();
		}
	}

	public function clearPause():Void
	{
		paused = false;
		webm.removePause();
	}

	public function onStop():Void
	{
		stopped = true;
	}

	public function onRestart():Void
	{
		restarted = true;
	}

	public function onPlay():Void
	{
		played = true;
	}

	public function onEnd():Void
	{
		trace("IT ENDED!");
		ended = true;
	}

	public function alpha():Void
	{
		webm.alpha = GlobalVideo.daAlpha1;
	}

	public function unalpha():Void
	{
		webm.alpha = GlobalVideo.daAlpha2;
	}

	public function hide():Void
	{
		webm.visible = false;
	}

	public function show():Void
	{
		webm.visible = true;
	}
	#else
	public var webm:Sprite;

	public function new()
	{
		Debug.logTrace("WebMHandler initialized on an unsupported platform, nothing will happen.");
	}
	#end
}
