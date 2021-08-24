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

/**
 * Global static configuration.
 */
class Custom {
  /**
   * [Description] Private constructor,
   *   to prevent unintentional initialization.
   */
  private function new() {}

  /**
   * Change this to false to hide the "Custom Keybinds"
   * option from the start menu.
   */
  public static final USE_CUSTOM_KEYBINDS = true;

  /**
   * Controls whether the charter uses 9K.
   */
  public static final USE_CUSTOM_CHARTER = true;

  /**
   * Change these options to hide individual keybinds
   * from the "Custom Keybinds" menu.
   */
  public static final SHOW_CUSTOM_KEYBINDS:Map<Int, Bool> = [
    0 => true, // Left 9K
    1 => true, // Down 9K
    2 => true, // Up 9K
    3 => true, // Right 9K
    4 => true, // Center
    5 => false, // Alt Left 9K
    6 => false, // Alt Down 9K
    7 => false, // Alt Up 9K
    8 => false, // Alt Right 9K
  ];
}
