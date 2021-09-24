package funkin.ui.component.modding;

import polymod.Polymod.ModMetadata;
import flixel.addons.ui.FlxUIList;

class ModList extends FlxUIList
{
	public function new(X:Float = 0, Y:Float = 0, W:Float = 0, H:Float = 0)
	{
		super(X, Y, null, W, H, "<X> more...", FlxUIList.STACK_VERTICAL, 0, null, null, null, null);
	}

	/**
	 * Add a mod to this modlist.
	 * @param modMetadata 
	 */
	public function addMod(modMetadata:ModMetadata)
	{
		add(new ModListItem(modMetadata));
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
