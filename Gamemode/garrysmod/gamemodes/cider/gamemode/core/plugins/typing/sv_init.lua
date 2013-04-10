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

-- A console command to tell all players that a player is typing.
concommand.Add("cider_typing_start", function(player, command, arguments)
	if (player:Alive() and !player._KnockedOut) then
		player:SetNetworkedBool("cider_Typing", true);
	end;
end);

-- A console command to tell all players that a player has finished typing.
concommand.Add("cider_typing_finish", function(player, command, arguments)
	if ( IsValid(player) ) then
		player:SetNetworkedBool("cider_Typing", false);
	end;
end);

-- Register the plugin.
cider.plugin.register(PLUGIN)