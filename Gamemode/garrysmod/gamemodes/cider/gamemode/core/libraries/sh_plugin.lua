--[[
Name: "sh_plugin.lua".
Product: "Cider (Roleplay)".
--]]

cider.plugin = {};
cider.plugin.stored = {};

-- Register a new plugin.
function cider.plugin.register(plugin)
	cider.plugin.stored[plugin.name] = plugin;
end;

-- Call a function for all plugins.
function cider.plugin.call(name, ...)
	for k, v in pairs(cider.plugin.stored) do
		if (type(v[name]) == "function") then
			local success, message = pcall( v[name], unpack(arg) )
			
			-- Check to see if we did not success.
			if (!success) then Msg(message.."\n"); end;
		end;
	end;
end;

-- Get a plugin by it's name.
function cider.plugin.get(name) return cider.plugin.stored[name]; end;