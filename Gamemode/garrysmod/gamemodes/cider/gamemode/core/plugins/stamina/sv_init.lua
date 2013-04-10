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
function PLUGIN.postPlayerSpawn(player, lightSpawn, changeTeam)
	if (!lightSpawn) then player._Stamina = 100; end;
end;

-- Add the hook.
cider.hook.add("PostPlayerSpawn", PLUGIN.postPlayerSpawn);

-- Called when a player presses a key.
function PLUGIN.keyPress(player, key)
	if (!player.cider._Arrested) then
		if (player:Alive() and !player._KnockedOut) then
			if (player:IsOnGround() and key == IN_JUMP) then
				player._Stamina = math.Clamp(player._Stamina - 5, 0, 100);
			end;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("KeyPress", PLUGIN.keyPress);

-- Called every tenth of a second that a player is on the server.
function PLUGIN.playerTenthSecond(player)
	if (!player.cider._Arrested) then
		if (player:KeyDown(IN_SPEED) and player:Alive() and !player._KnockedOut
		and player:GetVelocity():Length() > 0) then
			if (player:Health() < 50) then
				player._Stamina = math.Clamp(player._Stamina - (0.75 + ( ( 50 - player:Health() ) * 0.05 ) ), 0, 100);
			else
				player._Stamina = math.Clamp(player._Stamina - 0.75, 0, 100);
			end;
		else
			if (player:Health() < 50) then
				player._Stamina = math.Clamp(player._Stamina + (0.25 - ( ( 50 - player:Health() ) * 0.0025 ) ), 0, 100);
			else
				player._Stamina = math.Clamp(player._Stamina + 0.25, 0, 100);
			end;
		end;
		
		-- Check the player's stamina to see if it's at it's maximum.
		if (player._Stamina <= 1) then
			player:SetRunSpeed(cider.configuration["Run Speed"] / 2);
		else
			player:SetRunSpeed(cider.configuration["Run Speed"]);
		end;
	end;
	
	-- Set it so that we can get the player's stamina client side.
	cider.player.setLocalPlayerVariable( player, CLASS_LONG, "_Stamina", math.Round(player._Stamina) );
end;

-- Add the hook.
cider.hook.add("PlayerTenthSecond", PLUGIN.playerTenthSecond);

-- Register the plugin.
cider.plugin.register(PLUGIN)