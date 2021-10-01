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
 * HaxeCommit.hx
 * Retrieves the first seven characters of the commit hash for this repo and stores it as a variable.
 * Used in logging.
 * @see https://code.haxe.org/category/macros/add-git-commit-hash-in-build.html
 */
package funkin.util.macro;

class HaxeCommit
{
	public static macro function getGitCommitHash():haxe.macro.Expr.ExprOf<String>
	{
		#if !display
		// Get the current line number.
		var pos = haxe.macro.Context.currentPos();

		var process = new sys.io.Process('git', ['rev-parse', 'HEAD']);
		if (process.exitCode() != 0)
		{
			var message = process.stderr.readAll().toString();
			haxe.macro.Context.error("Cannot execute `git rev-parse HEAD`. " + message, pos);
		}

		// read the output of the process
		var commitHash:String = process.stdout.readLine();
		var commitHashSplice:String = commitHash.substr(0, 7);

		haxe.macro.Context.info('We are in git commit ${commitHashSplice}', pos);

		// Generates a string expression
		return macro $v{commitHashSplice};
		#else
		// `#if display` is used for code completion. In this case returning an
		// empty string is good enough; We don't want to call git on every hint.
		var commitHash:String = "";
		return macro $v{commitHashSplice};
		#end
	}
}
