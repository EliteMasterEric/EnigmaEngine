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
 * XMLLayoutState.hx
 * Provides convenience functions for creating UIs with layouts powered by XML.
 */
package funkin.ui.component.base;

import funkin.util.assets.Paths;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUIState;

using hx.strings.Strings;

class XMLLayoutState extends FlxUIState
{
	function getXMLId():String
	{
		// You MUST override me! Don't forget!
		throw 'You did not override getXMLId!';
	}

	override function create()
	{
		trace('Initializing a layout with XML (${getXMLId()})');
		this._liveFilePath = Paths.rawTxt('ui/');
		// Make sure the XML gets loaded.
		this._xml_id = getXMLId();

		// You dumbass. You cretin. You nincompoop.
		super.create();
	}

	public override function getRequest(id:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic
	{
		// If the request is to build a UI component...
		if (id.indexOf("ui_get:") == 0)
		{
			var tag = id.removeFirst("ui_get:");
			trace('XMLLayoutState received REQUEST: ui_get: $tag');
			return buildComponent(tag, target, data, params);
		}
		return null;
	}

	public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
	{
		super.getEvent(id, sender, data, params);
		trace('XMLLayoutState received EVENT: $id');
	}

	/**
	 * When an unknown tag is added to the XML, this function builds and returns a new FlxUI component based on the data.
	 * @param tag The XML tag of the element.
	 * @return The new UI element to render.
	 */
	public function buildComponent(tag:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Dynamic
	{
		// OVERRIDE ME! Don't forget to fall back to super.buildComponent()!
		switch (tag)
		{
			case 'test':
				return new FlxText(0, 0, 0, "Mod Configuration", 24);
			default:
				return null;
		}
	}
}
