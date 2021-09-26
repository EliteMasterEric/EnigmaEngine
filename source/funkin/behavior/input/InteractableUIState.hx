package funkin.behavior.input;

import funkin.util.input.GestureUtil;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;

class InteractableUIState extends FlxUIState
{
	var leftClickGestureStart:FlxPoint;

	override function update(elapsed:Float)
	{
		var mousePos = FlxG.mouse.getScreenPosition();
		if (FlxG.mouse.justPressed)
		{
			leftClickGestureStart = mousePos;
			onJustPressed(mousePos);
		}
		if (FlxG.mouse.justPressedMiddle)
		{
			onJustPressedMiddle(mousePos);
		}
		if (FlxG.mouse.justPressedRight)
		{
			onJustPressedRight(mousePos);
		}

		if (FlxG.mouse.justReleased)
		{
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicks;
			if (GestureUtil.isValidSwipe(leftClickGestureStart, mousePos))
				onJustSwiped(leftClickGestureStart, mousePos, pressTime, GestureUtil.getSwipeDirection(leftClickGestureStart, mousePos));

			leftClickGestureStart = null;
			onJustReleased(mousePos, pressTime);
		}
		if (FlxG.mouse.justReleasedMiddle)
		{
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicksMiddle;
			onJustReleasedMiddle(mousePos, pressTime);
		}
		if (FlxG.mouse.justReleasedRight)
		{
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicksRight;
			onJustReleasedRight(mousePos, pressTime);
		}

		super.update(elapsed);
	}

	/**
	 * This function is called when the left mouse or touch is pressed on this state.
	 		* Override this to trigger events.
	 * @param pos The position the user tapped or left clicked at.
	 */
	function onJustPressed(pos:FlxPoint)
	{
	}

	/**
	 * This function is called when the middle mouse is pressed on this state.
	 * Override this to trigger events.
	 * @param pos The position the user middle clicked at.
	 */
	function onJustPressedMiddle(pos:FlxPoint)
	{
	}

	/**
	 * This function is called when the right mouse is pressed on this state.
	 * Override this to trigger events.
	 * @param pos The position the user right clicked at.
	 */
	function onJustPressedRight(pos:FlxPoint)
	{
	}

	/**
	 * This function is called when the left mouse or touch is Released on this state.
	 * Override this to trigger events.
	 * @param pos The position the user tapped or left clicked at.
	 * @param pressDuration The duration the button was pressed, in millisecond ticks.
	 */
	function onJustReleased(pos:FlxPoint, pressDuration:Int)
	{
	}

	/**
	 * This function is called when the middle mouse is Released on this state.
	 * Override this to trigger events.
	 * @param pos The position the user middle clicked at.
	 * @param pressDuration The duration the button was pressed, in millisecond ticks.
	 */
	function onJustReleasedMiddle(pos:FlxPoint, pressDuration:Int)
	{
	}

	/**
	 * This function is called when the right mouse is Released on this state.
	 * Override this to trigger events.
	 * @param pos The position the user right clicked at.
	 		* @param pressDuration The duration the button was pressed, in millisecond ticks.
	 */
	function onJustReleasedRight(pos:FlxPoint, pressDuration:Int)
	{
	}

	/**
	 * This function is called when the user swipes with the touch screen or left mouse button.
	 * Override this to trigger events.
	 * @param start The position the user started the swipe at.
	 * @param end The position the user ended the swipe at.
	 * @param swipeDuration The duration the button was pressed, in millisecond ticks.
	 * @param swipeDirection An enum value for what direction the user swiped in.
	 */
	function onJustSwiped(start:FlxPoint, end:FlxPoint, swipeDuration:Int, swipeDirection:SwipeDirection)
	{
	}
}
