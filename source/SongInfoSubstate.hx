package;

import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import Song.SongData;
import flixel.FlxSubState;

using StringTools;

class SongInfoSubstate extends MusicBeatSubstate
{
	var chart:SongData;

	var blackBox:FlxSprite;

	var infoText:FlxText;

	public function new(Chart:SongData)
	{
		chart = Chart;
		super();
	}

	override function create()
	{
		super.create();

		persistentUpdate = true;
		blackBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(blackBox);

		// text shit !!

		infoText = new FlxText(50, 50, "swag", 32);

		infoText.text = 'NAME: ${chart.songName.toUpperCase()}\nBPM: ${chart.bpm}\nScroll Speed: ${chart.speed}\nVERSION: ${chart.chartVersion.toUpperCase()}';
		infoText.scrollFactor.set(0, 0);
		infoText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.borderSize = 2;
		infoText.borderQuality = 3;
		add(infoText);

		blackBox.alpha = 0;

		infoText.alpha = 0;
		infoText.y -= 24;

		FlxTween.tween(infoText, {alpha: 1, y: infoText.y + 24}, 1.4, {ease: FlxEase.expoInOut});
		FlxTween.tween(blackBox, {alpha: 0.7}, 1, {ease: FlxEase.expoInOut});

		FreeplayState.instance.acceptInput = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
		{
			FreeplayState.instance.acceptInput = true;

			FlxTween.tween(blackBox, {alpha: 0}, 1.1, {
				ease: FlxEase.expoInOut,
				onComplete: function(flx:FlxTween)
				{
					close();
				}
			});
			FlxTween.tween(infoText, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
		}
	}
}
