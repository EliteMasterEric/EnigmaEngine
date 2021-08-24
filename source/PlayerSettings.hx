import Controls;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxSignal;

// import ui.DeviceManager;
// import props.Player;
class PlayerSettings {
  public static var numPlayers(default, null) = 0;
  public static var numAvatars(default, null) = 0;
  public static var player1(default, null):PlayerSettings;
  public static var player2(default, null):PlayerSettings;

  #if (haxe >= "4.0.0")
  public static final onAvatarAdd = new FlxTypedSignal<PlayerSettings->Void>();
  public static final onAvatarRemove = new FlxTypedSignal<PlayerSettings->Void>();
  #else
  public static var onAvatarAdd = new FlxTypedSignal<PlayerSettings->Void>();
  public static var onAvatarRemove = new FlxTypedSignal<PlayerSettings->Void>();
  #end

  public var id(default, null):Int;

  public final controls:CustomControls;

  // public var avatar:Player;
  // public var camera(get, never):PlayCamera;

  function new(id, scheme) {
    this.id = id;
    this.controls = new CustomControls('player$id', scheme);
  }

  public function setKeyboardScheme(scheme) {
    controls.setKeyboardScheme(scheme);
  }

  public static function init():Void {
    if (player1 == null) {
      player1 = new PlayerSettings(0, Solo);
      ++numPlayers;
    }

    var numGamepads = FlxG.gamepads.numActiveGamepads;
    if (numGamepads > 0) {
      var gamepad = FlxG.gamepads.getByID(0);
      if (gamepad == null)
        throw 'Unexpected null gamepad. id:0';

      player1.controls.addDefaultGamepad(0);
    }

    if (numGamepads > 1) {
      if (player2 == null) {
        player2 = new PlayerSettings(1, None);
        ++numPlayers;
      }

      var gamepad = FlxG.gamepads.getByID(1);
      if (gamepad == null)
        throw 'Unexpected null gamepad. id:0';

      player2.controls.addDefaultGamepad(1);
    }

    // DeviceManager.init();
  }

  public static function reset() {
    player1 = null;
    player2 = null;
    numPlayers = 0;
  }
}
