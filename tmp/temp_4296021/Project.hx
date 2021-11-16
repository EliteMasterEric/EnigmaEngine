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
 * project.hxp
 * Provides project configuration in a format mirroring Haxe.
 * hey what if project.xml but instead it's code
 */
import hxp.*;
import lime.tools.*;
import sys.FileSystem;

class Project extends HXProject
{
	static final FEATURE_DISCORD:String = "FEATURE_DISCORD";
	static final FEATURE_POLYMOD:String = "FEATURE_POLYMOD";
	static final FEATURE_LUAMODCHART:String = "FEATURE_LUAMODCHART";
	static final FEATURE_FILESYSTEM:String = "FEATURE_FILESYSTEM";
	static final FEATURE_WEBM:String = "FEATURE_WEBM";
	static final FEATURE_MULTITHREADING:String = "FEATURE_MULTITHREADING";
	static final FEATURE_MODCORE:String = "FEATURE_MODCORE";
	static final FEATURE_GAMEJOLT:String = "FEATURE_GAMEJOLT";

	public function new()
	{
		super();

		// Set the project metadata.
		configureApp();

		// Apply project feature definitions.
		configureFeatureDefines();

		// Set the build output folder.
		configureOutputDir();

		// Configure the Polymod library.
		configurePolymod();

		// Configure library dependencies.
		configureLibraries();

		// Configure asset libraries.
		configureAssets();

		// Configure favicons.
		configureIcons();
	}

	/**
	 * Configure basic metadata about the project.
	 */
	function configureApp()
	{
		meta.title = "Enigma Engine";
		meta.description = "A moddable game engine for Friday Night Funkin'.";
		meta.version = "0.3.0-beta1";
		meta.packageName = "com.mastereric.enigmaengine";
		meta.company = "";
		// meta.buildNumber
		// meta.companyId
		// meta.companyUrl

		// The entry point for the application.
		app.main = "Main";
		// The name of the executable.
		app.file = "Enigma";
		app.preloader = "flixel.system.FlxPreloader";
		// app.path
		// app.init
		// app.swfVersion
		// app.url

		// Source directory for the application.
		sources.push('source');
	}

	/**
	 * Configure feature definitions based on the target platform.
	 */
	function configureFeatureDefines()
	{
		// Ensure only supported platforms are used.
		switch (target)
		{
			case Platform.WINDOWS:
				trace('Platform: Windows');
			case Platform.MAC: // Mac will probably work, but I can't build it right now.
				trace('Platform: Mac');
			case Platform.LINUX:
				trace('Platform: Linux');
			case Platform.ANDROID:
				trace('Platform: Android');
			case Platform.HTML5:
				trace('Platform: HTML5');
			// case Platform.EMSCRITEN: // A WebAssembly build might be interesting...
			// case Platform.IOS: // I can't support iOS right now, since I don't have the ability to build.
			// case Platform.AIR:
			// case Platform.BLACKBERRY:
			// case Platform.CONSOLE_PC:
			// case Platform.CUSTOM:
			// case Platform.FIREFOX:
			// case Platform.FLASH:
			// case Platform.PS3:
			// case Platform.PS4:
			// case Platform.TIZEN:
			// case Platform.TVOS:
			// case Platform.VITA:
			// case Platform.WEBOS:
			// case Platform.WIIU:
			// case Platform.XBOX1:
			default:
				error('Unsupported platform (got ${target})');
		}

		if (is64Bit())
		{
			trace('Architecture: x64 / 64-bit');
		}
		else if (is32Bit())
		{
			trace('Architecture: x86 / 32-bit');
		}
		else
		{
			Log.error('Unsupported architecture (got ${architectures[0]})');
		}

		if (isDesktop())
		{
			haxedefs.set(FEATURE_DISCORD, true);
			haxedefs.set(FEATURE_POLYMOD, true);
			haxedefs.set(FEATURE_LUAMODCHART, true);
			haxedefs.set(FEATURE_FILESYSTEM, true);
			haxedefs.set(FEATURE_MULTITHREADING, true);
			haxedefs.set(FEATURE_MODCORE, true);
			haxedefs.set(FEATURE_GAMEJOLT, true);
		}

		if (isDesktop() || isWeb())
		{
			haxedefs.set(FEATURE_WEBM, true);
		}

		if (isDesktop() && !isWeb())
		{
			haxedefs.set("FLX_NO_TOUCH", true);
		}

		if (isMobile())
		{
			haxedefs.set("FLX_NO_KEYBOARD", true);
			haxedefs.set("FLX_NO_MOUSE", true);
		}

		if (!debug)
		{
			haxedefs.set("FLX_NO_DEBUG", true);
			haxedefs.set("NAPE_RELEASE_BUILD", true);
		}

		haxedefs.set("HXCPP_CHECK_POINTER", true);
		haxedefs.set("HXCPP_STACK_LINE", true);
		haxedefs.set("FLX_NO_FOCUS_LOST_SCREEN", true);
	}

	function configureOutputDir()
	{
		// Set the output directory. Depends on the target platform and build type.
		var architecture = is64Bit() ? "x64" : "x86";
		var buildDir = 'export/${target}/${architecture.toString()}/${debug ? 'debug' : 'release'}/';

		setenv('BUILD_DIR', buildDir);
	}

	/**
	 * Configure the Polymod library.
	 */
	function configurePolymod()
	{
		haxedefs.set("POLYMOD_SCRIPT_EXT", ".hscript");
		haxedefs.set("POLYMOD_SCRIPT_LIBRARY", "scripts");
		haxedefs.set("POLYMOD_USE_NAMESPACE", "false");
		haxedefs.set("POLYMOD_ROOT_PATH", "assets/scripts");
		if (debug)
		{
			haxedefs.set("POLYMOD_DEBUG", "true");
		}
	}

	/**
	 * Configures library dependencies for the project.
	 */
	function configureLibraries()
	{
		// Primary asset management.
		addHaxelib("lime");
		addHaxelib("openfl");

		// The core game engine.
		addHaxelib("flixel");
		// A set of additional utilities for Flixel.
		addHaxelib("flixel-addons");
		// A set of user interface controls for Flixel.
		addHaxelib("flixel-ui");

		// A set of additional functions for working with strings.
		addHaxelib("haxe-strings");
		// A libary to provide internationalization support.
		addHaxelib("firetongue");
		// A motion library used by the video handler.
		addHaxelib("actuate");
		// A library which allows for loading and parsing of WEBM videos. Used for cutscenes.
		addHaxelib("extension-webm");

		// A library for tolerant JSON parsing. Fewer typo bugs means fewer GitHub issues.
		addHaxelib("tjson");

		// An FMOD wrapper for Haxe. Includes APIs for sound manipulation.
		// addHaxelib("haxefmod");

		// A libary which allows for parsing and executing Haxe code. Necessary for mods.
		addHaxelib("hscript");
		// A library for atomic mod loading and asset replacement.
		addHaxelib("polymod");

		if (isFeatureEnabled(FEATURE_DISCORD))
		{
			trace('Discord integration is enabled, adding libraries.');
			// A library for integration with the Discord API.
			addHaxelib("discord_rpc");
		}

		if (isFeatureEnabled(FEATURE_LUAMODCHART))
		{
			trace('Lua Modchart integration is enabled, adding libraries.');
			// A library for parsing and executing Lua code. Necessary for modcharts.
			addHaxelib("linc_luajit");
			addHaxelib("hxvm-luajit");
		}
	}

	/**
	 * Configures the application window.
	 */
	function configureWindow()
	{
		// Automatically configure FPS.
		window.fps = 0;
		// Set the window size.
		window.width = 1280;
		window.height = 720;
		// Blank or transparent background.
		window.background = null;

		window.hardware = true;
		window.vsync = false;

		if (isWeb())
		{
			window.resizable = true;
		}

		if (isDesktop())
		{
			window.orientation = Orientation.LANDSCAPE;
			window.fullscreen = false;
			window.resizable = true;
			window.vsync = false;
		}

		if (isMobile())
		{
			window.orientation = Orientation.LANDSCAPE;
			window.fullscreen = false;
			window.resizable = false;
			window.width = 0;
			window.height = 0;
		}

		// window.allowHighDPI:Bool;
		// window.allowShaders:Bool;
		// window.alwaysOnTop:Bool;
		// window.antialiasing:Int;
		// window.borderless:Bool;
		// window.colorDepth:Int;
		// window.depthBuffer:Bool;
		// window.display:Int;
		// window.element:js.html.Element;
		// window.hidden:Bool;
		// window.maximized:Bool;
		// window.minimized:Bool;
		// window.parameters:String;
		// window.requireShaders:Bool;
		// window.stencilBuffer:Bool;
		// window.title:String;
		// window.x:Float;
		// window.y:Float;
	}

	/**
	 * Configure the asset folders to be used by the project.
	 */
	function configureAssets()
	{
		var shouldEmbed = defines.exists("embedAssets");
		var includeDefaultWeeks = defines.exists("includeDefaultWeeks");
		var includeExampleMods = !defines.exists("excludeExampleMods");
		// Only use OGG on desktop and MP3 on web.
		var excludeExt = isWeb() ? ["*.md", "*.ogg"] : ["*.md", "*.mp3"];

		// You can use a define to force assets to be preloaded.
		// Github Copilot thought of that part all on its own and that's really scary.
		var shouldPreload = !isWeb() || defines.exists("preloadAssets");

		if (shouldEmbed)
		{
			trace('NOTICE: Embedding assets into executable...');
		}
		else
		{
			trace('NOTICE: Including assets alongside executable...');
		}

		// Put the assets in _includeDefaultWeeks before those in the main folders.
		if (includeDefaultWeeks)
		{
			trace('NOTICE: Including default weeks...');

			addAssetPath("assets/_includeDefaultWeeks", "assets", ["*"], excludeExt, shouldEmbed);
		}
		else
		{
			trace('NOTICE: Excluding default weeks...');
			// addAssetLibrary("assets/_excludeDefaultWeeks", "assets", ["*"], excludeExt, shouldEmbed);
		}

		// Add the preloaded main asset path.
		addAssetPath("assets/preload", "assets", ["*"], excludeExt, shouldEmbed);

		// Add the main libraries.
		addAssetLibrary("scripts", true, true); // Scripts should always be embedded.
		addAssetLibrary("songs", shouldEmbed, shouldPreload);
		addAssetLibrary("shared", shouldEmbed, shouldPreload);
		// addAssetLibrary("sm", shouldEmbed, shouldPreload);

		// Add the main asset paths (AFTER the libraries).
		addAssetPath("assets/core", "core", ["*"], excludeExt, true);
		addAssetPath("assets/scripts", "scripts", ["*"], excludeExt, true);
		addAssetPath("assets/songs", "songs", ["*"], excludeExt, shouldEmbed);
		addAssetPath("assets/shared", "shared", ["*"], excludeExt, shouldEmbed);
		// addAssetPath("assets/sm", "sm", ["*"], excludeExt, shouldEmbed);
		addAssetPath("assets/core", "core", ["*"], excludeExt, shouldEmbed);
		addAssetPath("assets/core", "core", ["*"], excludeExt, shouldEmbed);

		// TODO: Deprecate week-specific asset libraries.
		if (includeDefaultWeeks)
		{
			addAssetLibrary("assets/tutorial", shouldEmbed, shouldPreload);
			addAssetLibrary("assets/week1", shouldEmbed, shouldPreload);
			addAssetLibrary("assets/week2", shouldEmbed, shouldPreload);
			addAssetLibrary("assets/week3", shouldEmbed, shouldPreload);
			addAssetLibrary("assets/week4", shouldEmbed, shouldPreload);
			addAssetLibrary("assets/week5", shouldEmbed, shouldPreload);
			addAssetLibrary("assets/week6", shouldEmbed, shouldPreload);

			addAssetPath("assets/_includeDefaultWeeks/tutorial", "tutorial", ["*"], excludeExt, shouldEmbed);
			addAssetPath("assets/_includeDefaultWeeks/week1", "week1", ["*"], excludeExt, shouldEmbed);
			addAssetPath("assets/_includeDefaultWeeks/week2", "week2", ["*"], excludeExt, shouldEmbed);
			addAssetPath("assets/_includeDefaultWeeks/week3", "week3", ["*"], excludeExt, shouldEmbed);
			addAssetPath("assets/_includeDefaultWeeks/week4", "week4", ["*"], excludeExt, shouldEmbed);
			addAssetPath("assets/_includeDefaultWeeks/week5", "week5", ["*"], excludeExt, shouldEmbed);
			addAssetPath("assets/_includeDefaultWeeks/week6", "week6", ["*"], excludeExt, shouldEmbed);
		}

		addAsset("art/README.txt", "README.txt", false);
		addAsset("LICENSE", "LICENSE.txt", false);
		// To font, convert to OTF, then use setFormat on the text with the name of the font.
		addAssetPath("assets/fonts", null, ["*"], excludeExt, true);
	}

	/**
	 * Configure the favicon for the executable file.
	 */
	function configureIcons()
	{
		addIcon("art/icon8.png", 8);
		addIcon("art/icon16.png", 16);
		addIcon("art/icon32.png", 32);
		addIcon("art/icon64.png", 64);
		addIcon("art/icon128.png", 128);
		addIcon("art/icon256.png", 256);
		addIcon("art/iconOG.png");
	}

	/**
	 * Returns whether a given feature is enabled based on whether a HaxeDef has been provided.
	 * @param feature The feature to check.
	 */
	function isFeatureEnabled(feature):Bool
	{
		return defines.exists(feature);
	}

	/**
	 * Returns true if the current platform has a 64-bit architecture.
	 * @return Whether the current platform is 64-bit.
	 */
	function is64Bit():Bool
	{
		return architectures.contains(Architecture.X64);
	}

	/**
	 * Returns true if the current platform has a 32-bit architecture.
	 * @return Whether the current platform is 32-bit.
	 */
	function is32Bit():Bool
	{
		return architectures.contains(Architecture.X86);
	}

	/**
	 * Returns true if the current platform is a desktop platform, such as Windows or Linux.
	 * @return Whether the current platform is a desktop platform.
	 */
	function isDesktop():Bool
	{
		return platformType == PlatformType.DESKTOP;
	}

	/**
	 * Returns true if the current platform is a mobile platform, such as Android or iOS.
	 * @return Whether the current platform is a mobile platform.
	 */
	function isMobile():Bool
	{
		return platformType == PlatformType.MOBILE;
	}

	/**
	 * Returns true if the current platform is a web platform, such as HTML5.
	 * @return Whether the current platform is a web platform.
	 */
	function isWeb():Bool
	{
		return platformType == PlatformType.WEB;
	}

	/**
	 * Returns true if the current platform is a Windows desktop.
	 * @return Whether the current platform is a Windows desktop.
	 */
	function isWindows():Bool
	{
		return platformType == PlatformType.DESKTOP && target == Platform.WINDOWS;
	}

	/**
	 * Returns true if the current platform is a Linux desktop.
	 * @return Whether the current platform is a Linux desktop.
	 */
	function isLinux():Bool
	{
		return platformType == PlatformType.DESKTOP && target == Platform.LINUX;
	}

	/**
	 * Returns true if the current platform is a Mac desktop.
	 * @return Whether the current platform is a Mac desktop.
	 */
	function isMac():Bool
	{
		return platformType == PlatformType.DESKTOP && target == Platform.MAC;
	}

	/**
	 * Returns true if the current platform is an Android mobile device.
	 * @return Whether the current platform is an Android mobile device.
	 */
	function isAndroid():Bool
	{
		return platformType == PlatformType.MOBILE && target == Platform.ANDROID;
	}

	/**
	 * Returns true if the current platform is an iOS mobile device.
	 * @return Whether the current platform is an iOS mobile device.
	 */
	function isIOS():Bool
	{
		return platformType == PlatformType.MOBILE && target == Platform.IOS;
	}

	/**
	 * Adds a library to the list of dependencies to be included in the project.
	 * @param name The name of the library to add.
	 */
	function addHaxelib(name)
	{
		haxelibs.push(new Haxelib(name));
	}

	/**
	 * Add an icon file of the given size to the project.
	 * SVG is supported and preferred over bitmap files.
	 * @param icon The path to the icon file.
	 * @param size The size of the icon.
	 */
	function addIcon(icon:String, size:Int = null)
	{
		icons.push(new Icon(icon, size));
	}

	function addAssetLibrary(name:String, embed:Bool = false, preload:Bool = false)
	{
		var sourcePath = null;
		var type = null;
		var generate = false;
		var prefix = "";

		var assetLibrary = new Library(sourcePath, name, type, embed, preload, generate, prefix);
		libraries.push(assetLibrary);
	}

	function addAsset(path:String, rename:String = null, embed:Bool = false)
	{
		assets.push(new Asset(path, rename, null, embed, true));
	}

	function addAssetPath(path:String, rename:String = null, include:Array<String> = null, exclude:Array<String> = null, embed:Bool = false):Void
	{
		if (path == "")
			return;

		if (!FileSystem.exists(path))
		{
			error("Could not find asset path \"" + path + "\"");
			return;
		}

		if (include == null)
			include = ["*"];

		if (exclude == null)
			exclude = [];

		exclude = exclude.concat([".*", "cvs", "thumbs.db", "desktop.ini", "*.hash"]);

		var targetPath = "";

		if (rename != null)
		{
			targetPath = rename;
		}
		else
		{
			targetPath = path;
		}

		var files = FileSystem.readDirectory(path);

		if (targetPath != "")
			targetPath += "/";

		for (file in files)
		{
			if (FileSystem.isDirectory(path + "/" + file))
			{
				if (filter(file, ["*"], exclude))
					includeAssets(path + "/" + file, targetPath + file, include, exclude);
			}
			else
			{
				if (filter(file, include, exclude))
				{
					addAsset(path + "/" + file, targetPath + file, embed);
				}
			}
		}
	}

	/**
	 * Throw an error. This should stop the build process.
	 * @param message The error message to display.
	 */
	function error(message:String)
	{
		Log.error(message);
	}
}