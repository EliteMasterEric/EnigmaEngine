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
 * LibraryAssets.hx
 * Contains static utility functions used for metadata about asset libraries,
 * such as whether an asset or library exists.
 */
package funkin.util.assets;

import funkin.behavior.Debug;
import openfl.Assets as OpenFlAssets;

class LibraryAssets
{
	public static function assetExists(path:String, type:openfl.utils.AssetType)
	{
		if (type == null)
		{
			Debug.logError('Don\'t specify a null AssetType when querying for assets! ${path}');
			return false;
		}
		return OpenFlAssets.exists(path, type);
	}

	public static function binaryExists(path:String)
	{
		return assetExists(path, BINARY);
	}

	public static function soundExists(path:String)
	{
		if (path == null || path == "")
			return false;
		return assetExists(path, SOUND) || assetExists(path, MUSIC);
	}

	public static inline function textExists(path:String)
	{
		return assetExists(path, TEXT);
	}

	public static function imageExists(key:String, ?library:String):Bool
	{
		return assetExists(Paths.image(key, library), IMAGE);
	}
}
