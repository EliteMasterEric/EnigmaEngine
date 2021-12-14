package funkin.behavior.debug;

import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

class UncaughtErrorHandler
{
	/**
	 * LITERALLY copy-pasting from Forever Engine rn because I can't for the life of me figure out
	 * why my own implementation doesn't work.
	 * @see https://github.com/Yoshubs/Forever-Engine-Legacy/blob/33280d0f17feb7ada9b4483a99c2f15bf123d9e6/source/Main.hx
	 * @param error 
	 * @return void
	 */
	public static function onUncaughtError(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = './crash/EE_${dateNow}.txt';

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					print(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/Yoshubs/Forever-Engine";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		print(errMsg);
		print("Crash dump saved in " + Path.normalize(path));

		var crashDialoguePath:String = "CrashDialog";

		#if windows
		crashDialoguePath += ".exe";
		#end

		if (FileSystem.exists("./" + crashDialoguePath))
		{
			print("Found crash dialog: " + crashDialoguePath);

			#if linux
			crashDialoguePath = "./" + crashDialoguePath;
			#end
			new Process(crashDialoguePath, [path]);
		}
		else
		{
			print("No crash dialog found! Making a simple alert instead...");
			Application.current.window.alert(errMsg, "Error!");
		}

		#if sys
		Sys.exit(1);
		#end
	}

	static function print(string:String):Void
	{
		#if sys
		Sys.println(string);
		#else
		trace(string);
		#end
	}
}
