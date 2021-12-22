/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * HaxeRotatable.hx
 * Add methods to an FlxObject that allow it to be rotated as though it were in 3D space.
 */
package funkin.util.macro;

class HaxeRotatable
{
	public static macro function build():Array<Field>
	{
		var cls:haxe.macro.Type.ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		if (!checkSuperclass(cls))
		{
			return fields;
		}

		trace('[INFO] ${cls.name}: Implementing IRotatable...');

		// Create properties which additionally run this code when the updatePosition function when set.
		var propertyBody = [macro this.updatePosition()];
		fields = fields.concat(MacroUtil.buildProperty("positionX", macro:Float, null, null, propertyBody, true));
		fields = fields.concat(MacroUtil.buildProperty("positionY", macro:Float, null, null, propertyBody, true));
		// positionZ isn't helpful in 2D space.
		fields = fields.concat(MacroUtil.buildProperty("scaleX", macro:Float, null, null, propertyBody, true));
		fields = fields.concat(MacroUtil.buildProperty("scaleY", macro:Float, null, null, propertyBody, true));
		// scaleZ isn't helpful in 2D space.
		fields = fields.concat(MacroUtil.buildProperty("rotationX", macro:Float, null, null, propertyBody, true));
		fields = fields.concat(MacroUtil.buildProperty("rotationY", macro:Float, null, null, propertyBody, true));
		fields = fields.concat(MacroUtil.buildProperty("rotationZ", macro:Float, null, null, propertyBody, true));

		var updatePosBody = macro
			{
				// A value from 0 to 1, where 1 indicates the sprite is full width
				// and 0 indicates the sprite is invisible (perpendicular to the camera)
				var relativeWidth:Float = Math.cos(this.rotationY);
				var relativeHeight:Float = Math.cos(this.rotationX);
				var absoluteWidth:Float = relativeWidth * this.scaleX * this.width;
				var absoluteHeight:Float = relativeHeight * this.scaleY * this.height;

				this.setGraphicSize(Std.int(absoluteWidth), Std.int(absoluteHeight));

				// We need to recalculate the position of the sprite based on the rotation.
				// A relativeWidth of 1 means an X offset of 0.
				// A relativeWidth of 0 means an X offset of 0.5 * this.width.
				var xOffset:Float = (1 - relativeWidth) * this.width / 2;
				var yOffset:Float = (1 - relativeHeight) * this.height / 2;

				this.x = this.positionX + xOffset;
				this.y = this.positionY + yOffset;

				this.angle = this.rotationZ;
			};
		fields.push(MacroUtil.buildFunction("updatePosition", [updatePosBody], false, false));

		return fields;
	}

	static function checkSuperclass(cls:haxe.macro.Type.ClassType)
	{
		// Superclasses need to be checked recursively.
		if (cls.superClass != null)
		{
			var superCls = cls.superClass.t.get();
			for (field in superCls.fields.get())
			{
				// Parent already added, return false.
				if (field.name == 'parent')
					return false;
			}
			// Else, we need to check for the superclass's superclass.
			return checkSuperclass(superCls);
		}
		else
		{
			// No superclass, parent needs to be added. Return true;
			return true;
		}
	}
}
