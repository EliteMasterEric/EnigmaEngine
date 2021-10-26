/**
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
 * RelativeText.hx
 * A FlxUIText element with an additional handler for relative positioning.
 */
package funkin.ui.component.base;

import flixel.FlxObject;
import flixel.addons.ui.FlxUIText;

class RelativeText extends FlxUIText implements IRelative
{
	public function new(X:Float = 0, Y:Float = 0, Parent:FlxObject = null, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(0, 0, FieldWidth, Text, Size, EmbeddedFont);

		this.parent = Parent;
		this.relativeX = X;
		this.relativeY = Y;
	}
}
