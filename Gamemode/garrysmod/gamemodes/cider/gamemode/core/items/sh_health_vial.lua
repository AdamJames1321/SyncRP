--[[
Name: "sh_health_vial.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Health Vial";
ITEM.size = 1;
ITEM.cost = 50;
ITEM.team = TEAM_DOCTOR;
ITEM.model = "models/healthvial.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Health Vials";
ITEM.uniqueID = "health_vial";
ITEM.description = "A health vial which restores 25 health.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if (player:Health() >= 100) then
		cider.player.notify(player, "You do not need any more health!", 1);
		
		-- Return false because we cannot use the item.
		return false;
	else
		player:SetHealth( math.Clamp(player:Health() + 25, 0, 100) )
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);