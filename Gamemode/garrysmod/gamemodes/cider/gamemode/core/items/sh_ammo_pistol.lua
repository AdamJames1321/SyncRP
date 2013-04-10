--[[
Name: "sh_ammo_pistol.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Pistol Ammo";
ITEM.size = 1;
ITEM.cost = 600;
ITEM.team = TEAM_ARMSDEALER;
ITEM.model = "models/items/boxsrounds.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Pistol Ammo";
ITEM.uniqueID = "ammo_pistol";
ITEM.description = "Used to fill up pistols.";

-- Called when a player uses the item.
function ITEM:onUse(player) player:GiveAmmo(60, "pistol"); end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);