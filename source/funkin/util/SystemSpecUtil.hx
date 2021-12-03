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
 * SystemSpecUtil.hx
 * Utilities to retrieve system information.
 * This is used by the Debug logger at the start of the program to help provide more info to the devs in the event of an error.
 */
package funkin.util;

import openfl.system.Capabilities;
import openfl.system.System;

class SystemSpecUtil
{
	public static function getOS():String
	{
		return Capabilities.os;
	}

	public static function getCPU():String
	{
		return Capabilities.cpuArchitecture;
	}

	public static function getGPU():String
	{
		// TODO: Implement this.
		return "Unknown";
	}

	public static function getLanguage():String
	{
		return Capabilities.language;
	}

	public static function getManufacturer():String
	{
		return Capabilities.manufacturer;
	}

	/**
	 * Gets the current memory usage, in megabytes.
	 */
	public static function getMemory():String
	{
		return '${System.totalMemory / 1024 / 1024} MB';
	}

	public static function getScreenResolution():String
	{
		return Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY;
	}
}
