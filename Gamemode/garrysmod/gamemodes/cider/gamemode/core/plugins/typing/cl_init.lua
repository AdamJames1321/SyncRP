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
		local fadeDistance = cider.configuration["Talk Radius"];
		
		-- Check if the player is alive.
		if ( player:Alive() ) then
			if ( player != LocalPlayer() ) then
				if (!player._KnockedOut) then
					if ( player:GetNetworkedBool("cider_Typing") ) then
						local alpha = math.Clamp(255 - ( (255 / fadeDistance) * player:GetShootPos():Distance( LocalPlayer():GetShootPos() ) ), 0, 255);
						
						-- Define the x and y position.
						local x = player:GetShootPos():ToScreen().x;
						local y = player:GetShootPos():ToScreen().y - 64;
						
						-- Check if the position is visible.
						if (player:GetShootPos():ToScreen().visible) then
							y = y + (32 * (LocalPlayer():GetShootPos():Distance( player:GetShootPos() ) / fadeDistance)) * 0.5;
							
							-- Check if the player is a Combine or the City Administrator.
							if (LocalPlayer():Team() == TEAM_COMBINEOFFICER or LocalPlayer():Team() == TEAM_COMBINEOVERWATCH or LocalPlayer():Team() == TEAM_CITYADMINISTRATOR) then
								if (player:GetNetworkedString("cider_Warranted") != "") then y = y - 32; end;
							end;
							
							-- Draw the information and get the new y position.
							y = GAMEMODE:DrawInformation("Typing", "ChatFont", x, y + math.sin( CurTime() ) * 8, Color(255, 255, 255, 255), alpha)
						end;
					end;
				end;
			end;
		end;
	end;
end);

-- Called when a player starts typing.
cider.hook.add("OpenChatBox", function()
	RunConsoleCommand("cider_typing_start");
end);

-- Called when a player finishes typing.
cider.hook.add("CloseChatBox", function()
	RunConsoleCommand("cider_typing_finish");
end);

-- Register the plugin.
cider.plugin.register(PLUGIN);