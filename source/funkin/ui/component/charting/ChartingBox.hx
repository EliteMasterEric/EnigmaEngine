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
 * ChartingBox.hx
 * A box around a note in the Charter, used to indicate selection.
 */
package funkin.ui.component.charting;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import funkin.ui.component.play.Note;

class ChartingBox extends FlxSprite
{
	public var connectedNote:Note;
	public var connectedNoteData:Array<Dynamic>;

	public function new(x, y, originalNote:Note)
	{
		super(x, y);
		connectedNote = originalNote;

		makeGraphic(40, 40, FlxColor.fromRGB(173, 216, 230));
		alpha = 0.4;
	}
}
