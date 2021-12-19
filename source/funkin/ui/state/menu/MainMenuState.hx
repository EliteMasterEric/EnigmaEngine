/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * MainMenuState.hx
 * The main menu state, after the title screen,
 * which allows the user to navigate to the Options, Free Play, or Story menus.
 */
package funkin.ui.state.menu;

import funkin.ui.component.Alphabet;
import flixel.effects.FlxFlicker;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.text.FlxText;
import funkin.util.assets.AudioAssets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.behavior.mods.IHook;
import funkin.behavior.options.Controls.KeyboardScheme;
import funkin.behavior.options.Options;
import funkin.const.Enigma;
import funkin.behavior.play.Conductor;
import funkin.ui.component.menu.MainMenuItem;
import funkin.ui.state.options.OptionsMenu;
import funkin.ui.state.title.TitleState;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;
import lime.app.Application;
import openfl.Assets;
#if FEATURE_DISCORD
import funkin.behavior.api.Discord.DiscordClient;
#end

using hx.strings.Strings;

@hscript({
	context: ['addToState', 'currentMenuOption']
})
class MainMenuState extends MusicBeatState implements IHook
{
	var menuItems:FlxTypedGroup<FlxSprite>;

	var mainMenuOptions:Array<String> = ['story mode', 'freeplay', 'options'];

	var newGaming:FlxText;
	var newGaming2:FlxText;

	public static var firstStart:Bool = true;

	var yellow:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	public static var finishedFunnyMove:Bool = false;

	// There's only ever one MainMenuState at a time, so we can make this static.
	static var curSelected:Int = 0;

	// Callbacks provided by hscript.
	var cbOnCreate:Void->Void = function() return;
	var cbOnExit:Void->Void = function() return;

	/**
	 * Mod hook called when the credits sequence starts.
	 */
	@:hscript({
		pathName: "menu/TitleScreen",
	})
	public function buildTitleScreenHooks():Void
	{
		if (script_variables.get('onCreate') != null)
		{
			Debug.logTrace('Found hook: onCreate');
			cbOnCreate = script_variables.get('onCreate');
		}
		if (script_variables.get('onExit') != null)
		{
			Debug.logTrace('Found hook: onExit');
			cbOnExit = script_variables.get('onExit');
		}
		Debug.logTrace('Title screen hooks retrieved.');
	}

	function addToState(obj:FlxBasic)
	{
		this.add(obj);
	}

	override function create()
	{
		clean();

		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		AudioAssets.playMusic(Paths.music('freakyMenu'), true, false, 1);
		Conductor.changeBPM(102);

		// Load the player's keybinds.
		controls.loadKeyBinds();

		persistentUpdate = persistentDraw = true;

		yellow = new FlxSprite(-100).loadGraphic(GraphicsAssets.loadImage('menuBackground'));
		yellow.scrollFactor.x = 0;
		yellow.scrollFactor.y = 0.10;
		yellow.setGraphicSize(Std.int(yellow.width * 1.1));
		yellow.updateHitbox();
		yellow.screenCenter();
		yellow.visible = true;
		yellow.antialiasing = AntiAliasingOption.get();
		yellow.color = 0xFFfde871;
		add(yellow);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(GraphicsAssets.loadImage('menuBackground'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = AntiAliasingOption.get();
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		MainMenuItemBuilder.buildMainMenu(menuItems, finishFunnyMove);

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FramerateCapOption.get()));

		var versionText:FlxText = new FlxText(5, FlxG.height - 18, 0, 'FNF - ${Enigma.ENGINE_NAME} ${Enigma.ENGINE_VERSION}', 12);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionText);

		changeItem(0);

		cbOnCreate();

		super.create();

		Debug.logTrace('Finished building main menu state.');
	}

	public function finishFunnyMove(flxTween:FlxTween)
	{
		MainMenuState.finishedFunnyMove = true;
		changeItem(0);
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			#if FEATURE_GAMEPAD
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
			}
			#end

			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				if (FlashingLightsOption.get())
					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 1.3, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						if (FlashingLightsOption.get())
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								goToState();
							});
						}
						else
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								goToState();
							});
						}
					}
				});
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function goToState()
	{
		var currentMenuOption:String = mainMenuOptions[curSelected];

		cbOnExit();

		switch (currentMenuOption)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());

				trace("Freeplay Menu Selected");

			case 'options':
				FlxG.switchState(new OptionsMenu());
		}
	}

	public function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.animation.curAnim.frameRate = 24 * (60 / FramerateCapOption.get());

			spr.updateHitbox();
		});
	}
}
