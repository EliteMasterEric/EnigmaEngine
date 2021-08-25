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
 
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * A static class created to handle doing the funne.
 * Easter eggs and other crap.
 */
class CustomFunne {
  public static var jumpscareFrames = null;

  public static function doSonic() {
    if (jumpscareFrames == null) {
      var data:BitmapData = BitmapData.fromFile('assets/enigma/images/sonicJUMPSCARE.png');
      var graph = FlxGraphic.fromBitmapData(data);
      
      jumpscareFrames = FlxAtlasFrames.fromSparrow(graph, Paths.file('images/sonicJUMPSCARE.xml', 'enigma'));
      
      // What happens if we dispose the bitmap data and leave the frames?
      // The animation renders as fully black, and the memory gets freed after a couple seconds.
      // data.dispose();
      // What happens if we destroy the FlxGraphic? A Null Object Reference occurs.
      // graph.destroy();
    }
    
    var daJumpscare:FlxSprite = new FlxSprite(0, 0);
    daJumpscare.frames = jumpscareFrames;
    daJumpscare.animation.addByPrefix('jump','sonicSPOOK',24, false);
    daJumpscare.screenCenter();
    daJumpscare.scale.x = 1.1;
    daJumpscare.scale.y = 1.1;
    daJumpscare.y += 370;
    daJumpscare.cameras = [FlxG.camera];
    // Play sound.
    CustomMainMenu.pauseMenuMusic();
    FlxG.sound.play(Paths.sound('datOneSound', 'enigma'), 1);
    var longerSound = FlxG.sound.play(Paths.sound('jumpscare', 'enigma'), 1);
    longerSound.onComplete = function() {
      CustomMainMenu.playMenuMusic();
    }
    
    // Add to screen.
    addToScene(daJumpscare);
    // Play animation.
    daJumpscare.animation.play('jump');
    // Remove from screen.
    daJumpscare.animation.finishCallback = function(pog:String) {
      removeFromScene(daJumpscare);
    }
  }

  /**
   * Add the provided object to the scene.
   * Like calling add() but as a static function that can be run from anywhere.
   */
  public static function addToScene(input:FlxBasic) {
    FlxG.state.add(input);
  }

  /**
   * Remove the provided object from the scene.
   * Like calling remove() but as a static function that can be run from anywhere.
   */
   public static function removeFromScene(input:FlxBasic) {
    FlxG.state.remove(input);
  }

  public static function goToURL(schmancy:String) {
    #if linux
    Sys.command('/usr/bin/xdg-open', [schmancy, '&']);
    #else
    FlxG.openURL(schmancy);
    #end
  }
}