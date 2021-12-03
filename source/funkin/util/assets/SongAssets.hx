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
 * SongAssets.hx
 * Contains static utility functions used to retrieve song/chart data.
 * You may be looking for AudioAssets.hx.
 */
package funkin.util.assets;

import funkin.util.assets.Paths;
import funkin.util.assets.LibraryAssets;
import funkin.data.DifficultyData;
import openfl.Assets as OpenFlAssets;

class SongAssets
{
	/**
	 * List all the music files in the `songs` folder, so we can precache them all.
	 */
	public static function listMusicFilesToCache()
	{
		// We need to query OpenFlAssets, not the file system, because of Polymod.
		var soundAssets = OpenFlAssets.list(MUSIC).concat(OpenFlAssets.list(SOUND));

		var songNames = [];

		for (sound in soundAssets)
		{
			// Parse end-to-beginning to support mods.
			var path = sound.split('/');
			path.reverse();

			var fileName = path[0];
			var songName = path[1];

			if (path[2] != 'songs')
				continue;

			// Remove duplicates.
			if (songNames.indexOf(songName) != -1)
				continue;

			songNames.push(songName);
		}

		return songNames;
	}

	/**
	 * Returns whether there is song data for this song ID and difficulty.
	 * @return }
	 */
	public static function doesSongExist(songId:String, ?difficultyId:String = '')
	{
		if (songId == null || songId == "")
			return false;
		var suffix = DifficultyDataHandler.fetch(difficultyId).songSuffix;
		var path = Paths.json('songs/${songId}/${songId}${suffix}');
		return LibraryAssets.textExists(path);
	}

	/**
	 * Return a list of difficulty IDs that have valid chart files for a given song ID.
	 */
	public static function listDifficultiesForSong(songId:String)
	{
		var filteredDiffs = DifficultyDataHandler.difficultyIds.filter(function(diffId)
		{
			return doesSongExist(songId, diffId);
		});
		return filteredDiffs;
	}
}
