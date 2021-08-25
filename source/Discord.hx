import Sys.sleep;
import discord_rpc.DiscordRpc;

using StringTools;

/**
 * ERIC: This class handles Discord integration.
 * Players will see that you are playing FNF, and what song is on.
 */
class DiscordClient {
  public function new() {
    trace('Enabling Discord integration...');
    DiscordRpc.start({
      clientID: '557069829501091850', // change this to what ever the fuck you want lol
      onReady: onReady,
      onError: onError,
      onDisconnected: onDisconnected
    });
    trace('Discord integration enabled.');

    while (true) {
      // Here (this should be running in a separate thread),
      // continously update Discord integration.
      DiscordRpc.process();
      sleep(2);
    }

    DiscordRpc.shutdown();
  }

  public static function shutdown() {
    DiscordRpc.shutdown();
  }

  static function onReady() {
    // Start in the menus.
    DiscordRpc.presence({
      details: 'In the Menus',
      state: null,
      largeImageKey: 'icon',
      largeImageText: 'fridaynightfunkin'
    });
  }

  static function onError(_code:Int, _message:String) {
    trace('Error! $_code : $_message');
  }

  static function onDisconnected(_code:Int, _message:String) {
    trace('Disconnected! $_code : $_message');
  }

  public static function initialize() {
    // Starts a new Discord client (this class) in a separate thread.
    var DiscordDaemon = sys.thread.Thread.create(() -> {
      new DiscordClient();
    });
    trace('Discord Client initialized');
  }

  public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
    // Determine how long we've been ingame.
    var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;
    if (endTimestamp > 0) {
      endTimestamp = startTimestamp + endTimestamp;
    }

    DiscordRpc.presence({
      details: details,
      state: state,
      largeImageKey: 'icon',
      largeImageText: 'fridaynightfunkin',
      smallImageKey: smallImageKey,
      // Obtained times are in milliseconds so they are divided so Discord can use it
      startTimestamp: Std.int(startTimestamp / 1000),
      endTimestamp: Std.int(endTimestamp / 1000)
    });
  }
}
