--[[
Name: "sh_ammo_rifle.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Rifle Ammo";
ITEM.size = 1;
ITEM.cost = 800;
ITEM.team = TEAM_ARMSDEALER;
ITEM.model = "models/items/boxmrounds.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Rifle Ammo";
ITEM.uniqueID = "ammo_rifle";
ITEM.description = "Used to fill up rifles.";

-- Called when a player uses the item.
function ITEM:onUse(player) player:GiveAmmo(60, "smg1"); end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);