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
 * ArrowButton.hx
 * A work-in progress component, which renders a button with an arrow on it.
 */
package funkin.ui.component.input;

import flixel.addons.ui.FlxUIButton;

class ArrowButton extends FlxUIButton
{
	public function new(x:Float, y:Float, w:Float, h:Float, onClick:Void->Void, asset:Dynamic)
	{
		super(x, y, null, onClick);
	}

	public override function resize(W:Float, H:Float):Void
	{
		// TODO Implement this so that resizing doesn't mess up the arrow graphic,
		// or just use a custom arrow graphic.
		throw "Not implemented!";
	}
}
