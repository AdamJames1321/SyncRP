--[[
Name: "sh_cider_fiveseven.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Five Seven";
ITEM.size = 1;
ITEM.cost = 1250;
ITEM.team = TEAM_ARMSDEALER;
ITEM.model = "models/weapons/w_pist_fiveseven.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.weapon = true;
ITEM.plural = "Five Sevens";
ITEM.uniqueID = "cider_fiveseven";
ITEM.description = "A compact pistol which deals fair damage.";

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