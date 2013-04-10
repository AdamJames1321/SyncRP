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

-- Define a new table to store deaths.
PLUGIN.deaths = {};

-- Called when a player has initialized.
function PLUGIN.playerInitialized(player)
	if (PLUGIN.deaths[ player:UniqueID() ]) then
		player:SetDeaths( PLUGIN.deaths[ player:UniqueID() ] );
	end;
end;

-- Add the hook.
cider.hook.add("PlayerInitialized", PLUGIN.playerInitialized);

-- Called when a player has disconnected.
function PLUGIN.playerDisconnected(player)
	local deaths = player:Deaths();
	local uniqueID = player:UniqueID();
	
	-- Store the player's deaths in our table.
	PLUGIN.deaths[uniqueID] = deaths;
end;

-- Add the hook.
cider.hook.add("PlayerDisconnected", PLUGIN.playerDisconnected);

-- Register the plugin.
cider.plugin.register(PLUGIN);