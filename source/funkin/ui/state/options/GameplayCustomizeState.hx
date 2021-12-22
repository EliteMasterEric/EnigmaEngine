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
 * GameplayCustomizeState.hx
 * A state available from the options menu that allows the player to customize gameplay layout.
 * Currently manages the following:
 * - Judgement position
 * - Zoom level
 */
package funkin.ui.state.options;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.EnigmaNote;
import funkin.behavior.play.Scoring;
import funkin.const.Enigma;
import funkin.behavior.options.Options;
import funkin.ui.component.Cursor;
import funkin.ui.component.play.character.BaseCharacter;
import funkin.ui.component.play.character.CharacterFactory;
import funkin.ui.component.play.Note;
import funkin.util.assets.GraphicsAssets;
import funkin.util.assets.Paths;
#if FEATURE_DISCORD
import funkin.behavior.api.Discord.DiscordClient;
#end
import openfl.ui.Keyboard;

class GameplayCustomizeState extends MusicBeatState
{
	var defaultX:Float = FlxG.width * 0.55 - Scoring.TIMING_WINDOWS[1];
	var defaultY:Float = FlxG.height / 2 - 50;

	var background:FlxSprite;
	var curt:FlxSprite;
	var front:FlxSprite;

	var sick:FlxSprite;

	var text:FlxText;
	var blackBorder:FlxSprite;

	var bf:BaseCharacter;
	var dad:BaseCharacter;
	var gf:BaseCharacter;

	var strumLine:FlxSprite;
	var strumLineNotes:FlxTypedGroup<FlxSprite>;
	var playerStrums:FlxTypedGroup<FlxSprite>;
	private var camHUD:FlxCamera;

	public override function create()
	{
		#if FEATURE_DISCORD
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Customizing Gameplay Modules", null);
		#end

		sick = new FlxSprite().loadGraphic(GraphicsAssets.loadImage('sick', 'shared'));
		sick.antialiasing = AntiAliasingOption.get();
		sick.scrollFactor.set();
		background = new FlxSprite(-1000, -200).loadGraphic(GraphicsAssets.loadImage('stages/stage/stageback', 'shared'));
		curt = new FlxSprite(-500, -300).loadGraphic(GraphicsAssets.loadImage('stages/stage/stagecurtains', 'shared'));
		front = new FlxSprite(-650, 600).loadGraphic(GraphicsAssets.loadImage('stages/stage/stagefront', 'shared'));
		background.antialiasing = AntiAliasingOption.get();
		curt.antialiasing = AntiAliasingOption.get();
		front.antialiasing = AntiAliasingOption.get();

		persistentUpdate = true;

		super.create();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD);

		camHUD.zoom = FlxG.save.data.zoom;

		background.scrollFactor.set(0.9, 0.9);
		curt.scrollFactor.set(0.9, 0.9);
		front.scrollFactor.set(0.9, 0.9);

		add(background);
		add(front);
		add(curt);

		var camFollow = new FlxObject(0, 0, 1, 1);

		dad = CharacterFactory.buildCharacter('dad');
		dad.x = 100;
		dad.y = 100;

		bf = CharacterFactory.buildCharacter('bf');
		bf.x = 770;
		bf.y = 450;

		gf = CharacterFactory.buildCharacter('gf');
		gf.x = 400;
		gf.y = 130;
		gf.scrollFactor.set(0.95, 0.95);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + 400, dad.getGraphicMidpoint().y);

		camFollow.setPosition(camPos.x, camPos.y);

		add(gf);
		add(bf);
		add(dad);

		add(sick);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		FlxG.camera.zoom = 0.9;
		FlxG.camera.focusOn(camFollow.getPosition());

		strumLine = new FlxSprite(0, FlxG.save.data.strumline).makeGraphic(FlxG.width, 14);
		strumLine.scrollFactor.set();
		strumLine.alpha = 0.4;

		add(strumLine);

		if (DownscrollOption.get())
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		sick.cameras = [camHUD];
		strumLine.cameras = [camHUD];
		playerStrums.cameras = [camHUD];

		generateStrumlineArrows(true);
		generateStrumlineArrows(false);

		text = new FlxText(5, FlxG.height + 40, 0,
			"Click and drag around gameplay elements to customize their positions. Press R to reset. Q/E to change zoom. Press Escape to go back.", 12);
		text.scrollFactor.set();
		text.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height + 40).makeGraphic((Std.int(text.width + 900)), Std.int(text.height + 600), FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		background.cameras = [camHUD];
		text.cameras = [camHUD];

		text.scrollFactor.set();
		background.scrollFactor.set();

		add(blackBorder);

		add(text);

		FlxTween.tween(text, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});

		if (JudgementPositionOption.get() == null)
		{
			JudgementPositionOption.set(new FlxPoint(defaultX, defaultY));
		}

		sick.x = JudgementPositionOption.get().x;
		sick.y = JudgementPositionOption.get().y;

		Cursor.showCursor();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		if (ZoomLevelOption.get() < 0.8)
			ZoomLevelOption.set(0.8);

		if (ZoomLevelOption.get() > 1.2)
			ZoomLevelOption.set(1.2);

		FlxG.camera.zoom = FlxMath.lerp(0.9, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(ZoomLevelOption.get(), camHUD.zoom, 0.95);

		// Pressed mouse to drag the judgement position
		if (FlxG.mouse.overlaps(sick) && FlxG.mouse.pressed)
		{
			sick.x = (FlxG.mouse.x - sick.width / 2) - 60;
			sick.y = (FlxG.mouse.y - sick.height) - 60;
		}

		for (i in playerStrums)
			i.y = strumLine.y;

		for (i in strumLineNotes)
			i.y = strumLine.y;

		// Pressed Q to zoom in.
		if (FlxG.keys.justPressed.Q)
		{
			ZoomLevelOption.set(ZoomLevelOption.get() + 0.02);
			camHUD.zoom = ZoomLevelOption.get();
		}

		// Pressed E to zoom out.
		if (FlxG.keys.justPressed.E)
		{
			ZoomLevelOption.set(ZoomLevelOption.get() - 0.02);
			camHUD.zoom = ZoomLevelOption.get();
		}

		// Stopped dragging.
		if (FlxG.mouse.overlaps(sick) && FlxG.mouse.justReleased)
		{
			JudgementPositionOption.set(new FlxPoint(sick.x, sick.y));
		}

		// Pressed R to reset.
		if (FlxG.keys.justPressed.R)
		{
			sick.x = defaultX;
			sick.y = defaultY;
			ZoomLevelOption.set(1);
			camHUD.zoom = ZoomLevelOption.get();
			JudgementPositionOption.set(new FlxPoint(sick.x, sick.y));
		}

		if (controls.BACK)
		{
			Cursor.showCursor(false);
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new OptionsMenu());
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (curBeat % 2 == 0)
		{
			bf.onPlayIdle();
			dad.onPlayIdle();
		}
		else if (dad.characterId == 'spooky' || dad.characterId == 'gf')
			dad.onPlayIdle();

		gf.onPlayIdle();
		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.010;

		trace('beat');
	}

	// ripped from play state cuz im lazy

	private function generateStrumlineArrows(isPlayer):Void
	{
		EnigmaNote.buildStrumlines(isPlayer, strumLine.y, Enigma.USE_CUSTOM_KEYBINDS ? 9 : 4, "normal");
	}
}
