package funkin.ui.component.play.character;

import flixel.util.FlxColor;
import funkin.data.CharacterData;
import funkin.behavior.mods.IHook;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import funkin.util.assets.Paths;
import openfl.Assets;

using hx.strings.Strings;

@:hscript({
	context: [],
})
class BaseCharacter extends FlxSpriteGroup implements IHook
{
	public final characterId:String = '';
	public final idleOnBeat:Bool = false;
	public final charType:String = '';
	public final barColor:FlxColor;
	public final isPlayer:Bool = false;
	public final isGF:Bool = false;

	public static final DEFAULT_PLAYER_BAR_COLOR:FlxColor = FlxColor.fromString("#66FF33");
	public static final DEFAULT_ENEMY_BAR_COLOR:FlxColor = FlxColor.fromString("#FF0000");

	/**
	 * `mode` determines when the character should animate.
	 */
	public var mode(default, set):CharacterActiveMode = Inactive;

	function set_mode(value:CharacterActiveMode):CharacterActiveMode
	{
		this.mode = value;
		return this.mode;
	}

	public var holdTimer:Float = 0;

	/**
	 * Called when the character is created.
	 * You can use this to initialize and attach additional sprites or attributes to the character.
	 */
	private var cbOnCreate:() -> Void;

	/**
	 * Called when the game attempts to play the idle animation for the character.
	 * You can call your own logic, then return false to prevent the idle animation from playing.
	 * For example, characters like Spooky and Girlfriend override this to dance left and right.
	 */
	private var cbOnPlayIdle:() -> Bool;

	/**
	 * Called when the game attempts to play any animation.
	 * You can call your own logic, then return false to prevent the animation itself from playing.
	 */
	private var cbOnPlayAnimation:(String) -> Bool;

	function buildPathName():String
	{
		return 'play/character/$characterId';
	}

	/**
	 * Mod hook called when the credits sequence starts.
	 */
	@:hscript({
		pathName: buildPathName, // Path name is generated at the time the function is called.
		optional: false,
	})
	function buildCharacterHooks():Void
	{
		// TODO: I might be able to automate this with a macro...
		if (script_variables.get('onCreate') != null)
		{
			Debug.logInfo('Found character hook: onCreate');
			cbOnCreate = script_variables.get('onCreate');
		}
		if (script_variables.get('onPlayIdle') != null)
		{
			Debug.logInfo('Found character hook: onPlayIdle');
			cbOnPlayIdle = script_variables.get('onPlayIdle');
		}
		if (script_variables.get('onPlayAnimation') != null)
		{
			Debug.logInfo('Found character hook: onPlayAnimation');
			cbOnPlayAnimation = script_variables.get('onPlayAnimation');
		}
		Debug.logTrace('Character script hooks retrieved.');
	}

	public function new(charData:CharacterData)
	{
		super(0, 0, 0);

		this.charType = charData.atlasType;
		this.barColor = FlxColor.fromString(charData.barColor);
		this.characterId = charData.id;
		this.isPlayer = charData.isPlayer;
		this.isGF = charData.isGF;

		buildCharacterHooks();

		if (cbOnCreate != null)
		{
			cbOnCreate();
		}
	}

	/**
	 * Tells the character to play the current animation.
	 * Must be implemented by each subclass.
	 * @param animName The animation to play.
	 * @param restart If true, the animation will forcibly restart even if it's already playing.
	 * @return Whether the animation was played.
	 */
	public function playAnimation(animName:String, ?restart:Bool = false):Void
	{
		// When implementing, remember to add the cancellable cbOnPlayAnimation!
		throw 'playAnimation has not been implemented! ($characterId:$charType:$animName)';
	}

	/**
	 * Returns true if the given character supports playing the animation with the given name.
	 * @param animName The animation to play.
	 * @return Whether the animation is supported.
	 */
	public function hasAnimation(animName:String):Bool
	{
		throw 'hasAnimation has not been implemented! ($characterId:$charType:$animName)';
	}

	/**
	 * Retrieves the name of the current animation being played by the character.
	 * @return The name of the current animation.
	 */
	public function getAnimation():String
	{
		throw 'getAnimation has not been implemented! ($characterId:$charType)';
	}

	/**
	 * Gets the current frame number of the character's current animation.
	 */
	public function getAnimationFrame():Int
	{
		throw 'getAnimationFrame has not been implemented! ($characterId:$charType)';
	}

	/**
	 * Returns true if the current animation is finished playing.
	 */
	public function isAnimationFinished():Bool
	{
		throw 'isAnimationFinished has not been implemented! ($characterId:$charType)';
	}

	/**
	 * Sets the amount that the character moves relative to the camera.
	 * @param x Scroll factor in the x direction.
	 * @param y Scroll factor in the y direction.
	 */
	public function setScrollFactor(x:Float = 1, y:Float = 1):Void
	{
		throw 'setScrollFactor has not been implemented! ($characterId:$charType)';
	}

	/**
	 * Sets the visiblity of this character.
	 * @param visible Whether the character should be visible.
	 */
	public function setVisible(visible:Bool):Void
	{
		throw 'setVisible has not been implemented! ($characterId:$charType)';
	}

	/**
	 * Retrieves a list of all the animations which this character supports playing.
	 * @return A list of animation names.
	 */
	public function getAnimations():Array<String>
	{
		throw 'getAnimations has not been implemented! ($characterId:$charType)';
	}

	/**
	 * Gets the X and Y offsets of the character for the specified animation.
	 * Offsets should normally be only handled internally; this function should only be used by the Animation Debugger.
	 */
	public function getAnimationOffsets(name:String):Array<Int>
	{
		throw 'getAnimationOffsets has not been implemented! ($characterId:$charType:$name)';
	}

	/**
	 * Sets the X and Y offsets of the character for the specified animation.
	 * Offsets should normally be only handled internally; this function should only be used by the Animation Debugger.
	 */
	public function setAnimationOffsets(name:String, value:Array<Int>):Void
	{
		throw 'setAnimationOffsets has not been implemented! ($characterId:$charType:$name)';
	}

	/**
	 * Returns true if the current character is valid.
	 * @return Bool
	 */
	public function isValid():Bool
	{
		Debug.logError('isValid has not been implemented! ($characterId:$charType)');
		return false;
	}

	/**
	 * Call this to have the character play their idle animation.
	 * For example, on GF and the Spooky Kids, this plays the dance animation,
	 * and on Boyfriend, it plays the idle animation.
	 */
	public function onPlayIdle():Void
	{
		if (cbOnPlayIdle != null)
		{
			// If cbOnPlayIdle returns false, cancel the default idle animation handling.
			if (!cbOnPlayIdle())
				return;
		}

		playAnimation('idle');
	}

	/**
	 * Called by the game engine loop every frame.
	 * @param elapsedTime The time elapsed since the last frame.
	 */
	override function update(elapsed:Float):Void
	{
		if (getAnimation() == null)
		{
			Debug.logWarn('getAnimation returned null! Is your character metadata complete?');
			return;
		}

		if (getAnimation().startsWith('sing'))
		{
			holdTimer += elapsed;
		}
		else
		{
			holdTimer = 0;
		}

		if (getAnimation() == 'firstDeath' && isAnimationFinished())
		{
			playAnimation('deathLoop');
		}

		if (getAnimation().endsWith('miss') && isAnimationFinished())
		{
			onPlayIdle();
		}

		super.update(elapsed);
	}

	public override function toString():String
	{
		return 'Character[${characterId}][$charType]';
	}
}

/**
 * Represents the character's current state.
 * 
 */
enum CharacterActiveMode
{
	/**
	 * In the Inactive state, the character will only play their idle animation.
	 * If you want custom behavior, set the character to this state, then play animations manually.
	 */
	Inactive;

	/**
	 * In the Player state, the character will play the appropriate sing and miss animations for the player's strumline.
	 */
	Player;

	/**
	 * In the CPU state, the character will play the appropriate sing and miss animations for the CPU's strumline.
	 */
	Cpu;

	/**
	 * In the Girlfriend state, the character will idle to the beat of the song, and play the HEY! animation when triggered.
	 */
	Girlfriend;

	/**
	 * In this non-standard state, the character will play the appropriate sing and miss animations for both strumlines.
	 */
	Both;
}
