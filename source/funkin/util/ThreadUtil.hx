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
 * ThreadUtil.hx
 * Contains utility functions to simplify the process of performing tasks in a background thread.
 * Good for fully utilizing multi-processor support.
 */
package funkin.util;

class ThreadUtil
{
	public static function doInBackground(cb:Void->Void)
	{
		#if FEATURE_MULTITHREADING
		sys.thread.Thread.create(() ->
		{
			// Run in the background.
			cb();
		});
		#else
		trace('WARNING: Tried to run callback with doInBackground, but multithreading is disabled on this platform.');
		cb();
		#end
	}
}
