package funkin.ui.component.input;

import flixel.FlxObject;
import funkin.util.input.GestureUtil;
import flixel.FlxG;
import flixel.math.FlxPoint;
import funkin.util.input.GestureUtil.SwipeDirection;
import flixel.input.touch.FlxTouchManager;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * This extension of FlxSprite calls corresponding events when clicked or tapped.
 * Override it for custom behavior.
 */
class InteractableSprite extends FlxSprite implements IInteractable implements IRelative
{
	public static function initMouseControls()
	{
		FlxG.plugins.add(new FlxMouseEventManager());
	}

	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, ?Parent:FlxObject)
	{
		super(0, 0, SimpleGraphic);

		updatePosition();

		GestureUtil.addGestureCallbacks(this);
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
