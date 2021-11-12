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
 * NoteGroup.hx
 * An FlxTypedGroup that contains notes in a song.
 * Provides additional useful utility functions.
 */
package funkin.ui.component.play;

import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.ui.component.play.Note;

class NoteGroup extends FlxTypedGroup<Note>
{
	/**
	 * Returns just the Notes which could be hit.
	 * @param sort Whether to sort by strumtime.
	 * @return Array<Note>
	 */
	public function filterCanBeHit(?sort:Bool = true):Array<Note>
	{
		var result:Array<Note> = [];

		// TODO: We run this function a LOT, and this processing is O(n).
		// Can we optimize it somehow?

		forEachAlive(function(curNote:Note)
		{
			// The notes which are in range of the strumbar,
			// the notes which are on the player side (not the CPU side),
			// the notes which haven't been registered as hit yet.
			if (curNote.canBeHit && !curNote.isCPUNote && !curNote.wasGoodHit)
			{
				result.push(curNote);
			}
		});

		if (sort)
			result.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		return result;
	}
}
