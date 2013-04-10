--[[
Name: "sh_drug_lab.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;
if ( !cider.configuration["Contraband"]["cider_drug_lab"] ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Drug Lab";
ITEM.size = 3;
ITEM.cost = 750;
ITEM.model = "models/props_combine/combine_mine01.mdl";
ITEM.batch = 1;
ITEM.store = true;
ITEM.plural = "Drug Labs";
ITEM.uniqueID = "drug_lab";
ITEM.blacklist = {TEAM_COMBINEOFFICER, TEAM_COMBINEOVERWATCH, TEAM_CITYADMINISTRATOR};
ITEM.description = "A drug lab that earns you money over time.";

-- Called when a player drops the item.
function ITEM:onDrop(player, position)
	if (player:GetCount("druglabs") == cider.configuration["Contraband"]["cider_drug_lab"].maximum) then
		cider.player.notify(player, "You have reached the maximum drug labs!", 1);
		
		-- Return false because we're reached the maximum drug labs.
		return false;
	else
		local item = ents.Create("cider_drug_lab");
		
		-- Set the position and player of the drug lab.
		item:SetPos(position);
		item:SetPlayer(player);
		
		-- Set the unique ID of the drug lab.
		item._UniqueID = player:UniqueID();
		
		-- Spawn the item.
		item:Spawn();
		
		-- Increase the player's drug labs.
		player:AddCount("druglabs", item);
		
		-- Take away the item from the player.
		cider.inventory.update(player, "drug_lab", -1);
		
		-- Return false because we're going to handle this ourself.
		return false;
	end;
end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Called when a player attempts to manufacture an item.
function ITEM:canManufacture(player)
	if (player:GetCount("druglabs") == cider.configuration["Contraband"]["cider_drug_lab"].maximum) then
		cider.player.notify(player, "You have reached the maximum drug labs!", 1);
		
		-- Return false because we're reached the maximum drug labs.
		return false;
	end;
end;

-- On Manufacture.
function ITEM:onManufacture(player, entity)
	entity:Remove()
	
	-- Create the item.
	local item = ents.Create("cider_drug_lab");
	
	-- Set the position, angles and player.
	item:SetPos( entity:GetPos() );
	item:SetAngles( entity:GetAngles() );
	item:SetPlayer(player);
	
	-- Set the unique ID of the drug lab.
	item._UniqueID = player:UniqueID();
	
	-- Spawn the item.
	item:Spawn();
	
	-- Increase the player's drug labs.
	player:AddCount("druglabs", item);
end;

-- Register the item.
cider.item.register(ITEM);