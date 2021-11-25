/**
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
 * GameCamera.hx
 * This is an FlxCamera with additional utility functions applied to it.
 */
package funkin.ui.component;

import flixel.FlxCamera;
import flixel.math.FlxMath;

class GameCamera extends FlxCamera
{
	public var targetZoom(default, set):Float = 1.0;

	private var originalZoom:Float = 1.0;

	/**
	 * @param x Initial x position of the camera.
	 * @param y Initial y position of the camera.
	 * @param w Initial width of the camera view.
	 * @param h Initial height of the camera view.
	 * @param z Initial zoom of the camera view.
	 */
	public function new(x:Int = 0, y:Int = 0, w:Int = 0, h:Int = 0, z:Float = 1.0)
	{
		super(x, y, w, h, z);
	}

	/**
	 * Function called when setting this.targetZoom.
	 * Sets the original zoom and target zoom values.
	 */
	function set_targetZoom(value:Float):Float
	{
		this.originalZoom = this.zoom;
		this.targetZoom = value;
		return this.targetZoom;
	}

	/**
	 * Called every game tick.
	 * @param elapsed The time (in seconds) since the last call to update().
	 */
	public override function update(elapsed:Float)
	{
		lerpCameraZoom(elapsed);
	}

	static final ZOOM_RATE = 0.95;

	function lerpCameraZoom(elapsed:Float)
	{
		// We need to do this relative to the original zoom rather than relative to the current zoom,
		// otherwise we get a Zeno's paradox situation where the camera never reaches the destination.
		this.zoom = FlxMath.lerp(this.originalZoom, this.targetZoom, ZOOM_RATE);
	}

	public static function setDefaultCameras(cameras:Array<GameCamera>)
	{
		// I haven't figured out how to change this line without messing up the existing cameras.
		FlxCamera.defaultCameras = cast cameras;
	}
}
