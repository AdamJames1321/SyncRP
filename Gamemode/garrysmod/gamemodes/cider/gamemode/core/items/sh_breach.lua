--[[
Name: "sh_breach.lua".
Product: "Cider (Roleplay)".
--]]

if ( !cider.plugin.get("Generic") ) then return; end;

-- Define the item table.
local ITEM = {};

-- Set some information about the item.
ITEM.name = "Breach";
ITEM.size = 2;
ITEM.cost = 1000;
ITEM.team = TEAM_REBELDEALER;
ITEM.model = "models/weapons/w_c4_planted.mdl";
ITEM.batch = 10;
ITEM.store = true;
ITEM.plural = "Breaches";
ITEM.uniqueID = "breach";
ITEM.description = "Will blow a door open if it is planted on one and destroyed.";

-- Called when a player uses the item.
function ITEM:onUse(player)
	local trace = player:GetEyeTrace();
	local door = trace.Entity;
	
	-- Check if the trace entity is a valid door.
	if (cider.entity.isDoor(door) or door:GetClass() == "prop_dynamic") then
		if (door:GetPos():Distance( player:GetPos() ) <= 128) then
			if (door._Unownable and door:GetNetworkedString("cider_Name") == "Abandoned") then
				cider.player.notify(player, "This door cannot be breached!", 1);
				
				-- Return false because this door cannot be rammed.
				return false;
			else
				if ( !IsValid(door._Breach) ) then
					local entity = ents.Create("cider_breach");
					
					-- Spawn the entity.
					entity:Spawn();
					
					-- Set the door for the entity to breach.
					entity:SetDoor(door, trace);
					
					-- Set the door's breach entity to this one.
					door._Breach = entity;
				else
					cider.player.notify(player, "This door already has a breach!", 1);
					
					-- Return false because the door already has a breach.
					return false;
				end;
			end;
		else
			cider.player.notify(player, "You are not close enough to the door!", 1);
			
			-- Return false because the door is too far away.
			return false;
		end;
	else
		cider.player.notify(player, "That is not a valid door!", 1);
		
		-- Return false because this is not a valid door.
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:onDrop(player, position) end;

-- Called when a player destroys the item.
function ITEM:onDestroy(player) end;

-- Register the item.
cider.item.register(ITEM);