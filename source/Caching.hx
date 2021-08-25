import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText;
#if sys
import openfl.display.BitmapData;
import openfl.utils.Assets;
import flixel.ui.FlxBar;
#if cpp
import sys.FileSystem;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;

using StringTools;

class Caching extends MusicBeatState {
  var imagesDone = 0;
  var musicDone = 0;
  var totalDone = 0;
  var imagesToBeDone = 0;
  var musicToBeDone = 0;
  var totalToBeDone = 0;

  var loaded = false;

  var text:FlxText;
  var kadeLogo:FlxSprite;

  public static var bitmapData:Map<String, FlxGraphic>;

  var images = [];
  var music = [];
  var charts = [];

  override function create() {
    trace ('Loading player settings and save data...');
    FlxG.save.bind('funkin', 'ninjamuffin99');
    PlayerSettings.init();
    KadeEngineData.initSave();

    FlxG.mouse.visible = false;
    FlxG.worldBounds.set(0, 0);
    bitmapData = new Map<String, FlxGraphic>();

    trace('Building loading screen...');
    text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300, 0, 'Loading...');
    text.size = 34;
    text.alignment = FlxTextAlign.CENTER;
    // ERIC: Fading in the text was kind of annoying.
    text.alpha = 1;

    kadeLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('KadeEngineLogo'));
    // Move based on the image size so it stays centered.
    kadeLogo.x -= kadeLogo.width / 2;
    kadeLogo.y -= kadeLogo.height / 2 + 100;
    kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));
    kadeLogo.antialiasing = (FlxG.save.data.antialiasing != null) ? FlxG.save.data.antialiasing : true;
    // ERIC: Fading in the logo is cool though..
    kadeLogo.alpha = 0;
    // Move text so it's under the logo.
    text.y -= kadeLogo.height / 2 - 125;
    text.x -= 170;

    kadeLogo.alpha = 0;

    // If the user enabled caching character images,
    // cache all other images as well, once they've loaded.
    FlxGraphic.defaultPersist = FlxG.save.data.cacheImages;

    #if cpp
    if (FlxG.save.data.cacheImages) {
      trace('Queuing images to cache...');
      for (i in FileSystem.readDirectory(FileSystem.absolutePath('assets/shared/images/characters'))) {
        if (!i.endsWith('.png'))
          continue;
        images.push(i);
      }
    }

    trace('Queuing music to cache...');
    for (i in FileSystem.readDirectory(FileSystem.absolutePath('assets/songs'))) {
      music.push(i);
    }
    #end

    imagesToBeDone = Lambda.count(images);
    musicToBeDone = Lambda.count(music);
    totalToBeDone = imagesToBeDone + musicToBeDone;

    // Bar based on the "done" variable, with a min of 0 and a max of totalToBeDone.
    var bar = new FlxBar(10, FlxG.height - 50, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 40, null,
      'totalDone', 0, totalToBeDone);
    bar.color = FlxColor.PURPLE;

    add(bar);

    add(kadeLogo);
    add(text);

    trace('Begin caching assets...');

    #if cpp
    // update thread

    sys.thread.Thread.create(() -> {
      while (!loaded) {
        if (totalToBeDone != 0 && totalDone != totalToBeDone) {
          var alpha = HelperFunctions.truncateFloat(totalDone / totalToBeDone * 100, 2) / 100;
          kadeLogo.alpha = alpha;
          text.alpha = alpha;
          text.text = 'Loading... (' + totalDone + '/' + totalToBeDone + ')';
          // text.text += "\nTestingTestingTestingTestingTesting";
        }
      }
    });

    // cache thread

    sys.thread.Thread.create(() -> {
      cache();
    });
    #end

    super.create();
  }

  var calledDone = false;

  override function update(elapsed) {
    super.update(elapsed);
  }

  function cache() {
    #if !linux
    trace('Caching ' + totalToBeDone + ' total assets.');

    for (i in images) {
      // Get the file name.
      var replaced = i.replace('.png', '');
      // Load the bitmap data into a graphic.
      var data:BitmapData = BitmapData.fromFile('assets/shared/images/characters/${i}');
      trace('id ${replaced} file - assets/shared/images/characters/${i} ${data.width}');
      var graph = FlxGraphic.fromBitmapData(data);
      graph.persist = true;
      graph.destroyOnNoUse = false;
      bitmapData.set(replaced, graph);
      
      // Report back progress.
      imagesDone++;
      totalDone++;
    }

    for (i in music) {
      trace('Caching song audio ${i}');

      FlxG.sound.cache(Paths.inst(i));
      FlxG.sound.cache(Paths.voices(i));
      
      musicDone++;
      totalDone++;
    }

    trace('Finished caching.');

    // The game has loaded!
    loaded = true;

    trace('DEBUG: Did GF graphics load successfully? ${Assets.cache.hasBitmapData('GF_assets')}');
    #end
    FlxG.switchState(new TitleState());
  }
}
#end
