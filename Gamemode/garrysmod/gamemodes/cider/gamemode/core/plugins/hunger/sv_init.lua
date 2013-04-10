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

-- Called when a player initially spawns.
function PLUGIN.playerInitialSpawn(player) player._Hunger = {}; end;

-- Add the hook.
cider.hook.add("PlayerInitialSpawn", PLUGIN.playerInitialSpawn);

-- Called when a player has initialized.
function PLUGIN.playerInitialized(player)
	player._Hunger.lastTeam = nil;
	player._Hunger.suicided = false;
end;

-- Add the hook.
cider.hook.add("PlayerInitialized", PLUGIN.playerInitialized);

-- Called when a player spawns.
function PLUGIN.postPlayerSpawn(player, lightSpawn, changeTeam)
	if (!lightSpawn) then
		if ( (player._Hunger.suicided or player._Hunger.amount == 100)
		and player._Hunger.lastTeam and player:Team() == player._Hunger.lastTeam ) then
			player._Hunger.amount = 75;
		else
			player._Hunger.amount = 0;
		end;
	end;
	
	-- Set the last team.
	player._Hunger.lastTeam = player:Team();
	player._Hunger.suicided = false;
end;

-- Add the hook.
cider.hook.add("PostPlayerSpawn", PLUGIN.postPlayerSpawn);

-- Called when a player dies.
function PLUGIN.playerDeath(player, inflictor, killer)
	if ( player == killer or !killer:IsPlayer() ) then
		player._Hunger.suicided = true;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerDeath", PLUGIN.playerDeath);

-- Called every second that a player is on the server.
function PLUGIN.playerSecond(player)
	if (player:Alive() and !player.cider._Arrested) then
		player._Hunger.amount = math.Clamp(player._Hunger.amount + 0.075, 0, 100);
		
		-- Set it so that we can get the player's hunger client side.
		cider.player.setLocalPlayerVariable( player, CLASS_LONG, "_Hunger", math.Round(player._Hunger.amount) );
		
		-- Check the player's hunger to see if it's at it's maximum.
		if (player._Hunger.amount == 100) then
			local world = GetWorldEntity();
			
			-- Check if the player is knocked out.
			if (player._KnockedOut) then
				player._Ragdoll.entity:TakeDamage(5, world, world);
			else
				player:TakeDamage(5, world, world);
			end;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("PlayerSecond", PLUGIN.playerSecond);

-- Register the plugin.
cider.plugin.register(PLUGIN);