package funkin.util.input;

import funkin.behavior.input.IInteractable;
import funkin.behavior.input.InteractableSprite;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEventManager;

/**
 * Utility functions for dealing with gestures.
 * I only support swipe and have only needed to support swiping.
 * Check here for logic to copy if you need pan, zoom, or rotate gestures:
 * @see https://gitlab.com/wikiti-random-stuff/roxlib/-/blob/master/com/roxstudio/haxe/gesture/RoxGestureAgent.hx
 */
class GestureUtil
{
	/**
	 * Use these to handle gesture callbacks on a sprite.
	 * @param target 
	 */
	public static function addGestureCallbacks(target:InteractableSprite)
	{
		var mouseDownEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			t.onJustPressed(FlxG.mouse.getScreenPosition());
		}
		var mouseUpEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicks;
			t.onJustReleased(FlxG.mouse.getScreenPosition(), pressTime);
		}
		var mouseOverEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			t.onJustHoverEnter(FlxG.mouse.getScreenPosition());
		}
		var mouseOutEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			t.onJustHoverExit(FlxG.mouse.getScreenPosition());
		}
		var rightMouseDownEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			t.onJustPressedRight(FlxG.mouse.getScreenPosition());
		}
		var rightMouseUpEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicksRight;
			t.onJustReleasedRight(FlxG.mouse.getScreenPosition(), pressTime);
		}
		var middleMouseDownEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			t.onJustPressedMiddle(FlxG.mouse.getScreenPosition());
		}
		var middleMouseUpEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicksMiddle;
			t.onJustReleasedMiddle(FlxG.mouse.getScreenPosition(), pressTime);
		}

		FlxMouseEventManager.add(target, mouseDownEvent, mouseUpEvent, mouseOverEvent, mouseOutEvent, false, true, true, [LEFT]);
		FlxMouseEventManager.add(target, rightMouseDownEvent, rightMouseUpEvent, null, null, false, true, true, [RIGHT]);
		FlxMouseEventManager.add(target, middleMouseDownEvent, middleMouseUpEvent, null, null, false, true, true, [MIDDLE]);
	}

	public static function handleGestureState(target:IInteractable, inputData:GestureStateData):GestureStateData
	{
		var mousePos = FlxG.mouse.getScreenPosition();
		var outputData:GestureStateData = {
			leftClickGestureStart: inputData.leftClickGestureStart,
		};

		if (FlxG.mouse.justPressed)
		{
			outputData.leftClickGestureStart = mousePos;
			target.onJustPressed(mousePos);
		}
		if (FlxG.mouse.justPressedMiddle)
		{
			target.onJustPressedMiddle(mousePos);
		}
		if (FlxG.mouse.justPressedRight)
		{
			target.onJustPressedRight(mousePos);
		}

		if (FlxG.mouse.justReleased)
		{
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicks;
			if (GestureUtil.isValidSwipe(inputData.leftClickGestureStart, mousePos))
				target.onJustSwiped(inputData.leftClickGestureStart, mousePos, pressTime,
					GestureUtil.getSwipeDirection(inputData.leftClickGestureStart, mousePos));

			outputData.leftClickGestureStart = null;
			target.onJustReleased(mousePos, pressTime);
		}
		if (FlxG.mouse.justReleasedMiddle)
		{
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicksMiddle;
			target.onJustReleasedMiddle(mousePos, pressTime);
		}
		if (FlxG.mouse.justReleasedRight)
		{
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicksRight;
			target.onJustReleasedRight(mousePos, pressTime);
		}

		return outputData;
	}

	/**
	 * Defines the difference between a tap and a swipe.
	 * A swipe is longer than this many pixels, in screen space.
	 */
	static final SWIPE_DISTANCE_THRESHOLD = 10;

	public static function isValidSwipe(start:FlxPoint, end:FlxPoint)
	{
		if (start == null || end == null)
			return false;
		return start.distanceTo(end) >= SWIPE_DISTANCE_THRESHOLD;
	}

	/**
	 * You can swipe within 45 degrees of a direction for it to count.
	 */
	static final SWIPE_THRESHOLD = 45;

	static final SWIPE_THRESHOLD_N_NE = SWIPE_THRESHOLD / 2;
	static final SWIPE_THRESHOLD_NE_E = SWIPE_THRESHOLD_N_NE + SWIPE_THRESHOLD;
	static final SWIPE_THRESHOLD_E_SE = SWIPE_THRESHOLD_NE_E + SWIPE_THRESHOLD;
	static final SWIPE_THRESHOLD_SE_S = SWIPE_THRESHOLD_E_SE + SWIPE_THRESHOLD;
	static final SWIPE_THRESHOLD_N_NW = -1 * SWIPE_THRESHOLD / 2 * -1;
	static final SWIPE_THRESHOLD_NW_W = SWIPE_THRESHOLD_NW_W - SWIPE_THRESHOLD;
	static final SWIPE_THRESHOLD_W_SW = SWIPE_THRESHOLD_W_SW - SWIPE_THRESHOLD;
	static final SWIPE_THRESHOLD_SW_S = SWIPE_THRESHOLD_SW_S - SWIPE_THRESHOLD;

	public static function getSwipeDirection(start:FlxPoint, end:FlxPoint)
	{
		var swipeAngle = start.angleBetween(end);
		if (SWIPE_THRESHOLD_N_NW < swipeAngle && swipeAngle < SWIPE_THRESHOLD_N_NE)
		{
			return NORTH;
		}
		if (SWIPE_THRESHOLD_N_NE < swipeAngle && swipeAngle < SWIPE_THRESHOLD_NE_E)
		{
			return NORTHEAST;
		}
		if (SWIPE_THRESHOLD_NE_E < swipeAngle && swipeAngle < SWIPE_THRESHOLD_E_SE)
		{
			return EAST;
		}
		if (SWIPE_THRESHOLD_E_SE < swipeAngle && swipeAngle < SWIPE_THRESHOLD_SE_S)
		{
			return SOUTHEAST;
		}

		if (SWIPE_THRESHOLD_NW_W < swipeAngle && swipeAngle < SWIPE_THRESHOLD_N_NW)
		{
			return NORTHWEST;
		}

		if (SWIPE_THRESHOLD_W_SW < swipeAngle && swipeAngle < SWIPE_THRESHOLD_NW_W)
		{
			return WEST;
		}
		if (SWIPE_THRESHOLD_SW_S < swipeAngle && swipeAngle < SWIPE_THRESHOLD_W_SW)
		{
			return SOUTHWEST;
		}

		// South is either -180 or 180 so the easiest way is to make it the fallback.
		return SOUTH;
	}
}

enum SwipeDirection
{
	NORTH;
	NORTHEAST;
	NORTHWEST;
	SOUTH;
	SOUTHEAST;
	SOUTHWEST;
	EAST;
	WEST;
}

/**
 * Put this variable on an object to help it keep track of things that tapped it.
 */
typedef GestureStateData =
{
	var ?leftClickGestureStart:FlxPoint;
}
