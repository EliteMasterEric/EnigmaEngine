import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths {
  public static inline var SOUND_EXT = #if web "mp3" #else "ogg" #end;

  static var currentLevel:String;

  public static function setCurrentLevel(name:String) {
    currentLevel = name.toLowerCase();
  }

  static function getPath(file:String, type:AssetType, library:Null<String>) {
    if (library != null)
      return getLibraryPath(file, library);

    if (currentLevel != null) {
      var levelPath = getLibraryPathForce(file, currentLevel);
      if (OpenFlAssets.exists(levelPath, type))
        return levelPath;

      levelPath = getLibraryPathForce(file, "shared");
      if (OpenFlAssets.exists(levelPath, type))
        return levelPath;
    }

    return getPreloadPath(file);
  }

  public static function getLibraryPath(file:String, library = "preload") {
    return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
  }

  static inline function getLibraryPathForce(file:String, library:String) {
    return '$library:assets/$library/$file';
  }

  static inline function getPreloadPath(file:String) {
    return 'assets/$file';
  }

  public static inline function file(file:String, ?library:String, type:AssetType = TEXT) {
    return getPath(file, type, library);
  }

  public static inline function lua(key:String, ?library:String) {
    return getPath('data/$key.lua', TEXT, library);
  }

  public static inline function luaImage(key:String, ?library:String) {
    return getPath('data/$key.png', IMAGE, library);
  }

  public static inline function txt(key:String, ?library:String) {
    return getPath('$key.txt', TEXT, library);
  }

  public static inline function xml(key:String, ?library:String) {
    return getPath('data/$key.xml', TEXT, library);
  }

  public static inline function json(key:String, ?library:String) {
    return getPath('data/$key.json', TEXT, library);
  }

  public static function sound(key:String, ?library:String) {
    return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
  }

  public static inline function soundRandom(key:String, min:Int, max:Int, ?library:String) {
    return sound(key + FlxG.random.int(min, max), library);
  }

  public static inline function music(key:String, ?library:String) {
    return getPath('music/$key.$SOUND_EXT', MUSIC, library);
  }

  public static inline function voices(song:String) {
    var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
    switch (songLowercase) {
      case "dad-battle":
        songLowercase = "dadbattle";
      case "philly-nice":
        songLowercase = "philly";
    }
    return 'songs:assets/songs/${songLowercase}/Voices.$SOUND_EXT';
  }

  public static inline function inst(song:String) {
    var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
    switch (songLowercase) {
      case "dad-battle":
        songLowercase = "dadbattle";
      case "philly-nice":
        songLowercase = "philly";
    }
    return 'songs:assets/songs/${songLowercase}/Inst.$SOUND_EXT';
  }

  public static inline function image(key:String, ?library:String) {
    return getPath('images/$key.png', IMAGE, library);
  }

  public static inline function font(key:String) {
    return 'assets/fonts/$key';
  }

  public static inline function getSparrowAtlas(key:String, ?library:String, ?isCharacter:Bool = false) {
    var usecahce = FlxG.save.data.cacheImages;
    #if !cpp
    usecahce = false;
    #end
    if (isCharacter) {
      if (usecahce) {
        #if cpp
        return FlxAtlasFrames.fromSparrow(imageCached(key), file('images/characters/$key.xml', library));
        #else
        return null;
        #end
      } else {
        return FlxAtlasFrames.fromSparrow(image('characters/$key', library), file('images/characters/$key.xml', library));
      }
    }
    return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
  }

  #if cpp
  inline public static function imageCached(key:String):FlxGraphic {
    var data = Caching.bitmapData.get(key);
    trace('finding ${key} - ${data.bitmap}');
    return data;
  }
  #end

  public static inline function getPackerAtlas(key:String, ?library:String, ?isCharacter:Bool = false) {
    var usecahce = FlxG.save.data.cacheImages;
    #if !cpp
    usecahce = false;
    #end
    if (isCharacter)
      if (usecahce)
      #if cpp
    return FlxAtlasFrames.fromSpriteSheetPacker(imageCached(key), file('images/characters/$key.txt', library));
    #else
    return null;
    #end
    else
      return FlxAtlasFrames.fromSpriteSheetPacker(image('characters/$key'), file('images/characters/$key.txt', library));
    return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
  }
}
