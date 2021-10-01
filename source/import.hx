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
 * import.hx
 * Any imports placed into this file will be provided to all other modules in the project.
 * This is useful for automatically providing constants or widely-used classes.
 */
#if macro
// Imports used only for macros.
// =====================
// COMMONLY USED MODULES
// =====================
// haxe.macro
import haxe.macro.Expr;
import haxe.macro.Context;
#else
// Imports used only outside macros.
// =====================
// COMMONLY USED MODULES
// =====================
// flixel
import flixel.FlxG;
#end
