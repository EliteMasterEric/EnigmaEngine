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
 * CharacterData.hx
 * A type definition for character data stored in the JSON asset files.
 * Also includes a class of static utilities for managing and caching data.
 */
package funkin.data;

import funkin.util.concurrency.ThreadUtil;
import funkin.util.assets.DataAssets;

class CharacterDataHandler
{
	/**
	 * Contains all the character data elements.
	 * Caching this during the title screen saves a lot of time.
	 */
	static var cache(default, null):Map<String, CharacterData> = new Map<String, CharacterData>();

	/**
	 * Contains a list of all valid character IDs.
	 */
	public static var characterIds(default, null):Array<String> = [];

	/**
	 * Contains a list of character IDs valid to use as a player or CPU.
	 * Used to power the dropdown in the charter.
	 */
	public static var playerIds(default, null):Array<String> = [];

	/**
	 * Contains a list of character IDs valid only to use as a GF.
	 * Used to power the dropdown in the charter.
	 */
	public static var girlfriendIds(default, null):Array<String> = [];

	/**
	 * Load the character data directly from JSON.
	 * @param id 
	 * @return CharacterData
	 */
	static function loadCharacterData(id:String):CharacterData
	{
		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData = DataAssets.loadJSON('characters/${id}');
		if (jsonData == null)
		{
			Debug.logError('Failed to parse JSON data for character ${id}');
			return null;
		}

		return new CharacterData(id, jsonData);
	}

	/**
	 * Loads character data from disk and caches it.
	 * If the ID is already cached, it will be overwritten.
	 * @param id The ID to fetch.
	 */
	static function cacheCharacter(id:String):CharacterData
	{
		var charData:CharacterData = loadCharacterData(id);

		if (charData == null)
		{
			Debug.logError('Failed to load character data for ${id}');
			return null;
		}

		if (charData.isPlayer)
			playerIds.push(id);

		if (charData.isGF)
			girlfriendIds.push(id);

		if (!characterIds.contains(id))
			characterIds.push(id);

		cache.set(id, charData);

		return charData;
	}

	/**
	 * Gets all character IDs and loads all their data.
	 * @param progressCb A callback to use for progress bars.
	 * 	Provides the number of characters loaded and the total number of characters.
	 */
	public static function cacheWithProgress(progressCb:(Int, Int) -> Void)
	{
		var allCharacters = CharacterDataHandler.listIds();
		characterIds = allCharacters;

		for (charIndex in 0...allCharacters.length)
		{
			cacheCharacter(allCharacters[charIndex]);
			progressCb(charIndex, allCharacters.length);
		}
		progressCb(allCharacters.length, allCharacters.length);

		Debug.logInfo('Loaded ${allCharacters.length} characters into cache.');
	}

	/**
	 * Gets all character IDs and loads all their data.
	 * 
	 * Call this early in the program to store all character JSON in memory,
	 * improving load times while neglegibly increasing memory usage.
	 */
	public static function cacheSync()
	{
		cacheWithProgress(function(a, b)
		{
			return;
		});
	}

	/**
	 * Starts a thread to load all character data.
	 */
	public static function cacheAsync()
	{
		ThreadUtil.doInBackground(cacheSync);
	}

	/**
	 * Attempt to load the character directly from the cache.
	 * If the character data isn't cached, read it synchronously from the data assets.
	 * If data isn't there, return null.
	 * @param charId 
	 */
	public static function fetch(charId:String)
	{
		if (cache.exists(charId))
		{
			return cache.get(charId);
		}
		else
		{
			var charData = cacheCharacter(charId);

			if (charData != null)
			{
				return charData;
			}
			else
			{
				return null;
			}
		}
	}

	public static function listIds():Array<String>
	{
		return DataAssets.listJSONsInPath('characters/');
	}

	public static function clearCache()
	{
		playerIds = [];
		girlfriendIds = [];
		characterIds = [];

		cache.clear();
	}
}

class CharacterData
{
	/**
	 * The internal ID of the character.
	 */
	public var id:String = '';

	/**
	 * The readable name for this character.
	 * Used for menus like the Chart Editor.
	 */
	public var name:String = 'unknown';

	/**
	 * The location of this asset relative to `assets/images`.
	 */
	public var asset:String = '';

	/**
	 * The animation used when the character is initialized.
	 */
	public var startingAnim:String = 'idle';

	/**
	 * Value is true if the character is a Girlfriend character.
	 * Meant only to dance in the BG and play animations.
	 * Will not have singing animations.
	 * @default false
	 */
	public var isGF:Bool = false;

	/**
	 * Value is true if the character is a Player character.
	 * This means it should have a full set of sing and miss animations.
	 * Will not have singing animations.
	 * @default false
	 */
	public var isPlayer:Bool = false;

	/**
	 * Value is true if the character graphic is pixel art.
	 * Forcibly disables anti-aliasing.
	 * @default false
	 */
	public var isPixel:Bool = false;

	/**
	 * Multiplier to scale the sprite by.
	 * Default is 1 for no scaling.
	 * Set this to 6 for pixel characters from Week 6.
	 * @default 1
	 */
	public var scale:Null<Float> = 1;

	/**
	 * Set to true to flip the sprite horizontally.
	 * @default false
	 */
	public var flipX:Bool = false;

	/**
	 * Set to true to flip the sprite vertically.
	 * @default false
	 */
	public var flipY:Bool = false;

	/**
	 * Define what type of texture atlas is used for this sheet.
	 * Set this to 'packer' for the Spirit and 'sparrow' for everyone else.
	 * @default 'sparrow'
	 */
	public var atlasType:String = 'sparrow';

	/**
	 * The color of this character's health bar.
	 */
	public var barColor:String = '#ff0000';

	/**
	 * A list of animations to add to this character.
	 * If you're creating a GF, you should make a danceLeft and a danceRight.
	 * If you're creating a BF, you should add an idle, and singLEFT, singUP, etc.
	 */
	public var animations:Array<AnimationData> = [];

	public function new(id:String, data:Dynamic)
	{
		this.id = id;

		// Mandatory parameters
		this.name = data.name;
		this.asset = data.asset;
		this.animations = cast data.animations;

		// Optional parameters
		if (data.isGF != null)
			this.isGF = data.isGF;

		if (data.isPlayer != null)
			this.isPlayer = data.isPlayer;

		if (data.isPixel != null)
			this.isPixel = data.isPixel;

		if (data.scale != null)
			this.scale = data.scale;

		if (data.flipX != null)
			this.flipX = data.flipX;

		if (data.flipY != null)
			this.flipY = data.flipY;

		if (data.startingAnim != null)
			this.startingAnim = data.startingAnim;

		if (data.atlasType != null)
			this.atlasType = data.atlasType;

		if (data.barColor != null)
			this.barColor = data.barColor;
	}
}

typedef AnimationData =
{
	/**
	 * The name of this animation as referenced by the game.
	 */
	var name:String;

	/**
	 * The prefix for this animation's frames within the XML file.
	 */
	var prefix:String;

	/**
	 * The X and Y offset of this animation relative to the others. Defaults to 0, 0.
	 * @default [0, 0]
	 */
	var ?offsets:Array<Int>;

	/**
	 * Whether this animation is looped.
	 * @default false
	 */
	var ?looped:Bool;

	/**
	 * Set this to true to flip the sprites of this animation horizontally.
	 * @default false
	 */
	var ?flipX:Bool;

	/**
	 * Set this to true to flip the sprites of this animation vertically.
	 * @default false
	 */
	var ?flipY:Bool;

	/**
	 * The frame rate of this animation.
	 * @default 24
	 */
	var ?frameRate:Int;

	/**
	 * If you want this animation to use only certain frames of an animation with a given prefix,
	 * select them here.
	 * @example [] (all frames)
	 * @default [0, 1, 2, 3] (use only the first four frames)
	 */
	var ?frameIndices:Array<Int>;
}
