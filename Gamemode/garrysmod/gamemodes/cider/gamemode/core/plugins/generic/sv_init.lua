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

-- Say a message as a request.
function PLUGIN.sayRequest(player, text)
	for k, v in pairs( g_Player.GetAll() ) do
		if (v:Team() == TEAM_COMBINEOFFICER or v:Team() == TEAM_COMBINEOVERWATCH or v:Team() == TEAM_CITYADMINISTRATOR) then
			cider.chatBox.add(v, player, "request", text);
		end;
	end;
end;

-- Say a message as a broadcast.
function PLUGIN.sayBroadcast(player, text)
	cider.chatBox.add(nil, player, "broadcast", text);
end;

-- Called when a player has initialized.
function PLUGIN.playerInitialized(player)
	if (player.cider._Donator > 0) then
		local expire = math.max(player.cider._Donator - os.time(), 0);
		
		-- Check if the expire time is greater than 0.
		if (expire > 0) then
			local days = math.floor( ( (expire / 60) / 60 ) / 24 );
			local hours = string.format("%02.f", math.floor(expire / 3600));
			local minutes = string.format("%02.f", math.floor(expire / 60 - (hours * 60)));
			local seconds = string.format("%02.f", math.floor(expire - hours * 3600 - minutes * 60));
			
			-- Give them their access.
			cider.player.giveAccess(player, "tpew");
			
			-- Check if we still have at least 1 day.
			if (days > 0) then
				cider.player.printMessage(player, "Your Donator status expires in "..days.." day(s).");
			else
				cider.player.printMessage(player, "Your Donator status expires in "..hours.." hour(s) "..minutes.." minute(s) and "..seconds.." second(s).");
			end;
			
			-- Set some Donator only player variables.
			player._SpawnTime = cider.configuration["Spawn Time"] / 2;
			player._ArrestTime = cider.configuration["Arrest Time"] / 2;
			player._KnockOutTime = cider.configuration["Knock Out Time"] / 2;
		else
			player.cider._Donator = 0;
			
			-- Take away their access and save their data.
			cider.player.takeAccess(player, "tpew");
			cider.player.saveData(player);
			
			-- Notify the player about how their Donator status has expired.
			cider.player.notify(player, "Your Donator status has expired!", 1);
		end;
	end;
	
	-- Make the player a Citizen to begin with.
	cider.team.make(player, TEAM_CITIZEN);
end;

-- Add the hook.
cider.hook.add("PlayerInitialized", PLUGIN.playerInitialized);

-- Called when a player's radio recipients should be adjusted.
function PLUGIN.playerAdjustRadioRecipients(player, text, recipients)
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH
	or player:Team() == TEAM_CITYADMINISTRATOR) then
		for k, v in pairs(recipients) do recipients[k] = nil; end;
		
		-- Add the entries into the recipients table.
		table.Add( recipients, team.GetPlayers(TEAM_COMBINEOFFICER) );
		table.Add( recipients, team.GetPlayers(TEAM_COMBINEOVERWATCH) );
		table.Add( recipients, team.GetPlayers(TEAM_CITYADMINISTRATOR) );
	elseif (player:Team() == TEAM_REBELLEADER or player:Team() == TEAM_REBELDEALER
	or player:Team() == TEAM_REBEL) then
		for k, v in pairs(recipients) do recipients[k] = nil; end;
		
		-- Add the entries into the recipients table.
		table.Add( recipients, team.GetPlayers(TEAM_REBELLEADER) );
		table.Add( recipients, team.GetPlayers(TEAM_REBELDEALER) );
		table.Add( recipients, team.GetPlayers(TEAM_REBEL) );
	end;
end;

-- Add the hook.
cider.hook.add("PlayerAdjustRadioRecipients", PLUGIN.playerAdjustRadioRecipients);

-- Called when a player attempts to use a tool.
function PLUGIN.canTool(player, trace, tool)
	if ( !cider.player.hasAccess(player, "w") ) then
		if (string.sub(tool, 1, 5) == "wire_") then
			player:ConCommand("gmod_toolmode \"\"\n");
			
			-- Return false because we cannot use the tool.
			return false;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("CanTool", PLUGIN.canTool);

-- Called every frame.
function PLUGIN.think()
	if (PLUGIN.lockdown and team.NumPlayers(TEAM_CITYADMINISTRATOR) == 0) then
		PLUGIN.lockdown = false;
		
		-- Set a global integer so that the client can get whether there is a lockdown.
		SetGlobalInt("cider_Lockdown", 0);
	end;
end;

-- Add the hook.
cider.hook.add("Think", PLUGIN.think);

-- Called every second that a player is on the server.
function PLUGIN.playerSecond(player)
	if ( !cider.player.hasAccess(player, "w") ) then
		local tool = player:GetInfo("gmod_toolmode");
		
		-- Check if the tool they are using is a Wire tool.
		if (string.sub(tool, 1, 5) == "wire_") then player:ConCommand("gmod_toolmode \"\"\n"); end;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerSecond", PLUGIN.playerSecond);

-- Called when a player should be given their weapons.
function PLUGIN.playerLoadout(player)
	player._SpawnWeapons = {};
	
	-- Check the player's team.
	if (player:Team() == TEAM_REBELLEADER) then
		player:Give("cider_breakout");
		player:Give("cider_lockpick");
	elseif (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH) then
		player:Give("weapon_stunstick");
		player:Give("cider_glock18");
		player:Give("cider_mp5");
		player:Give("cider_arrest");
		player:Give("cider_unarrest");
		player:Give("cider_knockout");
		player:Give("cider_wakeup");
		player:Give("cider_ram");
		player:GiveAmmo(256, "pistol");
		player:GiveAmmo(512, "smg1");
		
		-- Add to the player's spawn weapons.
		player._SpawnWeapons["cider_glock18"] = true;
		player._SpawnWeapons["cider_mp5"] = true;
		
		-- Check if the player is the Combine Overwatch.
		if (player:Team() == TEAM_COMBINEOVERWATCH) then
			player:Give("cider_m3super90");
			player:Give("weapon_frag");
			player:GiveAmmo(2, "grenade");
			player:GiveAmmo(128, "buckshot");
			
			-- Add to the player's spawn weapons.
			player._SpawnWeapons["cider_m3super90"] = true;
		end;
	elseif (player:Team() == TEAM_CITYADMINISTRATOR) then
		player:Give("cider_ram");
		player:Give("cider_fiveseven");
		player:GiveAmmo(256, "pistol");
		
		-- Add to the player's spawn weapons.
		player._SpawnWeapons["cider_fiveseven"] = true;
	end;
	
	-- Select the hands weapon.
	player:SelectWeapon("cider_hands");
end;

-- Called when a player attempts to holster a weapon.
function PLUGIN.playerCanHolster(player, weapon, silent)
	if ( player._SpawnWeapons[weapon] ) then
		if (!silent) then cider.player.notify(player, "You cannot holster this weapon!", 1); end;
		
		-- Return false because they cannot holster this weapon.
		return false;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanHolster", PLUGIN.playerCanHolster);

-- Called when a player attempts to use a door.
function PLUGIN.playerCanUseDoor(player, door)
	if ( !IsValid(door._Owner) ) then
		if (player:Team() != TEAM_COMBINEOFFICER and player:Team() != TEAM_COMBINEOVERWATCH
		and player:Team() != TEAM_CITYADMINISTRATOR) then
			return false;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanUseDoor", PLUGIN.playerCanUseDoor);

-- Called when a player attempts to use an item.
function PLUGIN.playerCanUseItem(player, item, silent)
	if ( player._SpawnWeapons[item] ) then
		if (!silent) then cider.player.notify(player, "You cannot use this weapon!", 1); end;
		
		-- Return false because they cannot holster this weapon.
		return false;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanUseItem", PLUGIN.playerCanUseItem);

-- Called when a player's salary should be adjusted.
function PLUGIN.playerAdjustSalary(player)
	if (player.cider._Donator > 0) then player._Salary = player._Salary * 2; end;
end;

-- Add the hook.
cider.hook.add("PlayerAdjustSalary", PLUGIN.playerAdjustSalary);

-- Called when a player earns money from contraband.
function PLUGIN.PlayerCanEarnContraband(player)
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH or player:Team() == TEAM_CITYADMINISTRATOR) then
		return false;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanEarnContraband", PLUGIN.PlayerCanEarnContraband);

-- Called when a player attempts to demote another player.
function PLUGIN.playerCanDemote(player, target)
	if (target:Team() == TEAM_CITIZEN) then
		cider.player.notify(player, "You cannot demote a player from Citizen!", 1);
		
		-- Return false because they cannot demote this player.
		return false;
	end;
	
	-- Check to see if we are the City Administrator.
	if (player:Team() == TEAM_CITYADMINISTRATOR) then
		if (target:Team() == TEAM_COMBINEOFFICER or target:Team() == TEAM_COMBINEOVERWATCH) then
			return true;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanDemote", PLUGIN.playerCanDemote);

-- Called when a player attempts to drop a weapon.
function PLUGIN.playerCanDrop(player, weapon, silent, attacker)
	if ( attacker and attacker:IsPlayer() and (attacker:Team() == TEAM_COMBINEOFFICER
	or attacker:Team() == TEAM_COMBINEOVERWATCH or attacker:Team() == TEAM_CITYADMINISTRATOR) ) then
		if (!silent) then cider.player.notify(player, "You cannot drop this weapon!", 1); end;
		
		-- Return false because they cannot drop this weapon.
		return false;
	end;
	
	-- Check if the player spawned with this weapon.
	if ( player._SpawnWeapons[weapon] ) then
		if (!silent) then cider.player.notify(player, "You cannot drop this weapon!", 1); end;
		
		-- Return false because they cannot drop this weapon.
		return false;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanDrop", PLUGIN.playerCanDrop);

-- Called when a player destroys contraband.
function PLUGIN.playerDestroyContraband(player, entity)
	local contraband = cider.configuration["Contraband"][ entity:GetClass() ];
	
	-- Check if the contraband is valid.
	if (contraband) then
		cider.player.giveMoney(player, contraband.money);
		
		-- Notify them about the money they earned.
		cider.player.notify(player, "You earned $"..contraband.money.." for destroying contraband.", 0);
	end;
end;

-- Called when a player dies.
function PLUGIN.playerDeath(player, inflictor, killer)
	if ( killer:IsPlayer() and (killer:Team() == TEAM_COMBINEOFFICER or killer:Team() == TEAM_COMBINEOVERWATCH) ) then
		return;
	else
		if (player:Team() == TEAM_CITYADMINISTRATOR and !player._ChangeTeam) then
			for k, v in pairs( g_Player.GetAll() ) do cider.player.warrant(v, false); end;
			
			-- Make the City Administrator a Citizen again.
			cider.team.make(player, TEAM_CITIZEN); 
		end;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerDeath", PLUGIN.playerDeath);

-- Called when a player is blacklisted from a team.
function PLUGIN.playerBlacklisted(player, team)
	cider.player.holsterAll(player);
	
	-- Make the player a Citizen.
	cider.team.make(player, TEAM_CITIZEN);
end;

-- Called when a player is demoted.
function PLUGIN.playerDemoted(player, team) cider.team.make(player, TEAM_CITIZEN); end;

-- Called when a player attempts to arrest another player.
function PLUGIN.playerCanArrest(player, target)
	if (player:Team() != TEAM_COMBINEOFFICER and player:Team() != TEAM_COMBINEOVERWATCH) then
		cider.player.notify(player, "You do not have access to arrest this player!", 1);
		
		-- Return false because we cannot arrest this player.
		return false;
	else
		if (target:Team() == TEAM_CITYADMINISTRATOR or target:Team() == TEAM_COMBINEOFFICER or target:Team() == TEAM_COMBINEOVERWATCH) then
			return false;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanArrest", PLUGIN.playerCanArrest);

-- Called when a player attempts to knock out a player.
function PLUGIN.playerCanKnockOut(player, target)
	if (player:Team() != TEAM_COMBINEOFFICER and player:Team() != TEAM_COMBINEOVERWATCH) then
		cider.player.notify(player, "You do not have access to knock out this player!", 1);
		
		-- Return false because we cannot arrest this player.
		return false;
	else
		if (target:Team() == TEAM_CITYADMINISTRATOR or target:Team() == TEAM_COMBINEOFFICER or target:Team() == TEAM_COMBINEOVERWATCH) then
			return false;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanKnockOut", PLUGIN.playerCanKnockOut);

-- Called when a player attempts to wake up a player.
function PLUGIN.playerCanWakeUp(player, target)
	if (player:Team() != TEAM_COMBINEOFFICER and player:Team() != TEAM_COMBINEOVERWATCH) then
		cider.player.notify(player, "You do not have access to wake up this player!", 1);
		
		-- Return false because we cannot arrest this player.
		return false;
	else
		if (target:Team() == TEAM_CITYADMINISTRATOR or target:Team() == TEAM_COMBINEOFFICER or target:Team() == TEAM_COMBINEOVERWATCH) then
			return false;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanWakeUp", PLUGIN.playerCanWakeUp);

-- Called when a player attempts to unarrest another player.
function PLUGIN.playerCanUnarrest(player, target)
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH or player:Team() == TEAM_REBELLEADER) then
		return true;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanUnarrest", PLUGIN.playerCanUnarrest);

-- Called when a player spawns.
function PLUGIN.postPlayerSpawn(player, lightSpawn, changeTeam)
	if (player:Team() == TEAM_CITYADMINISTRATOR) then
		if (!lightSpawn or changeTeam) then
			player:GodEnable();
			
			-- The duration that the player will be immune.
			local duration = 30;
			
			-- Check if the player has Donator status.
			if (player.cider._Donator > 0) then duration = 60; end;
			
			-- Set the player's immunity time so that we can get it client side.
			cider.player.setLocalPlayerVariable(player, CLASS_LONG, "_SpawnImmunityTime", CurTime() + duration);
			
			-- Create a timer to disable the player's god mode.
			timer.Create("Spawn Immunity: "..player:UniqueID(), duration, 1, function()
				if ( IsValid(player) ) then player:GodDisable(); end;
			end);
		end;
	else
		timer.Remove( "Spawn Immunity: "..player:UniqueID() );
		
		-- Reset the player's immunity time client side.
		cider.player.setLocalPlayerVariable(player, CLASS_LONG, "_SpawnImmunityTime", 0);
	end;
	
	-- Check if the player is a Combine or the City Administrator.
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH
	or player:Team() == TEAM_CITYADMINISTRATOR) then player._ScaleDamage = 0.5; end;
end;

-- Add the hook.
cider.hook.add("PostPlayerSpawn", PLUGIN.postPlayerSpawn);

-- Called when a player attempts to warrant another player.
function PLUGIN.playerCanWarrant(player, target, class)
	if (class == "search") then
		class = "a search";
	elseif (class == "arrest") then
		class = "an arrest";
	end;
	
	-- Check if we can warrant this player.
	if (target:Team() == TEAM_COMBINEOFFICER or target:Team() == TEAM_COMBINEOVERWATCH) then
		cider.player.notify(player, "You cannot warrant the Combine!", 1);
		
		-- Return false because we cannot warrant them.
		return false;
	elseif (target:Team() == TEAM_CITYADMINISTRATOR) then
		cider.player.notify(player, "You cannot warrant the City Administrator!", 1);
		
		-- Return false because we cannot warrant them.
		return false;
	end;
	
	-- Check if there is a City Administrator.
	if (team.NumPlayers(TEAM_CITYADMINISTRATOR) > 0 and player:Team() != TEAM_CITYADMINISTRATOR) then
		if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH) then
			cider.player.sayRadio(player, "City Administrator could you warrant "..target:Name().." for "..class..".");
		else
			PLUGIN.sayRequest(player, "City Administrator could you warrant "..target:Name().." for "..class..".");
			
			-- Let the player know that their request was sent.
			cider.player.printMessage(player, "Your request has been sent to the City Administrator.");
		end;
		
		-- Return false because we cannot warrant them.
		return false;
	end;
	
	-- Check if the player is not the City Administrator.
	if (player:Team() != TEAM_CITYADMINISTRATOR) then
		if (team.NumPlayers(TEAM_COMBINEOVERWATCH) > 0 and player:Team() != TEAM_COMBINEOVERWATCH) then
			if (player:Team() == TEAM_COMBINEOFFICER) then
				cider.player.sayRadio(player, "Combine Overwatch could you warrant "..target:Name().." for "..class..".");
			else
				PLUGIN.sayRequest(player, "Combine Overwatch could you warrant "..target:Name().." for "..class..".");
				
				-- Let the player know that their request was sent.
				cider.player.printMessage(player, "Your request has been sent to the Combine Overwatch.");
			end;
			
			-- Return false because we cannot warrant them.
			return false;
		end;
	end;
	
	-- Check to see if the player cannot warrant.
	if (player:Team() != TEAM_COMBINEOFFICER and player:Team() != TEAM_COMBINEOVERWATCH
	and player:Team() != TEAM_CITYADMINISTRATOR) then
		cider.player.printMessage(player, "Your request has been sent to the Combine and City Administrator.");
		
		-- Check to see if there is a City Administrator.
		if (team.NumPlayers(TEAM_CITYADMINISTRATOR) > 0) then
			PLUGIN.sayRequest(player, "City Administrator could you warrant "..target:Name().." for "..class..".");
		elseif (team.NumPlayers(TEAM_COMBINEOVERWATCH) > 0) then
			PLUGIN.sayRequest(player, "Combine Overwatch could you warrant "..target:Name().." for "..class..".");
		else
			PLUGIN.sayRequest(player, "Could a Combine Officer warrant "..target:Name().." for "..class..".");
		end;
		
		-- Return false because we cannot warrant them.
		return false;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanWarrant", PLUGIN.playerCanWarrant);

-- Called when a player's warrant has expired.
function PLUGIN.playerWarrantExpired(player, class)
	if (team.NumPlayers(TEAM_CITYADMINISTRATOR) > 0) then
		cider.player.sayRadio(team.GetPlayers(TEAM_CITYADMINISTRATOR)[1], "The "..class.." warrant for "..player:Name().." has expired.");
	elseif (team.NumPlayers(TEAM_COMBINEOVERWATCH) > 0) then
		cider.player.sayRadio(team.GetPlayers(TEAM_COMBINEOVERWATCH)[1], "The "..class.." warrant for "..player:Name().." has expired.");
	elseif (team.NumPlayers(TEAM_COMBINEOFFICER) > 0) then
		cider.player.sayRadio(team.GetPlayers(TEAM_COMBINEOFFICER)[1], "The "..class.." warrant for "..player:Name().." has expired.");
	end;
end;

-- Add the hook.
cider.hook.add("PlayerWarrantExpired", PLUGIN.playerWarrantExpired);

-- Called when a player warrants another player.
function PLUGIN.playerWarrant(player, target, class)
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH
	or player:Team() == TEAM_CITYADMINISTRATOR) then
		if (class == "search") then
			cider.player.sayRadio(player, "I have warranted "..target:Name().." for a search.");
		elseif (class == "arrest") then
			cider.player.sayRadio(player, "I have warranted "..target:Name().." for an arrest.");
		end;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerWarrant", PLUGIN.playerWarrant);

-- Called when a player unwarrants another player.
function PLUGIN.playerUnwarrant(player, target)
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH
	or player:Team() == TEAM_CITYADMINISTRATOR) then
		cider.player.sayRadio(player, "I have unwarranted "..target:Name()..".");
	end;
end;

-- Add the hook.
cider.hook.add("PlayerUnwarrant", PLUGIN.playerUnwarrant);

-- Called when a player demotes another player.
function PLUGIN.playerDemote(player, target, team)
	if (player:Team() == TEAM_CITYADMINISTRATOR) then
		cider.player.sayRadio(player, "I have demoted "..target:Name().." from "..g_Team.GetName(team)..".");
		
		-- Notify the target that they have been demoted.
		cider.player.notify(target, "You have been demoted from "..g_Team.GetName(team)..".");
	else
		cider.player.notifyAll(player:Name().." demoted "..target:Name().." from "..g_Team.GetName(team)..".");
	end;
end;

-- Add the hook.
cider.hook.add("PlayerDemote", PLUGIN.playerDemote);

-- Called when a player wakes up another player.
function PLUGIN.playerWakeUp(player, target)
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH
	or player:Team() == TEAM_CITYADMINISTRATOR) then
		cider.player.sayRadio(player, "I have woken up "..target:Name()..".");
	end;
end;

-- Add the hook.
cider.hook.add("PlayerWakeUp", PLUGIN.playerWakeUp);

-- Called when a player knocks out another player.
function PLUGIN.playerKnockOut(player, target)
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH
	or player:Team() == TEAM_CITYADMINISTRATOR) then
		cider.player.sayRadio(player, "I have knocked out "..target:Name()..".");
	end;
end;

-- Add the hook.
cider.hook.add("PlayerKnockOut", PLUGIN.playerKnockOut);

-- Called when a player arrests another player.
function PLUGIN.playerArrest(player, target)
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH
	or player:Team() == TEAM_CITYADMINISTRATOR) then
		cider.player.sayRadio(player, "I have arrested "..target:Name()..".");
	end;
end;

-- Add the hook.
cider.hook.add("PlayerArrest", PLUGIN.playerArrest);

-- Called when a player unarrests another player.
function PLUGIN.playerUnarrest(player, target)
	if (player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH
	or player:Team() == TEAM_CITYADMINISTRATOR) then
		cider.player.sayRadio(player, "I have unarrested "..target:Name()..".");
	end;
end;

-- Add the hook.
cider.hook.add("PlayerUnarrest", PLUGIN.playerUnarrest);

-- Called when a player attempts to unwarrant another player.
function PLUGIN.playerCanUnwarrant(player, target)
	if (player:Team() == TEAM_CITYADMINISTRATOR or player:Team() == TEAM_COMBINEOFFICER or player:Team() == TEAM_COMBINEOVERWATCH) then
		return true;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanUnwarrant", PLUGIN.playerCanUnwarrant);

-- A command to broadcast to all players.
cider.command.add("broadcast", "b", 1, function(player, arguments)
	if (player:Team() == TEAM_CITYADMINISTRATOR) then
		local text = table.concat(arguments, " ");
		
		-- Check if the there is enough text.
		if (text == "") then
			cider.player.notify(player, "You did not specify enough text!", 1);
			
			-- Return because there wasn't enough text.
			return;
		end;
		
		-- Print a message to all players.
		cider.chatBox.add(nil, player, "broadcast", text);
	else
		cider.player.notify(player, "You are not the City Administrator!", 1);
	end;
end, "Commands", "<text>", "Broadcast a message to all players.");

-- A command to request assistance from the Combine and City Administrator.
cider.command.add("request", "b", 1, function(player, arguments)
	if (player:Team() != TEAM_COMBINEOFFICER and player:Team() != TEAM_COMBINEOVERWATCH and player:Team() != TEAM_CITYADMINISTRATOR) then
		local text = table.concat(arguments, " ");
		
		-- Check if the there is enough text.
		if (text == "") then
			cider.player.notify(player, "You did not specify enough text!", 1);
			
			-- Return because there wasn't enough text.
			return;
		end;
		
		-- Loop through all the players.
		for k, v in pairs( g_Player.GetAll() ) do
			if (v:Team() == TEAM_COMBINEOFFICER or v:Team() == TEAM_COMBINEOVERWATCH or v:Team() == TEAM_CITYADMINISTRATOR) then
				cider.chatBox.add(v, player, "request", text);
			end;
		end;
		
		-- Let them know that their request was sent.
		cider.player.printMessage(player, "Your request has been sent to the Combine and City Administrator.");
	else
		local text = table.concat(arguments, " ");
		
		-- Say a message as a radio broadcast.
		cider.player.sayRadio(player, text);
	end;
end, "Commands", "<text>", "Request assistance from the Combine and City Administrator.");

-- A command to set the Rebel objective.
cider.command.add("objective", "b", 1, function(player, arguments)
	if (player:Team() == TEAM_REBELLEADER) then
		local text = table.concat(arguments, " ");
		
		-- Check if the there is enough text.
		if (text == "") then
			cider.player.notify(player, "You did not specify enough text!", 1);
			
			-- Return because there wasn't enough text.
			return;
		end;
		
		-- Check if the there is too much text.
		if (string.len(text) > 125) then
			cider.player.notify(player, "Objectives can be a maximum of 125 characters!", 1);
			
			-- Return because there was too much text.
			return;
		end;
		
		-- Create a table to store our objective and a variable to store the position of our text.
		local objective = {};
		local position = 1;
		
		-- Do a while loop to store our objective.
		while (string.sub(text, position, position + 30) != "") do
			table.insert( objective, string.sub(text, position, position + 30) );
			
			-- Increase the position.
			position = position + 31;
		end;
		
		-- Loop through our text.
		for k, v in pairs(objective) do SetGlobalString("cider_Objective_"..k, v); end;
		
		-- Loop through any objectives we didnt set.
		for i = #objective + 1, 10 do SetGlobalString("cider_Objective_"..i, ""); end;
		
		-- Notify the player to tell him that the objective has been set.
		cider.player.notify(player, player:Name().." has set the Rebel objective.", 0);
		
		-- Loop through all of the Rebels.
		for k, v in pairs( team.GetPlayers(TEAM_REBEL) ) do
			cider.player.notify(v, player:Name().." has set the Rebel objective.", 0);
		end;
	else
		cider.player.notify(player, "You are not the Rebel Leader", 1);
	end;
end, "Commands", "<text>", "Set the Rebel objective.");

-- A command to initiate lockdown.
cider.command.add("lockdown", "b", 0, function(player, arguments)
	if (player:Team() == TEAM_CITYADMINISTRATOR) then
		if (!PLUGIN.lockdown) then
			PLUGIN.sayBroadcast(player, "A lockdown is in progress. Please return to your home.");
			
			-- Set the lockdown variable to true.
			PLUGIN.lockdown = true;
			
			-- Set a global integer so that the client can get whether there is a lockdown.
			SetGlobalInt("cider_Lockdown", 1);
		else
			cider.player.notify(player, "There is already an active lockdown!", 1);
		end;
	else
		cider.player.notify(player, "You are not the City Administrator!", 1);
	end;
end, "Commands", nil, "Initiate a lockdown.");

-- A command to cancel lockdown.
cider.command.add("unlockdown", "b", 0, function(player, arguments)
	if (player:Team() == TEAM_CITYADMINISTRATOR) then
		if (PLUGIN.lockdown) then
			PLUGIN.sayBroadcast(player, "The lockdown has been cancelled.");
			
			-- Set the lockdown variable to false.
			PLUGIN.lockdown = false;
			
			-- Set a global integer so that the client can get whether there is a lockdown.
			SetGlobalInt("cider_Lockdown", 0);
		else
			cider.player.notify(player, "There is no active lockdown!", 1);
		end;
	else
		cider.player.notify(player, "You are not the City Administrator!", 1);
	end;
end, "Commands", nil, "Cancel a lockdown.");

-- A command to give Donator status to a player.
cider.command.add("donator", "s", 1, function(player, arguments)
	local target = cider.player.get( arguments[1] )
	
	-- Calculate the days that the player will be given Donator status for.
	local days = math.ceil(tonumber( arguments[2] ) or 30);
	
	-- Check if we got a valid target.
	if (target) then
		target.cider._Donator = os.time() + (86400 * days);
		
		-- Give them their access and save their data.
		cider.player.giveAccess(target, "tpew");
		cider.player.saveData(target);
		
		-- Give them the tool and the physics gun.
		target:Give("gmod_tool");
		target:Give("weapon_physgun");
		
		-- Set some Donator only player variables.
		target._SpawnTime = player._SpawnTime / 2;
		target._ArrestTime = player._ArrestTime / 2;
		target._KnockOutTime = player._KnockOutTime / 2;
		
		-- Print a message to all players about this player getting Donator status.
		cider.player.printMessageAll(player:Name().." has given Donator status to "..target:Name().." for "..days.." day(s).");
	else
		cider.player.notify(player, arguments[1].." is not a valid player!", 1);
	end;
end, "Super Admin Commands", "<player> <days|none>", "Give Donator status to a player.");

-- Register the plugin.
cider.plugin.register(PLUGIN)