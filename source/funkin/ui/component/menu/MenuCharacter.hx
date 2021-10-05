package funkin.ui.component.menu;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import funkin.assets.Paths;

typedef CharacterSetting =
{
	var x:Int;
	var y:Int;
	var scale:Float;
	var ?flipped:Bool;
}

class MenuCharacter extends FlxSprite
{
	private var danceLeft:Bool = false;
	private var charId:String = '';
	private var charSettings:CharacterSetting = null;

	private static var menuCharCache = new Map<String, FlxFramesCollection>();

	var baseX:Float;
	var baseY:Float;

	public function new(baseX, baseY, menuCharId:String)
	{
		super(0, 0);
		this.charId = menuCharId;
		loadCharacterSettings();

		this.baseX = baseX;
		this.baseY = baseY;

		buildCharacter();
	}

	function loadCharacterSettings()
	{
		var jsonData = Paths.loadJSON('storymenu/${this.charId}');
		this.charSettings = cast jsonData;

		// Validation.
		if (this.charSettings != null)
		{
			this.x = this.baseX;
			if (this.charSettings.x != null)
			{
				this.x += this.charSettings.x;
			}

			this.y = baseY;
			if (this.charSettings.y != null)
			{
				this.y += this.charSettings.y;
			}

			if (this.charSettings.flipped != null)
			{
				this.flipX = this.charSettings.flipped;
			}
		}
	}

	function loadCharacterGraphic():FlxFramesCollection
	{
		if (menuCharCache.get(this.charId) == null)
		{
			var frameCollection = Paths.getSparrowAtlas('storymenu/characters/${this.charId}');
			menuCharCache.set(this.charId, frameCollection);
			return frameCollection;
		}
		else
		{
			return menuCharCache.get(frameCollection);
		}
	}

	function buildCharacter()
	{
		// Load character settings.
		frames = loadCharacterGraphic();
		animation.addByPrefix("idle");
		// This will silently fail if the animation is missing.
		animation.addByPrefix("confirm");
		antialiasing = FlxG.save.data.antialiasing;

		setGraphicSize(Std.int(width * scale));
		updateHitbox();
	}

	public function setCharacter(character:String):Void
	{
		var sameCharacter:Bool = character == this.character;
		this.character = character;
		if (character == '')
		{
			visible = false;
			return;
		}
		else
		{
			visible = true;
		}

		if (!sameCharacter)
		{
			loadCharacterSettings();
			buildCharacter();

			playIdle();
		}
	}

	public function playIdle():Void
	{
		if (animation.getByName("idle") != null)
		{
			animation.play("idle", true);
		}
	}

	public function playConfirm():Void
	{
		if (animation.getByName("confirm") != null)
		{
			animation.play("confirm", false);
		}
	}
}
