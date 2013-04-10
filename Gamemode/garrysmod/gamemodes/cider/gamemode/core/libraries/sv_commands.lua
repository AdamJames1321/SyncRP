--[[
Name: "sv_commands.lua".
Product: "Cider (Roleplay)".
--]]

cider.command = {};
cider.command.stored = {};

-- Add a new command.
function cider.command.add(command, access, arguments, callback, category, help, tip)
	cider.command.stored[command] = {access = access, arguments = arguments, callback = callback};
	
	-- Check to see if a category was specified.
	if (category) then
		if (!help or help == "") then
			cider.help.add(category, cider.configuration["Command Prefix"]..command.." <none>.", tip);
		else
			cider.help.add(category, cider.configuration["Command Prefix"]..command.." "..help..".", tip);
		end;
	end;
end;

-- This is called when a player runs a command from the console.
function cider.command.consoleCommand(player, command, arguments)
	if (player._Initialized) then
		if (arguments and arguments[1]) then
			command = arguments[1];
			
			-- Check to see if the command exists.
			if (cider.command.stored[command]) then
				table.remove(arguments, 1);
				
				-- Loop through the arguments and fix Valve's errors.
				for k, v in pairs(arguments) do
					arguments[k] = string.Replace(arguments[k], " ' ", "'");
					arguments[k] = string.Replace(arguments[k], " : ", ":");
				end;
				
				-- Check if the player can use this command.
				if ( hook.Call("PlayerCanUseCommand", GAMEMODE, player, command, arguments) ) then
					if (#arguments >= cider.command.stored[command].arguments) then
						if ( cider.player.hasAccess(player, cider.command.stored[command].access) ) then
							local success, fault = pcall(cider.command.stored[command].callback, player, arguments);
							
							-- Check if we're running on a listen server.
							if ( !GAMEMODE:IsListenServer() ) then
								if (table.concat(arguments, " ") != "") then
									print(player:Name().." used 'cider "..command.." "..table.concat(arguments, " ").."'.");
								else
									print(player:Name().." used 'cider "..command.."'.");
								end;
							end;
							
							-- Check if we have specified any arguments.
							if (table.concat(arguments, " ") != "") then
								cider.player.printConsoleAccess(player:Name().." used 'cider "..command.." "..table.concat(arguments, " ").."'.", "a");
							else
								cider.player.printConsoleAccess(player:Name().." used 'cider "..command.."'.", "a");
							end;
							
							-- Check to see if we did not succeed.
							if (!success) then print(fault); end;
						else
							cider.player.notify(player, "You do not have access to this command, "..player:Name()..".", 1);
						end;
					else
						cider.player.notify(player, "This command requires "..cider.command.stored[command].arguments.." arguments!", 1);
					end;
				end;
			else
				cider.player.notify(player, "This is not a valid command!", 1);
			end;
		else
			cider.player.notify(player, "This is not a valid command!", 1);
		end;
	else
		cider.player.notify(player, "You haven't initialized yet!", 1);
	end;
end;

-- Add a new console command.
concommand.Add("cider", cider.command.consoleCommand);