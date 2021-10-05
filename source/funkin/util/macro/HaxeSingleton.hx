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
 * HaxeSingleton.hx
 * Performs a macro that creates an instance of the class and append the value as a static property `instance`.
 * @see https://en.wikipedia.org/wiki/Singleton_pattern
 * @see https://code.haxe.org/category/macros/build-static-field.html
 * @see https://community.haxe.org/t/initialize-class-instance-from-expr-in-macro/521
 */
package funkin.util.macro;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using Lambda;

class HaxeSingleton
{
	public static macro function build():Array<Field>
	{
		var cls:haxe.macro.Type.ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		// We first make sure the class has a constructor.

		if (cls.constructor == null)
		{
			// Context.info('Adding constructor to class ${cls.name}...', cls.pos);

			var constBody:Array<Expr> = [];

			var parentCls = cls.superClass.t.get();
			if (parentCls != null)
			{
				var parentCons = parentCls.constructor;
				if (parentCons != null)
				{
					var constructorCall = macro
						{
							super();
						};
					constBody.push(constructorCall);
				}
				else
				{
					Context.error('Class ${cls.name} needs a constructor, or a parent with a constructor!', cls.pos);
				}
			}
			else
			{
				Context.error('Class ${cls.name} needs a constructor, or a parent with a constructor!', cls.pos);
			}

			// This constructor takes zero arguments or parameters, and only calls the superClass constructor
			// with zero arguments.
			fields.push(MacroUtil.buildConstructor(constBody));
		}

		// Context.info('Adding instance to class ${cls.name}...', cls.pos);
		// Create a public static variable called 'instance'.
		fields.push(MacroUtil.buildVariable("instance", TPath(MacroUtil.buildTypePath(cls)), MacroUtil.createInstance(cls), true, true));

		return fields;
	}
}
