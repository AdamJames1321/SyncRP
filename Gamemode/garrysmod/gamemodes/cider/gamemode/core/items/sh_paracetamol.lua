--[[
Name: "sh_paracetamol.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Paracetamol";
ITEM.size = 1;
ITEM.cost = 100;
ITEM.team = TEAM_PHARMACIST;
ITEM.model = "models/props_junk/garbage_metalcan002a.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Paracetamol";
ITEM.uniqueID = "paracetamol";
ITEM.description = "Small pills which unblur vision when low on health.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	if (player:Health() >= 50) then
		cider.player.notify(player, "You do not need any paracetamol!", 1);
		
		-- Return false because we cannot use the item.
		return false;
	else
		player._HideHealthEffects = true;
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);