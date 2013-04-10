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

-- Called when a player spawns.
function PLUGIN.postPlayerSpawn(player, light)
	if (!light) then player._Flashlight = 100; end;
end;

-- Add the hook.
cider.hook.add("PostPlayerSpawn", PLUGIN.postPlayerSpawn);

-- Called when a player switches their flashlight on or off.
function PLUGIN.playerSwitchFlashlight(player, on)
	if (on and player._Flashlight < 10 and player._Flashlight != -1) then return false; end;
end;

-- Add the hook.
cider.hook.add("PlayerSwitchFlashlight", PLUGIN.playerSwitchFlashlight);

-- Called every tenth of a second that a player is on the server.
function PLUGIN.playerTenthSecond(player)
	if (!player.cider._Arrested and player._Flashlight != -1) then
		if ( player:FlashlightIsOn() ) then
			player._Flashlight = math.Clamp(player._Flashlight - 0.75, 0, 100);
			
			-- Check the player's stamina to see if it's at it's maximum.
			if (player._Flashlight == 0) then player:Flashlight(false); end;
		else
			player._Flashlight = math.Clamp(player._Flashlight + 0.5, 0, 100);
		end;
	end;
	
	-- Check if the player has -1 flashlight power.
	if (player._Flashlight == -1) then
		cider.player.setLocalPlayerVariable(player, CLASS_LONG, "_Flashlight", -1);
	else
		cider.player.setLocalPlayerVariable( player, CLASS_LONG, "_Flashlight", math.Round(player._Flashlight) );
	end;
end;

-- Add the hook.
cider.hook.add("PlayerTenthSecond", PLUGIN.playerTenthSecond);

-- Register the plugin.
cider.plugin.register(PLUGIN)