--[[
Name: "cl_init.lua".
Product: "Cider (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file.
include("sh_init.lua");

-- Called when the top text should be drawn.
cider.hook.add("DrawTopText", function(text)
	local frags = 8;
	
	-- Check if the player is an administrator.
	if ( LocalPlayer():IsAdmin() ) then return; end;
	
	-- Check if the player has Donator status.
	if ( LocalPlayer():GetNetworkedBool("cider_Donator") ) then frags = frags + 4; end;
	
	-- Check if the player is not warranted.
	if (LocalPlayer():GetNetworkedString("cider_Warranted") != "arrest") then
		if (LocalPlayer():Frags() >= 1) then
			if (LocalPlayer():Frags() >= frags) then
				local seconds = math.floor( (LocalPlayer()._KillResetTime or 0) - CurTime() );
				
				-- Check if the amount of seconds is greater than 60.
				if (seconds > 60) then
					text.y = GAMEMODE:DrawInformation("You have reached maximum kills until "..math.ceil(seconds / 60).." minute(s).", "ChatFont", text.x, text.y, Color(255, 150, 75, 255), 255, true, function(x, y, width, height)
						return x - width - 8, y;
					end);
				else
					text.y = GAMEMODE:DrawInformation("You have reached maximum kills until "..seconds.." second(s).", "ChatFont", text.x, text.y, Color(255, 150, 75, 255), 255, true, function(x, y, width, height)
						return x - width - 8, y;
					end);
				end;
			elseif ( LocalPlayer():Frags() >= (frags - 4) ) then
				text.y = GAMEMODE:DrawInformation("You have reached "..LocalPlayer():Frags().."/"..frags.." kills for this hour.", "ChatFont", text.x, text.y, Color(255, 150, 75, 255), 255, true, function(x, y, width, height)
					return x - width - 8, y;
				end);
			end;
		end;
	else
		text.y = GAMEMODE:DrawInformation("You may kill the Combine and City Administrator.", "ChatFont", text.x, text.y, Color(255, 150, 75, 255), 255, true, function(x, y, width, height)
			return x - width - 8, y;
		end);
	end;
end);

-- Register the plugin.
cider.plugin.register(PLUGIN);