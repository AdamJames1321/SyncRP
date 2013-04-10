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

-- Define a new table to store frags.
PLUGIN.frags = {};

-- Called when a player has initialized.
function PLUGIN.playerInitialized(player)
	if ( !PLUGIN.frags[ player:UniqueID() ] ) then
		PLUGIN.frags[ player:UniqueID() ] = CurTime() + 3600;
		
		-- Set the player's kill reset time so that we can get it client side.
		cider.player.setLocalPlayerVariable( player, CLASS_LONG, "_KillResetTime", PLUGIN.frags[ player:UniqueID() ] );
		
		-- Reset the player's frags.
		player:SetFrags(0);
	end;
end;

-- Add the hook.
cider.hook.add("PlayerInitialized", PLUGIN.playerInitialized);

-- Called when a player should gain a frag.
function PLUGIN.playerFragsAdd(player, victim)
	if (player._Warranted == "arrest") then
		if (victim:Team() == TEAM_COMBINEOFFICER or victim:Team() == TEAM_COMBINEOVERWATCH
		or victim:Team() == TEAM_CITYADMINISTRATOR) then
			return false;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerCanGainFrag", PLUGIN.playerFragsAdd);

-- Create a timer to check frags every second.
timer.Create(tostring(PLUGIN), 1, 0, function()
	for k, v in pairs( player.GetAll() ) do
		if ( !v:IsAdmin() ) then
			local frags = 8;
			local uniqueID = v:UniqueID();
			
			-- Check if the player's frags table.
			if ( PLUGIN.frags[uniqueID] and CurTime() > PLUGIN.frags[uniqueID] ) then
				PLUGIN.frags[uniqueID] = CurTime() + 3600;
				
				-- Set the player's kill reset time so that we can get it client side.
				cider.player.setLocalPlayerVariable( v, CLASS_LONG, "_KillResetTime", PLUGIN.frags[uniqueID] );
				
				-- Reset the player's frags.
				v:SetFrags(0);
			else
				if (v.cider._Donator > 0) then frags = frags + 4; end;
				
				-- Check if the player has reached their maximum frags.
				if (v:Frags() > frags) then
					v:SetFrags(0);
					
					-- Set the player's frags table to nil.
					PLUGIN.frags[uniqueID] = nil;
					
					-- Check if Citrus is installed.
					if (citrus) then
						citrus.Bans.Add(v, nil, 172800, "Maximum Kills", true);
					else
						game.ConsoleCommand("banid 120 "..v:SteamID().."\n");
						game.ConsoleCommand("kickid "..v:SteamID().." 2880 Hour Ban (Maximum Kills)\n");
					end;
				end;
			end;
		end;
	end;
end);

-- Register the plugin.
cider.plugin.register(PLUGIN);