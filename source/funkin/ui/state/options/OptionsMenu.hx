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
 * OptionsMenu.hx
 * The state containing the main options menu.
 */
package funkin.ui.state.options;

import funkin.const.Enigma;
import funkin.util.assets.Paths;
import funkin.ui.state.options.EnigmaKeyBindMenu;
import funkin.ui.state.menu.MainMenuState;
import funkin.util.Util;
import funkin.util.assets.Paths;
import flash.text.TextField;
import flixel.addons.display.FlxGridOverlay;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.util.assets.GraphicsAssets;
import flixel.util.FlxColor;
import funkin.behavior.options.Controls.Control;
import funkin.behavior.options.Options;
import funkin.ui.component.Alphabet;
import openfl.Lib;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Gameplay", [
			new BasicKeybindOption(), Enigma.USE_CUSTOM_KEYBINDS ? new CustomKeybindsOption() : null, new DownscrollOption(), new AntiMashOption(),
			new SafeFramesOption(), #if desktop new FramerateCapOption(), #end new ScrollSpeedOption(), new WIFE3AccuracyOption(), new ResetButtonOption(),
			new InstantRespawnOption(), new CustomizeGameplayMenu()]),
		new OptionCategory("Appearance", [
			new EditorGridOption(), new DistractionsAndEffectsOption(), new FlashingLightsOption(), new CameraZoomOption(), new NoteQuantizationOption(),
			new ShowAccuracyOption(), new SongPositionOption(), new HPBarColorOption(), new NPSDisplayOption(), new RainbowFPSCounterOption(),
			new CPUStrumOption(),
		]),
		new OptionCategory("Misc", [
			new FPSCounterOption(),
			new AntiAliasingOption(),
			new MissSoundsOption(),
			new ScoreScreenOption(),
			new ExtendedScoreInfoOption(),
			new MinimalModeOption(),
			new CharacterPreloadOption(),
			new BotPlayOption()
		]),
		new OptionCategory("Saves and Data", [
			new ReplayMenu(),
			new ResetScoreOption(),
			new ResetWeekProgressOption(),
			new ResetPreferencesOption()
		])
	];

	/**
	 * Whether the Options menu is currently accepting input.
	 		* Set to false if a substate opens.
	 */
	public var acceptInput:Bool = true;

	private var grpControls:FlxTypedGroup<Alphabet>;

	public static var versionText:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;

	override function create()
	{
		clean();
		instance = this;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(GraphicsAssets.loadImage("menuBackground"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = AntiAliasingOption.get();
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].name, true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		versionText = new FlxText(5, FlxG.height
			+ 40, 0,
			"Offset (Left, Right, Shift for slow): "
			+ Util.truncateFloat(FlxG.save.data.offset, 2)
			+ " - Description - NONE", 12);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height + 40).makeGraphic((Std.int(versionText.width + 900)), Std.int(versionText.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		add(blackBorder);

		add(versionText);

		FlxTween.tween(versionText, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

		changeSelection();

		super.create();
	}

	var isInCategory:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (acceptInput)
		{
			if (controls.BACK && !isInCategory)
			{
				FlxG.switchState(new MainMenuState());
			}
			else if (controls.BACK)
			{
				isInCategory = false;
				grpControls.clear();
				for (i in 0...options.length)
				{
					trace('Rendering category ${options[i].name}');
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i].name, true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
				}

				curSelected = 0;

				changeSelection(curSelected);
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeSelection(1);
				}
			}

			// Select a different option.
			if (FlxG.keys.justPressed.UP)
				changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN)
				changeSelection(1);

			// Increment or decrement a value.
			if (FlxG.keys.justPressed.LEFT)
				if (currentSelectedCat.getOptions()[curSelected].onLeft())
					rerenderCurrentOption();
			if (FlxG.keys.justPressed.RIGHT)
				if (currentSelectedCat.getOptions()[curSelected].onRight())
					rerenderCurrentOption();
			if (FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.LEFT)
					if (currentSelectedCat.getOptions()[curSelected].onLeftHold())
						rerenderCurrentOption();
				if (FlxG.keys.pressed.RIGHT)
					if (currentSelectedCat.getOptions()[curSelected].onRightHold())
						rerenderCurrentOption();
			}

			// Kade handled offsets in the controls globally.
			// Whover made it that way was awful at UI design I was so confused for a while.
			// Now they're in their own option.

			if (controls.RESET)
				if (currentSelectedCat.getOptions()[curSelected].onReset())
					rerenderCurrentOption();

			if (controls.ACCEPT)
			{
				if (isInCategory)
				{
					// Press an option.
					if (currentSelectedCat.getOptions()[curSelected].onPress())
						rerenderCurrentOption();
				}
				else
				{
					// Enter a category.
					currentSelectedCat = options[curSelected];
					isInCategory = true;
					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
					{
						trace('Rendering option "${currentSelectedCat.getOptions()[i].name}"');
						var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, currentSelectedCat.getOptions()[i].name, true, false);
						controlLabel.isMenuItem = true;
						controlLabel.targetY = i;
						grpControls.add(controlLabel);
						// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
					}
					curSelected = 0;
				}
				changeSelection();
			}
		}
	}

	function rerenderCurrentOption()
	{
		// Name.
		grpControls.members[curSelected].reType(currentSelectedCat.getOptions()[curSelected].name);
		// Description.
		versionText.text = currentSelectedCat.getOptions()[curSelected].description;
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		if (isInCategory)
			versionText.text = currentSelectedCat.getOptions()[curSelected].description;
		else
			versionText.text = "Please select a category";

		var curControlsMember:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = curControlsMember - curSelected;
			curControlsMember++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
