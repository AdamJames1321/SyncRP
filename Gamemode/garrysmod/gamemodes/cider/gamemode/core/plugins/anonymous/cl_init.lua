--[[
Name: "cl_init.lua".
Product: "Cider (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file.
include("sh_init.lua");

-- Overwrite some user messages.
usermessage.Hook("NPCKilledNPC", function() end);
usermessage.Hook("PlayerKilledNPC", function() end);
usermessage.Hook("PlayerKilled", function() end);
usermessage.Hook("PlayerKilledSelf", function() end);
usermessage.Hook("PlayerKilledByPlayer", function() end);

-- Register the plugin.
cider.plugin.register(PLUGIN);