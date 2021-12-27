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
 * HaxeFlxZLevel.hx
 * This macro goes to the FlxBasic class and injects a z-index value that can be defined,
 * to easily define custom behavior for FlxTypedGroup.sort().
 * 
 * By adding it to the FlxBasic class, we make it available without having to create a custom
 * subclass of FlxSprite that we then have to require other classes to extend, etc.
 */
package funkin.util.macro;

class HaxeFlxZIndex
{
	public static macro function build():Array<Field>
	{
		var cls:haxe.macro.Type.ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		if (!checkSuperclass(cls))
		{
			return fields;
		}

		trace('[INFO] ${cls.name}: Adding zIndex attribute...');

		// Create properties which additionally run this code when the updatePosition function when set.
		var defaultZIndex:Expr = macro $v{0};
		fields = fields.concat(MacroUtil.buildVariable("zIndex", macro:Int, defaultZIndex, true, false));

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
