--[[
Name: "sh_nitrazepam.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Nitrazepam";
ITEM.size = 1;
ITEM.cost = 100;
ITEM.team = TEAM_PHARMACIST;
ITEM.model = "models/props_c17/trappropeller_lever.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Nitrazepam";
ITEM.uniqueID = "nitrazepam";
ITEM.description = "An injection which puts players to sleep instantly.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	cider.player.knockOut(player, true);
	
	-- Set sleeping to true because we are now sleeping.
	player._Sleeping = true;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);