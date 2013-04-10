--[[
Name: "sv_init.lua".
Product: "Cider (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file and add it to the client download list.
include("sh_init.lua");
AddCSLuaFile("sh_init.lua");

-- Run some console commands to make sure everything goes smoothly.
RunConsoleCommand("ai_keepragdolls", "0");
RunConsoleCommand("ai_ignoreplayers", "0");
RunConsoleCommand("ai_disabled", "0");

-- A function to load the zombie spawn points.
function PLUGIN.loadSpawnPoints()
	PLUGIN.spawnPoints = {};
	
	-- Check to see if there are zombie spawn points for this map.
	if ( file.Exists("cider/plugins/zombies/"..game.GetMap()..".txt") ) then
		local spawnPoints = util.KeyValuesToTable( file.Read("cider/plugins/zombies/"..game.GetMap()..".txt") );
		
		-- Loop through the spawn points and convert them to a vector.
		for k, v in pairs(spawnPoints) do
			local x, y, z = string.match(v, "(.-), (.-), (.+)");
			
			-- Create a new table to store the data.
			local data = { position = Vector( tonumber(x), tonumber(y), tonumber(z) ) };
			
			-- Insert the data into our spawn points table.
			table.insert(PLUGIN.spawnPoints, data);
		end;
	end;
end;

-- Load the zombie spawn points.
PLUGIN.loadSpawnPoints();

-- A function to save the zombie spawn points.
function PLUGIN.saveSpawnPoints()
	local spawnPoints = {};
	
	-- Loop through the spawn points and add it to our table.
	for k, v in pairs(PLUGIN.spawnPoints) do
		if (!v.timed) then
			table.insert(spawnPoints, v.position.x..", "..v.position.y..", "..v.position.z);
		end;
	end;
	
	-- Write the spawn points to our map file.
	file.Write( "cider/plugins/zombies/"..game.GetMap()..".txt", util.TableToKeyValues(spawnPoints) );
end;

-- Give money to a player.
function PLUGIN.giveMoney(player, money)
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH or player:Team() == TEAM_CITYADMINISTRATOR) then
		if (!player._WarnedAboutZombieTeam) then
			cider.player.notify(player, "The Combine and City Administrator do not gain money from this!", 1);
		end;
		
		-- Warn them about their team.
		player._WarnedAboutZombieTeam = true;
		
		-- This player doesn't get money from killing zombies.
		return;
	else
		player._WarnedAboutZombieTeam = false;
	end;
	
	-- Give the money to the player.
	cider.player.giveMoney(player, money);
	
	-- Notify them about the money they received.
	cider.player.notify(player, "You got $"..money.." for killing a zombie.", 0);
end;

-- Called when an NPC is killed.
function PLUGIN.onNPCKilled(npc, player, weapon)
	if ( player:IsPlayer() ) then
		if (player.cider._Money < 10000) then
			if (npc:GetClass() == "npc_fastzombie") then
				PLUGIN.giveMoney(player, 35);
			elseif (npc:GetClass() == "npc_zombie") then
				PLUGIN.giveMoney(player, 25);
			elseif (npc:GetClass() == "npc_headcrab_fast") then
				PLUGIN.giveMoney(player, 15);
			elseif (npc:GetClass() == "npc_headcrab") then
				PLUGIN.giveMoney(player, 10);
			end;
			
			-- We want to warn them about the zombies next time.
			player._WarnedAboutZombies = false;
		else
			if (!player._WarnedAboutZombies) then
				cider.player.notify(player, "You already have at least $10000!", 1);
				
				-- Warn them about the zombies.
				player._WarnedAboutZombies = true;
			end;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("OnNPCKilled", PLUGIN.onNPCKilled);

-- Create a zombie at a specified position.
function PLUGIN.createZombie(class, position)
	local zombie = ents.Create(class);
	
	-- Set the position and then spawn and activate it.
	zombie:SetPos(position);
	zombie:Spawn();
	zombie:Activate();
	
	-- Return the new zombie entity.
	return zombie;
end;

-- A command to add a zombie spawn point.
cider.command.add("zombie", "a", 1, function(player, arguments)
	if (arguments[1] == "add") then
		local position = player:GetEyeTrace().HitPos;
		
		-- Add the position to our spawn points table.
		table.insert( PLUGIN.spawnPoints, {position = position} );
		
		-- Save the spawn points.
		PLUGIN.saveSpawnPoints();
		
		-- Print a message to the player tell tell him that the jail point has been added.
		cider.player.printMessage(player, "You have added a zombie spawn point.");
	elseif (arguments[1] == "timed") then
		local minutes = tonumber(arguments[2]);
		
		-- Check if this is a valid amount of minutes.
		if (minutes and minutes > 0) then
			local position = player:GetEyeTrace().HitPos;
			
			-- Add the position to our spawn points table.
			table.insert( PLUGIN.spawnPoints, {position = position, timed = true} );
			
			-- Get the last index created.
			local index = #PLUGIN.spawnPoints;
			
			-- Create a simple timer to remove the spawn point.
			timer.Simple(minutes * 60, function()
				if (PLUGIN.spawnPoints[index]) then
					if ( IsValid(PLUGIN.spawnPoints[index].zombie) ) then
						PLUGIN.spawnPoints[index].zombie:Remove();
					end;
					
					-- Remove it from the table.
					PLUGIN.spawnPoints[index] = nil;
				end;
			end);
			
			-- Print a message to the player tell tell him that the jail point has been added.
			cider.player.printMessage(player, "You have added a timed zombie spawn point.");
		else
			cider.player.notify(player, "This is not a valid amount of minutes!", 1);
		end;
	elseif (arguments[1] == "remove") then
		local position = player:GetEyeTrace().HitPos;
		local removed = 0;
		
		-- Loop through our zombie spawn points to find ones near this position.
		for k, v in pairs(PLUGIN.spawnPoints) do
			if (v.position:Distance(position) <= 256) then
				if ( IsValid(v.zombie) ) then v.zombie:Remove(); end;
				
				-- Remove it from the table.
				PLUGIN.spawnPoints[k] = nil;
				
				-- Increase the amount that we removed.
				removed = removed + 1;
			end;
		end;
		
		-- Check if we removed more than 0 spawn points.
		if (removed > 0) then
			if (removed == 1) then
				cider.player.printMessage(player, "You have removed "..removed.." zombie spawn point.");
			else
				cider.player.printMessage(player, "You have removed "..removed.." zombie spawn points.");
			end;
		else
			cider.player.printMessage(player, "There were no zombie spawn points near this position.");
		end;
		
		-- Save the zombie spawn points.
		PLUGIN.saveSpawnPoints();
	end;
end, "Admin Commands", "<add|remove|timed> <minutes|none>", "Add or remove a zombie spawn point.");

-- Create a timer to create zombies if the old ones have died.
timer.Create("cider.zombies.create", 15, 0, function()
	for k, v in pairs(PLUGIN.spawnPoints) do
		if ( !IsValid(v.zombie) ) then
			local class = math.random(1, 2);
			
			-- Check if the random class is a regular zombie.
			if (class == 1) then
				v.zombie = PLUGIN.createZombie("npc_zombie", v.position);
			elseif (class == 2) then
				v.zombie = PLUGIN.createZombie("npc_fastzombie", v.position);
			end;
		end;
	end;
end);

-- Register the plugin.
cider.plugin.register(PLUGIN)