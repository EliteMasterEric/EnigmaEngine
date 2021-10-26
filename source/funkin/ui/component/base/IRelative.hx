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
 * IRelative.hx
 * Adding this interface to an FlxObject (yes, merely adding the interface),
 * adds several methods which enable the object to be positioned relative to a parent object.
 */
package funkin.ui.component.base;

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
