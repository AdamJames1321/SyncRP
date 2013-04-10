--[[
Name: "sh_item.lua".
Product: "Cider (Roleplay)".
--]]

cider.item = {};
cider.item.stored = {};

-- Register a new item.
function cider.item.register(item)
	cider.item.stored[item.uniqueID] = item;
end;

-- Get an item by it's name.
function cider.item.get(name)
	for k, v in pairs(cider.item.stored) do
		if (name == v.uniqueID) then return v; end;
		
		-- Check to see if the name matches or is found in the item's name.
		if ( string.find( string.lower(v.name), string.lower(name) ) ) then return v; end;
	end;
end;

-- Check to see if we're running on the server.
if (SERVER) then
	function cider.item.use(player, item)
		if (player.cider._Inventory[item] and player.cider._Inventory[item] > 0) then
			if (cider.item.stored[item]) then
				if (cider.item.stored[item].onUse) then
					if ( cider.item.stored[item]:onUse(player) == false ) then
						return false;
					end;
					
					-- Update the player's inventory.
					cider.inventory.update(player, item, -1);
					
					-- Return true because we did it successfully.
					return true;
				end;
			end;
		end;
		
		-- Return false because we failed somewhere.
		return false;
	end;
	
	-- Drops an item from a player.
	function cider.item.drop(player, item, position)
		if (player.cider._Inventory[item] and player.cider._Inventory[item] > 0) then
			if (cider.item.stored[item]) then
				if (!position) then
					position = player:GetEyeTrace().HitPos
					
					-- Set the z position of the vector to be 32 units higher.
					position.z = position.z + 16;
				end;
				
				-- Check to see if we have an on drop function.
				if (cider.item.stored[item].onDrop) then
					if ( cider.item.stored[item]:onDrop(player, position) == false ) then return false; end;
					
					-- Update the player's inventory.
					cider.inventory.update(player, item, -1);
					
					-- Make the item at that position.
					cider.item.make(item, position)
					
					-- Return true because we did it successfully.
					return true;
				end;
			end;
		end;
		
		-- Return false because we failed somewhere.
		return false;
	end;
	
	-- Destroys a player's item.
	function cider.item.destroy(player, item)
		if (player.cider._Inventory[item] and player.cider._Inventory[item] > 0) then
			if (cider.item.stored[item]) then
				if (cider.item.stored[item].onDestroy) then
					if ( cider.item.stored[item]:onDestroy(player) == false ) then
						return false;
					end;
					
					-- Update the player's inventory.
					cider.inventory.update(player, item, -player.cider._Inventory[item]);
					
					-- Return true because we did it successfully.
					return true;
				end;
			end;
		end;
		
		-- Return false because we failed somewhere.
		return false;
	end;
	
	-- Makes an item at the specified position.
	function cider.item.make(item, position)
		local entity = ents.Create("cider_item");
		
		-- Set the item and the position of the entity and then spawn it.
		entity:SetItem(item);
		entity:SetPos(position);
		entity:Spawn();
		
		-- Return the new entity.
		return entity;
	end;
end;