package funkin.behavior.input;

import funkin.util.input.GestureUtil.SwipeDirection;
import flixel.math.FlxPoint;

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
