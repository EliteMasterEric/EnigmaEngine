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
 * RelativeSprite.hx
 * An FlxSprite which has additional handlers for relative positioning.
 */
package funkin.ui.component.base;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * This extension of FlxSprite adds the ability to set relativeX and relativeY,
 * to position itself in relation to a parent.
 */
class RelativeSprite extends FlxSprite implements IRelative
{
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, ?Parent:FlxObject)
	{
		super(0, 0, SimpleGraphic);

		this.relativeX = X;
		this.relativeY = Y;

		if (Parent != null)
			this.parent = Parent;

		updatePosition();
	}

	public override function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):RelativeSprite
	{
		super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
		// Override to change the return type of the function.
		return this;
	}
}
