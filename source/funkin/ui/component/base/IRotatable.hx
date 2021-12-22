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
 * IRotatable.hx
 * Adding this interface to an FlxObject (yes, merely adding the interface),
 * adds several properties which enable the 2D object to be rotated as though it were in 3D space.
 * 
 * Rotation is emulated by squishing the object.
 */
package funkin.ui.component.base;

@:autoBuild(funkin.util.macro.HaxeRotatable.build()) // This macro adds a working `parent` field to each FlxObject that implements it.
interface IRotatable
{
	/*
		// These fields are imaginary, but VSCode will still see them.
		// You need to use this instead of sprite.x
		public var positionX(default, set):Float = 0;
		// You need to use this instead of sprite.y
		public var positionY(default, set):Float = 0;
		// You need to use this instead of sprite.scale.x
		public var scaleX(default, set):Float = 1;
		// You need to use this instead of sprite.scale.y
		public var scaleY(default, set):Float = 1;
		public var rotationX(default, set):Float = 0;
		public var rotationY(default, set):Float = 0;
		// You need to use this instead of sprite.angle
		public var rotationZ(default, set):Float = 0;
	 */
}
