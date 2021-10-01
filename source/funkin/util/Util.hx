package funkin.util;

import Type;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Util
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard"];

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	/**
	 * Given a text file path, load the file, clean it up, and split it into individual lines.
	 * @param path The text file path to load.
	 * @return A list of lines from that file.
	 */
	public static function loadLinesFromFile(path:String):Array<String>
	{
		var rawText:String = OpenFlAssets.getText(path);
		var result:Array<String> = rawText.trim().split('\n');

		for (i in 0...result.length)
		{
			result[i] = result[i].trim();
		}

		return result;
	}

	public static function buildArrayFromRange(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	/*
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
	 */
}
