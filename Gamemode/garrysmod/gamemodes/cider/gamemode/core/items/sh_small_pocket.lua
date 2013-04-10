--[[
Name: "sh_small_pocket.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Small Pocket";
ITEM.size = -5;
ITEM.model = "models/props_junk/garbage_bag001a.mdl";
ITEM.plural = "Small Pockets";
ITEM.uniqueID = "small_pocket";
ITEM.description = "A small pocket which allows you to hold more.";

-- Called when a player drops the item.
function ITEM:onDrop(player, position)
	cider.item.make("boxed_pocket", position);
	
	-- Remove the item from the player's inventory.
	cider.inventory.update(player, "small_pocket", -1);
	
	-- Return false because we aren't really dropping it.
	return false;
end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);