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
 * HaxeHScriptFixer.hx
 * A macro designed to augment the Polymod HScript Macro.
 * Adds a call to `Debug.logError` to all `@:hscript` functions.
 * Previously contained code to inject additional variables; this has been contributed to Polymod instead.
 */
package funkin.util.macro;

using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using Lambda;

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
