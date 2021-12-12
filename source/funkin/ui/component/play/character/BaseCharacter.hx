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
	 * You can call your own logic, then return true to prevent the idle animation from playing.
	 * For example, characters like Spooky and Girlfriend override this to dance left and right.
	 */
	private var cbOnPlayIdle:() -> Bool;

	/**
	 * Called when the game attempts to play any animation.
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
	public function playAnimation(animName:String, ?restart:Bool = false):Bool
	{
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

	public function isAnimationFinished():Bool
	{
		throw 'isAnimationFinished has not been implemented! ($characterId:$charType)';
	}

	/**
	 * Manages characters dancing to the beat, or playing their idle animation.
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
