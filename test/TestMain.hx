/**
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
 * TestMain.hx
 * The main class for a test suite for Enigma Engine.
 * Initializes then executes the test suite.
 */
package;

import openfl.Lib;
import flixel.FlxGame;
import flixel.FlxState;
import massive.munit.TestRunner;
import massive.munit.client.HTTPClient;
import massive.munit.client.SummaryReportClient;
import funkin.TestSuite;

/**
 * Auto generated Test Application.
 * Refer to munit command line tool for more information (haxelib run munit)
 */
class TestMain
{
	static function main()
	{
		new TestMain();
	}

	public function new()
	{
		// Flixel was not designed for unit testing so we can only have one instance for now.
		Lib.current.stage.addChild(new FlxGame(640, 480, FlxState, 1, 60, 60, true));

		var suites = new Array<Class<massive.munit.TestSuite>>();
		suites.push(funkin.TestSuite);

		#if fdb
		var client = new massive.munit.client.AbstractTestResultClient();
		#else
		var client = new massive.munit.client.RichPrintClient();
		#end

		var httpClient = new HTTPClient(new SummaryReportClient());

		var runner = new TestRunner(client);
		runner.addResultClient(httpClient);

		runner.completionHandler = completionHandler;
		runner.run(suites);
	}

	/**
	 * updates the background color and closes the current browser
	 * for flash and html targets (useful for continuos integration servers)
	 */
	function completionHandler(successful:Bool):Void
	{
		try
		{
			#if flash
			flash.external.ExternalInterface.call("testResult", successful);
			#elseif js
			js.Lib.eval("testResult(" + successful + ");");
			#elseif sys
			Sys.exit(successful ? 0 : 1);
			#end
		}
		// if run from outside browser can get error which we can ignore
		catch (e:Dynamic)
		{
		}
	}
}
