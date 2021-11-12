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
 * ModList.hx
 * A component which displays a list of one or more mods, based on their Metadata.
 */
package funkin.ui.component.modding;

import funkin.behavior.Debug;
import flixel.addons.ui.FlxUIList;
import funkin.ui.component.input.InteractableUIList;
import polymod.Polymod.ModMetadata;

/**
 * This function is called when the user clicks the load or unload buttons, on either side.
 */
typedef ModListRemoveCallback = ModMetadata->Void;

/**
 * This function is called when the user clicks the up or down buttons.
 * Unused/hidden on the "unloaded mods" side.
 */
typedef ModListReorderCallback = (ModMetadata, Int) -> Void;

class ModList extends InteractableUIList
{
	// Whether this is the Loaded Mods list.
	final loaded:Bool = false;

	public var cbAddToOtherList:ModMetadata->Void = null;

	public function new(X:Float = 0, Y:Float = 0, W:Float = 0, H:Float = 0, loaded:Bool = false)
	{
		super(X, Y, null, W, H, "<X> more...", FlxUIList.STACK_VERTICAL, 0, null, null, null, null);
		this.loaded = loaded;
	}

	/**
	 * Add a mod to this modlist.
	 * @param modMetadata 
	 */
	public function addMod(modMetadata:ModMetadata, ?refresh:Bool = true)
	{
		var item = new ModListItem(modMetadata, 0, 0, this, loaded);
		safeAdd(item);
		if (refresh)
			refreshList();
	}

	public function insertMod(modMetadata:ModMetadata, pos:Int, ?refresh:Bool = true)
	{
		var item = new ModListItem(modMetadata, 0, 0, this, loaded);
		group.members.insert(pos, item);
		if (refresh)
			refreshList();
	}

	public function onUserLoadUnloadMod(modMetadata:ModMetadata)
	{
		removeMod(modMetadata.id);
		cbAddToOtherList(modMetadata);
	}

	public function onUserReorderMod(modMetadata:ModMetadata, offset:Int)
	{
		var modIndex = -1;
		for (m in group.members)
		{
			if (Std.isOfType(m, ModListItem))
			{
				var mod:ModListItem = cast m;
				if (mod.modId == modMetadata.id)
				{
					modIndex = group.members.indexOf(m);
				}
			}
		}

		if (modIndex == -1)
		{
			Debug.logWarn('Could not find mod list item to reorder! ${modMetadata.id} / $offset');
		}

		var newIndex = modIndex + offset;

		// Delete the element.
		var elements = group.members.splice(modIndex, 1);
		if (elements.length != 1)
		{
			Debug.logWarn('Logic error while splicing for modlist item reorder! ${modMetadata.id}');
		}
		// We have to recreate the item or list item offsets don't update properly.
		var oldModListItem:ModListItem = cast elements[0];
		insertMod(oldModListItem.modMetadata, newIndex);
	}

	/**
	 * Remove the mod of the given ID from this mod list.
	 * @param modId 
	 */
	public function removeMod(modId:String, ?refresh:Bool = true)
	{
		for (m in group.members)
		{
			if (Std.isOfType(m, ModListItem))
			{
				var mod:ModListItem = cast m;
				if (mod.modId == modId)
				{
					remove(m, true);
				}
			}
		}
		if (refresh)
			refreshList();
	}

	/**
	 * Remove all items from this modlist so that they can be readded.
	 */
	public function clearModList()
	{
		// If you use a for loop for this, some entries get skipped, I guess.
		while (group.members.length > 0)
		{
			if (group.members[0] != null)
			{
				remove(group.members[0]);
			}
			else
			{
				// Remove the element directly, to prevent null reference.
				group.members.splice(0, 1);
			}
		}
	}

	public function listCurrentMods():Array<ModMetadata>
	{
		var currentModList:Array<ModMetadata> = group.members.map(function(a)
		{
			if (Std.isOfType(a, ModListItem))
			{
				var modA:ModListItem = cast a;
				return modA.modMetadata;
			}
			return null;
		}).filter(function(b)
		{
			return b != null;
		});
		return currentModList;
	}
}
