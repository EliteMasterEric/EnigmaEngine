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
 * This is an extension of FlxCamera with additional utility functions applied to it.
 */
package funkin.ui.component;

import flixel.FlxCamera;
import flixel.math.FlxMath;

class GameCamera extends FlxCamera
{
	public var targetZoom(default, set):Float = 1.0;

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

	function set_targetZoom(value:Float):Float
	{
		// Set the desired zoom level. Each frame, the camera will linearly interpolate towards the target value.
		this.targetZoom = value;
		return this.targetZoom;
	}

	/**
	 * Each frame, move X% of the way to the target zoom level.
	 */
	static final ZOOM_RATE = 0.05;

	/**
	 * If the camera is this close to the target zoom, it will snap to it.
	 * This prevents the weird floating-point Zeno's-paradox situation.
	 */
	static final ZOOM_THRESHOLD = 0.001;

	/**
	 * Called every game tick.
	 * @param elapsed The time (in seconds) since the last call to update().
	 */
	public override function update(elapsed:Float)
	{
		// Lerp the camera zoom towards the target zoom level.
		this.zoom = FlxMath.lerp(this.zoom, this.targetZoom, ZOOM_RATE);

		// Stop lerping if we're really close.
		if (Math.abs(this.zoom - this.targetZoom) < ZOOM_THRESHOLD)
			this.zoom = this.targetZoom;
	}

	public static function setDefaultCameras(cameras:Array<FlxCamera>)
	{
		// I haven't figured out how to change this line without messing up the existing cameras.
		FlxCamera.defaultCameras = cast cameras;
	}
}
