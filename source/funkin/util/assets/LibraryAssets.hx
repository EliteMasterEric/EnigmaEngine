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
 * LibraryAssets.hx
 * Contains static utility functions used for metadata about asset libraries,
 * such as whether an asset or library exists.
 */
package funkin.util.assets;

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

	/**
	 * List all file IDs files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of image files under that path.
	 */
	public static function listImagesInPath(path:String, ?library:String = null)
	{
		// We need to query OpenFlAssets, not the file system, because of Polymod.

		// These are in the form of a RAW file system path.
		// We need to filter them by
		// then make them in the form of an internal asset ID.
		var typedAssets = OpenFlAssets.list(IMAGE);

		var queryRegex = new EReg('^(assets|mods/[a-z0-9]+)/' + (library != null ? '${library}/' : '') + 'images/(${path}/.+)\\.(.+)$', 'i');

		var filteredAssets = typedAssets.map(function(asset:String):String
		{
			// Get just the asset ID, without the extension. Filter out any values that don't match the query.
			return queryRegex.match(asset) ? queryRegex.matched(2) : null;
		}).filter(function(asset:String):Bool
		{
			return asset != null;
		});

		return filteredAssets;
	}
}
