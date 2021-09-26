package funkin.util.macro;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using Lambda;

/**
 * A macro built for a macro!
 * 
 * Adds a call to `Debug.logError` to all `@:hscript` functions.
 */
class HaxeHScriptFixer
{
	public static macro function build():Array<Field>
	{
		var cls = Context.getLocalClass().get();
		var fields:Array<Field> = Context.getBuildFields();

		var constructor_setup:Array<Expr> = null;

		var hscript_global_field_names:Array<String> = [];

		// Find all fields with @:hscript metadata
		for (field in fields)
		{
			var scriptable_meta = field.meta.find(function(m) return m.name == ":hscript");
			if (scriptable_meta != null)
			{
				switch field.kind
				{
					case FFun(func):
						var return_expr = switch func.ret
						{
							case TPath({name: "Void", pack: [], params: []}):
								// Function sigture says Void, don't return anything
								macro null;
							default:
								macro return script_result;
						}

						var pathName = field.name;
						if (polymod.hscript.HScriptConfig.useNamespaceInPaths)
						{
							var module:String = Context.getLocalModule();
							module = StringTools.replace(module, ".", "/");
							pathName = $v{module + "/" + pathName};
						}

						// Alter the function body:
						func.expr = macro
							{
								${func.expr};
								if (script_error != null)
								{
									funkin.behavior.Debug.logError('SCRIPT ERROR: An error occurred while running a script.');
									funkin.behavior.Debug.logError(script_error);
								}
								$return_expr;
							}
					default:
						Context.error("Error: The @:hscript meta is only allowed on functions", field.pos);
				}
			}
		}

		return fields;
	}
}
