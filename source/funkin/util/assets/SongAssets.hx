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
 * SongAssets.hx
 * Contains static utility functions used to retrieve song/chart data.
 * You may be looking for AudioAssets.hx.
 */
package funkin.util.assets;

import funkin.util.assets.Paths;
import funkin.util.assets.LibraryAssets;
import funkin.behavior.play.Difficulty.DifficultyCache;
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
		var suffix = DifficultyCache.getSuffix(difficultyId);
		var path = Paths.json('songs/${songId}/${songId}${suffix}');
		return LibraryAssets.textExists(path);
	}

	/**
	 * Return a list of difficulty IDs that have valid chart files for a given song ID.
	 */
	public static function listDifficultiesForSong(songId:String)
	{
		var diffList = DifficultyCache.difficultyList;
		var filteredDiffs = diffList.filter(function(diffId)
		{
			return doesSongExist(songId, diffId);
		});
		return filteredDiffs;
	}
}
