package funkin.util.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * Add methods to an FlxObject that allow it to be positioned and rotated relative to a parent.
 */
class HaxeRelative
{
	public static macro function build():Array<Field>
	{
		var cls:haxe.macro.Type.ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		if (cls.superClass.t.get() != null)
		{
			for (field in cls.superClass.t.get().fields.get())
			{
				if (field.name == 'parent')
				{
					Context.info('${cls.name}: IRelative already implemented...', cls.pos);
					return fields;
				}
			}
		}
		Context.info('${cls.name}: IMPLEMENTING IRelative...', cls.pos);

		// Create properties which additionally run this code when the updatePosition function when set.
		var propertyBody = [macro this.updatePosition()];
		fields = fields.concat(MacroUtil.buildProperty("parent", macro:flixel.FlxObject, null, null, propertyBody, true));
		fields = fields.concat(MacroUtil.buildProperty("relativeX", macro:Float, null, null, propertyBody, true));
		fields = fields.concat(MacroUtil.buildProperty("relativeY", macro:Float, null, null, propertyBody, true));
		fields = fields.concat(MacroUtil.buildProperty("relativeAngle", macro:Float, null, null, propertyBody, true));

		var updatePosBody = macro
			{
				if (this.parent != null)
				{
					// Set the absolute X and Y relative to the parent.
					this.x = this.parent.x + this.relativeX;
					this.y = this.parent.y + this.relativeY;
					this.angle = this.parent.angle + this.relativeAngle;
				}
				else
				{
					this.x = this.relativeX;
					this.y = this.relativeY;
				}
			};
		fields.push(MacroUtil.buildFunction("updatePosition", [updatePosBody], false, false));

		return fields;
	}
}
