--[[
Name: "sh_boxed_pocket.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Boxed Pocket";
ITEM.size = 2;
ITEM.cost = 7500;
ITEM.team = TEAM_CITIZEN;
ITEM.model = "models/props_junk/cardboard_box004a.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Boxed Pockets";
ITEM.uniqueID = "boxed_pocket";
ITEM.description = "Open this box to reveal a small pocket.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if (player.cider._Inventory["small_pocket"] == 6) then
		cider.player.notify(player, "You've hit the pockets limit!", 1);
		
		-- Return false because we cannot use this item.
		return false;
	end;
	
	-- Update the player's inventory with a new item.
	cider.inventory.update(player, "small_pocket", 1);
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);