--[[
Name: "sv_commands.lua".
Product: "Cider (Roleplay)".
--]]

cider.command.add("giveaccess", "a", 2, function(player, arguments)
	local target = cider.player.get(arguments[1])
	
	-- Check if we got a valid target.
	if (target) then
		if ( string.find(arguments[2], "a") or string.find(arguments[2], "s") ) then
			cider.player.notify(player, "You cannot give 'a' or 's' access!", 1);
			
			-- Return here because they tried to give invalid access.
			return;
		end;
		
		-- Give the access to the player.
		cider.player.giveAccess(target, arguments[2]);
		
		-- Print a message to every player telling them that we gave this player some access.
		cider.player.notifyAll(player:Name().." gave "..target:Name().." '"..arguments[2].."' access.");
	else
		cider.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Admin Commands", "<player> <access>", "Give access to a player.");

-- A command to take access from a player.
cider.command.add("takeaccess", "a", 2, function(player, arguments)
	local target = cider.player.get(arguments[1])
	
	-- Check if we got a valid target.
	if (target) then
		if ( string.find(arguments[2], "a") or string.find(arguments[2], "s") ) then
			cider.player.notify(player, "You cannot take 'a' or 's' access!", 1);
			
			-- Return here because they tried to give invalid access.
			return;
		end;
		
		-- Take the access from the player.
		cider.player.takeAccess(target, arguments[2]);
		
		-- Print a message to every player telling them that we gave this player some access.
		cider.player.notifyAll(player:Name().." took '"..arguments[2].."' access from "..target:Name()..".");
	else
		cider.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Admin Commands", "<player> <access>", "Take access from a player.");

-- A command to unblacklist a player from a team.
cider.command.add("unblacklist", "a", 2, function(player, arguments)
	local target = cider.player.get(arguments[1])
	
	-- Check if we got a valid target.
	if (target) then
		local team = cider.team.get(arguments[2]);
		
		-- Check if the team exists.
		if (team or arguments[2] == "advert") then
			if (arguments[2] == "advert") then
				player.cider._Blacklist["advert"] = false;
				
				-- Print a message to every player telling them that we have unblacklisted a player.
				cider.player.notifyAll(player:Name().." unblacklisted "..target:Name().." from advert.");
			else
				cider.team.blacklist(target, team.index, false);
				
				-- Print a message to every player telling them that we have unblacklisted a player.
				cider.player.notifyAll(player:Name().." unblacklisted "..target:Name().." from "..team.name..".");
			end;
		else
			cider.player.notify(player, "This is not a valid team!", 1);
		end;
	else
		cider.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Admin Commands", "<player> <team>", "Blacklist a player from a team.");

-- A command to blacklist a player from a team.
cider.command.add("blacklist", "a", 2, function(player, arguments)
	local target = cider.player.get(arguments[1])
	
	-- Check if we got a valid target.
	if (target) then
		local team = cider.team.get(arguments[2]);
		
		-- Check if the team exists.
		if (team or arguments[2] == "advert") then
			if (arguments[2] == "advert" or team.blacklist) then
				if (arguments[2] == "advert") then
					player.cider._Blacklist["advert"] = true;
					
					-- Print a message to every player telling them that we have blacklisted a player.
					cider.player.notifyAll(player:Name().." blacklisted "..target:Name().." from advert.");
				else
					cider.team.blacklist(target, team.index, true);
					
					-- Tell the plugins that a player has been blacklisted.
					cider.plugin.call("playerBlacklisted", target, team.index);
					
					-- Print a message to every player telling them that we have blacklisted a player.
					cider.player.notifyAll(player:Name().." blacklisted "..target:Name().." from "..team.name..".");
				end;
			else
				cider.player.notify(player, "You cannot blacklist "..target:Name().." from this team!", 1);
			end;
		else
			cider.player.notify(player, "This is not a valid team!", 1);
		end;
	else
		cider.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Admin Commands", "<player> <team>", "Unblacklist a player from a team.");

-- A command to demote a player.
cider.command.add("demote", "b", 1, function(player, arguments)
	local target = cider.player.get(arguments[1])
	
	-- Check if we got a valid target.
	if (target) then
		if ( hook.Call("PlayerCanDemote", GAMEMODE, player, target) ) then
			local team = target:Team();
			
			-- Demote the player from their current team.
			cider.player.demote(target);
			
			-- Call a hook.
			hook.Call("PlayerDemote", GAMEMODE, player, target, team);
		end;
	else
		cider.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Commands", "<player> <team>", "Demote a player from their current team.");

-- A command to give a player an item.
cider.command.add("giveitem", "s", 2, function(player, arguments)
	local target = cider.player.get(arguments[1])
	
	-- Check if we got a valid target.
	if (target) then
		local item = cider.item.get(arguments[2])
		
		-- Check if this is a valid item.
		if (item) then
			local success, fault = cider.inventory.update(target, item.uniqueID, 1);
			
			-- Check if we didn't succeed.
			if (!success) then
				cider.player.notify(player, target:Name().." does not have enough space for this item!", 1);
			else
				if (string.sub(item.name, -1) == "s") then
					cider.player.notify(player, "You have given "..target:Name().." some "..item.name..".", 0);
				else
					cider.player.notify(player, "You have given "..target:Name().." a "..item.name..".", 0);
				end;
				
				-- Check if the player is not the target.
				if (player != target) then
					if (string.sub(item.name, -1) == "s") then
						cider.player.notify(target, player:Name().." has given you some "..item.name..".", 0);
					else
						cider.player.notify(target, player:Name().." has given you a "..item.name..".", 0);
					end;
				end;
			end;
		else
			cider.player.notify(player, "This is not a valid item!", 1);
		end;
	else
		cider.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Super Admin Commands", "<player> <item>", "Give an item to a player.");

-- A command to privately message a player.
cider.command.add("pm", "b", 2, function(player, arguments)
	local target = cider.player.get(arguments[1])
	
	-- Check if we got a valid target.
	if (target) then
		if (player != target) then
			local text = table.concat(arguments, " ", 2);
			
			-- Check if the there is enough text.
			if (text == "") then
				cider.player.notify(player, "You did not specify enough text!", 1);
				
				-- Return because there wasn't enough text.
				return;
			end;
			
			-- Print a message to both players participating in the private message.
			cider.chatBox.add(player, player, "pm", text);
			cider.chatBox.add(target, player, "pm", text);
		else
			cider.player.notify(player, "You cannot send a private message to yourself!", 1);
		end;
	else
		cider.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Commands", "<player> <text>", "Privately message a player.");

-- A command to give a player some money.
cider.command.add("givemoney", "b", 1, function(player, arguments)
	local target = player:GetEyeTrace().Entity;
	
	-- Check if we got a valid target and that they are a player.
	if ( target and target:IsPlayer() ) then
		local money = tonumber(arguments[1]);
		
		-- Check if it's a valid amount of money.
		if (money and money > 0) then
			money = math.floor(money);
			
			-- Check if the player can afford it.
			if ( cider.player.canAfford(player, money) ) then
				cider.player.giveMoney(player, -money);
				cider.player.giveMoney(target, money);
				
				-- Print a message to both player's informing them of how much was sent/received.
				cider.player.notify(player, "You have given "..target:Name().." $"..money..".", 0);
				cider.player.notify(target, player:Name().." has given you $"..money..".", 0);
			else
				local amount = money - player.cider._Money;
				
				-- Print a message to the player telling them how much they need.
				cider.player.notify(player, "You need another $"..amount.."!", 1);
			end;
		else
			cider.player.notify(player, "This is not a valid amount!", 1);
		end;
	else
		cider.player.notify(player, "This is not a valid player!", 1);
	end;
end, "Commands", "<money>", "Give money to the player you're looking at.");

-- A command to drop money.
cider.command.add("dropmoney", "b", 1, function(player, arguments)
	local position = player:GetEyeTrace().HitPos;
	
	-- Get the amount of money.
	local money = tonumber(arguments[1]);
	
	-- Check if it's a valid amount of money.
	if (money and money > 0) then
		money = math.floor(money);
		
		-- Check to see if the amount is greater than 25.
		if (money >= 25) then
			if ( cider.player.canAfford(player, money) ) then
				cider.player.giveMoney(player, -money);
				
				-- Create the money entity.
				local entity = ents.Create("cider_money");
				
				-- Set the amount and position of the money.
				entity:SetAmount(money);
				entity:SetPos( position + Vector(0, 0, 16 ) );
				
				-- Spawn the money entity.
				entity:Spawn();
			else
				local amount = money - player.cider._Money;
				
				-- Print a message to the player telling them how much they need.
				cider.player.notify(player, "You need another $"..amount.."!", 1);
			end;
		else
			cider.player.notify(player, "You can drop a minimum of $25!", 1);
		end;
	else
		cider.player.notify(player, "This is not a valid amount!", 1);
	end;
end, "Commands", "<money>", "Drop money at your target position.");

-- A command to write a note.
cider.command.add("note", "b", 1, function(player, arguments)
	if (player:GetCount("notes") == cider.configuration["Maximum Notes"]) then
		cider.player.notify(player, "You've hit the notes limit!", 1);
	else
		local position = player:GetEyeTrace().HitPos;
		
		-- Check to see if this position is too far away.
		if (player:GetPos():Distance(position) <= 256) then
			local text = table.concat(arguments, " ");
			
			-- Check if the there is enough text.
			if (text == "") then
				cider.player.notify(player, "You did not specify enough text!", 1);
				
				-- Return because there wasn't enough text.
				return;
			end;
			
			-- Check if the there is too much text.
			if (string.len(text) > 125) then
				cider.player.notify(player, "Notes can be a maximum of 125 characters!", 1);
				
				-- Return because there was too much text.
				return;
			end;
			
			-- Create the money entity.
			local entity = ents.Create("cider_note");
			
			-- Set the amount and position of the money.
			entity:SetText(text);
			entity:SetPos( position + Vector(0, 0, 16 ) );
			
			-- Spawn the money entity.
			entity:Spawn();
			
			-- Add this entity to our notes count.
			player:AddCount("notes", entity);
			
			-- Add this to our undo table.
			undo.Create("Note");
				undo.SetPlayer(player);
				undo.AddEntity(entity);
			undo.Finish();
		else
			cider.player.notify(player, "You cannot create a note that far away!", 1);
		end;
	end;
end, "Commands", "<text>", "Write a note at your target position.");

-- A command to change your job.
cider.command.add("job", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");

	-- Check if the there is enough text.
	if (text == "") then
		cider.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Check the length of the arguments.
	if ( string.len(text) <= 48 ) then
		player._Job = text;
		
		-- Print a message to the player.
		cider.player.printMessage(player, "You have changed your job to '"..text.."'.");
	else
		cider.player.notify(player, "Your job can be a maximum of 48 characters!", 1);
	end;
end, "Commands", "<text>", "Change your job.");

-- A command to change your clan.
cider.command.add("clan", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");

	-- Check if the there is enough text.
	if (string.len(text) < 8 and string.lower(text) != "quit" and string.lower(text) != "none") then
		cider.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Check the length of the arguments.
	if ( string.len(text) <= 48 ) then
		if (text == " " or string.lower(text) == "none" or string.lower(text) == "quit") then
			player.cider._Clan = "";
			
			-- Print a message to the player.
			cider.player.printMessage(player, "You have quit your current clan.");
		else
			player.cider._Clan = text;
			
			-- Print a message to the player.
			cider.player.printMessage(player, "You have changed your clan to '"..text.."'.");
		end;
	else
		cider.player.notify(player, "Your clan can be a maximum of 48 characters!", 1);
	end;
end, "Commands", "<text|quit>", "Change your clan or quit your current one.");

-- A command to change your gender.
cider.command.add("gender", "b", 1, function(player, arguments)
	if (arguments[1] == "male" or arguments[1] == "female") then
		if (player._Gender == arguments[1]) then
			cider.player.notify(player, "You are already a "..arguments[1].."!", 1);
		else
			if (arguments[1] == "male") then
				player._NextSpawnGender = "Male";
			else
				player._NextSpawnGender = "Female";
			end;
			
			-- Notify them about their new gender.
			cider.player.notify(player, "You will be a "..arguments[1].." the next time you spawn.", 0);
		end;
	else
		cider.player.notify(player, "That is not a valid gender!", 1);
	end;
end, "Commands", "<male|female>", "Change your gender.");

-- A command to yell in character.
cider.command.add("y", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		cider.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Print a message to other players within a radius of the player's position.
	cider.chatBox.addInRadius(player, "yell", text, player:GetPos(), cider.configuration["Talk Radius"] * 2);
end, "Commands", "<text>", "Yell to players near you.");

-- A command to do 'me' style text.
cider.command.add("me", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		cider.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Print a message to other players within a radius of the player's position.
	cider.chatBox.addInRadius(player, "me", text, player:GetPos(), cider.configuration["Talk Radius"]);
end, "Commands", "<text>", "e.g: <your name> cries a river.");

-- A command to whisper in character.
cider.command.add("w", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Check if the there is enough text.
	if (text == "") then
		cider.player.notify(player, "You did not specify enough text!", 1);
		
		-- Return because there wasn't enough text.
		return;
	end;
	
	-- Print a message to other players within a radius of the player's position.
	cider.chatBox.addInRadius(player, "whisper", text, player:GetPos(), cider.configuration["Talk Radius"] / 2);
end, "Commands", "<text>", "Whisper to players near you.");

-- A command to send an advert to all players.
cider.command.add("advert", "b", 1, function(player, arguments)
	if ( player.cider._Blacklist["advert"] ) then
		cider.player.notify(player, "You have been blacklisted from advert!", 1);
	else
		if ( cider.player.canAfford(player, cider.configuration["Advert Cost"]) ) then
			local text = table.concat(arguments, " ");
			
			-- Check if the there is enough text.
			if (text == "") then
				cider.player.notify(player, "You did not specify enough text!", 1);
				
				-- Return because there wasn't enough text.
				return;
			end;
			
			-- Print a message to all players.
			cider.chatBox.add(nil, player, "advert", text);
			
			-- Take away the advert cost from the player's money.
			cider.player.giveMoney(player, -cider.configuration["Advert Cost"]);
		else
			local amount = cider.configuration["Advert Cost"] - player.cider._Money;
			
			-- Print a message to the player telling them how much they need.
			cider.player.notify(player, "You need another $"..amount.."!", 1);
		end;
	end;
end, "Commands", "<text>", "Send an advert to all players ($"..cider.configuration["Advert Cost"]..").");

-- A command to change your team.
cider.command.add("team", "b", 1, function(player, arguments)
	local team = cider.team.get(arguments[1]);
	
	-- Check if the team exists.
	if (team) then
		if ( g_Team.NumPlayers(team.index) >= team.limit ) then
			cider.player.notify(player, "This team is full!", 1);
		else
			if (player:Team() != team.index) then
				if ( hook.Call("PlayerCanJoinTeam", GAMEMODE, player, team.index) ) then
					cider.player.holsterAll(player);
					
					-- Check if the player can join this team.
					local success, fault = cider.team.make(player, team.index);
					
					-- Check if it was unsuccessful.
					if (!success) then cider.player.notify(player, fault, 1); end;
				end;
			end;
		end;
	else
		cider.player.notify(player, "This is not a valid team!", 1);
	end;
end, "Commands", "<team>", "Change your team.");

-- A command to perform inventory action on an item.
cider.command.add("inventory", "b", 2, function(player, arguments)
	if ( player:Alive() ) then
		local item = arguments[1];
		local amount = player.cider._Inventory[item];
		
		-- Check if the item exists.
		if ( cider.item.stored[item] ) then
			if (amount and amount > 0) then
				if (arguments[2] == "destroy") then
					cider.item.destroy(player, item)
				elseif (arguments[2] == "drop") then
					local position = player:GetEyeTrace().HitPos;
					
					-- Check to see if this position is too far away.
					if (player:GetPos():Distance(position) <= 256) then
						cider.item.drop(player, item);
					else
						cider.player.notify(player, "You cannot drop the item that far away!", 1);
					end;
				elseif (arguments[2] == "use") then
					if ( !player:IsAdmin() and player._NextUseItem and player._NextUseItem > CurTime() ) then
						cider.player.notify(player, "You cannot use another item for "..math.ceil( player._NextUseItem - CurTime() ).." second(s)!", 1);
						
						-- Return because we cannot use it.
						return;
					else
						player._NextUseItem = CurTime() + 2;
					end;
					
					-- Check if the player is in a vehicle.
					if ( player:InVehicle() ) then
						cider.player.notify(player, "You cannot use an item in this state!", 1);
						
						-- Return because we cannot use it.
						return;
					end;
					
					-- Check if the player can use the item.
					if ( hook.Call("PlayerCanUseItem", GAMEMODE, player, item) ) then
						if (cider.item.stored[item].weapon) then
							player._NextHolsterWeapon = CurTime() + 5;
						end;
						
						-- Use the item.
						cider.item.use(player, item)
					end;
				end;
			else
				cider.player.notify(player, "You do not own a "..cider.item.stored[item].name.."!", 1);
			end;
		end;
	else
		cider.player.notify(player, "You cannot do that in this state!", 1);
	end;
end, "Commands", "<item> <destroy|drop|use>", "Perform an inventory action on an item.");

-- A command to holster your current weapon.
cider.command.add("holster", "b", 0, function(player, arguments)
	if ( player:Alive() ) then
		local weapon = player:GetActiveWeapon();
		
		-- Check if they can holster another weapon yet.
		if ( !player:IsAdmin() and player._NextHolsterWeapon and player._NextHolsterWeapon > CurTime() ) then
			cider.player.notify(player, "You cannot holster this weapon for "..math.ceil( player._NextHolsterWeapon - CurTime() ).." second(s)!", 1);
			
			-- Return false because we cannot manufacture it.
			return false;
		else
			player._NextHolsterWeapon = CurTime() + 2;
		end;
		
		-- Check if the weapon is a valid entity.
		if ( IsValid(weapon) ) then
			local class = weapon:GetClass();
			
			-- Check if this is a valid item.
			if ( cider.item.stored[class] ) then
				if ( hook.Call("PlayerCanHolster", GAMEMODE, player, class) ) then
					local success, fault = cider.inventory.update(player, class, 1);
					
					-- Check if we didn't succeed.
					if (!success) then
						cider.player.notify(player, fault, 1);
					else
						player:StripWeapon(class);
						
						-- Select their hands.
						player:SelectWeapon("cider_hands");
					end;
				end;
			else
				cider.player.notify(player, "This is not a valid weapon!", 1);
			end;
		else
			cider.player.notify(player, "This is not a valid weapon!", 1);
		end;
	else
		cider.player.notify(player, "You cannot do that in this state!", 1);
	end;
end, "Commands", nil, "Holster your current weapon.");

-- A command to drop your current weapon.
cider.command.add("drop", "b", 0, function(player, arguments)
	if ( player:Alive() ) then
		local weapon = player:GetActiveWeapon();
		
		-- Check if the weapon is a valid entity.
		if ( IsValid(weapon) ) then
			local class = weapon:GetClass();
			
			-- Check if this is a valid item.
			if ( cider.item.stored[class] ) then
				if ( hook.Call("PlayerCanDrop", GAMEMODE, player, class) ) then
					local position = player:GetEyeTrace().HitPos;
					
					-- Check to see if this position is too far away.
					if (player:GetPos():Distance(position) <= 256) then
						cider.item.make( class, position + Vector(0, 0, 32) );
						
						-- Strip the player of their weapon.
						player:StripWeapon(class);
						
						-- Select their hands.
						player:SelectWeapon("cider_hands");
					else
						cider.player.notify(player, "You cannot drop your weapon that far away!", 1);
					end;
				end;
			else
				cider.player.notify(player, "This is not a valid weapon!", 1);
			end;
		else
			cider.player.notify(player, "This is not a valid weapon!", 1);
		end;
	else
		cider.player.notify(player, "You cannot do that in this state!", 1);
	end;
end, "Commands", nil, "Drop your current weapon at your target position.");

-- A command to perform an action on a door.
cider.command.add("door", "b", 1, function(player, arguments)
	if ( player:Alive() ) then
		local door = player:GetEyeTrace().Entity;
		
		-- Check if the player is aiming at a door.
		if ( IsValid(door) and cider.entity.isDoor(door) ) then
			if ( IsValid(door._Owner) ) then
				if (arguments[1] == "purchase") then
					if (door._Owner == player) then
						cider.player.notify(player, "You already own this door!", 1);
					else
						cider.player.notify(player, "This door is owned by "..door._Owner:Name().."!", 1);
					end;
				elseif (arguments[1] == "sell") then
					if (door._Owner == player) then
						if (!door._Unsellable) then
							cider.player.takeDoor(player, door);
						else
							cider.player.notify(player, "This door cannot be sold!", 1);
						end;
					else
						cider.player.notify(player, "This door is owned by "..door._Owner:Name().."!", 1);
					end;
				elseif (arguments[1] == "access") then
					if (door._Owner == player) then
						local entID = tonumber(arguments[2]);
						
						-- Check if it is a valid entity ID.
						if (entID) then
							local target = g_Player.GetByID(entID);
							
							-- Check if we have a valid target.
							if ( IsValid(target) ) then
								local uniqueID = target:UniqueID();
								
								-- Check if the player has access already.
								if (door._Access[uniqueID]) then
									door._Access[uniqueID] = false;
								else
									door._Access[uniqueID] = true;
								end;
							else
								cider.player.notify(player, "This is not a valid player!", 1);
							end;
						else
							cider.player.notify(player, "This is not a valid entity ID!", 1);
						end;
					else
						cider.player.notify(player, "This door is owned by "..door._Owner:Name().."!", 1);
					end;
				elseif (arguments[1] == "name") then
					if (door._Owner == player) then
						local name = table.concat(arguments, " ", 2);
						
						-- Check if the name has any text.
						if (name != "") then
							if ( string.len(name) < 24 ) then
								door:SetNetworkedString("cider_Name", name);
							else
								cider.player.notify(player, "Door names can be a maximum of 32 characters!", 1);
							end;
						else
							cider.player.notify(player, "This is not a valid name!", 1);
						end;
					else
						cider.player.notify(player, "This door is owned by "..door._Owner:Name().."!", 1);
					end;
				end;
			else
				if (arguments[1] == "purchase") then
					if ( hook.Call("PlayerCanOwnDoor", GAMEMODE, player, door) ) then
						local doors = 0;
						
						-- Loop through the entities in the map.
						for k, v in pairs( ents.GetAll() ) do
							if ( cider.entity.isDoor(v) ) then
								if (v._Owner == player) then doors = doors + 1; end;
							end;
						end;
						
						-- Check if we have already got the maximum doors.
						if (doors == cider.configuration["Maximum Doors"]) then
							cider.player.notify(player, "You've hit the doors limit!", 1);
						else
							local cost = cider.configuration["Door Cost"];
							
							-- Check if the player can afford this door.
							if ( cider.player.canAfford(player, cost) ) then
								cider.player.giveMoney(player, -cost);
								
								-- Get the name from the arguments.
								local name = string.sub(table.concat(arguments, " ", 2), 1, 24);
								
								-- Check if the name has any text.
								if (name != "") then
									cider.player.giveDoor(player, door, name);
								else
									cider.player.giveDoor(player, door);
								end;
							else
								local amount = cost - player.cider._Money;
								
								-- Print a message to the player telling them how much they need.
								cider.player.notify(player, "You need another $"..amount.."!", 1);
							end;
						end;
					end;
				elseif (arguments[1] == "sell") then
					cider.player.notify(player, "This door does not have an owner!", 1);
				elseif (arguments[1] == "access") then
					cider.player.notify(player, "This door does not have an owner!", 1);
				elseif (arguments[1] == "name") then
					cider.player.notify(player, "This door does not have an owner!", 1);
				end;
			end;
		else
			cider.player.notify(player, "This is not a valid door!", 1);
		end;
	else
		cider.player.notify(player, "You cannot do that in this state!", 1);
	end;
end, "Commands", "<purchase|sell>", "Perform an action on the door you're looking at.");

-- A command to manufacture an item.
cider.command.add("manufacture", "b", 1, function(player, arguments)
	local item = cider.item.get(arguments[1]);
	
	-- Check if the item exists.
	if (item) then
		if (item.team) then
			if (player:Team() != item.team) then
				cider.player.notify(player, "This item can only be manufactured by "..team.GetName(item.team).."!", 1);
				
				-- Return false because we're not a member of the required team.
				return false;
			end;
		end;
		
		-- Check if the item has a blacklist.
		if (item.blacklist) then
			if ( table.HasValue( item.blacklist, player:Team() ) ) then
				cider.player.notify(player, "This item cannot be manufactured by "..team.GetName( player:Team() ).."!", 1);
				
				-- Return false because we're a member of a blacklisted team.
				return false;
			end;
		end;
		
		-- Check if they can manufacture this item yet.
		if ( !player:IsAdmin() and player._NextManufactureItem and player._NextManufactureItem > CurTime() ) then
			cider.player.notify(player, "You cannot manufacture another item for "..math.ceil( player._NextManufactureItem - CurTime() ).." second(s)!", 1);
			
			-- Return false because we cannot manufacture it.
			return false;
		else
			player._NextManufactureItem = CurTime() + (5 * item.batch);
		end;
		
		-- Check if the player is alive.
		if ( player:Alive() ) then
			if ( cider.player.canAfford(player, item.cost * item.batch) ) then
				if (item.canManufacture) then
					if (item:canManufacture(player, v) == false) then return; end;
				end;
				
				-- Take the cost the from player.
				cider.player.giveMoney( player, -(item.cost * item.batch) );
				
				-- Get a trace line from the player's eye position.
				local trace = player:GetEyeTrace();
				
				-- Create a table to store our created items.
				local items = {};
				
				-- Loop through the amount we're creating.
				for i = 1, item.batch do
					local entity = cider.item.make( item.uniqueID, Vector( trace.HitPos.x, trace.HitPos.y, trace.HitPos.z + 16 + (i * 2) ) );
					
					-- Insert the new entity into our items list.
					table.insert(items, entity);
				end;
				
				-- Loop through our created items and no-collide them with each other.
				for k, v in pairs(items) do
					for k2, v2 in pairs(items) do
						if (v != v2) then
							if ( IsValid(v) and IsValid(v2) ) then
								constraint.NoCollide(v, v2, 0, 0);
							end;
						end;
					end;
				end;
				
				-- Loop through our created items.
				for k, v in pairs(items) do
					if (item.onManufacture) then item:onManufacture(player, v); end;
				end;
				
				-- Check if the item comes as a batch.
				if (item.batch > 1) then
					cider.player.printMessage(player, "You manufactured a shipment of "..item.plural..".");
				else
					cider.player.printMessage(player, "You manufactured a "..item.name..".");
				end;
			else
				local amount = (item.cost * item.batch) - player.cider._Money;
				
				-- Print a message to the player telling them how much they need.
				cider.player.notify(player, "You need another $"..amount.."!", 1);
			end;
		else
			cider.player.notify(player, "You cannot do that in this state!", 1);
		end;
	else
		cider.player.notify(player, "This is not a valid item!", 1);
	end;
end, "Commands", "<item>", "Manufacture an item (usually a shipment).");

-- A command to warrant a player.
cider.command.add("warrant", "b", 1, function(player, arguments)
	local target = cider.player.get(arguments[1])
	
	-- Get the class of the warrant.
	local class = string.lower(arguments[2] or "");
	
	-- Check if a second argument was specified.
	if (class == "search" or class == "arrest") then
		if (target) then
			if ( target:Alive() ) then
				if (target._Warranted != class) then
					if (!target.cider._Arrested) then
						if (CurTime() > target._CannotBeWarranted) then
							if ( hook.Call("PlayerCanWarrant", GAMEMODE, player, target, class) ) then
								hook.Call("PlayerWarrant", GAMEMODE, player, target, class);
								
								-- Warrant the player.
								cider.player.warrant(target, class);
							end;
						else
							cider.player.notify(player, target:Name().." has only just spawned!", 1);
						end;
					else
						cider.player.notify(player, target:Name().." is already arrested!", 1);
					end;
				else
					if (class == "search") then
						cider.player.notify(player, target:Name().." is already warranted for a search!", 1);
					elseif (class == "arrest") then
						cider.player.notify(player, target:Name().." is already warranted for an arrest!", 1);
					end;
				end;
			else
				cider.player.notify(player, target:Name().." is dead and cannot be warranted!", 1);
			end;
		else
			cider.player.notify(player, arguments[1].." is not a valid player!", 1);
		end;
	else
		cider.player.notify(player, "This has changed to /warrant <player> <search|arrest>!", 1);
	end;
end, "Commands", "<player> <search|arrest>", "Warrant a player.");

-- A command to unwarrant a player.
cider.command.add("unwarrant", "b", 1, function(player, arguments)
	local target = cider.player.get(arguments[1])
	
	-- Check to see if we got a valid target.
	if (target) then
		if (target._Warranted) then
			if ( hook.Call("PlayerCanUnwarrant", GAMEMODE, player, target) ) then
				hook.Call("PlayerUnwarrant", GAMEMODE, player, target);
				
				-- Warrant the player.
				cider.player.warrant(target, false);
			end;
		else
			cider.player.notify(player, target:Name().." does not have a warrant!", 1);
		end;
	else
		cider.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Commands", "<player>", "Unwarrant a player.");

-- A command to sleep or wake up.
cider.command.add("sleep", "b", 0, function(player, arguments)
	if (player._Sleeping and player._KnockedOut) then
		cider.player.knockOut(player, false);
		
		-- Set sleeping to false because we are no longer sleeping.
		player._Sleeping = false;
	else
		local position = player:GetPos();
		
		-- Check if the sleep waiting time is greater than 0.
		if (cider.configuration["Sleep Waiting Time"] > 0) then
			cider.player.notify(player, "Stand still for "..cider.configuration["Sleep Waiting Time"].." second(s) to fall asleep.", 0);
		end;
		
		-- Create a timer to check if the player has moved since we started.
		timer.Create("Sleep: "..player:UniqueID(), cider.configuration["Sleep Waiting Time"], 1, function()
			if ( IsValid(player) ) then
				if (player:GetPos() == position) then
					cider.player.knockOut(player, true);
					
					-- Set sleeping to true because we are now sleeping.
					player._Sleeping = true;
				else
					if (cider.configuration["Sleep Waiting Time"] > 0) then
						cider.player.notify(player, "You have moved since you started sleeping!", 1);
					end;
				end;
			end;
		end);
	end;
end, "Commands", nil, "Go to sleep or wake up from sleeping.");

-- A command to send a message to all players on the same team.
cider.command.add("radio", "b", 1, function(player, arguments)
	local text = table.concat(arguments, " ");
	
	-- Say a message as a radio broadcast.
	cider.player.sayRadio(player, text);
end, "Commands", "<text>", "Send a message to all players on your team.");