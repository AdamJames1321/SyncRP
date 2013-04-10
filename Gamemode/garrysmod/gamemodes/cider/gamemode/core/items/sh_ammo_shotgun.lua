--[[
Name: "sh_ammo_shotgun.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Shotgun Ammo";
ITEM.size = 1;
ITEM.cost = 1000;
ITEM.team = TEAM_ARMSDEALER;
ITEM.model = "models/items/boxbuckshot.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Shotgun Ammo";
ITEM.uniqueID = "ammo_shotgun";
ITEM.description = "Used to fill up shotguns.";

-- Called when a player uses the item.
function ITEM:onUse(player) player:GiveAmmo(30, "buckshot"); end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);