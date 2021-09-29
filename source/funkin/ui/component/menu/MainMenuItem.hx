package funkin.ui.component.menu;

import flixel.math.FlxPoint;
import funkin.behavior.input.InteractableSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import funkin.ui.state.menu.MainMenuState;
import flixel.FlxSprite;
import funkin.assets.Paths;

class MainMenuItemBuilder
{
	/**
	 * A list of menu options whose graphics are available in the vanilla graphic.
	 */
	static final VANILLA_MAIN_MENU_ITEM_NAMES:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];

	public static function buildMainMenu(menuItemGroup:FlxTypedGroup<FlxSprite>, onFinishFirstStart:TweenCallback)
	{
		var mainMenuItems = ['story mode', 'freeplay', 'options'];
		for (i in 0...mainMenuItems.length)
		{
			var sprite = buildMainMenuItem(mainMenuItems[i], i, onFinishFirstStart);

			menuItemGroup.add(sprite);
		}
	}

	public static function buildMainMenuItem(menuOptionName:String, id:Int, onFinishFirstStart:TweenCallback):FlxSprite
	{
		if (VANILLA_MAIN_MENU_ITEM_NAMES.contains(menuOptionName))
		{
			// The base game's main menu rendering code.
			var menuItem:MainMenuItem = new MainMenuItem(0, FlxG.height * 1.6, id, menuOptionName, onFinishFirstStart);

			return menuItem;
		}
		else
		{
			// Here we use text  to approximate the menu option.
			// If you have a cleaner graphic, you can use logic to add that in here.

			// Did you know this counts as an FlxSprite?
			var menuItem:Alphabet = new Alphabet(0, 10, menuOptionName);
			menuItem.screenCenter(X);
			menuItem.y = 60 + (id * 160);

			menuItem.ID = id;

			return menuItem;
		}
	}
}

class MainMenuItem extends InteractableSprite
{
	public var menuOptionName(default, null):String;
	public var id(default, null):Int;

	public function new(x:Float, y:Float, id:Int, menuOptionName:String, onFinishFirstStart:TweenCallback)
	{
		super(x, y);
		this.frames = Paths.getSparrowAtlas('FNF_main_menu_assets');
		this.animation.addByPrefix('idle', '$menuOptionName basic', 24);
		this.animation.addByPrefix('selected', '$menuOptionName white', 24);
		this.animation.play('idle');
		this.ID = id;
		this.screenCenter(X);
		this.scrollFactor.set();
		this.antialiasing = FlxG.save.data.antialiasing;

		// Ease the menu option in from the top on first start.
		if (MainMenuState.firstStart)
		{
			FlxTween.tween(this, {y: 60 + (id * 160)}, 1 + (id * 0.25), {
				ease: FlxEase.expoInOut,
				onComplete: onFinishFirstStart
			});
		}
		else
		{
			// Otherwise start at the correct position.
			this.y = 60 + (id * 160);
		}
	}

	override function onJustPressed(pos:FlxPoint)
	{
		trace('Pressed menu item ${menuOptionName}');
	}

	override function onJustReleased(pos:FlxPoint, pressDuration:Int)
	{
		trace('Released menu item ${menuOptionName}');
	}
}
