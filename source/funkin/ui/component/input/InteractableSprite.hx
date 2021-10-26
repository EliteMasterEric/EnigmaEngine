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
 * InteractableSprite.hx
 * An FlxSprite which has additional handlers for gestures and interaction.
 */
package funkin.ui.component.input;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.touch.FlxTouchManager;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import funkin.ui.component.base.RelativeSprite;
import funkin.util.input.GestureUtil;
import funkin.util.input.GestureUtil.SwipeDirection;

/**
 * This extension of FlxSprite calls corresponding events when clicked or tapped.
 * Override it for custom behavior.
 */
class InteractableSprite extends RelativeSprite implements IInteractable
{
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, ?Parent:FlxObject)
	{
		super(X, Y, SimpleGraphic, Parent);

		GestureUtil.addGestureCallbacks(this);
	}

	public override function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):InteractableSprite
	{
		super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
		// Override to change the return type of the function.
		return this;
	}

	public function onJustPressed(pos:FlxPoint)
	{
		// OVERRIDE ME!
	}

	public function onJustPressedMiddle(pos:FlxPoint)
	{
		// OVERRIDE ME!
	}

	public function onJustPressedRight(pos:FlxPoint)
	{
		// OVERRIDE ME!
	}

	public function onJustReleased(pos:FlxPoint, pressDuration:Int)
	{
		// OVERRIDE ME!
	}

	public function onJustReleasedMiddle(pos:FlxPoint, pressDuration:Int)
	{
		// OVERRIDE ME!
	}

	public function onJustReleasedRight(pos:FlxPoint, pressDuration:Int)
	{
		// OVERRIDE ME!
	}

	public function onJustSwiped(start:FlxPoint, end:FlxPoint, swipeDuration:Int, swipeDirection:SwipeDirection)
	{
		// OVERRIDE ME!
	}

	public function onJustHoverEnter(pos:FlxPoint)
	{
		// OVERRIDE ME!
	}

	public function onJustHoverExit(pos:FlxPoint)
	{
		// OVERRIDE ME!
	}
}
