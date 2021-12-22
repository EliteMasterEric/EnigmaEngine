package funkin.ui.component.play.stage;

class Stage extends FlxTypedGroup<FlxBasic> implements IHook
{
	public final stageId:String;

	public var characters:Map<Int, Character> = new Map<Int, Character>();

	public static final CHARACTER_BF:Int = 0;
	public static final CHARACTER_DAD:Int = 1;
	public static final CHARACTER_GF:Int = 2;

	private final cbOnCreate:() -> Void;
	private final cbOnBeatHit:(Int) -> Void;
	private final cbOnStepHit:(Int) -> Void;
	private final cbOnUpdate:(Float) -> Void;
	private final cbOnPlayerHitNote:(Note) -> Void;
	private final cbOnCPUHitNote:(Note) -> Void;
	private final cbOnPlayerMissNote:(Note) -> Void;
	private final cbOnCPUMissNote:(Note) -> Void;
	private final cbOnUpdateNote:(Note) -> Void;
	private final cbOnDestroy:() -> Void;

	function buildPathName():String
	{
		return 'play/stage/$stageId';
	}

	/**
	 * Mod hook called when the credits sequence starts.
	 */
	@:hscript({
		pathName: buildPathName, // Path name is generated at the time the function is called.
	})
	function buildStageHooks():Void
	{
		if (script_variables.get('onCreate') != null)
		{
			Debug.logInfo('Found stage hook: onCreate');
			cbOnCreate = script_variables.get('onCreate')
		}
		if (script_variables.get('onBeatHit') != null)
		{
			Debug.logInfo('Found stage hook: onBeatHit');
			cbOnBeatHit = script_variables.get('onBeatHit')
		}
		if (script_variables.get('onStepHit') != null)
		{
			Debug.logInfo('Found stage hook: onStepHit');
			cbOnStepHit = script_variables.get('onStepHit')
		}
		if (script_variables.get('onUpdate') != null)
		{
			Debug.logInfo('Found stage hook: onUpdate');
			cbOnUpdate = script_variables.get('onUpdate')
		}
		if (script_variables.get('onPlayerHitNote') != null)
		{
			Debug.logInfo('Found stage hook: onPlayerHitNote');
			cbOnPlayerHitNote = script_variables.get('onPlayerHitNote')
		}
		if (script_variables.get('onCPUHitNote') != null)
		{
			Debug.logInfo('Found stage hook: onCPUHitNote');
			cbOnCPUHitNote = script_variables.get('onCPUHitNote')
		}
		if (script_variables.get('onPlayerMissNote') != null)
		{
			Debug.logInfo('Found stage hook: onPlayerMissNote');
			cbOnPlayerMissNote = script_variables.get('onPlayerMissNote')
		}
		if (script_variables.get('onCPUMissNote') != null)
		{
			Debug.logInfo('Found stage hook: onCPUMissNote');
			cbOnCPUMissNote = script_variables.get('onCPUMissNote')
		}
		if (script_variables.get('onUpdateNote') != null)
		{
			Debug.logInfo('Found stage hook: onUpdateNote');
			cbOnUpdateNote = script_variables.get('onUpdateNote')
		}
		if (script_variables.get('onDestroy') != null)
		{
			Debug.logInfo('Found stage hook: onDestroy');
			cbOnDestroy = script_variables.get('onDestroy')
		}
		Debug.logTrace('Script hooks retrieved.');
	}

	public function new(stageId:String)
	{
		this.stageId = stageId;
	}

	public function addCharacter(id:Int, charId:String):BaseCharacter
	{
		var character:BaseCharacter = CharacterFactory.buildCharacter(charId);
		characters.set(id, character);
		return character;
	}
}
