/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * MainMenuItem.hx
 * A component which handles rendering of each item in the main menu.
 */
package funkin.ui.component.menu;

import funkin.behavior.options.Options.AntiAliasingOption;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.ui.component.input.InteractableSprite;
import funkin.ui.state.menu.MainMenuState;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;

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
		this.frames = GraphicsAssets.loadSparrowAtlas('FNF_main_menu_assets');
		this.animation.addByPrefix('idle', '$menuOptionName basic', 24);
		this.animation.addByPrefix('selected', '$menuOptionName white', 24);
		this.animation.play('idle');
		this.ID = id;
		this.screenCenter(X);
		this.scrollFactor.set();
		this.antialiasing = AntiAliasingOption.get();

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
