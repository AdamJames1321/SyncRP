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
	if (PLUGIN.frags[ player:UniqueID() ]) then
		player:SetFrags( PLUGIN.frags[ player:UniqueID() ] );
	end;
end;

-- Add the hook.
cider.hook.add("PlayerInitialized", PLUGIN.playerInitialized);

-- Called when a player has disconnected.
function PLUGIN.playerDisconnected(player)
	local frags = player:Frags();
	local uniqueID = player:UniqueID();
	
	-- Store the player's frags in our table.
	PLUGIN.frags[uniqueID] = frags;
end;

-- Add the hook.
cider.hook.add("PlayerDisconnected", PLUGIN.playerDisconnected);

-- Register the plugin.
cider.plugin.register(PLUGIN);