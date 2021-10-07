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
 * ArrowButton.hx
 * A work-in progress component, which renders a button with an arrow on it.
 */
package funkin.ui.component.input;

import flixel.addons.ui.FlxUIButton;

class ArrowButton extends FlxUIButton
{
	public function new(x:Float, y:Float, w:Float, h:Float, onClick:Void->Void, asset:Dynamic)
	{
		super(x, y, null, onClick);
	}

	public override function resize(W:Float, H:Float):Void
	{
		// TODO Implement this so that resizing doesn't mess up the arrow graphic,
		// or just use a custom arrow graphic.
		throw "Not implemented!";
	}
}
