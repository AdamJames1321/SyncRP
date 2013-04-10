--[[
Name: "sh_inventory.lua".
Product: "Cider (Roleplay)".
--]]

cider.inventory = {};

-- Check if we're running on the server.
if (SERVER) then
	function cider.inventory.update(player, item, amount, force)
		if (cider.item.stored[item]) then
			if (amount < 1 or cider.inventory.canFit(player, cider.item.stored[item].size * amount) or force) then
				player.cider._Inventory[item] = (player.cider._Inventory[item] or 0) + (amount or 0);
				
				-- Check to see if we do not have any of this item now.
				if (player.cider._Inventory[item] <= 0) then
					if (amount > 0) then
						player.cider._Inventory[item] = amount;
					else
						player.cider._Inventory[item] = nil;
					end;
				end;
				
				-- Send a usermessage to the player to tell him his items have been updated.
				umsg.Start("cider_Inventory_Item", player);
					umsg.String(item);
					umsg.Long(player.cider._Inventory[item] or 0);
				umsg.End();
				
				-- Return true because we updated the inventory successfully.
				return true;
			else
				return false, "You do not have enough inventory space!";
			end;
		else
			return false, "That is not a valid item!";
		end;
	end;
	
	-- Get the maximum amount of space a player has.
	function cider.inventory.getMaximumSpace(player)
		local size = cider.configuration["Inventory Size"];
		
		-- Loop through the player's inventory.
		for k, v in pairs(player.cider._Inventory) do
			if (cider.item.stored[k]) then
				if (cider.item.stored[k].size < 0) then
					size = size + (math.abs(cider.item.stored[k].size) * v);
				end;
			end;
		end;
		
		-- Return the size.
		return size;
	end;
	
	-- Get the size of a player's inventory.
	function cider.inventory.getSize(player)
		local size = 0;
		
		-- Loop through the player's inventory.
		for k, v in pairs(player.cider._Inventory) do
			if (cider.item.stored[k].size > 0) then
				size = size + (cider.item.stored[k].size * v);
			end;
		end;
		
		-- Return the size.
		return size;
	end;
	
	-- Check if a player can fit a specified size into their inventory.
	function cider.inventory.canFit(player, size)
		if ( cider.inventory.getSize(player) + size > cider.inventory.getMaximumSpace(player) ) then
			return false;
		else
			return true;
		end;
	end;
	
	-- Called when a player has initialized.
	hook.Add("PlayerInitialized", "cider.inventory.playerInitialized", function(player)
		timer.Simple(1, function()
			for k, v in pairs(player.cider._Inventory) do cider.inventory.update(player, k, 0, true); end;
		end);
	end);
else
	cider.inventory.stored = {};
	cider.inventory.updatePanel = true;
	
	-- Hook into when the server sends the client an inventory item.
	usermessage.Hook("cider_Inventory_Item", function(msg)
		local item = msg:ReadString();
		local amount = msg:ReadLong();
		
		-- Check to see if the amount is smaller than 1.
		if (amount < 1) then
			cider.inventory.stored[item] = nil;
		else
			cider.inventory.stored[item] = amount;
		end;
		
		-- Tell the inventory panel that we should update.
		cider.inventory.updatePanel = true;
	end);
	
	-- Get the maximum amount of space a player has.
	function cider.inventory.getMaximumSpace()
		local size = cider.configuration["Inventory Size"];
		
		-- Loop through the player's inventory.
		for k, v in pairs(cider.inventory.stored) do
			if (cider.item.stored[k]) then
				if (cider.item.stored[k].size < 0) then
					size = size + (math.abs(cider.item.stored[k].size) * v);
				end;
			end;
		end;
		
		-- Return the size.
		return size;
	end;
	
	-- Get the size of the local player's inventory.
	function cider.inventory.getSize()
		local size = 0;
		
		-- Loop through the player's inventory.
		for k, v in pairs(cider.inventory.stored) do
			if (cider.item.stored[k]) then
				if (cider.item.stored[k].size > 0) then
					size = size + (cider.item.stored[k].size * v);
				end;
			end;
		end;
		
		-- Return the size.
		return size;
	end;
	
	-- Check if the local player can fit a specified size into their inventory.
	function cider.inventory.canFit(size)
		if ( cider.inventory.getSize() + size > cider.inventory.getMaximumSpace() ) then
			return false;
		else
			return true;
		end;
	end;
end