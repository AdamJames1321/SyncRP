--[[
Name: "sh_help.lua".
Product: "Cider (Roleplay)".
--]]

cider.help = {};
cider.help.stored = {};
cider.help.category = nil;

-- Add a new line of help to the specified category.
function cider.help.add(category, help, tip)
	local new = true;
	
	-- Loop through the help to try and find the category.
	for k, v in pairs(cider.help.stored) do
		if (v.category == category) then
			if (help) then table.insert( v.help, {text = help, tip = tip} ); end;
			
			-- Set the new variable to false because we found an existing category.
			new = false;
		end;
	end;
	
	-- Check to see if we should create a new category.
	if (new) then
		if (help) then
			table.insert( cider.help.stored, { category = category, help = {help} } );
		else
			table.insert( cider.help.stored, { category = category, help = {} } );
		end;
	end;
	
	-- Check if we have any help to send.
	if (help) then
		if (CLIENT) then
			if (cider.help.panel) then cider.help.panel:Reload(); end;
		else
			umsg.Start("cider.help.category", player) umsg.String(category); umsg.End();
			umsg.Start("cider.help.help", player)
				umsg.String(help);
				
				-- Check to see if we supplied a tip.
				if (tip) then umsg.String(tip); end;
			umsg.End();
		end;
	end;
end;

-- Add the common help categories.
cider.help.add("General");
cider.help.add("Commands");
cider.help.add("Admin Commands");
cider.help.add("Super Admin Commands");

-- Check if we're running on the client.
if (CLIENT) then
	usermessage.Hook("cider.help.category", function(msg)
		cider.help.category = msg:ReadString();
	end);
	
	-- A usermessage to get a line of help from the server.
	usermessage.Hook("cider.help.help", function(msg)
		local help = msg:ReadString();
		local tip = msg:ReadString();
		
		-- Add the help to the specified category.
		cider.help.add(cider.help.category, help, tip);
	end);
	
	-- Add some general help.
	cider.help.add("General", "You may get better help if you hover over the text.");
	
	-- Add some general help.
	cider.help.add("General", "If you have less than $10000 you can kill zombies for money.");
	cider.help.add("General", "Using any exploits will get you banned permanently.");
	cider.help.add("General", "Use // before your message to talk in OOC.");
	cider.help.add("General", "Use .// before your message to talk in local OOC.");
	cider.help.add("General", "Press F1 to see the main menu.");
	cider.help.add("General", "Press F2 to see the door menu.");
else
	function cider.help.playerInitialized(player)
		timer.Simple(2, function()
			if ( IsValid(player) ) then
				for k, v in pairs(cider.help.stored) do
					umsg.Start("cider.help.category", player) umsg.String(v.category); umsg.End();
					
					-- Loop through the help in this category.
					for k2, v2 in pairs(v.help) do
						umsg.Start("cider.help.help", player)
							umsg.String(v2.text);
							
							-- Check to see if we have a tip.
							if (v2.tip) then umsg.String(v2.tip); end;
						umsg.End();
					end;
				end;
				
				-- Show the player the help menu.
				GAMEMODE:ShowHelp(player);
			end;
		end);
	end;
	
	-- Add the hook on a timer.
	timer.Simple(FrameTime() * 0.5, function()
		cider.hook.add("PlayerInitialized", cider.help.playerInitialized);
	end);
end;