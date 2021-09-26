package funkin.util.input;

import flixel.math.FlxPoint;

/**
 * Utility functions for dealing with gestures.
 * I only support swipe and have only needed to support swiping.
 * Check here for logic to copy if you need pan, zoom, or rotate gestures:
 * @see https://gitlab.com/wikiti-random-stuff/roxlib/-/blob/master/com/roxstudio/haxe/gesture/RoxGestureAgent.hx
 */
class GestureUtil
{
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
