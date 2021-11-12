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
