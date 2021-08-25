/**
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
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * A static class created to handle custom options in the main menu.
 * 
 * This class assumes you are augmenting the main menu,
 * I haven't written anything to fully revamp the main menu as of yet
 * (like Sonic.exe or Tricky).
 */
class CustomMainMenu {
  /**
   * Private constructor, to prevent unintentional initialization.
   */
  private function new() {}

  // Imagine having a variable named shit.

  /**
   * The main menu items that this main menu uses, in order.
   */
  static final MAIN_MENU_ITEMS: Array<String> = ['story mode', 'freeplay', /*'sonic',*/ 'options'];
  static final MAIN_MENU_ITEM_BLINK: Array<Bool> = [true, true, /*false,*/ true];
  /**
   * A list of menu options whose graphics are available in the vanilla graphic.
   */
  static final VANILLA_MAIN_MENU_ITEM_NAMES: Array<String> = ['story mode', 'freeplay', 'donate', 'options'];

  public static function buildMainMenu(menuItemGroup:FlxTypedGroup<FlxSprite>, onFinishFirstStart:TweenCallback) {
    for (i in 0...MAIN_MENU_ITEMS.length) {
      var sprite = buildMainMenuItem(MAIN_MENU_ITEMS[i], i, onFinishFirstStart);
      
      menuItemGroup.add(sprite);
    }
  }

  public static function buildMainMenuItem(menuOptionName:String, id:Int, onFinishFirstStart:TweenCallback):FlxSprite {
    if (VANILLA_MAIN_MENU_ITEM_NAMES.contains(menuOptionName)) {
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
      if (MainMenuState.firstStart) {
        FlxTween.tween(menuItem, {y: 60 + (id * 160)}, 1 + (id * 0.25), {
          ease: FlxEase.expoInOut,
          onComplete: onFinishFirstStart
        });
      } else {
        menuItem.y = 60 + (id * 160);
      }

      return menuItem;
    } else {
      // Here we use text that looks like the Friday Night Funkin logo to approximate the menu option.
      // If you have a cleaner graphic, you can use logic to add that in here.


      // Did you know this counts as an FlxSprite?
      var menuItem:FlxText = new FlxText(0, 10, Std.int(FlxG.width * 0.6), menuOptionName, 32);
      menuItem.font = 'Friday Funkin';
      menuItem.screenCenter(X);
      menuItem.y = 60 + (id * 160);

      menuItem.ID = id;

      return menuItem;
    }
  }

  /**
   * Returns true if the selected main menu item should flash and play a sound when selected,
   * or false to just immediately run the action.
   * @param curSelected 
   * @return Bool
   */
  public static function shouldMainMenuItemBlink(curSelected:Int):Bool {
    return MAIN_MENU_ITEM_BLINK[curSelected];
  }

  /**
   * Plays the main menu music.
   * If it was previously paused, it will continue where it left off.
   */
  public static function playMenuMusic() {
    if (FlxG.sound.music == null) {
      FlxG.sound.playMusic(Paths.music('freakyMenu'));
    } else {
      FlxG.sound.music.play();
    }
  }

  /**
   * Stops the main menu music.
   * Attempting to play it again will start where it left off.
   */
  public static function pauseMenuMusic() {
    if (FlxG.sound.music != null && FlxG.sound.music.playing) {
      FlxG.sound.music.pause();
    }
  }

  /**
   * Stops the main menu music.
   * Attempting to play it again will restart it.
   */
  public static function stopMenuMusic() {
    if (FlxG.sound.music != null && FlxG.sound.music.playing) {
      FlxG.sound.music.stop();
    }
  }

  /**
   * This function is called when the user presses ENTER on a main menu option.
   * Do whatever you want here! Go to another screen or what have you.
   */
  public static function onSelectMainMenuItem(curSelected:Int):Void {
    // The main menu option you chose.
    var daChoice:String = CustomMainMenu.MAIN_MENU_ITEMS[curSelected];
  
    trace('Main menu: Selected $daChoice...');

    // Do a thing!
    switch (daChoice) {
      case 'story mode':
        // Open the story mode menu.
        FlxG.switchState(new StoryMenuState());
      case 'freeplay':
        FlxG.switchState(new FreeplayState());
      case 'options':
        FlxG.switchState(new OptionsMenu());
      case 'donate':
        CustomFunne.goToURL('https://ninja-muffin24.itch.io/funkin');
      case 'sonic':
        CustomFunne.doSonic();
    }
  }

}