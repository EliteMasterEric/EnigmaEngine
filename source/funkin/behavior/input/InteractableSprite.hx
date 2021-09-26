package funkin.behavior.input;

import flixel.input.mouse.FlxMouseEventManager;
import flixel.input.touch.FlxTouchManager;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * This extension of FlxSprite calls corresponding events when clicked or tapped.
 * Override it for custom behavior.
 */
class InteractableSprite extends FlxSprite
{
	public var clickable = true;
	public var tappable = true;

	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
	}

	function initTouchSupport()
	{
		var mouseDownEvent = function(target:InteractableSprite)
		{
			@:privateAccess
			target.onMouseDown();
		}
		var mouseUpEvent = function(target:InteractableSprite)
		{
			@:privateAccess
			target.onMouseUp();
		}
		var mouseOverEvent = function(target:InteractableSprite)
		{
			@:privateAccess
			target.onMouseOver();
		}
		var mouseOutEvent = function(target:InteractableSprite)
		{
			@:privateAccess
			target.onMouseOut();
		}
		var rightMouseDownEvent = function(target:InteractableSprite)
		{
			@:privateAccess
			target.onMouseDown();
		}
		var rightMouseUpEvent = function(target:InteractableSprite)
		{
			@:privateAccess
			target.onMouseUp();
		}

		FlxMouseEventManager.add(this, mouseDownEvent, mouseUpEvent, mouseOverEvent, mouseOutEvent, false, true, true, [LEFT]);
		FlxMouseEventManager.add(this, rightMouseDownEvent, rightMouseUpEvent, null, null, false, true, true, [RIGHT]);
		// FlxMouseEventManager.add(this, middleMouseDownEvent, middleMouseUpEvent, null, null, false, true, true, [MIDDLE]);
	}

	/*
	 * Called when the user presses the mouse or touch input over the element.
	 * Override this for custom behavior.
	 */
	function onMouseDown()
	{
	}

	/**
	 * Called when the user releases the mouse or touch input over the element.
	 * Override this for custom behavior.
	 */
	function onMouseUp()
	{
	}

	/*
	 * Called when the user presses the right mouse button over the element.
	 * Override this for custom behavior.
	 */
	function onRightMouseDown()
	{
	}

	/**
	 * Called when the user releases the right mouse button over the element.
	 * Override this for custom behavior.
	 */
	function onRightMouseUp()
	{
	}

	/*
	 * Called when the user starts hovering over the element.
	 * Override this for custom behavior.
	 */
	function onMouseOver()
	{
	}

	/**
	 * Called when the user stops hovering over the element.
	 * Override this for custom behavior.
	 */
	function onMouseOut()
	{
	}
}
