/*
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
		suites.push(TestSuite);

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
