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
