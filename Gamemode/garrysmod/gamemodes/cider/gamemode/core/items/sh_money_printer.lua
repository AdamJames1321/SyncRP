--[[
Name: "sh_money_printer.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;
if ( !cider.configuration["Contraband"]["cider_money_printer"] ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Money Printer";
ITEM.size = 3;
ITEM.cost = 1500;
ITEM.model = "models/props_c17/cashregister01a.mdl";
ITEM.batch = 1;
ITEM.store = true;
ITEM.plural = "Money Printers";
ITEM.uniqueID = "money_printer";
ITEM.blacklist = {TEAM_COMBINEOFFICER, TEAM_COMBINEOVERWATCH, TEAM_CITYADMINISTRATOR};
ITEM.description = "A money printer that earns you money over time.";

-- Called when a player drops the item.
function ITEM:onDrop(player, position)
	if (player:GetCount("moneyprinters") == cider.configuration["Contraband"]["cider_money_printer"].maximum) then
		cider.player.notify(player, "You have reached the maximum money printers!", 1);
		
		-- Return false because we're reached the maximum money printers.
		return false;
	else
		local item = ents.Create("cider_money_printer");
		
		-- Set the position and player of the money printer.
		item:SetPos(position);
		item:SetPlayer(player);
		
		-- Set the unique ID of the money printer.
		item._UniqueID = player:UniqueID();
		
		-- Spawn the item.
		item:Spawn();
		
		-- Increase the player's money printers.
		player:AddCount("moneyprinters", item);
		
		-- Take away the item from the player.
		cider.inventory.update(player, "money_printer", -1);
		
		-- Return false because we're going to handle this ourself.
		return false;
	end;
end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Called when a player attempts to manufacture an item.
function ITEM:canManufacture(player)
	if (player:GetCount("moneyprinters") == cider.configuration["Contraband"]["cider_money_printer"].maximum) then
		cider.player.notify(player, "You have reached the maximum money printers!", 1);
		
		-- Return false because we're reached the maximum money printers.
		return false;
	end;
end;

-- On Manufacture.
function ITEM:onManufacture(player, entity)
	entity:Remove()
	
	-- Create the item.
	local item = ents.Create("cider_money_printer");
	
	-- Set the position, angles and player.
	item:SetPos( entity:GetPos() );
	item:SetAngles( entity:GetAngles() );
	item:SetPlayer(player);
	
	-- Set the unique ID of the money printer.
	item._UniqueID = player:UniqueID();
	
	-- Spawn the item.
	item:Spawn();
	
	-- Increase the player's money printers.
	player:AddCount("moneyprinters", item);
end;

-- Register the item.
cider.item.register(ITEM);