--[[
Name: "init.lua".
Product: "Cider (Roleplay)".
--]]

Msg("Loading tmysql module...\n");
require("tmysql4");


if (tmysql) then
		Msg("Loaded tmysql module... \n");
    else
		Msg("Failed to load tmysql module... \n");
    end

-- Include the shared gamemode file.
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_init.lua")
include("sh_init.lua");

-- Add the Lua files that we need to send to the client.
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("sh_init.lua");
AddCSLuaFile("core/sh_configuration.lua");
AddCSLuaFile("core/sh_enumerations.lua");
AddCSLuaFile("core/scoreboard/admin_buttons.lua");
AddCSLuaFile("core/scoreboard/player_frame.lua");
AddCSLuaFile("core/scoreboard/player_infocard.lua");
AddCSLuaFile("core/scoreboard/player_row.lua");
AddCSLuaFile("core/scoreboard/scoreboard.lua");
AddCSLuaFile("core/scoreboard/vote_button.lua");

-- Add our red glow to the download list.
resource.AddFile("materials/sprites/redglow8.vmt");

-- Enable realistic fall damage for this gamemode.
game.ConsoleCommand("mp_falldamage 1\n");
game.ConsoleCommand("sbox_godmode 0\n");
game.ConsoleCommand("sbox_plpldamage 0\n");

-- Check to see if local voice is enabled.
if (cider.configuration["Local Voice"]) then
	game.ConsoleCommand("sv_voiceenable 1\n");
	game.ConsoleCommand("sv_alltalk 1\n");
	game.ConsoleCommand("sv_voicecodec voice_speex\n");
	game.ConsoleCommand("sv_voicequality 5\n");
end;

-- Some useful ConVars that can be changed in game.
CreateConVar("cider_ooc", 1);

-- Store the old hook.Call function.
hookCall = hook.Call;

-- Overwrite the hook.Call function.
function hook.Call(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
	if (a == "PlayerSay") then d = string.Replace(d, "$q", "\""); end;
	
	-- Call the original hook.Call function.
	return hookCall(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z);
end;

-- A table that will hold entities that were there when the map started.
GM.entities = {};

-- Called when the server initializes.
function GM:Initialize()
	local host = cider.configuration["MySQL Host"];
	local username = cider.configuration["MySQL Username"];
	local password = cider.configuration["MySQL Password"];
	local database = cider.configuration["MySQL Database"];
	
	-- Initialize a connection to the MySQL database.
	local db, err = tmysql.initialize(host, username, password, database, 3306);
	
	if db then
		
		print("[MySQL] Connected to SV_DATABASE!\n")
        SV_DATABASE = db
		
	else
	
        print("[MySQL] Error connecting to SV_DATABASE:\n")
        print(err)
	
	end
	
	db = nil
	err = nil
	
	-- Call the base class function.
	return self.BaseClass:Initialize();
end;

-- Called when a player switches their flashlight on or off.
function GM:PlayerSwitchFlashlight(player, on)
	if (player.cider._Arrested or player._KnockedOut) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to use an entity.
function GM:PlayerUse(player, entity)
	if (player._KnockedOut) then
		return false;
	elseif (player.cider._Arrested) then
		if ( !player._NextNotify or player._NextNotify < CurTime() ) then
			cider.player.notify(player, "You cannot do that in this state!", 1);
			
			-- Set their next notify so that they don't get spammed with the message.
			player._NextNotify = CurTime() + 2;
		end;
		
		-- Return false because they are arrested.
		return false;
	elseif (cider.entity.isDoor(entity) or entity:GetClass() == "prop_dynamic") then
		if ( hook.Call("PlayerCanUseDoor", GAMEMODE, player, entity) ) then
			cider.entity.openDoor(entity, 0);
		end;
	end;
	
	-- Call the base class function.
	return self.BaseClass:PlayerUse(player, entity);
end;

-- Called when a player's warrant has expired.
function GM:PlayerWarrantExpired(player, class) end;

-- Called when a player demotes another player.
function GM:PlayerDemote(player, target, team) end;

-- Called when a player knocks out another player.
function GM:PlayerKnockOut(player, target) end;

-- Called when a player wakes up another player.
function GM:PlayerWakeUp(player, target) end;

-- Called when a player arrests another player.
function GM:PlayerArrest(player, target) end;

-- Called when a player unarrests another player.
function GM:PlayerUnarrest(player, target) end;

-- Called when a player warrants another player.
function GM:PlayerWarrant(player, target, class) end;

-- Called when a player unwarrants another player.
function GM:PlayerUnwarrant(player, target) end;

-- Called when a player attempts to own a door.
function GM:PlayerCanOwnDoor(player, door) return true; end;

-- Called when a player attempts to view a door.
function GM:PlayerCanViewDoor(player, door) return true; end;

-- Called when a player attempts to holster a weapon.
function GM:PlayerCanHolster(player, weapon, silent) return true; end;

-- Called when a player attempts to drop a weapon.
function GM:PlayerCanDrop(player, weapon, silent, attacker) return true; end;

-- Called when a player attempts to use an item.
function GM:PlayerCanUseItem(player, item, silent) return true; end;

-- Called when a player attempts to knock out a player.
function GM:PlayerCanKnockOut(player, target) return true; end;

-- Called when a player attempts to warrant a player.
function GM:PlayerCanWarrant(player, target) return true; end;

-- Called when a player attempts to wake up another player.
function GM:PlayerCanWakeUp(player, target) return true; end;

-- Called when a player attempts to ram a door.
function GM:PlayerCanRamDoor(player, door, silent)
	if ( IsValid(door._Owner) ) then
		if (!door._Owner._Warranted and !door._Owner.cider._Arrested and door._Owner != player) then
			cider.player.notify(player, "This player does not have a search warrant!", 1);
			
			-- Return false because the player requires a warrant.
			return false;
		end;
	end;
	
	-- Return true because we can ram this door.
	return true;
end;

-- Called when a player attempts to use a door.
function GM:PlayerCanUseDoor(player, door)
	if ( IsValid(door._Owner) ) then
		if (!door._Owner._Warranted and door._Owner != player) then
			return false;
		end;
	end;
	
	-- Return true because we can use this door.
	return true;
end;

-- Called when a player enters a vehicle.
function GM:PlayerEnteredVehicle(player, vehicle, role)
	timer.Simple(FrameTime() * 0.5, function()
		if ( IsValid(player) ) then player:SetCollisionGroup(COLLISION_GROUP_PLAYER); end;
	end);
end;

-- Called when a player attempts to join a team.
function GM:PlayerCanJoinTeam(player, team)
	team = cider.team.get(team);
	
	-- Check if this is a valid team.
	if (team) then
		if (player._NextChangeTeam[team.index]) then
			if ( player._NextChangeTeam[team.index] > CurTime() ) then
				local seconds = math.floor( player._NextChangeTeam[team.index] - CurTime() );
				
				-- Notify them that they cannot change to this team yet.
				cider.player.notify(player, "Wait "..seconds.." second(s) to become a "..team.name.."!", 1);
				
				-- Return here because they can't become this team.
				return false;
			end;
		end;
	end;
	
	-- Check if the player is warranted.
	if (player._Warranted) then
		cider.player.notify(player, "You cannot do that while you are warranted!", 1);
		
		-- Return here because they can't become this team.
		return false;
	end;
	
	-- Check if the player is knocked out.
	if (player._KnockedOut) then
		cider.player.notify(player, "You cannot do that in this state!", 1);
		
		-- Return here because they can't become this team.
		return false;
	end;
	
	-- Return true because they can join this team.
	return true;
end;

-- Called when a player earns contraband money.
function GM:PlayerCanEarnContraband(player) return true; end;

-- Called when a player attempts to unwarrant a player.
function GM:PlayerCanUnwarrant(player, target)
	if ( !player:IsAdmin() ) then
		return true;
	else
		cider.player.notify(player, "You do not have access to unwarrant this player!", 1);
		
		-- Return false because they cannot unwarrant this player.
		return false;
	end;
end;


-- Called when a player attempts to demote another player.
function GM:PlayerCanDemote(player, target)
	if ( !player:IsAdmin() ) then
		cider.player.notify(player, "You do not have access to demote this player!", 1);
		
		-- Return false because they cannot demote this player.
		return false;
	else
		return true;
	end;
end;

-- Called when all of the map entities have been initialized.
function GM:InitPostEntity()
	for k, v in pairs( ents.GetAll() ) do self.entities[v] = v; end;
	
	-- Call the base class function.
	return self.BaseClass:InitPostEntity();
end;

-- Called when a player attempts to say something in-character.
function GM:PlayerCanSayIC(player, text)
	if (!player:Alive() or player._KnockedOut) then
		cider.player.notify(player, "You cannot talk in this state!", 1);
		
		-- Return false because we can't say anything.
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to say something in OOC.
function GM:PlayerCanSayOOC(player, text)
	if (player:IsAdmin() or GetConVarNumber("cider_ooc") == 1) then
		return true;
	else
		cider.player.notify(player, "Talking in OOC has been disabled, if you talk OOC in advert you'll be permabanned!", 1);
		
		-- Return false because we cannot talk out-of-character.
		return false;
	end;
end;

-- Called when a player attempts to say something in local OOC.
function GM:PlayerCanSayLOOC(player, text) return true; end;

-- Called when attempts to use a command.
function GM:PlayerCanUseCommand(player, command, arguments)
	if (command == "sleep" and player:Alive() and !player.cider._Arrested and player._Sleeping) then
		return true;
	else
		if (!player:Alive() or player._KnockedOut or player.cider._Arrested) then
			cider.player.notify(player, "You cannot do that in this state!", 1);
			
			-- Return false because we can't say anything.
			return false;
		else
			return true;
		end;
	end;
end;

-- Called when a player says something.
function GM:PlayerSay(player, text, public)
	if ( string.find(text, "CONNA YOU ARE THE GREATEST CODER") ) then return ""; end;
	
	-- Fix Valve's errors.
	text = string.Replace(text, " ' ", "'");
	text = string.Replace(text, " : ", ":");
	
	-- Check if we're speaking on OOC.
	if (string.sub(text, 1, 2) == "//") then
		if (string.Trim( string.sub(text, 3) ) != "") then
			if ( hook.Call("PlayerCanSayOOC", GAMEMODE, player, text) ) then
				cider.chatBox.add( nil, player, "ooc", string.Trim( string.sub(text, 3) ) );
			end;
		end;
	elseif (string.sub(text, 1, 3) == ".//") then
		if (string.Trim( string.sub(text, 4) ) != "") then
			if ( hook.Call("PlayerCanSayLOOC", GAMEMODE, player, text) ) then
				cider.chatBox.addInRadius(player, "looc", string.Trim( string.sub(text, 4) ), player:GetPos(), cider.configuration["Talk Radius"]);
			end;
		end;
	else
		if ( string.sub(text, 1, 1) == cider.configuration["Command Prefix"] ) then
			local arguments = string.Explode(" ", text);
			
			-- Get the command from the arguments.
			local command = string.sub(arguments[1], string.len(cider.configuration["Command Prefix"]) + 1);
			local quote = false;
			
			-- Loop through the arguments that we specified.
			for k, v in pairs(arguments) do
				if (!quote and string.sub(v, 1, 1) == '"') then quote = true; end
				
				-- Check if the key is greater than 1 so that we don't affect the command.
				if (k > 1) then if (!quote) then arguments[k] = "\""..arguments[k].."\""; end; end;
				
				-- Check if we are quoting and the last character is a quote.
				if (quote and string.sub(v, -1) == '"') then quote = false; end;
			end;
			
			-- Run the console command on the player so that we can handle quoted arguments.
			player:ConCommand("cider "..command.." "..table.concat(arguments, " ", 2).."\n");
		else
			if ( hook.Call("PlayerCanSayIC", GAMEMODE, player, text) ) then	
				if (player.cider._Arrested) then
					cider.chatBox.addInRadius(player, "arrested", text, player:GetPos(), cider.configuration["Talk Radius"]);
				else
					cider.chatBox.addInRadius(player, "ic", text, player:GetPos(), cider.configuration["Talk Radius"]);
				end;
			end;
		end;
	end;
	
	-- Return an empty string so the text doesn't show.
	return "";
end;

-- Called when a player attempts suicide.
function GM:CanPlayerSuicide(player) return false; end;

-- Called when a player attempts to punt an entity with the gravity gun.
function GM:GravGunPunt(player, entity) return false; end;

-- Called when a player attempts to pick up an entity with the physics gun.
function GM:PhysgunPickup(player, entity)
	if (self.entities[entity]) then return false; end;
	
	-- Check if the player is an administrator.
	if ( player:IsAdmin() ) then
		if ( entity:IsPlayer() ) then
			if ( !entity:InVehicle() ) then
				entity:SetMoveType(MOVETYPE_NOCLIP);
			else
				return false;
			end;
		end;
		
		-- Return true because administrators can pickup any entity.
		return true;
	end;
	
	-- Check if this entity is a player's ragdoll.
	if ( IsValid(entity._Player) ) then return false; end;
	
	-- Check if the entity is a forbidden class.
	if ( string.find(entity:GetClass(), "npc_")
	or string.find(entity:GetClass(), "cider_")
	or string.find(entity:GetClass(), "prop_dynamic") ) then
		return false;
	end;
	
	-- Call the base class function.
	return self.BaseClass:PhysgunPickup(player, entity);
end;

-- Called when a player attempts to drop an entity with the physics gun.
function GM:PhysgunDrop(player, entity)
	if ( entity:IsPlayer() ) then entity:SetMoveType(MOVETYPE_WALK); end;
end;

-- Called when a player attempts to arrest another player.
function GM:PlayerCanArrest(player, target)
	if (target._Warranted == "arrest") then
		return true;
	else
		cider.player.notify(player, target:Name().." does not have an arrest warrant!", 1);
		
		-- Return false because the target does not have a warrant.
		return false;
	end;
end;

-- Called when a player attempts to unarrest a player.
function GM:PlayerCanUnarrest(player, target)
	if ( !player:IsAdmin() ) then
		return true;
	else
		cider.player.notify(player, "You do not have access to unarrest this player!", 1);
		
		-- Return false because we cannot unarrest this player.
		return false;
	end;
end;

-- Called when a player attempts to spawn an NPC.
function GM:PlayerSpawnNPC(player, model)
	if (!player:Alive() or player.cider._Arrested or player._KnockedOut) then
		cider.player.notify(player, "You cannot do that in this state!", 1);
		
		-- Return false because we cannot spawn it.
		return false;
	end;
	
	-- Check if the player is an administrator.
	if ( !player:IsAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to spawn a prop.
function GM:PlayerSpawnProp(player, model)
	if ( !cider.player.hasAccess(player, "e") ) then return false; end;
	
	-- Check if the player can spawn this prop.
	if (!player:Alive() or player.cider._Arrested or player._KnockedOut) then
		cider.player.notify(player, "You cannot do that in this state!", 1);
		
		-- Return false because we cannot spawn it.
		return false;
	end;
	
	-- Check if the player is an administrator.
	if ( player:IsAdmin() ) then return true; end;
	
	-- Escape the bad characters from the model.
	model = string.Replace(model, "\\", "/");
	model = string.Replace(model, "//", "/");
	
	-- Loop through our banned props to see if this one is banned.
	for k, v in pairs(cider.configuration["Banned Props"]) do
		if ( string.lower(v) == string.lower(model) ) then
			cider.player.notify(player, "You cannot spawn banned props!", 1);
			
			-- Return false because we cannot spawn it.
			return false;
		end;
	end;
	
	-- Check if they can spawn this prop yet.
	if ( player._NextSpawnProp and player._NextSpawnProp > CurTime() ) then
		cider.player.notify(player, "You cannot spawn another prop for "..math.ceil( player._NextSpawnProp - CurTime() ).." second(s)!", 1);
		
		-- Return false because we cannot spawn it.
		return false;
	else
		player._NextSpawnProp = CurTime() + 1;
	end;
	
	-- Call the base class function.
	return self.BaseClass:PlayerSpawnProp(player, model);
end;

-- Called when a player attempts to spawn a ragdoll.
function GM:PlayerSpawnRagdoll(player, model)
	if (!player:Alive() or player.cider._Arrested or player._KnockedOut) then
		cider.player.notify(player, "You cannot do that in this state!", 1);
		
		-- Return false because we cannot spawn it.
		return false;
	end;
	
	-- Check if the player is an administrator.
	if ( !player:IsAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to spawn an effect.
function GM:PlayerSpawnEffect(player, model)
	if (!player:Alive() or player.cider._Arrested or player._KnockedOut) then
		cider.player.notify(player, "You cannot do that in this state!", 1);
		
		-- Return false because we cannot spawn it.
		return false;
	end;
	
	-- Check if the player is an administrator.
	if ( !player:IsAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player attempts to spawn a vehicle.
function GM:PlayerSpawnVehicle(player, model)
	if ( !cider.player.hasAccess(player, "e") ) then return false; end;
	
	-- Check if the model is a chair.
	if ( !string.find(model, "chair") and !string.find(model, "seat") ) then
		return false;
	end;
	
	-- Check if the player can spawn this vehicle.
	if (!player:Alive() or player.cider._Arrested or player._KnockedOut) then
		cider.player.notify(player, "You cannot do that in this state!", 1);
		
		-- Return false because we cannot spawn it.
		return false;
	end;
	
	-- Check if the player is an administrator.
	if ( player:IsAdmin() ) then return true; end;
	
	-- Call the base class function.
	return self.BaseClass:PlayerSpawnVehicle(player, model);
end;

-- A function to check whether we're running on a listen server.
function GM:IsListenServer()
	for k, v in pairs( g_Player.GetAll() ) do
		if ( v:IsListenServerHost() ) then return true; end;
	end;
	
	-- Check if we're running on single player.
	if ( SinglePlayer() ) then return true; end;
	
	-- Return false because there is no listen server host and it isn't single player.
	return false;
end;

-- Called when a player attempts to use a tool.
function GM:CanTool(player, trace, tool)
	if ( player:IsAdmin() ) then return true; end;
	
	-- Check if the trace entity is valid.
	if ( IsValid(trace.Entity) ) then
		if (tool == "nail") then
			local line = {};
			
			-- Set the information for the trace line.
			line.start = trace.HitPos;
			line.endpos = trace.HitPos + player:GetAimVector() * 16;
			line.filter = {player, trace.Entity};
			
			-- Perform the trace line.
			line = util.TraceLine(line);
			
			-- Check if the trace entity is valid.
			if ( IsValid(line.Entity) ) then
				if (self.entities[line.Entity]) then return false; end;
			end;
		end
		
		-- Check if we're using the remover tool and we're trying to remove constrained entities.
		if ( tool == "remover" and player:KeyDown(IN_ATTACK2) and !player:KeyDownLast(IN_ATTACK2) ) then
			local entities = constraint.GetAllConstrainedEntities(trace.Entity);
			
			-- Loop through the constained entities.
			for k, v in pairs(entities) do
				if (self.entities[v]) then return false; end;
			end
		end
		
		-- Check if this entity cannot be used by the tool.
		if (self.entities[trace.Entity]) then return false; end;
		
		-- Check if this entity is a player's ragdoll.
		if ( IsValid(trace.Entity._Player) ) then return false; end;
	end;
	
	-- Call the base class function.
	return self.BaseClass:CanTool(player, trace, tool);
end;

-- Called when a player attempts to noclip.
function GM:PlayerNoClip(player)
	if (player.cider._Arrested or player._KnockedOut) then
		return false;
	else
		if ( player:IsAdmin() ) then
			return true;
		else
			return false;
		end;
	end;
end;

-- Called when the player has initialized.
function GM:PlayerInitialized(player)
	local uniqueID = player:UniqueID();
	
	-- Create a timer to give this player their salary.
	timer.Create("Give Salary: "..uniqueID, cider.configuration["Salary Interval"], 0, function()
		if ( IsValid(player) ) then
			if (player:Alive() and !player.cider._Arrested) then
				cider.player.giveMoney(player, player._Salary);
				
				-- Print a message to the player letting them know they received their salary.
				cider.player.notify(player, "You received $"..player._Salary.." salary.", 0);
			end;
			
			-- Save the player's data.
			cider.player.saveData(player);
		else
			timer.Remove("Give Salary: "..uniqueID);
		end;
	end);
end;

-- Called when a player's data is loaded.
function GM:PlayerDataLoaded(player, success)
	player._Job = cider.configuration["Default Job"];
	player._Ammo = {};
	player._Gender = "Male";
	player._Salary = 0;
	player._Ragdoll = {};
	player._Sleeping = false;
	player._Warranted = false;
	player._LightSpawn = false;
	player._ScaleDamage = false;
	player._Initialized = true;
	player._ChangeTeam = false;
	player._NextChangeTeam = {};
	player._NextSpawnGender = "";
	player._HideHealthEffects = false;
	player._CannotBeWarranted = 0;
	
	-- Some player variables based on configuration.
	player._SpawnTime = cider.configuration["Spawn Time"];
	player._ArrestTime = cider.configuration["Arrest Time"];
	player._KnockOutTime = cider.configuration["Knock Out Time"];

	-- Call a hook for the gamemode.
	hook.Call("PlayerInitialized", GAMEMODE, player);
	
	-- Respawn them now that they have initialized and then freeze them.
	player:Spawn();
	player:Freeze(true);
	
	-- Unfreeze them in a few seconds from now.
	timer.Simple(2, function()
		if ( IsValid(player) ) then
			player:Freeze(false);
			
			-- We can now start updating the player's data.
			player._UpdateData = true;
			
			-- Send a user message to remove the loading screen.
			umsg.Start("cider.player.initialized", player); umsg.End();
		end;
	end);
	
	-- Check if the player is arrested.
	if (player.cider._Arrested) then cider.player.arrest(player, true, true); end;
end;

-- Called when a player initially spawns.
function GM:PlayerInitialSpawn(player)
	if ( IsValid(player) ) then
		cider.player.loadData(player);
		
		-- A table of valid door classes.
		local doorClasses = {
			"func_door",
			"func_door_rotating",
			"prop_door_rotating"
		};
		
		-- Loop through our table of valid door classes.
		for k, v in pairs(doorClasses) do
			for k2, v2 in pairs( ents.FindByClass(v) ) do
				if ( cider.entity.isDoor(v2) ) then
					if (player:UniqueID() == v2._UniqueID) then
						v2._Owner = player;
						
						-- Set the networked owner so that the client can get it.
						v2:SetNetworkedEntity("cider_Owner", player);
					end;
				end;
			end;
		end;
		
		-- A table to store every contraband entity.
		local contraband = {};
		
		-- Loop through each contraband class.
		for k, v in pairs( cider.configuration["Contraband"] ) do
			table.Add( contraband, ents.FindByClass(k) );
		end;
		
		-- Loop through all of the contraband.
		for k, v in pairs(contraband) do
			if (player:UniqueID() == v._UniqueID) then v:SetPlayer(player); end;
		end;
		
		-- Kill them silently until we've loaded the data.
		player:KillSilent();
	end;
end

-- Called every frame that a player is dead.
function GM:PlayerDeathThink(player)
	if (!player._Initialized) then return true; end;
	
	-- Check if the player is a bot.
	if (player:SteamID() == "BOT") then
		if (player.NextSpawnTime and CurTime() >= player.NextSpawnTime) then player:Spawn(); end;
	end;
	
	-- Return the base class function.
	return self.BaseClass:PlayerDeathThink(player);
end;

-- Called when a player's salary should be adjusted.
function GM:PlayerAdjustSalary(player) end;

-- Called when a player's radio recipients should be adjusted.
function GM:PlayerAdjustRadioRecipients(player, text, recipients) end;

-- Called when a player should gain a frag.
function GM:PlayerCanGainFrag(player, victim) return true; end;

-- Called when a player's model should be set.
function GM:PlayerSetModel(player)
	local models = cider.team.query(player:Team(), "models");
	
	-- Check if the models table exists.
	if (models) then
		models = models[ string.lower(player._Gender) ];
		
		-- Check if the models table exists for this gender.
		if (models) then
			local model = models[ math.random(1, #models) ];
			
			-- Set the player's model to the we got.
			player:SetModel(model);
		end;
	end;
end;

-- Called when a player spawns.
function GM:PlayerSpawn(player)
	if (player._Initialized) then
		if (player._NextSpawnGender != "") then
			player._Gender = player._NextSpawnGender; player._NextSpawnGender = "";
		end;
		
		-- Set it so that the player does not drop weapons.
		player:ShouldDropWeapon(false);
		
		-- Check if we're not doing a light spawn.
		if (!player._LightSpawn) then
			player:SetRunSpeed( cider.configuration["Run Speed"] );
			player:SetWalkSpeed( cider.configuration["Walk Speed"] );
			
			-- Set some of the player's variables.
			player._Ammo = {};
			player._Sleeping = false;
			player._ScaleDamage = false;
			player._HideHealthEffects = false;
			player._CannotBeWarranted = CurTime() + 15;
			
			-- Make the player become conscious again.
			cider.player.knockOut(player, false, nil, true);
			
			-- Set the player's model and give them their loadout.
			self:PlayerSetModel(player);
			self:PlayerLoadout(player);
		end;
		
		-- Call a gamemode hook for when the player has finished spawning.
		hook.Call("PostPlayerSpawn", GAMEMODE, player, player._LightSpawn, player._ChangeTeam);
		
		-- Set some of the player's variables.
		player._LightSpawn = false;
		player._ChangeTeam = false;
	else
		player:KillSilent();
	end;
end;

-- Called when a player should take damage.
function GM:PlayerShouldTakeDamage(player, attacker) return true; end;

-- Called when a player is attacked by a trace.
function GM:PlayerTraceAttack(player, damageInfo, direction, trace)
	player._LastHitGroup = trace.HitGroup;
	
	-- Return false so that we don't override internals.
	return false;
end;

-- Called just before a player dies.
function GM:DoPlayerDeath(player, attacker, damageInfo)
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		
		-- Check if this is a valid item.
		if (cider.item.stored[class]) then
			if ( hook.Call("PlayerCanDrop", GAMEMODE, player, class, true, attacker) ) then
				cider.item.make( class, player:GetPos() );
			end;
		end;
	end;
	
	-- Unwarrant them, unarrest them and stop them from bleeding.
	cider.player.warrant(player, false);
	cider.player.arrest(player, false, true);
	cider.player.bleed(player, false);
	
	-- Strip the player's weapons and ammo.
	player:StripWeapons();
	player:StripAmmo();
	
	-- Add a death to the player's death count.
	player:AddDeaths(1);
	
	-- Check it the attacker is a valid entity and is a player.
	if ( IsValid(attacker) and attacker:IsPlayer() ) then
		if (player != attacker) then
			if ( hook.Call("PlayerCanGainFrag", GAMEMODE, attacker, player) ) then
				attacker:AddFrags(1);
			end;
		end;
	end;
end;

-- Called when a player dies.
function GM:PlayerDeath(player, inflictor, attacker, ragdoll)
	if (ragdoll != false) then
		player._Ragdoll.weapons = {};
		player._Ragdoll.health = player:Health();
		player._Ragdoll.model = player:GetModel();
		player._Ragdoll.team = player:Team();
		
		-- Knockout the player to simulate their death.
		cider.player.knockOut(player, true);
	end;
	
	-- Set their next spawn time.
	player.NextSpawnTime = CurTime() + player._SpawnTime;
	
	-- Set it so that we can the next spawn time client side.
	cider.player.setLocalPlayerVariable(player, CLASS_LONG, "_NextSpawnTime", player.NextSpawnTime);
	
	-- Check if the attacker is a player.
	if ( attacker:IsPlayer() ) then
		if ( IsValid( attacker:GetActiveWeapon() ) ) then
			cider.player.printConsoleAccess(attacker:Name().." killed "..player:Name().." with "..attacker:GetActiveWeapon():GetClass()..".", "a");
		else
			cider.player.printConsoleAccess(attacker:Name().." killed "..player:Name()..".", "a");
		end;
	else
		cider.player.printConsoleAccess(attacker:GetClass().." killed "..player:Name()..".", "a");
	end;
end;

-- Called when a player's weapons should be given.
function GM:PlayerLoadout(player)
	if ( cider.player.hasAccess(player, "t") ) then player:Give("gmod_tool"); end
	if ( cider.player.hasAccess(player, "p") ) then player:Give("weapon_physgun"); end
	
	-- Give the player the camera, the hands and the physics cannon.
	player:Give("gmod_camera");
	player:Give("cider_hands");
	player:Give("cider_keys");
	player:Give("weapon_physcannon");
	
	-- Call the player loadout hook.
	cider.plugin.call("playerLoadout", player);
	
	-- Select the hands by default.
	player:SelectWeapon("cider_hands");
end

-- Called when the server shuts down or the map changes.
function GM:ShutDown()
	for k, v in pairs( g_Player.GetAll() ) do
		cider.player.holsterAll(v2);
		
		-- Save the player's data.
		cider.player.saveData(v);
	end;
end;

-- Called when a player presses F1.
function GM:ShowHelp(player) umsg.Start("cider_Menu", player); umsg.End(); end;

-- Called when a player presses F2.
function GM:ShowTeam(player)
	local door = player:GetEyeTrace().Entity;
	
	-- Check if the player is aiming at a door.
	if ( IsValid(door) and cider.entity.isDoor(door) ) then
		if (door:GetPos():Distance( player:GetPos() ) <= 128) then
			if ( hook.Call("PlayerCanViewDoor", GAMEMODE, player, door) ) then
				umsg.Start("cider_Door", player);
					umsg.Bool(door._Unsellable or false);
					
					-- Check if the owner is a valid entity.
					if ( IsValid(door._Owner) ) then
						umsg.Entity(door._Owner);
					else
						umsg.Entity(NULL);
					end;
					
					-- Send the door as an entity and unsellable as a bool.
					umsg.Entity(door);
					
					-- Check if the door has access.
					if (door._Access) then
						for k, v in pairs( g_Player.GetAll() ) do
							if (v != door._Owner) then
								local uniqueID = v:UniqueID();
								
								-- Check if they have access.
								if (door._Access[uniqueID]) then
									umsg.Short( v:EntIndex() );
									umsg.Short(1);
								else
									umsg.Short( v:EntIndex() );
									umsg.Short(0);
								end;
							end;
						end;
					end;
				umsg.End();
			end;
		end;
	end;
end;

-- Called when an entity takes damage.
function GM:EntityTakeDamage(entity, inflictor, attacker, amount, damageInfo)
	if (attacker:IsPlayer() and IsValid( attacker:GetActiveWeapon() )
	and attacker:GetActiveWeapon():GetClass() == "weapon_stunstick") then
		damageInfo:SetDamage(10);
	elseif (attacker:IsPlayer() and IsValid( attacker:GetActiveWeapon() )
	and attacker:GetActiveWeapon():GetClass() == "cider_hands") then
		damageInfo:ScaleDamage(1);
	end;
	
	-- Check if the entity that got damaged is a player.
	if ( entity:IsPlayer() ) then
		if (entity._KnockedOut) then
			if ( IsValid(entity._Ragdoll.entity) ) then
				hook.Call("EntityTakeDamage", GAMEMODE, entity._Ragdoll.entity, inflictor, attacker, damageInfo:GetDamage(), damageInfo);
			end;
		else
			if ( entity:InVehicle() and damageInfo:IsExplosionDamage() ) then
				if (!damageInfo:GetDamage() or damageInfo:GetDamage() == 0) then
					damageInfo:SetDamage(100);
				end;
			end;
			
			-- Check if the player has a last hit group defined.
			if (entity._LastHitGroup) then
				if (entity._LastHitGroup == HITGROUP_HEAD) then
					damageInfo:ScaleDamage( cider.configuration["Scale Head Damage"] );
				elseif (entity._LastHitGroup == HITGROUP_CHEST or entity._LastHitGroup == HITGROUP_GENERIC) then
					damageInfo:ScaleDamage( cider.configuration["Scale Chest Damage"] );
				elseif (entity._LastHitGroup == HITGROUP_LEFTARM or
				entity._LastHitGroup == HITGROUP_RIGHTARM or 
				entity._LastHitGroup == HITGROUP_LEFTLEG or
				entity._LastHitGroup == HITGROUP_RIGHTLEG or
				entity._LastHitGroup == HITGROUP_GEAR) then
					damageInfo:ScaleDamage( cider.configuration["Scale Limb Damage"] );
				end;
				
				-- Set the last hit group to nil so that we don't use it again.
				entity._LastHitGroup = nil;
			end;
			
			-- Check if the player is supposed to scale damage.
			if (entity._ScaleDamage) then damageInfo:ScaleDamage(entity._ScaleDamage); end;
			
			-- Make the player bleed.
			cider.player.bleed( entity, true, cider.configuration["Bleed Time"] );
		end;
	elseif ( entity:IsNPC() ) then
		if (attacker:IsPlayer() and IsValid( attacker:GetActiveWeapon() )
		and attacker:GetActiveWeapon():GetClass() == "weapon_crowbar") then
			damageInfo:ScaleDamage(0.25);
		end;
	end;
	
	-- Check if the entity is a knocked out player.
	if ( IsValid(entity._Player) ) then
		local player = entity._Player;
		
		-- Set the damage to the amount we're given.
		damageInfo:SetDamage(amount);
		
		-- Check if the attacker is not a player.
		if ( !attacker:IsPlayer() ) then
			if ( attacker == GetWorldEntity() ) then
				if ( ( entity._NextWorldDamage and entity._NextWorldDamage > CurTime() )
				or damageInfo:GetDamage() <= 10 ) then return; end;
				
				-- Set the next world damage to be 1 second from now.
				entity._NextWorldDamage = CurTime() + 1;
			else
				if (damageInfo:GetDamage() <= 25) then return; end;
			end;
		else
			damageInfo:ScaleDamage( cider.configuration["Scale Ragdoll Damage"] );
		end;
		
		-- Check if the player is supposed to scale damage.
		if (entity._Player._ScaleDamage) then damageInfo:ScaleDamage(entity._Player._ScaleDamage); end;
		
		-- Take the damage from the player's health.
		player:SetHealth( math.max(player:Health() - damageInfo:GetDamage(), 0) );
		
		-- Set the player's conscious health.
		player._Ragdoll.health = player:Health();
		
		-- Create new effect data so that we can create a blood impact at the damage position.
		local effectData = EffectData();
			effectData:SetOrigin( damageInfo:GetDamagePosition() );
		util.Effect("BloodImpact", effectData);
		
		-- Loop from 1 to 4 so that we can draw some blood decals around the ragdoll.
		for i = 1, 2 do
			local trace = {};
			
			-- Set some settings and information for the trace.
			trace.start = damageInfo:GetDamagePosition();
			trace.endpos = trace.start + (damageInfo:GetDamageForce() + (VectorRand() * 16) * 128);
			trace.filter = entity;
			
			-- Create the trace line from the set information.
			trace = util.TraceLine(trace);
			
			-- Draw a blood decal at the hit position.
			util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
		end;
		
		-- Check to see if the player's health is less than 0 and that the player is alive.
		if ( player:Health() <= 0 and player:Alive() ) then
			player:KillSilent();
			
			-- Call some gamemode hooks to fake the player's death.
			hook.Call("DoPlayerDeath", GAMEMODE, player, attacker, damageInfo);
			hook.Call("PlayerDeath", GAMEMODE, player, inflictor, attacker, false);
		end;
	end;
end; 

-- Called when a player has disconnected.
function GM:PlayerDisconnected(player)
	cider.player.holsterAll(player);
	cider.player.knockOut(player, false, nil, true);
	
	-- Save the player's data.
	cider.player.saveData(player);
	
	-- Call the base class function.
	self.BaseClass:PlayerDisconnected(player);
end;

-- Called when a player attempts to spawn a SWEP.
function GM:PlayerSpawnSWEP(player, class, weapon)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player is given a SWEP.
function GM:PlayerGiveSWEP(player, class, weapon)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when attempts to spawn a SENT.
function GM:PlayerSpawnSENT(player, class)
	if ( !player:IsSuperAdmin() ) then
		return false;
	else
		return true;
	end;
end;

-- Called when a player presses a key.
function GM:KeyPress(player, key)
	if (key == IN_JUMP and player._StuckInWorld) then
		cider.player.holsterAll(player);
		
		-- Spawn them lightly now that we holstered their weapons.
		cider.player.lightSpawn(player);
	end;
end;

-- Create a timer to automatically clean up decals.
timer.Create("Cleanup Decals", 60, 0, function()
	if ( cider.configuration["Cleanup Decals"] ) then
		for k, v in pairs( g_Player.GetAll() ) do v:ConCommand("r_cleardecals\n"); end;
	end;
end);

-- Create a timer to give players money for their contraband.
timer.Create("Contraband", cider.configuration["Contraband Interval"], 0, function()
	local players = {};
	local contraband = {};
	
	-- Loop through each contraband class.
	for k, v in pairs( cider.configuration["Contraband"] ) do
		table.Add( contraband, ents.FindByClass(k) );
	end;
	
	-- Loop through all of the contraband.
	for k, v in pairs(contraband) do
		local player = v:GetPlayer();
		
		-- Check if the player is a valid entity,
		if ( IsValid(player) ) then
			players[player] = players[player] or {refill = 0, money = 0};
			
			-- Decrease the energy of the contraband.
			v._Energy = math.Clamp(v._Energy - 1, 0, 5);
			
			-- Set the networked variable so that the client can use it.
			v:SetNetworkedInt("cider_Energy", v._Energy);
			
			-- Check the energy of the contraband.
			if (v._Energy == 0) then
				players[player].refill = players[player].refill + 1;
			else
				players[player].money = players[player].money + cider.configuration["Contraband"][ v:GetClass() ].money;
			end;
		end;
	end;
	
	-- Loop through our players list.
	for k, v in pairs(players) do
		if ( hook.Call("PlayerCanEarnContraband", GAMEMODE, k) ) then
			if (v.refill > 0) then
				cider.player.notify(k, v.refill.." of your contraband need refilling!", 1);
			elseif (v.money > 0) then
				cider.player.notify(k, "You earned $"..v.money.." from contraband.", 0);
				
				-- Give the player their money.
				cider.player.giveMoney(k, v.money);
			end;
		end;
	end;
end);