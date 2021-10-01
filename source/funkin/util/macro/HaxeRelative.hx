/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * HaxeRelative.hx
 * Add methods to an FlxObject that allow it to be positioned and rotated relative to a parent.
 */
package funkin.util.macro;

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
		Context.info('${cls.name}: Implementing IRelative...', cls.pos);

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
