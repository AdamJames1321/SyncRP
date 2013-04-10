--[[
Name: "sh_beans.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Hunger") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Beans";
ITEM.size = 1;
ITEM.cost = 50;
ITEM.team = TEAM_CHEF;
ITEM.model = "models/props_lab/jar01b.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Beans";
ITEM.uniqueID = "beans";
ITEM.description = "Some beans which restore 25 hunger.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	player._Hunger.amount = math.Clamp(player._Hunger.amount - 25, 0, 100);
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);