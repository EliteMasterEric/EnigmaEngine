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
