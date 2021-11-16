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
 * Util.hx
 * Contains generic static utility functions.
 */
package funkin.util;

import Type;
import openfl.utils.Assets as OpenFlAssets;
import flixel.math.FlxMath;

using hx.strings.Strings;

class Util
{
	public static function buildArrayFromRange(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	public static function GCD(a, b)
	{
		return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);
	}

	/**
	 * @param duration The duration in seconds
	 * @return The duration in the format "MM:SS"
	 */
	public static function durationToString(duration:Float):String
	{
		var seconds = FlxMath.roundDecimal(duration, 0) % 60;
		var secondsStr = Strings.lpad('$seconds', 2, '0');
		var minutes = FlxMath.roundDecimal(duration - seconds, 0) / 60;
		var minutesStr = FlxMath.roundDecimal(minutes, 0);
		return '$minutesStr:$secondsStr';
	}

	public static function getTypeName(input:Dynamic):String
	{
		return switch (Type.typeof(input))
		{
			case TEnum(e):
				Type.getEnumName(e);
			case TClass(c):
				Type.getClassName(c);
			case TInt:
				"int";
			case TFloat:
				"float";
			case TBool:
				"bool";
			case TObject:
				"object";
			case TFunction:
				"function";
			case TNull:
				"null";
			case TUnknown:
				"unknown";
			default:
				"";
		}
	}

	/**
	 * Utility to parse an ARGB value from the current hex value
	 * Hex string is cached on the class so that it does not need to be recalculated for every pixel.
	 */
	public static function parseARGB(alpha:Int, hexStr:String):UInt
	{
		return Std.parseInt("0x" + Strings.toHex(alpha) + hexStr);
	}

	/**
	 * Convert a hexadecimal number to a hexadecimal string.
	 */
	public static function toHexString(hex:UInt):String
	{
		var r:Int = (hex >> 16);
		var g:Int = (hex >> 8 ^ r << 8);
		var b:Int = (hex ^ (r << 16 | g << 8));

		var red:String = Strings.toHex(r);
		var green:String = Strings.toHex(g);
		var blue:String = Strings.toHex(b);

		red = (red.length < 2) ? "0" + red : red;
		green = (green.length < 2) ? "0" + green : green;
		blue = (blue.length < 2) ? "0" + blue : blue;
		return (red + green + blue).toUpperCase();
	}
}
