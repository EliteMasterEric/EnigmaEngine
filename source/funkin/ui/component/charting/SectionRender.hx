package funkin.ui.component.charting;

import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.behavior.play.Section.SwagSection;

class SectionRender extends FlxSprite
{
	public var section:SwagSection;
	public var icon:FlxSprite;
	public var lastUpdated:Bool;

	public function new(x:Float, y:Float, GRID_SIZE:Int, ?Height:Int = 16)
	{
		super(x, y);

		makeGraphic(GRID_SIZE * ChartingState.GRID_WIDTH_IN_CELLS, GRID_SIZE * Height, 0xffe7e6e6);

		var h = GRID_SIZE;
		if (Math.floor(h) != h)
			h = GRID_SIZE;

		if (FlxG.save.data.editorBG)
		{
			FlxGridOverlay.overlay(this, GRID_SIZE, Std.int(h), GRID_SIZE * ChartingState.GRID_WIDTH_IN_CELLS, GRID_SIZE * Height);
		}
	}

	override function update(elapsed)
	{
	}
}
