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
 * FlxTest.hx
 * A basic test which ensures that Flixel is working properly within the test suite.
 */
package funkin;

import flixel.FlxG;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import massive.munit.Assert;

class FlxTest
{
	// approx. amount of ticks at 60 fps
	static inline var TICKS_PER_FRAME:UInt = 25;
	static var totalSteps:UInt = 0;

	var destroyable:IFlxDestroyable;

	public function new()
	{
	}

	@After
	@:access(flixel)
	function after()
	{
		FlxG.game.getTimer = function()
		{
			return totalSteps * TICKS_PER_FRAME;
		}

		// make sure we have the same starting conditions for each test
		resetGame();
	}

	@:access(flixel)
	function step(steps:UInt = 1, ?callback:Void->Void)
	{
		for (i in 0...steps)
		{
			FlxG.game.step();
			if (callback != null)
				callback();
			totalSteps++;
		}
	}

	function resetGame()
	{
		FlxG.resetGame();
		step();
	}

	function switchState(nextState:FlxState)
	{
		FlxG.switchState(nextState);
		step();
	}

	function resetState()
	{
		FlxG.resetState();
		step();
	}

	@Test
	function testDestroy()
	{
		if (destroyable == null)
		{
			return;
		}

		try
		{
			destroyable.destroy();
			destroyable.destroy();
		}
		catch (e)
		{
			Assert.fail(e.message);
		}
	}

	function finishTween(tween:FlxTween)
	{
		while (!tween.finished)
		{
			step();
		}
	}
}
