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

/**
 * A static class created to contain week information.
 */
class WeekData {
  /**
   * [Description] Private constructor,
   *   to prevent unintentional initialization.
   */
  private function new() {}

  /**
   * A data structure containing:
   * Week Name
   * Week Song Names
   * Base Characters Used [ENEMY, BF, GF]
   * Unlocked by Default
   */
  public static final WEEK_DATA = [
    {
      name: "Tutorial",
      songs: ["Tutorial"],
      characters: ["", "bf", "gf"],
      unlocked: true,
    },
    {
      name: "Daddy Dearest",
      songs: ["Bopeebo", "Fresh", "Dad Battle"],
      characters: ["dad", "bf", "gf"],
      unlocked: false,
    },
    /*
      {
        name: "Spooky Month",
        songs: ["Spookeez", "South", "Monster"],
        characters: ["spooky", "bf", "gf"],
        unlocked: false,
      },
      {
        name: "PICO",
        songs: ["Pico", "Philly Nice", "Blammed"],
        characters: ["pico", "bf", "gf"],
        unlocked: false,
      },
      {
        name: "MOMMY MUST MURDER",
        songs: ["Satin Panties", "High", "Milf"],
        characters: ["mom", "bf", "gf"],
        unlocked: false,
      },
      {
        name: "RED SNOW",
        songs: ["Cocoa", "Eggnog", "Winter Horrorland"],
        characters: ["parents-christmas", "bf", "gf"],
        unlocked: false,
      },
      {
        name: "Hating Simulator ft. Moawling",
        songs: ["Senpai", "Roses", "Thorns"],
        characters: ["senpai", "bf", "gf"],
        unlocked: false,
      },
     */
  ];
}
