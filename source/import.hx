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
import funkin.behavior.Debug;
#end
