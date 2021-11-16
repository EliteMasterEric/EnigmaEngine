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
 * HealthIcon.hx
 * A sprite which displays on the health bar, used for either the player or the opponent.
 *
 * The health icon has been completely reengineered, to allow for a winning state, animated states,
 * as well as animated transitions, while still fully supporting the simple health icons used in Kade Engine.
 */
package funkin.ui.component.play;

import funkin.behavior.options.Options.AntiAliasingOption;
import flixel.FlxG;
import flixel.FlxSprite;
import funkin.behavior.Debug;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.LibraryAssets;

using hx.strings.Strings;

/**
 * Internally, the health icon utilizes a state machine to manage animations.
 */
enum HealthIconState
{
	/**
	 * Temporary/transitional state.
	 * Indicates that the health icon should recalulate its state.
	 * Set when the icon is initialized or when a transition animation finishes.
	 */
	None;

	/**
	 * Triggers for the player when health is greater than 80%,
	 * or for the opponent when health is less than 20%.
	 * Plays the animation `winning-base`.
	 */
	Winning;

	/**
	 * Triggers for the player when health is less than 20%,
	 * or for the opponent when health is greater than 80%.
	 * Plays the animation `losing-base`.
	 */
	Losing;

	/**
	 * Triggers when the health is not in the winning or losing ranges.
	 * Plays the animation `idle-base`.
	 */
	Idle;

	/**
	 * Transition state that triggers when the icon is in the `Winning` state,
	 * and seeks to move to the `Idle` state.
	 * Moves to the `Idle` state once the animation is done, or if the animation is not specified.
	 */
	WinningToIdle;

	/**
	 * Transition state that triggers when the icon is in the `Losing` state,
	 * and seeks to move to the `Idle` state.
	 * Moves to the `Idle` state once the animation is done, or if the animation is not specified.
	 */
	LosingToIdle;

	/**
	 * Transition state that triggers when the icon is in the `Idle` state,
	 * and seeks to move to the `Winning` state.
	 * Moves to the `Winning` state once the animation is done, or if the animation is not specified.
	 */
	IdleToWinning;

	/**
	 * Transition state that triggers when the icon is in the `Idle` state,
	 * and seeks to move to the `Losing` state.
	 * Moves to the `Losing` state once the animation is done, or if the animation is not specified.
	 */
	IdleToLosing;
}

class HealthIcon extends FlxSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	public var state(default, null):HealthIconState = None;

	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(?char:String = "bf", ?isPlayer:Bool = false)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;

		isPlayer = isOldIcon = false;

		changeIcon(char);
		scrollFactor.set();

		animation.finishCallback = onAnimFinish;
	}

	public function swapOldIcon()
	{
		(!isOldIcon) ? changeIcon("bf-old") : changeIcon(char);
	}

	public function changeIcon(input:String)
	{
		if (input != 'bf-pixel' && input != 'bf-old')
			input = input.split("-")[0];

		if (GraphicsAssets.isAnimated('characters/icons/icon-$input'))
		{
			// Animated icon.
			loadIcon(input);
		}
		else
		{
			// Legacy icon.
			loadIconLegacy(input);
		}

		// TODO: Un-hardcode this
		if (input.endsWith('-pixel') || input.startsWith('senpai') || input.startsWith('spirit'))
			antialiasing = false
		else
			antialiasing = AntiAliasingOption.get();
	}

	/**
	 * Load an Enigma-style animated icon.
	 */
	function loadIcon(char:String)
	{
		if (!LibraryAssets.imageExists('characters/icons/icon-$char'))
		{
			// Image is missing, fallback to 'face'
			loadIconLegacy('face');
			return;
		}
		frames = GraphicsAssets.loadSparrowAtlas('characters/icons/icon-${char}', null, true);

		animation.addByPrefix("idle", "idle-base", 24, true, isPlayer);
		animation.addByPrefix("winning", "winning-base", 24, true, isPlayer);
		animation.addByPrefix("losing", "losing-base", 24, true, isPlayer);
		// Transition animations don't loop.
		animation.addByPrefix("idle-winning", "idle-winning", 24, false, isPlayer);
		animation.addByPrefix("idle-losing", "idle-losing", 24, false, isPlayer);
		animation.addByPrefix("winning-idle", "winning-idle", 24, false, isPlayer);
		animation.addByPrefix("losing-idle", "losing-idle", 24, false, isPlayer);
		// winning-losing and losing-winning would never happen,
		// you'd have to lose all your health at once.

		playIdle();
	}

	/**
	 * Load a Kade Engine-style icon.
	 */
	function loadIconLegacy(char:String)
	{
		var image = GraphicsAssets.loadImage('characters/icons/icon-${char}');
		if (image == null)
		{
			Debug.logError('Error loading graphic for health icon ${char}');
			return;
		}

		loadGraphic(image, true, 150, 150);

		animation.add("idle", [0], 0, false, isPlayer);
		animation.add("losing", [1], 0, false, isPlayer);

		playIdle();
	}

	/**
	 * The floating point value for the player's maximum health.
	 * In the vanilla game, the starting value is 1.0 and the max is 2.0.
	 */
	static final MAX_HEALTH = 2;

	/**
	 * The percentage at which the player is considered to be winning.
	 */
	static final WINNING_THRESHOLD = 0.8;

	/**
	 * The percentage at which the player is considered to be losing.
	 */
	static final LOSING_THRESHOLD = 0.2;

	/**
	 * Play the appropriate animation based on the character's health.
	 * Call this in the update loop.
	 */
	public function handleHealth(health:Float)
	{
		if (health > WINNING_THRESHOLD * MAX_HEALTH)
		{
			isPlayer ? playWinning() : playLosing();
		}
		else if (health < LOSING_THRESHOLD * MAX_HEALTH)
		{
			isPlayer ? playLosing() : playWinning();
		}
		else
		{
			playIdle();
		}
	}

	public function playIdle()
	{
		switch (state)
		{
			case WinningToIdle:
				return;
			case LosingToIdle:
				return;
			case Idle:
				return;
			case IdleToLosing:
				state = Idle;
				animation.play('idle');
			case IdleToWinning:
				state = Idle;
				animation.play('idle');
			case Winning:
				if (hasAnim('winning-idle'))
				{
					state = WinningToIdle;
					animation.play('winning-idle');
				}
				else
				{
					state = None;
				}
			case Losing:
				if (hasAnim('losing-idle'))
				{
					state = LosingToIdle;
					animation.play('losing-idle');
				}
				else
				{
					state = None;
				}
			case None:
				state = Idle;
				animation.play('idle');
		}
	}

	public function playWinning()
	{
		if ([Idle, WinningToIdle, LosingToIdle, Losing, IdleToLosing].contains(state))
		{
			if (hasAnim('idle-winning'))
			{
				state = IdleToWinning;
				animation.play('idle-winning');
			}
			else
			{
				state = None;
			}
		}
		else if (state == None)
		{
			state = Winning;
			animation.play(hasAnim('winning') ? 'winning' : 'idle');
		}
	}

	public function playLosing()
	{
		if ([Idle, LosingToIdle, Winning, WinningToIdle, IdleToWinning].contains(state))
		{
			if (hasAnim('idle-losing'))
			{
				state = IdleToLosing;
				animation.play('idle-losing');
			}
			else
			{
				state = None;
			}
		}
		else if (state == None)
		{
			state = Losing;
			animation.play(hasAnim('losing') ? 'losing' : 'idle');
		}
	}

	/**
	 * Returns whether this graphic has an animation with the given name.
	 * Will be false if the animation was never defined,
	 * or if `addByPrefix` was called when no frames exist for that animation.
	 * @param name The name to query.
	 * @returns Whether the animation exists.
	 */
	function hasAnim(name:String)
	{
		return animation.getByName(name) != null;
	}

	/**
	 * Called when an animation on this sprite reaches the last frame.
	 * @param name The name of the animation that finished.
	 */
	function onAnimFinish(name:String)
	{
		// Finish the transition and load the proper state.
		state = None;
		switch (name)
		{
			case 'losing-idle':
				playIdle();
			case 'winning-idle':
				playIdle();
			case 'idle-winning':
				playWinning();
			case 'idle-losing':
				playLosing();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
