package funkin.util.input;

import flixel.FlxObject;
import flixel.addons.ui.Anchor;

/**
 * Static utility functions for working with Flixel UI.
 */
class FlixelUIUtil
{
	/**
	 * Anchor an object to another object.
	 * @param child 
	 * @param parent 
	 * @param anchor 
	 */
	public static function anchorObject(child:FlxObject, parent:FlxObject, anchor:Anchor = null)
	{
		if (anchor == null)
		{
			anchor = new Anchor(0, 0, Anchor.CENTER, Anchor.CENTER, Anchor.CENTER, Anchor.CENTER);
		}

		anchor.anchorThing(child, parent);
	}
}
