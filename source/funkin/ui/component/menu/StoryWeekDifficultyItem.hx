package funkin.ui.component.menu;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.assets.menu.WeekData;
import funkin.assets.Paths;
import funkin.behavior.Debug;
import funkin.ui.component.input.InteractableSprite;
import funkin.ui.state.menu.MainMenuState;

typedef Difficulty =
{
	var id:String;
	var songSuffix:String;
	var graphic:FlxGraphic;
}

class StoryWeekDifficultyItem extends InteractableSprite
{
	public static final defaultDifficulty = "normal";

	public static var difficultyList(default, null):Array<String> = [];
	public static var difficultyData(default, null) = new Map<String, Difficulty>();

	static function initDifficulties():String
	{
		if (Lambda.count(difficultyData) > 0)
			return;

		var difficultyRawList:Array<String> = Util.loadLinesFromFile("data/difficulties.txt");
		for (element in difficultyRawList)
		{
			// Each item is of the format id:songSuffix
			var elementItems = element.split(":");
			var difficultyGraphic = Paths.loadImage('storymenu/difficulty/${elementItems[0]}');
			if (difficultyGraphic != null)
			{
				var difficulty:Difficulty = {
					id: elementItems[0],
					songSuffix: elementItems[1],
					graphic: difficultyGraphic
				}

				difficultyList.push(difficulty.id);
				difficultyData.set(difficulty.id, difficulty);
			}
		}
	}

	public var curDifficultyId(default, set):String = "normal";
	public var curDifficultyData(default, null):Difficulty = {
		id: "normal",
		songSuffix: "",
		graphic: null, // Load this later.
	};

	function set_curDifficultyId(newValue:String)
	{
		if (difficultyData.exists(newValue))
		{
			this.curDifficultyId = newValue;
			this.curDifficultyData = difficultyData.get(this.curDifficultyId);
			loadDifficultyGraphic();
		}
		else
		{
			Debug.logError('Attempted to specify invalid difficulty "${newValue}"');
		}
		return this.curDifficultyId;
	}

	public function changeDifficulty(index:Int)
	{
		var oldIndex = difficultyList.indexOf(index);
		if (oldIndex < 0)
			oldIndex = 0;

		var newIndex = oldIndex + index;
		if (newIndex < 0)
			newIndex = difficultyList.length - 1;
		if (newIndex >= difficultyList.length)
			newIndex = 0;
	}

	public static function getDifficultySuffix(difficultyId:String)
	{
		return difficultyData.get(difficultyId).songSuffix;
	}

	public function new(x:Float, y:Float)
	{
		super(x, y);

		initGraphicsCache();

		loadDifficultyGraphic();
	}

	function loadDifficultyGraphic()
	{
		Debug.logTrace('Loading difficulty graphic for ${currentDifficulty}');
		if (Lambda.count(difficultyList) == 0)
		{
			Debug.logWarn("WARNING: No difficulty graphics loaded.");
			return;
		}
		if (difficultyList.exists(currentDifficulty))
		{
			this.loadGraphic(difficultyList.get(currentDifficulty).graphic);
		}
		else
		{
			this.loadGraphic(difficultyList.get(difficultyList.keys()[0]).graphic);
		}
	}

	override function onJustPressed(pos:FlxPoint)
	{
		trace('Pressed menu difficulty item ${menuOptionName}');
	}

	override function onJustReleased(pos:FlxPoint, pressDuration:Int)
	{
		trace('Released menu item ${menuOptionName}');
	}
}
