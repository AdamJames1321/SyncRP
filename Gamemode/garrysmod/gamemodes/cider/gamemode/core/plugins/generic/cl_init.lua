--[[
Name: "cl_init.lua".
Product: "Cider (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file.
include("sh_init.lua");

-- Called when a player's HUD should be painted.
cider.hook.add("PlayerHUDPaint", function(player)
	if ( LocalPlayer():Alive() and !LocalPlayer():GetNetworkedBool("cider_KnockedOut") ) then
		if (LocalPlayer():Team() == TEAM_COMBINEOFFICER or LocalPlayer():Team() == TEAM_COMBINEOVERWATCH or LocalPlayer():Team() == TEAM_CITYADMINISTRATOR) then
			if ( player:Alive() ) then
				if (player:GetNetworkedString("cider_Warranted") != "") then
					local alpha = math.Clamp( 255 - ( (255 / 4096) * ( LocalPlayer():GetShootPos():Distance( player:GetShootPos() ) ) ), 0, 255 );
					
					-- Set the text that will display and the color of the text.
					local text = player:Name();
					local color = Color(255, 255, 255, 255);
					
					-- Check the class of the warrant.
					if (player:GetNetworkedString("cider_Warranted") == "search") then
						text = text.." (Search Warrant)"; color = Color(75, 150, 255, 255);
					elseif (player:GetNetworkedString("cider_Warranted") == "arrest") then
						text = text.." (Arrest Warrant)"; color = Color(255, 50, 50, 255);
					end;
					
					-- Define the x and y position.
					local x = player:GetShootPos():ToScreen().x;
					local y = player:GetShootPos():ToScreen().y - 64;
					
					-- Check if the player is knocked out.
					if ( player:GetNetworkedBool("cider_KnockedOut") ) then
						if ( IsValid( player:GetNetworkedEntity("cider_Ragdoll") ) ) then
							x = player:GetNetworkedEntity("cider_Ragdoll"):GetPos():ToScreen().x;
							y = player:GetNetworkedEntity("cider_Ragdoll"):GetPos():ToScreen().y - 64;
						end;
					end;
					
					-- Balance out the y position.
					y = y + (32 * (LocalPlayer():GetShootPos():Distance( player:GetShootPos() ) / 4096)) * 0.5;
					
					-- Draw the information and get the new y position.
					y = GAMEMODE:DrawInformation(text, "ChatFont", x, y + math.sin( CurTime() ) * 8, color, alpha);
				end;
			end;
		end;
	end;
end);

-- Called when the top text should be drawn.
cider.hook.add("DrawTopText", function(text)
	if (GetGlobalInt("cider_Lockdown") == 1) then
		text.y = GAMEMODE:DrawInformation("A lockdown is in progress. Please return to your home.", "ChatFont", text.x, text.y, Color(255, 50, 50, 255), 255, true, function(x, y, width, height)
			return x - width - 8, y;
		end);
	end;
	
	-- Check if the player is the City Administrator.
	if (LocalPlayer():Team() == TEAM_CITYADMINISTRATOR) then
		local _SpawnImmunityTime = LocalPlayer()._SpawnImmunityTime or 0;
		
		-- Check if the spawn immunity time is greater than the current time.
		if ( _SpawnImmunityTime > CurTime() ) then
			local seconds = math.floor( _SpawnImmunityTime - CurTime() );
			
			-- Check if the amount of seconds is greater than 0.
			if (seconds > 0) then
				text.y = GAMEMODE:DrawInformation("You have spawn immunity for "..seconds.." second(s).", "ChatFont", text.x, text.y, Color(150, 255, 75, 255), 255, true, function(x, y, width, height)
					return x - width - 8, y;
				end);
			end;
		end;
	end;
	
	-- Check if the player is warranted.
	if (LocalPlayer():GetNetworkedString("cider_Warranted") != "") then
		local _WarrantExpireTime = LocalPlayer()._WarrantExpireTime;
		
		-- Text which is extended to the notice.
		local extension = ".";
		
		-- Check if the warrant expire time exists.
		if (_WarrantExpireTime) then
			local seconds = math.floor( _WarrantExpireTime - CurTime() );
			
			-- Check if the amount of seconds is greater than 0.
			if (seconds > 0) then
				if (seconds > 60) then
					extension = " which expires in "..math.ceil(seconds / 60).." minute(s).";
				else
					extension = " which expires in "..seconds.." second(s).";
				end;
			end;
		end;
		
		-- Check the class of the warrant.
		if (LocalPlayer():GetNetworkedString("cider_Warranted") == "search") then
			text.y = GAMEMODE:DrawInformation("You have a search warrant"..extension, "ChatFont", text.x, text.y, Color(150, 255, 75, 255), 255, true, function(x, y, width, height)
				return x - width - 8, y;
			end);
		elseif (LocalPlayer():GetNetworkedString("cider_Warranted") == "arrest") then
			text.y = GAMEMODE:DrawInformation("You have an arrest warrant"..extension, "ChatFont", text.x, text.y, Color(150, 255, 75, 255), 255, true, function(x, y, width, height)
				return x - width - 8, y;
			end);
		end;
	end;
	
	-- Check if the player is arrested.
	if ( LocalPlayer():GetNetworkedBool("cider_Arrested") ) then
		local _UnarrestTime = LocalPlayer()._UnarrestTime or 0;
		
		-- Check if the unarrest time is greater than the current time.
		if ( _UnarrestTime > CurTime() ) then
			local seconds = math.floor( _UnarrestTime - CurTime() );
			
			-- Check if the amount of seconds is greater than 0.
			if (seconds > 0) then
				if (seconds > 60) then
					text.y = GAMEMODE:DrawInformation("You will be unarrested in "..math.ceil(seconds / 60).." minute(s).", "ChatFont", text.x, text.y, Color(75, 150, 255, 255), 255, true, function(x, y, width, height)
						return x - width - 8, y;
					end);
				else
					text.y = GAMEMODE:DrawInformation("You will be unarrested in "..seconds.." second(s).", "ChatFont", text.x, text.y, Color(75, 150, 255, 255), 255, true, function(x, y, width, height)
						return x - width - 8, y;
					end);
				end;
			end;
		end;
	end;
	
	-- Check if the player is wearing kevlar.
	if (LocalPlayer()._ScaleDamage == 0.5) then
		text.y = GAMEMODE:DrawInformation("You are wearing kevlar which reduces damage by 50%.", "ChatFont", text.x, text.y, Color(255, 75, 150, 255), 255, true, function(x, y, width, height)
			return x - width - 8, y;
		end);
	end;
end);
	
-- Called when the HUD should be painted.
cider.hook.add("HUDPaint", function()
	if (IsValid( LocalPlayer():GetActiveWeapon() )
	and LocalPlayer():GetActiveWeapon():GetClass() != "gmod_tool"
	and LocalPlayer():GetActiveWeapon():GetClass() != "gmod_camera") then
		if (LocalPlayer():Team() == TEAM_REBEL or LocalPlayer():Team() == TEAM_REBELLEADER) then
			for k, v in pairs( team.GetPlayers(TEAM_REBELLEADER) ) do
				local text = "";
				
				-- Loop through 1 to 10.
				for i = 1, 10 do
					local line = GetGlobalString("cider_Objective_"..i);
					
					-- Check if the line exists.
					if (line != "") then
						line = string.Replace(line, " ' ", "'");
						line = string.Replace(line, " : ", ":");
						
						-- Add the line to our text.
						text = text..line;
					end;
				end;
				
				-- Create a table to store the wrapped text and then get the wrapped text.
				local wrapped = {};
				
				-- Wrap the text into our table.
				cider.chatBox.wrapText(text, "ChatFont", 256, nil, wrapped);
				
				-- Check if we have at least 1 line in our text.
				if (wrapped[1] != "") then
					local width, height = surface.GetTextSize("ChatFont", wrapped[1]);
					
					-- Adjust the maximum width to our objective display.
					width = GAMEMODE:AdjustMaximumWidth("ChatFont", "Rebel Objective", width, 16);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						width = GAMEMODE:AdjustMaximumWidth("ChatFont", v, width, 16);
					end;
					
					-- Draw a box in the the top left corner.
					draw.RoundedBox( 2, 8, 8, width, 22 * (table.Count(wrapped) + 1) + 12, Color(0, 0, 0, 200) );
					
					-- Set the x and y position of the text.
					local x, y = 16, 16;
					
					-- Draw some text to show we're gonna display their objective.
					y = GAMEMODE:DrawInformation("Rebel Objective", "ChatFont", x, y, Color(175, 175, 175, 255), 255, true);
					
					-- Loop through our text.
					for k, v in pairs(wrapped) do
						y = GAMEMODE:DrawInformation(v, "ChatFont", x, y, Color(255, 255, 255, 255), 255, true);
					end;
				end;
				
				-- Break because we only have one Rebel Leader.
				break;
			end;
		end;
	end;
end);

-- Register the plugin.
cider.plugin.register(PLUGIN);