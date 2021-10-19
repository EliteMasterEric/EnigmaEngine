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
 * IHook.hx
 * An interface which can be added to a class, which indicates that one or more functions on it are script hooks.
 * A compile time macro will apply logic as needed to ensure scripts are loaded and run.
 */
package funkin.behavior.mods;

import polymod.hscript.HScriptable;

// @:autoBuild(funkin.util.macro.HaxeSingleton.build()) // This macro adds an `interface` field to each class that implements it.
@:autoBuild(funkin.util.macro.HaxeHScriptFixer.build()) // This macro adds a `Debug.logError` call that occurs if a script error occurs.
@:hscript(Std, Math, FlxG) // ALL of these values are added to ALL scripts in the child classes.
interface IHook extends HScriptable
{
}
