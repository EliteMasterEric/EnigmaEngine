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
