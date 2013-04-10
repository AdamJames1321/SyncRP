--[[
Name: "sh_init.lua".
Product: "Cider (Roleplay)".
--]]

local PLUGIN = PLUGIN_SHARED;

-- Set some information for the plugin.
PLUGIN.name = "Hunger";
PLUGIN.author = "Kudomiku";

-- Add the Chef team.
TEAM_CHEF = cider.team.add("Chef", Color(255, 125, 200, 255), "models/player/group01/male_02.mdl", "models/player/group01/female_01.mdl", "Deals food to the city's inhabitants.", 60, 6, nil, true);