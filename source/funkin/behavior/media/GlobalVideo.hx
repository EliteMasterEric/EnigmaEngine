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
 * GlobalVideo.hx
 * A utility class which is part of handling WEBM videos.
 */
package funkin.behavior.media;

import funkin.const.GameDimensions;
import openfl.Lib;

class GlobalVideo
{
	private static var video:VideoHandler;
	private static var webm:WebmHandler;
	public static var isWebm:Bool = false;
	public static var isAndroid:Bool = false;
	public static var daAlpha1:Float = 0.2;
	public static var daAlpha2:Float = 1;

	public static function setVid(vid:VideoHandler):Void
	{
		video = vid;
	}

	public static function getVid():VideoHandler
	{
		return video;
	}

	public static function setWebm(vid:WebmHandler):Void
	{
		webm = vid;
		isWebm = true;
	}

	public static function getWebm():WebmHandler
	{
		return webm;
	}

	public static function get():Dynamic
	{
		if (isWebm)
		{
			return getWebm();
		}
		else
		{
			return getVid();
		}
	}

	public static function calc(ind:Int):Dynamic
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		var width:Float = GameDimensions.width;
		var height:Float = GameDimensions.height;

		var ratioX:Float = height / width;
		var ratioY:Float = width / height;
		var appliedWidth:Float = stageHeight * ratioY;
		var appliedHeight:Float = stageWidth * ratioX;
		var remainingX:Float = stageWidth - appliedWidth;
		var remainingY:Float = stageHeight - appliedHeight;
		remainingX = remainingX / 2;
		remainingY = remainingY / 2;

		appliedWidth = Std.int(appliedWidth);
		appliedHeight = Std.int(appliedHeight);

		if (appliedHeight > stageHeight)
		{
			remainingY = 0;
			appliedHeight = stageHeight;
		}

		if (appliedWidth > stageWidth)
		{
			remainingX = 0;
			appliedWidth = stageWidth;
		}

		switch (ind)
		{
			case 0:
				return remainingX;
			case 1:
				return remainingY;
			case 2:
				return appliedWidth;
			case 3:
				return appliedHeight;
		}

		return null;
	}
}
