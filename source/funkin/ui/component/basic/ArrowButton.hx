package funkin.ui.component.basic;

import flixel.addons.ui.FlxUIButton;

class ArrowButton extends FlxUIButton
{
	public function new(x:Float, y:Float, w:Float, h:Float, onClick:Void->Void, asset:Dynamic)
	{
		super(x, y, null, onClick);
	}

	public override function resize(W:Float, H:Float):Void
	{
		// TODO Implement this so that resizing doesn't mess up the arrow graphic,
		// or just use a custom arrow graphic.
		throw "Not implemented!";
	}
}
