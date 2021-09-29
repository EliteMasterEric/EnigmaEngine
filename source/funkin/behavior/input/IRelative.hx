package funkin.behavior.input;

/**
 * Adding this interface to an FlxObject (yes, merely adding the interface),
 * adds several methods which enable the object to be positioned relative to a parent object.
 */
@:autoBuild(funkin.util.macro.HaxeRelative.build()) // This macro adds a working `parent` field to each FlxObject that implements it.
interface IRelative
{
	/*
		// These fields are imaginary, but VSCode will still see them.
		public var parent(default, set):FlxObject = null;
		public var relativeX(default, set):Float = 0;
		public var relativeY(default, set):Float = 0;
		public var relativeAngle(default, set):Float = 0;
	 */
}
