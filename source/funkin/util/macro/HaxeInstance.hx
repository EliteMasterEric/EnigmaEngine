package funkin.util.macro;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using Lambda;

/**
 * Create an instance of the class and append the value as a static field `instance`.
 * @see https://code.haxe.org/category/macros/build-static-field.html
 * @see https://community.haxe.org/t/initialize-class-instance-from-expr-in-macro/521
 */
class HaxeInstance
{
	public static macro function build():Array<Field>
	{
		var cls:haxe.macro.Type.ClassType = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		// We first make sure the class has a constructor.

		if (cls.constructor == null)
		{
			Context.info('Adding constructor to class ${cls.name}...', cls.pos);

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

		Context.info('Adding instance to class ${cls.name}...', cls.pos);
		// Create a public static variable called 'instance'.
		fields.push(MacroUtil.buildVariable("instance", TPath(MacroUtil.buildTypePath(cls)), MacroUtil.createInstance(cls), true, true));

		return fields;
	}
}
