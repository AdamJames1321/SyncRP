--[[
Name: "sh_cider_knife.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Knife";
ITEM.size = 1;
ITEM.cost = 2550;
ITEM.team = TEAM_ARMSDEALER;
ITEM.model = "models/weapons/w_knife_t.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "Knives";
ITEM.uniqueID = "cider_knife";
ITEM.description = "A compact knife that does greater damage from behind.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if ( !player:HasWeapon(self.uniqueID) ) then
		player:Give(self.uniqueID);
		player:SelectWeapon(self.uniqueID);
		
		-- Return here because we're going to use the item.
		return;
	end;
	
	-- Select the weapon.
	player:SelectWeapon(self.uniqueID);
	
	-- Return false because we already have this item out.
	return false;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);