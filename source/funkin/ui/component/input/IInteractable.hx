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
 * IInteractable.hx
 * An interface used for shared methods for interactable FlxObjects.
 */
package funkin.ui.component.input;

import flixel.math.FlxPoint;
import funkin.util.input.GestureUtil.SwipeDirection;

interface IInteractable
{
	/**
	 * This function is called when the left mouse or touch is pressed on this.
	 * Override this to trigger events.
	 * @param pos The position the user tapped or left clicked at.
	 */
	function onJustPressed(pos:FlxPoint):Void;

	/**
	 * This function is called when the middle mouse is pressed on this.
	 * Override this to trigger events.
	 * @param pos The position the user middle clicked at.
	 */
	function onJustPressedMiddle(pos:FlxPoint):Void;

	/**
	 * This function is called when the right mouse is pressed on this.
	 * Override this to trigger events.
	 * @param pos The position the user right clicked at.
	 */
	function onJustPressedRight(pos:FlxPoint):Void;

	/**
	 * This function is called when the mouse hovers over this.
	 * Override this to trigger events.
	 * @param pos The position the user is currently at.
	 */
	function onJustHoverEnter(pos:FlxPoint):Void;

	/**
	 * This function is called when the mose stops hovering over this.
	 * Override this to trigger events.
	 * @param pos The position the user is currently at.
	 */
	function onJustHoverExit(pos:FlxPoint):Void;

	/**
	 * This function is called when the left mouse or touch is Released on this.
	 * Override this to trigger events.
	 * @param pos The position the user tapped or left clicked at.
	 * @param pressDuration The duration the button was pressed, in millisecond ticks.
	 */
	function onJustReleased(pos:FlxPoint, pressDuration:Int):Void;

	/**
	 * This function is called when the middle mouse is Released on this.
	 * Override this to trigger events.
	 * @param pos The position the user middle clicked at.
	 * @param pressDuration The duration the button was pressed, in millisecond ticks.
	 */
	function onJustReleasedMiddle(pos:FlxPoint, pressDuration:Int):Void;

	/**
	 * This function is called when the right mouse is Released on this.
	 * Override this to trigger events.
	 * @param pos The position the user right clicked at.
	 * @param pressDuration The duration the button was pressed, in millisecond ticks.
	 */
	function onJustReleasedRight(pos:FlxPoint, pressDuration:Int):Void;

	/**
	 * This function is called when the user swipes with the touch screen or left mouse button.
	 * TODO: Should swipe count only if it starts on this, only if it ends on this, or only if it stays on this?
	 * Override this to trigger events.
	 * @param start The position the user started the swipe at.
	 * @param end The position the user ended the swipe at.
	 * @param swipeDuration The duration the button was pressed, in millisecond ticks.
	 * @param swipeDirection An enum value for what direction the user swiped in.
	 */
	function onJustSwiped(start:FlxPoint, end:FlxPoint, swipeDuration:Int, swipeDirection:SwipeDirection):Void;
}
