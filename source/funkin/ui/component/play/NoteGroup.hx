/*
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
 * NoteGroup.hx
 * An FlxTypedGroup that contains notes in a song.
 * Provides additional useful utility functions.
 */
class NoteGroup extends FlxTypedGroup<Note> {
  /**
   * Returns just the Notes which could be hit.
   * @param sort Whether to sort by strumtime.
   * @return Array<Note>
   */
  public function filterCanBeHit(?sort:Bool = true):Array<Note> {
    var result:Array<Note> = [];

    // TODO: We run this function a LOT, and this processing is O(n).
    // Can we optimize it somehow?

    forEachAlive(function(curNote:Note) {
      // The notes which are in range of the strumbar,
      // the notes which are on the player side (not the CPU side),
      // the notes which haven't been registered as hit yet.
      if (curNote.canBeHit && !curNote.isCPUNote && !curNote.wasGoodHit) {
        result.push(curNote);
      }
    });

    if (sort)
      result.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

    return result;
  }
}