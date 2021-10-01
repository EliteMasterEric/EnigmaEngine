package funkin.behavior.mods;

import polymod.hscript.HScriptable;

@:autoBuild(funkin.util.macro.HaxeSingleton.build()) // This macro adds an `interface` field to each class that implements it.
@:autoBuild(funkin.util.macro.HaxeHScriptFixer.build()) // This macro adds a `Debug.logError` call that occurs if a script error occurs.
@:hscript(Std, Math, FlxG) // ALL of these values are added to ALL scripts in the child classes.
interface IHook extends HScriptable
{
}
