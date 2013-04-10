--[[
Name: "sh_health_kit.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Health Kit";
ITEM.size = 2;
ITEM.cost = 100;
ITEM.team = TEAM_DOCTOR;
ITEM.model = "models/items/healthkit.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Health Kit";
ITEM.uniqueID = "health_kit";
ITEM.description = "A health kit which restores 50 health.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if (player:Health() >= 100) then
		cider.player.notify(player, "You do not need any more health!", 1);
		
		-- Return false because we cannot use the item.
		return false;
	else
		player:SetHealth( math.Clamp(player:Health() + 50, 0, 100) )
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);