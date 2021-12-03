package funkin.ui.component.play.character;

import funkin.behavior.mods.IHook;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import funkin.util.assets.Paths;
import openfl.Assets;

@:hscript({
	context: [],
})
class BaseCharacter extends FlxSpriteGroup implements IHook
{
	public final characterId:String = '';
	public final idleOnBeat:Bool = false;
	public final charType:String = '';

	/**
	 * `mode` determines when the character should animate.
	 */
	public var mode(default, set):CharacterActiveMode = Inactive;

	function set_mode(value:CharacterActiveMode):CharacterActiveMode
	{
		this.mode = value;
		return this.mode;
	}

	public var stunned:Bool = false;
	public var holdTimer:Float = 0;

	private var cbOnCreate:() -> Void;
	private var cbOnPlayAnimation:(String) -> Void;

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
			Debug.logInfo('Found stage hook: onCreate');
			cbOnCreate = script_variables.get('onCreate');
		}
		if (script_variables.get('onPlayAnimation') != null)
		{
			Debug.logInfo('Found stage hook: onPlayAnimation');
			cbOnPlayAnimation = script_variables.get('onPlayAnimation');
		}
		Debug.logTrace('Character script hooks retrieved.');
	}

	public function new(charType:String)
	{
		super(0, 0, 0);

		this.charType = charType;

		buildCharacterHooks();
	}

	function playAnimation(animName:String)
	{
		if (cbOnPlayAnimation != null)
		{
			cbOnPlayAnimation(animName);
		}

		throw 'playAnimation has not been implemented! ($characterId:$animName)';
	}

	public override function toString():String
	{
		return 'Character[${characterId}][Base]';
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
	BothStrumlines;
}
