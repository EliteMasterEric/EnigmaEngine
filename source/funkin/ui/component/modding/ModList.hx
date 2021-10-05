package funkin.ui.component.modding;

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
	public static final MENU_WIDTH = 500;

	// Whether this is the Loaded Mods list.
	final loaded:Bool = false;

	public function new(X:Float = 0, Y:Float = 0, H:Float = 0, loaded:Bool = false)
	{
		super(X, Y, null, MENU_WIDTH, H, "<X> more...", FlxUIList.STACK_VERTICAL, 0, null, null, null, null);
		this.loaded = loaded;
	}

	/**
	 * Add a mod to this modlist.
	 * @param modMetadata 
	 */
	public function addMod(modMetadata:ModMetadata)
	{
		var item = new ModListItem(modMetadata, 0, 0, loaded);
		item.parent = this;
		add(item);
	}

	/**
	 * Remove the mod of the given ID from this mod list.
	 * @param modId 
	 */
	public function removeMod(modId:String)
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
	}

	/**
	 * Sort the mod list such that it matches the array you pass in.
	 * @param modIds 
	 */
	public function sortMods(modIds:Array<String>)
	{
		group.members.sort(function(a, b)
		{
			if (Std.isOfType(a, ModListItem) && Std.isOfType(b, ModListItem))
			{
				var modA:ModListItem = cast a;
				var modB:ModListItem = cast b;
				return modIds.indexOf(modA.modId) - modIds.indexOf(modB.modId);
			}
			// Don't sort otherwise.
			return 0;
		});
	}
}
