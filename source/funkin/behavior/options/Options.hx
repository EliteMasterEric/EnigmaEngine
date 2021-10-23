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
 * Options.hx
 * Contains handlers for individual options in the Options menu,
 * including what text to display and what actions to perform when they are modified.
 */
package funkin.behavior.options;

import flixel.FlxG;
import flixel.util.FlxColor;
import funkin.behavior.options.Controls.KeyboardScheme;
import funkin.behavior.play.Conductor;
import funkin.behavior.play.Highscore;
import funkin.behavior.play.Scoring;
import funkin.behavior.play.Song;
import funkin.ui.state.LoadingState;
import funkin.ui.state.options.GameplayCustomizeState;
import funkin.ui.state.options.KeyBindMenu;
import funkin.ui.state.options.OptionsMenu;
import funkin.ui.state.play.LoadReplayState;
import funkin.ui.state.play.PlayState;
import funkin.util.Util;
import funkin.util.Util;
import lime.app.Application;
import openfl.Lib;

/**
 * Represents data about a category of options in the Options pane.
 */
class OptionCategory
{
	/**
	 * The display name of this category.
	 */
	private var name(get, null):String = "BLANK Category";

	/**
	 * The options in this category.
	 */
	private var _options:Array<Option> = new Array<Option>();

	/**
	 * The constructor.
	 * @param catName The name to use for this category.
	 * @param options The initial list of options for this category.
	 */
	public function new(catName:String, options:Array<Option>)
	{
		this.name = catName;
		this._options = options;
	}

	/**
	 * Get the list of options in this category.
	 * @return An array of Options objects.
	 */
	public final function getOptions():Array<Option>
	{
		return _options;
	}

	/**
	 * Add an option to this category.
	 * @param opt The option to add.
	 */
	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

  /**
	 * Remove an option from this category.
	 * @param opt The option to remove, if possible.
	 */
	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}
}

/**
 * An option for the options menu.
 * The parameter type is the type of the value you're handling with this option.
 * For example, a toggle should extend `BoolOption`.
 * An option that opens a submenu should probably be `Option<Null>`.
 * 
 * You can use `TheOption.get()` to retrieve the value of the option from a static context,
 * and `TheOption.set()` to modify that value.
 */
class Option<T>
{
	/**
	 * The name of this option in the options menu.
	 */
	public var name(default, null):String = "";
	/**
	 * The long-form description of this option, shown at the bottom of the screen.
	 */
	public var description(default, null):String = "";

  /**
   * Reset all user preferences to their default values.
   */
  public static function resetPreferences() {
    FlxG.save.data.preferences = getDefaultPreferences();
  }

  /**
   * Get a list of the default values for all user preferences .
   */
  public static inline function getDefaultPreferences():Dynamic {
    return [
      antiAliasing => AntiAliasingOption.DEFAULT,
      antiMash => AntiMashOption.DEFAULT,
      botPlay => BotPlayOption.DEFAULT,
      cameraZoom => CameraZoomOption.DEFAULT,
      coloredHPBar => HPBarColorOption.DEFAULT,
      cpuStrums => CPUStrumOption.DEFAULT,
      distractions => DistractionsAndEffectsOption.DEFAULT,
      downscroll => DownscrollOption.DEFAULT,
      editorGrid => EditorGridOption.DEFAULT,
      extendedScoreInfo => ExtendedScoreInfoOption.DEFAULT,
      flashingLights => FlashingLightsOption.DEFAULT,
      fpsCounter => FPSCounterOption.DEFAULT,
      framerateCap => FramerateCapOption.DEFAULT,
      instantRespawn => InstantRespawnOption.DEFAULT,
      minimalMode => MinimalModeOption.DEFAULT,
      missSounds => MissSoundsOption.DEFAULT,
      noteQuantization => NoteQuantizationOption.DEFAULT,
      npsDisplay => NPSDisplayOption.DEFAULT,
      preloadCharacters => CharacterPreloadOption.DEFAULT,
      rainbowFpsCounter => RainbowFPSCounterOption.DEFAULT,
      resetButton => ResetButtonOption.DEFAULT,
      safeFrames => SafeFramesOption.DEFAULT,
      scoreScreenEnabled => ScoreScreenOption.DEFAULT,
      scrollSpeed => ScrollSpeedOption.DEFAULT,
      showAccuracy => ShowAccuracyOption.DEFAULT,
      songOffset => SongOffsetOption.DEFAULT,
      songPosition => SongPositionOption.DEFAULT,
      wife3Accuracy => WIFE3AccuracyOption.DEFAULT,
    ];
  }

  /**
   * The constructor. Builds a new option.
   */
  public function new()
	{
    updateName();
		updateDescription();
	}

  /**
   * Get the current value of this option.
   * @return A value matching this option's type.
   */
  public static inline function get():T {
		throw "get() is not implemented";
  }

  /**
   * Set the current value of this option.
   * @return The value you passed in.
   */
  public static inline function set(value:T):T {
		throw "set() is not implemented";
  }

	/**
	 * Called when ACCEPT is pressed while highlighting the item.
   * Use this to change the value of the item (especially a boolean toggle).
	 * @return Return true if value was changed successfully and getName() should be rerun.
	 */
  public function onPress():Bool {
		return false;
  }

  /**
	 * Called when RESET is pressed while highlighting the item.
   * Use this to change the value of the item to its default.
	 * @return Return true if value was changed successfully and getName() should be rerun.
	 */
  public function onReset():Bool {
		return false;
  }

  /**
   * Called when LEFT is pressed while highlighting the item.
   * Use this to change the value of the item (especially a numeric value).
   * @return Return true if value was changed successfully and getName() should be rerun.
   */
  public function onLeft():Bool
	{
    return false;
	}

  /**
   * Called when LEFT is held while highlighting the item.
   * Use this to change the value of the item (especially a numeric value).
   * @return Return true if value was changed successfully and getName() should be rerun.
   */
  public function onLeftHold():Bool
	{
    return false;
	}

  /**
   * Called when RIGHT is pressed while highlighting the item.
   * Use this to change the value of the item (especially a numeric value).
   * @return Return true if value was changed successfully and getName() should be rerun.
   */
  public function onRight():Bool
	{
		return false;
	}

  /**
   * Called when RIGHT is pressed while highlighting the item.
   * Use this to change the value of the item (especially a numeric value).
   * @return Return true if value was changed successfully and getName() should be rerun.
   */
  public function onRightHold():Bool
	{
		return false;
	}

  /**
   * Recomputes the value of the name property and stores it.
   */
  private function updateName() {
    throw "updateName() is not implemented";
  }

  /**
   * Recomputes the value of the description property and stores it.
   */
  private function updateDescription() {
    throw "updateDescription() is not implemented";
  }
}

class BoolOption extends Option<Bool> {
	public override function onPress():Bool
	{
    set(!get());
	
		name = updateName();
    description = updateDescription();
		return true;
	}
}

class AntiAliasingOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.antiAliasing;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.antiAliasing = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Anti-Aliasing On" : "Anti-Aliasing Off";
	}

  private override function updateDescription()
	{
		return get() ? "Turn off to make sprites less blurry." : "Turn on to make sprites less pixelly (except Week 6).";
	}
}

class AntiMashOption extends BoolOption
{
  public static final DEFAULT:Bool = false;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.antiMash;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.antiMash = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Anti-Mash On" : "Anti-Mash Off";
	}

  private override function updateDescription()
	{
		return "If turned on, pressing a key when no note is there counts as a miss.";
	}
}

class BasicKeybindOption extends Option<Null>
{
	public override function onPress():Bool
	{
		OptionsMenu.instance.openSubState(new KeyBindMenu());
		return false;
	}

	private inline override function updateName():String
	{
		name = "Basic Key Bindings";
	}

  private inline override function updateDescription():String
	{
		description = "Key bindings for basic gameplay.";
	}
}

class BotPlayOption extends BoolOption
{
  public static final DEFAULT:Bool = false;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.botPlay;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.botPlay = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

  private override function updateName():String
	{
		return get() ? "Bot Play On" : "Bot Play Off";
	}

  private override function updateDescription():String
	{
		return "The computer will play the song for you. Scores won't be saved but you can preview the song's chart.";
	}
}

class CamZoomOption extends Option
{
  public static final DEFAULT:Bool = false;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.cameraZoom;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.cameraZoom = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

  private override function updateName():String
	{
		return get() ? "Camera Zoom On" : "Camera Zoom Off";
	}

  private override function updateDescription():String
	{
		return "Turn off to disable special effects where the camera zooms in.";
	}
}

class CharacterPreloadOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.preloadCharacters;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.preloadCharacters = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName():String
	{
		return get() ? "Preload Characters" : "Do not Preload Characters";
	}

  private override function updateDescription():String
	{
		return "Cache characters when the game starts. Significantly reduce song load time but increase memory usage.";
	}
}

class CPUStrumOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.cpuStrums;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.cpuStrums = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

  private override function updateName():String
	{
		return get() ? "CPU Strums on Notes" : "CPU Strums are Static";
	}

  private override function updateDescription():String
	{
		return "The CPU's strumline notes will animate when they play a note.";
	}
}

class CustomizeGameplayMenu extends Option<Null>
{
  public override function onPush():Bool {
    // Open the Gameplay Customize state.
		FlxG.switchState(new GameplayCustomizeState());
    return false;
  }

	private override function updateName()
	{
		return "Customize Gameplay";
	}

  private override function updateDescription()
	{
		return "Drag and drop gameplay modules to your preferred positions!";
	}
}

class DistractionsAndEffectsOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.distractions;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.distractions = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Distractions On" : "Distractions Off";
	}

  private override function updateDescription()
	{
		return "Turn this off to hide stuff like moving trains and lightning strikes.";
	}
}

class DownscrollOption extends BoolOption
{
  public static final DEFAULT:Bool = false;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.downscroll;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.downscroll = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Downscroll On" : "Downscroll Off";
	}

  private override function updateDescription()
	{
		return "Move the strumline to the bottom, and the notes move downward.";
	}
}

class EditorGridOption extends BoolOption
{
  public static final DEFAULT:Bool = false;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.editorGrid;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.editorGrid = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Editor Grid On" : "Editor Grid Off";
	}

  private override function updateDescription()
	{
		return "Display the grid in the chart editor. May cause lag?";
	}
}

class ExtendedScoreInfoOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.extendedScoreInfo;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.extendedScoreInfo = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Extended Score Info" : "Minimal Score Info";
	}

  private override function updateDescription()
	{
		return get() ? "Display additional useful info at the end of the song." : "Hide additional performance reporting..";
	}
}

class FlashingLightsOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.flashingLights;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.flashingLights = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Flashing Lights" : "No Flashing Lights";
	}

  private override function updateDescription()
	{
		return get() "Some visual effects may cause flashing." : "Flashing visual effects are now disabled.";
	}
}

class FPSCounterOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.fpsCounter;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.fpsCounter = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "FPS Counter On" : "FPS Counter Off";
	}

  private override function updateDescription()
	{
		return "Display your frames per second in the corner. Useful for performance checking.";
	}
}

class FramerateCapOption extends Option<Int>
{
  public static final DEFAULT:Int = 120;

  public static inline function get():Int {
    return FlxG.save.data.preferences.framerateCap;
  }

  public static inline function set(value:Int):Int {
    FlxG.save.data.preferences.framerateCap = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

  function setGameFPS() {
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(get());
  }

  function getRefreshRate():Int {
    return Application.current.window.displayMode.refreshRate;
  }

  public override function onLeft():Bool {
    if (get() <= 60)
      return false;

    set(get() - 10);

    setGameFPS();

    description = updateDescription();

    return true;
  }

  public override function onRight():Bool {
    if (get() >= 300)
      return false;

    set(get() + 10);

    setGameFPS();

    description = updateDescription();

    return true;
  }

	private override function updateDisplay():String
	{
		return "Framerate Cap";
	}

	override function getValue():String
	{
		return "Current Framerate Cap: "
			+ get()
			+ (get() == getRefreshRate() ? "Hz (Refresh Rate)" : "Hz");
	}
}

class HPBarColorOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.coloredHPBar;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.coloredHPBar = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Character HP Bars" : "Green/Red HP Bars";
	}

  private override function updateDescription()
	{
		return "Enable this to recolor the HP bar based on who's singing.";
	}
}

class InstantRespawnOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.instantRespawn;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.instantRespawn = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Instant Respawn On" : "Instant Respawn Off";
	}

  private override function updateDescription()
	{
		return "When enabled, immediately start the song again after dying.";
	}
}

class MinimalModeOption extends BoolOption
{
  public static final DEFAULT:Bool = false;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.minimalMode;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.minimalMode = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Minimal Mode On" : "Minimal Mode Off";
	}

  private override function updateDescription()
	{
    // This was named Optimize in Kade, IDK why that's very vague.
		return "Turn on minimal mode to hide the stage and your opponent's notes. Just pure gaming.";
	}
}

class MissSoundsOption extends BoolOption
{
  public static final DEFAULT:Bool = false;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.missSounds;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.missSounds = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Miss Sounds On" : "Miss Sounds Off";
	}

  private override function updateDescription()
	{
		return get() ? "Boyfriend makes a weird noise when missing notes." : "Vocals simply mute when missing notes.";
	}
}

class NoteQuantizationOption extends BoolOption
{
  public static final DEFAULT:Bool = false;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.noteQuantization;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.noteQuantization = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Note Quantization On" : "Note Quantization Off";
	}

  private override function updateDescription()
	{
		return "When on, note color is based on beat rather than direction.";
	}
}

class NPSDisplayOption extends BoolOption
{
  public static final DEFAULT:Bool = false;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.npsDisplay;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.npsDisplay = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Notes Per Second Display On" : "Notes Per Second Display Off";
	}

  private override function updateDescription()
	{
		return "Show a counter of how many notes are pressed per second.";
	}
}

class RainbowFPSCounterOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.rainbowFpsCounter;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.rainbowFpsCounter = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Rainbow FPS Counter" : "White FPS Counter";
	}

  private override function updateDescription()
	{
		return "Display your frames per second in the corner, in fancy colors.";
	}
}

class ReplayMenu extends Option<Null>
{
  public override function onPush():Bool {
    // Open the Replay state.
		FlxG.switchState(new LoadReplayState());
    return false;
  }

	private override function updateName()
	{
		return "Load a Replay";
	}

  private override function updateDescription()
	{
		return "Why this menu option is in the options menu is beyond me.";
	}
}

class ResetButtonOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.resetButton;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.resetButton = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Song Reset Button On" : "Song Reset Button Off";
	}

  private override function updateDescription()
	{
		return get() ? "You can press the R key during a song to restart." : "You can't accidentally restart because the R key is ignored.";
	}
}

class ResetPreferencesOption extends Option<Null> {
  var hasConfirmed:Bool = false;

  public override function onPress():Bool {
    if (!hasConfirmed) {
      hasConfirmed = true;
      name = updateName();
      description = updateDescription();
      return true;
    } else {
		  Debug.logWarn('User opted to reset their preferences.');
      Option.resetPreferences();

      hasConfirmed = false;
      name = updateName();
      description = updateDescription();
      return true;
    }

    return true;
  }

  private override function updateName()
	{
		return hasConfirmed ? "Are You Sure?" : "Reset Preferences";
	}

  private override function updateDescription()
	{
		return "Use this to set all the above options to default. IRREVERSIBLE.";
	}
}

class ResetScoreOption extends Option<Null> {
  var hasConfirmed:Bool = false;

  function resetWeekProgress() {
    FlxG.save.data.weekProgress = DEFAULT;
  }

  public override function onPress():Bool {
    if (!hasConfirmed) {
      hasConfirmed = true;
      name = updateName();
      description = updateDescription();
      return true;
    } else {
		  Debug.logWarn('User opted to reset their highscores.');
      Highscore.clearScores();

      hasConfirmed = false;
      name = updateName();
      description = updateDescription();
      return true;
    }

    return true;
  }

  private override function updateName()
	{
		return hasConfirmed ? "Are You Sure?" : "Reset Highscores";
	}

  private override function updateDescription()
	{
		return "Use this to set all your high scores and max combos to 0. IRREVERSIBLE.";
	}
}

class ResetWeekProgressOption extends Option<Null> {
  var hasConfirmed:Bool = false;

  public static final DEFAULT:Map<String, Bool> = ['tutorial' => true];

  function resetWeekProgress() {
    FlxG.save.data.weekProgress = DEFAULT;
  }

  public override function onPress():Bool {
    if (!hasConfirmed) {
      hasConfirmed = true;
      name = updateName();
      description = updateDescription();
      return true;
    } else {    
  		Debug.logWarn('User opted to reset their story unlocks.');
      resetWeekProgress();

      hasConfirmed = false;
      name = updateName();
      description = updateDescription();
      return true;
    }

    return true;
  }

  	private override function updateName()
	{
		return hasConfirmed ? "Are You Sure?" : "Reset Story Progress";
	}

  private override function updateDescription()
	{
		return "Use this to lock all weeks but the Tutorial week and Week 1. IRREVERSIBLE.";
	}
}

class SafeFramesOption extends Option<Int>
{
  public static final DEFAULT:Int = 10;

  public static inline function get():Int {
    return FlxG.save.data.preferences.safeFrames;
  }

  public static inline function set(value:Int):Int {
    FlxG.save.data.preferences.safeFrames = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

  public override function onLeft():Bool {
    if (get() <= 1)
      return false;

    set(get() - 1);

    Conductor.safeFrames = get();
		Conductor.recalculateTimings();

    description = updateDescription();

    return true;
  }

  public override function onRight():Bool {
    if (get() >= 20)
      return false;

    set(get() + 1);

    Conductor.safeFrames = get();
		Conductor.recalculateTimings();

    description = updateDescription();

    return true;
  }

	public override function updateName():String
	{
		return "Safe Frames";
	}

  public override function updateDescription():String
	{
		return "Safe Frames: "
			+ Conductor.safeFrames
			+ " - SIK: "
			+ Util.truncateFloat(45 * Conductor.timeScale, 0)
			+ "ms GD: "
			+ Util.truncateFloat(90 * Conductor.timeScale, 0)
			+ "ms BD: "
			+ Util.truncateFloat(Scoring.TIMING_WINDOWS[1] * Conductor.timeScale, 0)
			+ "ms SHT: "
			+ Util.truncateFloat(Scoring.TIMING_WINDOWS[0] * Conductor.timeScale, 0)
			+ "ms TOTAL: "
			+ Util.truncateFloat(Conductor.safeZoneOffset, 0)
			+ "ms";
	}
}

class ScrollSpeedOption extends Option<Float>
{
  public static final DEFAULT:Float = 1.0;

  public static inline function get():Float {
    return FlxG.save.data.preferences.scrollSpeed;
  }

  public static inline function set(value:Int):Int {
    FlxG.save.data.preferences.scrollSpeed = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

  public override function onLeft():Bool {
    if (get() <= 1.0)
      return false;

    set(get() - 0.1);

    description = updateDescription();

    return true;
  }

  public override function onRight():Bool {
    if (get() >= 4.0)
      return false;

    set(get() + 0.1);

    description = updateDescription();

    return true;
  }

	public override function updateName():String
	{
		return "Scroll Speed";
	}

  public override function updateDescription():String
	{
    return (get() == 1.0) ? "Default note speed." : 'Fixed note speed: ${Util.truncateFloat(get(), 1)}';
	}
}

class ScoreScreenOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.scoreScreenEnabled;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.scoreScreenEnabled = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Score Screen On" : "Score Screen Off";
	}

  private override function updateDescription()
	{
		return get() ? "Disable to hide the score screen at the end entirely." : "Enable to add a final score screen.";
	}
}

class ShowAccuracyOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.showAccuracy;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.showAccuracy = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Show Accuracy" : "Hide Accuracy";
	}

  private override function updateDescription()
	{
		return "Enable to show your accuracy % in the score area.";
	}
}

class SongOffsetOption extends Option<Float>
{
  public static final DEFAULT:Float = 0.0;

  public static inline function get():Int {
    return FlxG.save.data.preferences.songOffset;
  }

  public static inline function set(value:Int):Int {
    FlxG.save.data.preferences.songOffset = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	public override function onPress():Bool
	{
		Debug.logTrace("Options: Offset Test...");

		PlayState.SONG = Song.loadFromJson('tutorial', '');
		PlayState.storyWeek = null;
		PlayState.songDifficulty = "easy";
		PlayState.offsetTesting = true;
		Debug.logTrace('Entering week ' + PlayState.storyWeek.id);
		LoadingState.loadAndSwitchState(new PlayState());
		return false;
	}

  public override function onLeft():Bool {
    set(get() - 0.1);

    description = updateDescription();

    return true;
  }

  public override function onLeftHold():Bool {
    return onLeft();
  }

  public override function onRight():Bool {
    set(get() + 0.1);
    
    description = updateDescription();

    return true;
  }

  public override function onRightHold():Bool {
    return onRight();
  }

	private override function updateName():String
	{
		return "Song Offset";
	}

  private override function updateDescription()
	{
		return 'Press ENTER to test. Current Offset: ${Util.truncateFloat(get(), 1)}';
	}
}

class SongPositionOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.songPosition;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.songPosition = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "Song Position Shown" : "Song Position Hidden";
	}

  private override function updateDescription()
	{
		return "Toggles a progress bar and timer showing progress in the song.";
	}
}

class WIFE3AccuracyOption extends BoolOption
{
  public static final DEFAULT:Bool = true;

  public static inline function get():Bool {
    return FlxG.save.data.preferences.wife3Accuracy;
  }

  public static inline function set(value:Bool):Bool {
    FlxG.save.data.preferences.wife3Accuracy = value;
    return get();
  }

  public static inline function onReset():Bool {
    set(DEFAULT);
    return true;
  }

	private override function updateName()
	{
		return get() ? "WIFE3 Accuracy Mode" : "Judgement Accuracy Mode";
	}

  private override function updateDescription()
	{
		return get() ? "Fancy accuracy algorithm for pro gamers." : "Simple accuracy algorithm; a sick is +1, a bad is +0.5, a miss is -1.";
	}
}
