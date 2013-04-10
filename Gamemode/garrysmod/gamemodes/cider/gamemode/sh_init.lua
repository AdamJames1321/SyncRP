--[[
Name: "sh_init.lua".
Product: "Cider (Roleplay)".
--]]

GM.Name = "Cider";
GM.Email = "kudomiku@gmail.com";
GM.Author = "Kudomiku";
GM.Website = "http://kudomiku.com";

-- Derive the gamemode from sandbox.
DeriveGamemode("Sandbox");

-- I do this because I use some of these variable names a lot by habbit.
for k, v in pairs(_G) do
	if (!tonumber(k) and type(v) == "table") then
		if (!string.find(k, "%u") and string.sub(k, 1, 1) != "_") then
			_G[ "g_"..string.upper( string.sub(k, 1, 1) )..string.sub(k, 2) ] = v;
		end;
	end;
end;

-- Create the Cider table and the configuration table.
cider = {};
cider.configuration = {};

-- Include the configuration and enumeration files.
include("core/sh_configuration.lua");
include("core/sh_enumerations.lua");

-- Check if we're running on the server.
if (SERVER) then include("core/sv_configuration.lua"); end;

-- Loop through libraries and include them.
for k, v in pairs( file.Find("cider/gamemode/core/libraries/*.lua","LUA") ) do
	if (SERVER) then
		if (string.sub(v, 1, 3) == "sv_" or string.sub(v, 1, 3) == "sh_") then
			include("core/libraries/"..v);
		end;
		if (string.sub(v, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_") then
			AddCSLuaFile("core/libraries/"..v);
		end;
	else
		if (string.sub(v, 1, 3) == "cl_" or string.sub(v, 1, 3) == "sh_") then
			include("core/libraries/"..v);
		end;
	end;
end;

-- Check if we're running on the server.
if (SERVER) then include("core/sv_commands.lua"); end;

-- Loop through plugins and include them.
for k, v in pairs( file.Find("cider/gamemode/core/plugins/*","LUA") ) do
	if (v != "." and v != "..") then
		if (SERVER) then
			if ( file.Exists("../gamemodes/cider/gamemode/core/plugins/"..v.."/sv_init.lua") ) then
				include("core/plugins/"..v.."/sv_init.lua");
			end;
			
			-- Check to see if the client side file exists.
			if ( file.Exists("../gamemodes/cider/gamemode/core/plugins/"..v.."/cl_init.lua") ) then
				AddCSLuaFile("core/plugins/"..v.."/cl_init.lua");
			end;
		else
			if ( file.Exists("../lua_temp/cider/gamemode/core/plugins/"..v.."/cl_init.lua")
				or file.Exists("../gamemodes/cider/gamemode/core/plugins/"..v.."/cl_init.lua") ) then
				include("core/plugins/"..v.."/cl_init.lua");
			end;
		end;
	end;
end;

-- Loop through items and include them.
for k, v in pairs( file.Find("cider/gamemode/core/items/*.lua","LUA") ) do
	include("core/items/"..v);
	
	-- Check to see if we're running on the server.
	if (SERVER) then AddCSLuaFile("core/items/"..v); end;
end;

-- Loop through derma panels and include them.
for k, v in pairs( file.Find("cider/gamemode/core/derma/*.lua","LUA") ) do
	if (CLIENT) then include("core/derma/"..v); else AddCSLuaFile("core/derma/"..v); end;
end;