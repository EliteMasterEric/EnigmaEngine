import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
#if desktop
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState {
  var curSelected:Int = 0;

  var menuItems:FlxTypedGroup<FlxSprite>;

  var newGaming:FlxText;
  var newGaming2:FlxText;

  public static var firstStart:Bool = true;

  public static var nightly:String = " (ENIGMA)";

  public static var kadeEngineVer:String = "1.7" + nightly;
  public static var gameVer:String = "0.2.7.1";

  var magenta:FlxSprite;
  var camFollow:FlxObject;

  public static var finishedFunnyMove:Bool = false;

  override function create() {
    clean();
    #if desktop
    // Updating Discord Rich Presence
    DiscordClient.changePresence("In the Menus", null);
    #end

    CustomMainMenu.playMenuMusic();

    persistentUpdate = persistentDraw = true;

    var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
    bg.scrollFactor.x = 0;
    bg.scrollFactor.y = 0.10;
    bg.setGraphicSize(Std.int(bg.width * 1.1));
    bg.updateHitbox();
    bg.screenCenter();
    bg.antialiasing = FlxG.save.data.antialiasing;
    add(bg);

    camFollow = new FlxObject(0, 0, 1, 1);
    add(camFollow);

    magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
    magenta.scrollFactor.x = 0;
    magenta.scrollFactor.y = 0.10;
    magenta.setGraphicSize(Std.int(magenta.width * 1.1));
    magenta.updateHitbox();
    magenta.screenCenter();
    magenta.visible = false;
    magenta.antialiasing = FlxG.save.data.antialiasing;
    magenta.color = 0xFFfd719b;
    add(magenta);
    // magenta.scrollFactor.set();

    menuItems = new FlxTypedGroup<FlxSprite>();
    add(menuItems);

    CustomMainMenu.buildMainMenu(menuItems, function(flxTween:FlxTween) {
      MainMenuState.finishedFunnyMove = true;
      changeItem();
    });

    firstStart = false;

    FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

    var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer + (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : ""), 12);
    versionShit.scrollFactor.set();
    versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(versionShit);

    // NG.core.calls.event.logEvent('swag').send();

    if (FlxG.save.data.dfjk)
      controls.setKeyboardScheme(KeyboardScheme.Solo, true);
    else
      controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

    changeItem();

    super.create();
  }

  var selectedSomethin:Bool = false;

  override function update(elapsed:Float) {
    if (FlxG.sound.music.volume < 0.8) {
      FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
    }

    if (!selectedSomethin) {
      var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

      if (gamepad != null) {
        if (gamepad.justPressed.DPAD_UP) {
          FlxG.sound.play(Paths.sound('scrollMenu'));
          changeItem(-1);
        }
        if (gamepad.justPressed.DPAD_DOWN) {
          FlxG.sound.play(Paths.sound('scrollMenu'));
          changeItem(1);
        }
      }

      if (FlxG.keys.justPressed.UP) {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        changeItem(-1);
      }

      if (FlxG.keys.justPressed.DOWN) {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        changeItem(1);
      }

      if (controls.BACK) {
        FlxG.switchState(new TitleState());
      }

      if (controls.ACCEPT) {
        if (CustomMainMenu.shouldMainMenuItemBlink(curSelected)){
          selectedSomethin = true;

          FlxG.sound.play(Paths.sound('confirmMenu'));

          if (FlxG.save.data.flashing)
            FlxFlicker.flicker(magenta, 1.1, 0.15, false);

          menuItems.forEach(function(spr:FlxSprite) {
            if (curSelected != spr.ID) {
              FlxTween.tween(spr, {alpha: 0}, 1.3, {
                ease: FlxEase.quadOut,
                onComplete: function(twn:FlxTween) {
                  spr.kill();
                }
              });
            } else {
              if (FlxG.save.data.flashing) {
                FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
                  CustomMainMenu.onSelectMainMenuItem(curSelected);
                  selectedSomethin = false;
                });
              } else {
                new FlxTimer().start(1, function(tmr:FlxTimer) {
                  CustomMainMenu.onSelectMainMenuItem(curSelected);
                  selectedSomethin = false;
                });
              }
            }
          });
        } else {
          // Do the thing immediately.
          selectedSomethin = true;
          CustomMainMenu.onSelectMainMenuItem(curSelected);
          selectedSomethin = false;
        }
      }
    }

    super.update(elapsed);

    menuItems.forEach(function(spr:FlxSprite) {
      spr.screenCenter(X);
    });
  }

  function changeItem(huh:Int = 0) {
    if (finishedFunnyMove) {
      curSelected += huh;

      if (curSelected >= menuItems.length)
        curSelected = 0;
      if (curSelected < 0)
        curSelected = menuItems.length - 1;
    }
    menuItems.forEach(function(spr:FlxSprite) {
      spr.animation.play('idle');

      if (spr.ID == curSelected && finishedFunnyMove) {
        spr.animation.play('selected');
        camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
      }

      spr.updateHitbox();
    });
  }
}
