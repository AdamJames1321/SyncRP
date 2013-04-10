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

-- A table of entity classes that will be removed when the map is loaded.
PLUGIN.entities = {
	{"rp_tb_city45_v02n", "func_movelinear", Vector(2804.8884, 1413.8890, 182.0313), 512},
	"item_suitcharger",
	"item_healthcharger",
	"weapon_"
};

-- Called when the map has loaded all the entities.
function PLUGIN.initPostEntity()
	for k, v in pairs( ents.GetAll() ) do
		for k2, v2 in pairs(PLUGIN.entities) do
			if (type(v2) == "table") then
				if ( string.find( v:GetClass(), v2[2] )
				and string.lower( game.GetMap() ) == string.lower( v2[1] ) ) then
					if ( !v2[3] or v:GetPos():Distance( v2[3] ) <= (v2[4] or 32) ) then
						v:Remove();
					end;
				end;
			else
				if ( string.find(v:GetClass(), v2) ) then v:Remove(); end;
			end;
		end;
	end;
end;

-- Add the hook.
cider.hook.add("InitPostEntity", PLUGIN.initPostEntity);

-- Register the plugin.
cider.plugin.register(PLUGIN)