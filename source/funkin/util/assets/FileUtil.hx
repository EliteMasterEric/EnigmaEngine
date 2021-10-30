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
 * FileUtil.hx
 * Contains static utility functions used for reading and writing files.
 */
package funkin.util.assets;

import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using hx.strings.Strings;

class FileUtil
{
	static var currentFileRef:FileReference;

	public static function writeStringData(fileName:String, data:String)
	{
		if ((data != null) && (data.length > 0))
		{
			currentFileRef = new FileReference();
			currentFileRef.addEventListener(Event.COMPLETE, onSaveComplete);
			currentFileRef.addEventListener(Event.CANCEL, onSaveCancel);
			currentFileRef.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			currentFileRef.save(data.trim(), fileName);
		}
		/*
			// TODO: Make this work in HTML5.
			var b:ByteArray = new ByteArray();
			b = bitmapData.encode(bitmapData.rect, new PNGEncoderOptions(true), b);
			new FileDialog().save(b, "png", null, "file");
		 */
	}

	static function onSaveComplete(_):Void
	{
		currentFileRef.removeEventListener(Event.COMPLETE, onSaveComplete);
		currentFileRef.removeEventListener(Event.CANCEL, onSaveCancel);
		currentFileRef.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		currentFileRef = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	static function onSaveCancel(_):Void
	{
		currentFileRef.removeEventListener(Event.COMPLETE, onSaveComplete);
		currentFileRef.removeEventListener(Event.CANCEL, onSaveCancel);
		currentFileRef.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		currentFileRef = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	static function onSaveError(_):Void
	{
		currentFileRef.removeEventListener(Event.COMPLETE, onSaveComplete);
		currentFileRef.removeEventListener(Event.CANCEL, onSaveCancel);
		currentFileRef.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		currentFileRef = null;
		FlxG.log.error("Problem saving Level data");
	}
}
