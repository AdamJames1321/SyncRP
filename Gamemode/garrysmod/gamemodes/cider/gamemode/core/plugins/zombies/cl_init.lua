--[[
Name: "cl_init.lua".
Product: "Cider (Roleplay)".
--]]

local PLUGIN = {};

-- Create a variable to store the plugin for the shared file.
PLUGIN_SHARED = PLUGIN;

-- Include the shared file.
include("sh_init.lua");

-- Called every frame.
function PLUGIN.think()
	for k, v in pairs( ents.FindByClass("class C_ClientRagdoll") ) do
		v._Fade = math.Clamp( (v._Fade or 512) - 2, 0, 512 );
		
		-- Get the color of the entity.
		local r, g, b, a = v:GetColor();
		
		-- Set the alpha of the entity.
		v:SetColor( r, g, b, math.Clamp(v._Fade, 0, 255) );
		
		-- Check if the fade is equal to 0.
		if (v._Fade == 0) then v:Remove(); end;
	end;
end;

-- Add the hook.
cider.hook.add("Think", PLUGIN.think);

-- Register the plugin.
cider.plugin.register(PLUGIN);