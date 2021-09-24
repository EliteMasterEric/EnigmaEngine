package funkin.ui.state.title;

import funkin.ui.state.menu.MainMenuState;
import funkin.util.FunneUtil;
import funkin.const.Enigma;
import funkin.assets.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "IDFK LOL";
	public static var currChanges:String = "dk";

	private var bgColors:Array<String> = ['#314d7f', '#4e7093', '#70526e', '#594465'];
	private var colorRotation:Int = 1;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage('week54prototype', 'shared'));
		bg.scale.x *= 1.55;
		bg.scale.y *= 1.55;
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		var gameLogo:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.loadImage('logo'));
		gameLogo.scale.y = 0.3;
		gameLogo.scale.x = 0.3;
		gameLogo.x -= gameLogo.frameHeight;
		gameLogo.y -= 180;
		gameLogo.alpha = 0.8;
		gameLogo.antialiasing = FlxG.save.data.antialiasing;
		add(gameLogo);

		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"Your Enigma Engine is outdated!\nYou are on "
			+ Enigma.ENGINE_VERSION
			+ "\nwhile the most recent version is "
			+ needVer
			+ "."
			+ "\n\nWhat's new:\n\n"
			+ currChanges
			+ "\n& more changes and bugfixes in the full changelog"
			+ "\n\nPress Space to view the full changelog and update\nor ESCAPE to ignore this",
			32);

		if (Enigma.ENGINE_SUFFIX != "")
			txt.text = "You are on\n"
				+ Enigma.ENGINE_VERSION
				+ '\nWhich is a DEVELOPMENT BUILD (${Enigma.ENGINE_SUFFIX})!'
				+ "\n\nReport all bugs to the author of the build.\nSpace/Escape ignores this.";

		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);

		FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
		FlxTween.angle(gameLogo, gameLogo.angle, -10, 2, {ease: FlxEase.quartInOut});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
			if (colorRotation < (bgColors.length - 1))
				colorRotation++;
			else
				colorRotation = 0;
		}, 0);

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if (gameLogo.angle == -10)
				FlxTween.angle(gameLogo, gameLogo.angle, 10, 2, {ease: FlxEase.quartInOut});
			else
				FlxTween.angle(gameLogo, gameLogo.angle, -10, 2, {ease: FlxEase.quartInOut});
		}, 0);

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			if (gameLogo.alpha == 0.8)
				FlxTween.tween(gameLogo, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
			else
				FlxTween.tween(gameLogo, {alpha: 0.8}, 0.8, {ease: FlxEase.quartInOut});
		}, 0);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && Enigma.ENGINE_SUFFIX == "")
		{
			FunneUtil.openURL('https://github.com/EnigmaEngine/EnigmaEngine/blob/stable/docs/changelogs/changelog-${needVer}.md');
		}
		else if (controls.ACCEPT)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
