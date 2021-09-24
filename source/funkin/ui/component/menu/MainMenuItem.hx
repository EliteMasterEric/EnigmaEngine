package funkin.ui.component.menu;

import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import funkin.ui.state.menu.MainMenuState;
import flixel.FlxSprite;
import funkin.assets.Paths;

class MainMenuItem
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
			var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', menuOptionName + ' basic', 24);
			menuItem.animation.addByPrefix('selected', menuOptionName + ' white', 24);
			menuItem.animation.play('idle');
			menuItem.ID = id;
			menuItem.screenCenter(X);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = FlxG.save.data.antialiasing;
			if (MainMenuState.firstStart)
			{
				FlxTween.tween(menuItem, {y: 60 + (id * 160)}, 1 + (id * 0.25), {
					ease: FlxEase.expoInOut,
					onComplete: onFinishFirstStart
				});
			}
			else
			{
				menuItem.y = 60 + (id * 160);
			}

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
