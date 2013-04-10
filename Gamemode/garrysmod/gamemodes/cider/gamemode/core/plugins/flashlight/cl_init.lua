--[[
Name: "cl_init.lua".
Product: "Cider (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file.
include("sh_init.lua");

-- Called when the bottom bars should be drawn.
cider.hook.add("DrawBottomBars", function(bar)
	local flashlight = LocalPlayer()._Flashlight or 100;
	
	-- Check if the flashlight is smaller than 100.
	if (flashlight < 100 and flashlight != -1) then
		GAMEMODE:DrawBar("Default", bar.x, bar.y, bar.width, bar.height, Color(225, 75, 200, 200), "Flashlight: "..flashlight, 100, flashlight, bar);
	end;
end);

-- Register the plugin.
cider.plugin.register(PLUGIN);