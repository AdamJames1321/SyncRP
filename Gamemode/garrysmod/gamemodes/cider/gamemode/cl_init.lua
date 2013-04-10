--[[
Name: "cl_init.lua".
Product: "Cider (Roleplay)".
--]]

include("sh_init.lua");
include("core/scoreboard/scoreboard.lua");

-- Set some information for the gamemode.
GM.topTextGradient = {};
GM.variableQueue = {};
GM.ammoCount = {};

-- Add a usermessage to recieve a notification.
usermessage.Hook("cider_Notification", function(msg)
	local message = msg:ReadString();
	local class = msg:ReadShort();
	
	-- The sound of the notification.
	local sound = "ambient/water/drip2.wav";
	
	-- Check the class of the message.
	if (class == 1) then
		sound = "buttons/button10.wav";
	elseif (class == 2) then
		sound = "buttons/button17.wav";
	elseif (class == 3) then
		sound = "buttons/bell1.wav";
	elseif (class == 4) then
		sound = "buttons/button15.wav";
	end
	
	-- Play the sound to the local player.
	surface.PlaySound(sound);
	
	-- Add the notification using Garry's system.
	GAMEMODE:AddNotify(message, class, 10);
end);

-- Override the weapon pickup function.
function GM:HUDWeaponPickedUp(...) end;

-- Override the item pickup function.
function GM:HUDItemPickedUp(...) end;

-- Override the ammo pickup function.
function GM:HUDAmmoPickedUp(...) end;

-- Called when an entity is created.
function GM:OnEntityCreated(entity)
	if (LocalPlayer() == entity) then
		for k, v in pairs(self.variableQueue) do LocalPlayer()[k] = v; end;
	end;
	
	-- Call the base class function.
	return self.BaseClass:OnEntityCreated(entity);
end;

-- Called when a player presses a bind.
function GM:PlayerBindPress(player, bind, press)
	if ( !self.playerInitialized and string.find(bind, "+jump") ) then
		RunConsoleCommand("retry");
	end;
	
	-- -- Check if they're trying to use a binded Cider command.
	-- if ( string.find(bind, "cider ") or string.find(bind, "say /") ) then
		-- if ( !player:GetNetworkedBool("cider_Donator") ) then
			-- player:ChatPrint("Only Donators can use binded Cider commands!");
			
			-- -- Return true because they cannot use the command.
			-- return true;
		-- end;
	-- end;
	
	-- Call the base class function.
	return self.BaseClass:PlayerBindPress(player, bind, press);
end;

-- Check if the local player is using the camera.
function GM:IsUsingCamera()
	if (IsValid( LocalPlayer():GetActiveWeapon() )
	and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera") then
		return true;
	else
		return false;
	end;
end;

-- Hook into when the server sends us a variable for the local player.
usermessage.Hook("cider._LocalPlayerVariable", function(message)
	local class = message:ReadChar();
	local key = message:ReadString();
	
	-- Create the variable which we'll store our received variable in.
	local variable = nil;
	
	-- Check if we can get what class of variable it is.
	if (class == CLASS_STRING) then
		variable = message:ReadString();
	elseif (class == CLASS_LONG) then
		variable = message:ReadLong();
	elseif (class == CLASS_SHORT) then
		variable = message:ReadShort();
	elseif (class == CLASS_BOOL) then
		variable = message:ReadBool();
	elseif (class == CLASS_VECTOR) then
		variable = message:ReadVector();
	elseif (class == CLASS_ENTITY) then
		variable = message:ReadEntity();
	elseif (class == CLASS_ANGLE) then
		variable = message:ReadAngle();
	elseif (class == CLASS_CHAR) then
		variable = message:ReadChar();
	elseif (class == CLASS_FLOAT) then
		variable = message:ReadFloat();
	end;
	
	-- Check if the local player is a valid entity.
	if ( IsValid( LocalPlayer() ) ) then
		LocalPlayer()[key] = variable;
		
		-- Set the variable queue variable to nil so that we don't overwrite it later on.
		GAMEMODE.variableQueue[key] = nil;
	else
		GAMEMODE.variableQueue[key] = variable;
	end;
end);

-- A function to override whether a HUD element should draw.
function GM:HUDShouldDraw(name)
	if (!self.playerInitialized) then
		if (name != "CHudGMod") then return false; end;
	else
		if (name == "CHudHealth" or name == "CHudBattery" or name == "CHudSuitPower"
		or name == "CHudAmmo" or name == "CHudSecondaryAmmo") then
			return false;
		end;
		
		-- Return true if it's none of the others.
		return true;
	end;
	
	-- Call the base class function.
	return self.BaseClass:HUDShouldDraw(name);
end

-- A function to adjust the width of something by making it slightly more than the width of a text.
function GM:AdjustMaximumWidth(font, text, width, addition, extra)
	surface.SetFont(font);
	
	-- Get the width of the text.
	local textWidth = surface.GetTextSize( tostring( string.Replace(text, "&", "U") ) ) + (extra or 0);
	
	-- Check if the width of the text is greater than our current width.
	if (textWidth > width) then width = textWidth + (addition or 0); end;
	
	-- Return the new width.
	return width;
end;

-- A function to draw a bar with a maximum and a variable.
function GM:DrawBar(font, x, y, width, height, color, text, maximum, variable, bar)
	draw.RoundedBox( 2, x, y, width, height, Color(0, 0, 0, 200) );
	draw.RoundedBox( 0, x + 2, y + 2, width - 4, height - 4, Color(25, 25, 25, 150) );
	draw.RoundedBox( 0, x + 2, y + 2, math.Clamp( ( (width - 4) / maximum ) * variable, 0, width - 4 ), height - 4, color );
	
	-- Set the font of the text to this one.
	surface.SetFont(font);
	
	-- Adjust the x and y positions so that they don't screw up.
	x = math.floor( x + (width / 2) );
	y = math.floor(y + 1);
	
	-- Draw text on the bar.
	draw.DrawText(text, font, x + 1, y + 1, Color(0, 0, 0, 255), 1);
	draw.DrawText(text, font, x, y, Color(255, 255, 255, 255), 1);
	
	-- Check if a bar table was specified.
	if (bar) then bar.y = bar.y - (height + 4); end;
end;

-- Get the bouncing position of the screen's center.
function GM:GetScreenCenterBounce(bounce)
	return ScrW() / 2, (ScrH() / 2) + 32 + ( math.sin( CurTime() ) * (bounce or 8) );
end;

-- Called when the target ID should be drawn.
function GM:HUDDrawTargetID()
	if ( LocalPlayer():Alive() and !LocalPlayer():GetNetworkedBool("cider_KnockedOut") ) then
		local trace = LocalPlayer():GetEyeTrace();
		
		-- Set the distance that text will be completely faded to the same as the talk radius.
		local fadeDistance = cider.configuration["Talk Radius"];
		
		-- Check if we hit a valid entity.
		if ( IsValid(trace.Entity) ) then
			local class = trace.Entity:GetClass();
			
			-- Check if the entity is a player.
			if ( trace.Entity:IsPlayer() ) then
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the player's name.
				y = self:DrawInformation(trace.Entity:Name(), "ChatFont", x, y, team.GetColor( trace.Entity:Team() ), alpha);
				
				-- Check if the player is in a clan.
				if (trace.Entity:GetNetworkedString("cider_Clan") != "") then
					y = self:DrawInformation("Clan: "..trace.Entity:GetNetworkedString("cider_Clan"), "ChatFont", x, y, Color(255, 255, 255, 255), alpha);
				end;
				
				-- Draw the player's job.
				y = self:DrawInformation("Job: "..trace.Entity:GetNetworkedString("cider_Job"), "ChatFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif ( IsValid( trace.Entity:GetNetworkedEntity("cider_Player") ) ) then
				local player = trace.Entity:GetNetworkedEntity("cider_Player");
				
				-- Check if the player is alive.
				if ( player:Alive() and player != LocalPlayer() ) then
					local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
					
					-- Get the x and y position.
					local x, y = self:GetScreenCenterBounce();
					
					-- Draw the player's name.
					y = self:DrawInformation(player:Name(), "ChatFont", x, y, team.GetColor( player:Team() ), alpha);
					
					-- Check if the player is in a clan.
					if (player:GetNetworkedString("cider_Clan") != "") then
						y = self:DrawInformation("Clan: "..player:GetNetworkedString("cider_Clan"), "ChatFont", x, y, Color(255, 255, 255, 255), alpha);
					end;
					
					-- Draw the player's job.
					y = self:DrawInformation("Job: "..player:GetNetworkedString("cider_Job"), "ChatFont", x, y, Color(255, 255, 255, 255), alpha);
				end;
			elseif (class == "cider_item") then
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation(trace.Entity:GetNetworkedString("cider_Name"), "ChatFont", x, y, Color(255, 125, 0, 255), alpha);
				y = GAMEMODE:DrawInformation("Size: "..trace.Entity:GetNetworkedInt("cider_Size"), "ChatFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif ( cider.configuration["Contraband"][class] ) then
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x position, y position and contraband table.
				local x, y = self:GetScreenCenterBounce();
				local contraband = cider.configuration["Contraband"][class];
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation(contraband.name, "ChatFont", x, y, Color(125, 255, 50, 255), alpha);
				y = GAMEMODE:DrawInformation("Energy: "..trace.Entity:GetNetworkedInt("cider_Energy").."/"..contraband.energy, "ChatFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif ( cider.entity.isDoor(trace.Entity) ) then
				local unownable = trace.Entity:GetNetworkedBool("cider_Unownable");
				local owner = trace.Entity:GetNetworkedEntity("cider_Owner");
				local name = trace.Entity:GetNetworkedString("cider_Name");
				
				-- Check if the door is unownable.
				if (unownable or trace.Entity.unownable) then
					owner = "Unownable";
					
					-- Check to see if the name is an empty string.
					if (name == "") then name = trace.Entity.name or ""; end;
				else
					if ( IsValid(owner) ) then
						owner = "Sold"
					else
						owner = "For Sale";
						name = "Press F2";
					end;
				end;
				
				-- Calculate the alpha from the distance.
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation(owner, "ChatFont", x, y, Color(125, 50, 255, 255), alpha);
				y = GAMEMODE:DrawInformation(name, "ChatFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif ( string.lower( class ) == "cider_money" ) then
				local amount = trace.Entity:GetNetworkedInt("cider_Amount");
				
				-- Calculate the alpha from the distance.
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation("Money", "ChatFont", x, y, Color(75, 150, 255, 255), alpha);
				y = GAMEMODE:DrawInformation("$"..amount, "ChatFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif ( class == "cider_breach" ) then
				local health = trace.Entity:GetNetworkedInt("cider_Health");
				
				-- Calculate the alpha from the distance.
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation("Breach", "ChatFont", x, y, Color(75, 150, 255, 255), alpha);
				y = GAMEMODE:DrawInformation("Health: "..health.."/100", "ChatFont", x, y, Color(255, 255, 255, 255), alpha);
			elseif ( class == "cider_note" ) then
				local text = "";
				
				-- Loop through 1 to 10.
				for i = 1, 10 do
					local line = trace.Entity:GetNetworkedString("cider_Text_"..i);
					
					-- Check if this line exists.
					if (line != "") then
						line = string.Replace(line, " ' ", "'");
						line = string.Replace(line, " : ", ":");
						
						-- Add the line to our text.
						text = text..line;
					end;
				end;
				
				-- Create a table to store the wrapped text and then get the wrapped text.
				local wrapped = {};
				
				-- Wrap the text into our table.
				cider.chatBox.wrapText(text, "ChatFont", 256, nil, wrapped);
				
				-- Calculate the alpha from the distance.
				local alpha = math.Clamp(255 - ( (255 / fadeDistance) * ( LocalPlayer():GetPos():Distance( trace.Entity:GetPos() ) ) ), 0, 255);
				
				-- Get the x and y position.
				local x, y = self:GetScreenCenterBounce();
				
				-- Draw the information and get the new y position.
				y = GAMEMODE:DrawInformation("Note", "ChatFont", x, y, Color(75, 150, 255, 255), alpha);
				
				-- Loop through our text.
				for k, v in pairs(wrapped) do
					y = GAMEMODE:DrawInformation(v, "ChatFont", x, y, Color(255, 255, 255, 255), alpha);
				end;
			end;
		end;
	end;
end;

-- Called when screen space effects should be rendered.
function GM:RenderScreenspaceEffects()
	local modify = {};
	local color = 0.8;
	
	-- Check if the player is low on health.
	if (LocalPlayer():Health() < 50 and !LocalPlayer()._HideHealthEffects) then
		if ( LocalPlayer():Alive() ) then
			color = math.Clamp(color - ( ( 50 - LocalPlayer():Health() ) * 0.025 ), 0, color);
		else
			color = 0;
		end;
		
		-- Draw the motion blur.
		DrawMotionBlur(math.Clamp(1 - ( ( 50 - LocalPlayer():Health() ) * 0.025 ), 0.1, 1), 1, 0);
	end;
	
	-- Set some color modify settings.
	modify["$pp_colour_addr"] = 0;
	modify["$pp_colour_addg"] = 0;
	modify["$pp_colour_addb"] = 0;
	modify["$pp_colour_brightness"] = 0;
	modify["$pp_colour_contrast"] = 1;
	modify["$pp_colour_colour"] = color;
	modify["$pp_colour_mulr"] = 0;
	modify["$pp_colour_mulg"] = 0;
	modify["$pp_colour_mulb"] = 0;
	
	-- Draw the modified color.
	DrawColorModify(modify);
end;

-- Called when the scoreboard should be drawn.
function GM:HUDDrawScoreBoard()
	self.BaseClass:HUDDrawScoreBoard(player);
	
	-- Check if the player hasn't initialized yet.
	if (!self.playerInitialized) then
		draw.RoundedBox( 2, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255) );
		
		-- Set the font of the text to Chat Font.
		surface.SetFont("ChatFont");
		
		-- Get the size of the loading text.
		local width, height = surface.GetTextSize("Loading!");
		
		-- Get the x and y position.
		local x, y = self:GetScreenCenterBounce();
		
		-- Draw a rounded box for the loading text to go on.
		draw.RoundedBox( 2, (ScrW() / 2) - (width / 2) - 8, (ScrH() / 2) - 8, width + 16, 30, Color(25, 25, 25, 255) );
		
		-- Draw the loading text in the middle of the screen.
		draw.DrawText("Loading!", "ChatFont", ScrW() / 2, ScrH() / 2, Color(255, 255, 255, 255), 1, 1);
		
		-- Let them know how to rejoin if they are stuck.
		draw.DrawText("Press 'Jump' to rejoin if you are stuck on this screen!", "ChatFont", ScrW() / 2, ScrH() / 2 + 32, Color(255, 50, 25, 255), 1, 1);
	end;
end;

-- Draw Information.
function GM:DrawInformation(text, font, x, y, color, alpha, left, callback, shadow)
	surface.SetFont(font);
	
	-- Get the width and height of the text.
	local width, height = surface.GetTextSize(text);
	
	-- Check if we shouldn't left align it, if we have a callback, and if we should draw a shadow.
	if (!left) then x = x - (width / 2); end;
	if (callback) then x, y = callback(x, y, width, height); end;
	if (shadow) then draw.DrawText(text, font, x + 1, y + 1, Color(0, 0, 0, alpha or color.a)); end;
	
	-- Draw the text on the player.
	draw.DrawText(text, font, x, y, Color(color.r, color.g, color.b, alpha or color.a));
	
	-- Return the new y position.
	return y + height + 8;
end;

-- Draw the player's information.
function GM:DrawPlayerInformation()
	local width = 0;
	local height = 0;
	
	-- Create a table to store the text.
	local text = {};
	local information = {};
	
	-- Insert the player's information into the text table.
	table.insert( text, {"Gender: "..(LocalPlayer()._Gender or "Male"), "gui/silkicons/user"} );
	table.insert( text, {"Salary: $"..(LocalPlayer()._Salary or 0), "gui/silkicons/folder_go"} );
	table.insert( text, {"Money: $"..(LocalPlayer()._Money or 0), "gui/silkicons/star"} );
	table.insert( text, {"Clan: "..LocalPlayer():GetNetworkedString("cider_Clan"), "gui/silkicons/group"} );
	table.insert( text, {"Job: "..LocalPlayer():GetNetworkedString("cider_Job"), "gui/silkicons/wrench"} );
	
	-- Loop through each of the text and adjust the width.
	for k, v in pairs(text) do
		if (string.Explode( ":", v[1] )[2] != " ") then
			if ( v[2] ) then
				width = self:AdjustMaximumWidth("ChatFont", v[1], width, nil, 24);
			else
				width = self:AdjustMaximumWidth("ChatFont", v[1], width);
			end;
			
			-- Insert this text into the information table.
			table.insert(information, v);
		end;
	end;
	
	-- Add 16 to the width and set the height of the box.
	width = width + 16;
	height = (18 * #information) + 14;
	
	-- The position of the information box.
	local x = 8;
	local y = ScrH() - height - 8;
	
	-- Draw a rounded box to put the information text onto.
	draw.RoundedBox( 2, x, y, width, height, Color(0, 0, 0, 200) );
	
	-- Increase the x and y position by 8.
	x = x + 8;
	y = y + 8;
	
	-- Draw the information on the box.
	for k, v in pairs(information) do
		if ( v[2] ) then
			self:DrawInformation(v[1], "ChatFont", x + 24, y, Color(255, 255, 255, 255), 255, true);
			
			-- Draw the icon that respresents the text.
			surface.SetTexture( surface.GetTextureID( v[2] ) );
			surface.SetDrawColor(255, 255, 255, 255);
			surface.DrawTexturedRect(x, y - 1, 16, 16);
		else
			self:DrawInformation(v[1], "ChatFont", x, y, Color(255, 255, 255, 255), 255, true);
		end;
		
		
		-- Increase the y position.
		y = y + 18;
	end;
	
	-- Return the width and height of the box.
	return width, height;
end;

-- Draw the health bar.
function GM:DrawHealthBar(bar)
	local health = math.Clamp(LocalPlayer():Health(), 0, 100);
	
	-- Draw the health and ammo bars.
	self:DrawBar("Default", bar.x, bar.y, bar.width, bar.height, Color(255, 50, 50, 200), "Health: "..health, 100, health, bar);
end;

-- Draw the ammo bar.
function GM:DrawAmmoBar(bar)
	local weapon = LocalPlayer():GetActiveWeapon();
	
	-- Check if the weapon is valid.
	if ( IsValid(weapon) ) then
		if ( !self.ammoCount[ weapon:GetClass() ] ) then
			self.ammoCount[ weapon:GetClass() ] = weapon:Clip1();
		end;
		
		-- Check if the weapon's first clip is bigger than the amount we have stored for clip one.
		if ( weapon:Clip1() > self.ammoCount[ weapon:GetClass() ] ) then
			self.ammoCount[ weapon:GetClass() ] = weapon:Clip1();
		end;
		
		-- Get the amount of ammo the weapon has in it's first clip.
		local clipOne = weapon:Clip1();
		local clipMaximum = self.ammoCount[ weapon:GetClass() ];
		local clipAmount = LocalPlayer():GetAmmoCount( weapon:GetPrimaryAmmoType() );
		
		-- Check if the maximum clip if above 0.
		if (clipMaximum > 0) then
			self:DrawBar("Default", bar.x, bar.y, bar.width, bar.height, Color(100, 100, 255, 200), "Ammo: "..clipOne.." ["..clipAmount.."]", clipMaximum, clipOne, bar);
		end;
	end;
end;

-- Called when the bottom bars should be drawn.
function GM:DrawBottomBars(bar) end;

-- Called when the top text should be drawn.
function GM:DrawTopText(text) end;

-- Called every time the HUD should be painted.
function GM:HUDPaint()
	if ( !self:IsUsingCamera() ) then
		self:DrawInformation(cider.configuration["Website URL"], "ChatFont", ScrW(), ScrH(), Color(255, 255, 255, 255), 255, true, function(x, y, width, height)
			return x - width - 8, y - height - 8;
		end);
		
		-- Get the size of the information box.
		local width, height = self:DrawPlayerInformation();
		
		-- A table to store the bar and text information.
		local bar = {x = width + 16, y = ScrH() - 24, width = 144, height = 16};
		local text = {x = ScrW(), y = 8};
		
		-- Draw the player's health and ammo bars.
		self:DrawHealthBar(bar);
		self:DrawAmmoBar(bar);
		
		-- Call a hook to let plugins know that we're now drawing bars and text.
		hook.Call("DrawBottomBars", GAMEMODE, bar);
		hook.Call("DrawTopText", GAMEMODE, text);
		
		-- Set the position of the chat box.
		cider.chatBox.position = {x = 8, y = math.min(bar.y + 20, ScrH() - height - 8) - 40};
		
		-- Get the player's next spawn time.
		local _NextSpawnTime = LocalPlayer()._NextSpawnTime or 0;
		
		-- Check if the next spawn time is greater than the current time.
		if ( !LocalPlayer():Alive() and _NextSpawnTime > CurTime() ) then
			local seconds = math.floor( _NextSpawnTime - CurTime() );
			
			-- Check if the amount of seconds is greater than 0.
			if (seconds > 0) then
				self:DrawInformation("You must wait "..seconds.." second(s) to spawn.", "ChatFont", ScrW() / 2, (ScrH() / 2) + 16, Color(255, 255, 255, 255), 255);
			end;
		elseif ( LocalPlayer():GetNetworkedBool("cider_KnockedOut") ) then
			local _BecomeConsciousTime = LocalPlayer()._BecomeConsciousTime or 0;
			
			-- Check if the unknock out time is greater than the current time.
			if ( _BecomeConsciousTime > CurTime() ) then
				local seconds = math.floor( _BecomeConsciousTime - CurTime() );
				
				-- Check if the amount of seconds is greater than 0.
				if (seconds > 0) then
					self:DrawInformation("You will become conscious in "..seconds.." second(s).", "ChatFont", ScrW() / 2, (ScrH() / 2) + 16, Color(255, 255, 255, 255), 255);
				end;
			end;
		end;
		
		-- Get whether the player is stuck in the world.
		local stuckInWorld = LocalPlayer()._StuckInWorld;
		
		-- Check whether the player is stuck in the world.
		if (stuckInWorld) then
			self:DrawInformation("You are stuck! Press 'Jump' to holster your weapons and respawn.", "ChatFont", ScrW() / 2, (ScrH() / 2) - 16, Color(255, 50, 25, 255), 255);
		end;
		
		-- Loop through every player.
		for k, v in pairs( g_Player.GetAll() ) do hook.Call("PlayerHUDPaint", GAMEMODE, v); end;
		
		-- Call the base class function.
		self.BaseClass:HUDPaint();
	end;
end;

-- Called to check if a player can use voice.
function GM:PlayerCanVoice(player)
	if ( player:Alive()
	and player:GetPos():Distance( LocalPlayer():GetPos() ) <= cider.configuration["Talk Radius"]
	and !player:GetNetworkedBool("cider_Arrested")
	and !player:GetNetworkedBool("cider_KnockedOut") ) then
		return true;
	else
		return false;
	end;
end;

-- Called every frame.
function GM:Think()
	if ( cider.configuration["Local Voice"] ) then
		for k, v in pairs( player.GetAll() ) do
			if ( hook.Call("PlayerCanVoice", GAMEMODE, v) ) then
				if ( v:IsMuted() ) then v:SetMuted(); end;
			else
				if ( !v:IsMuted() ) then v:SetMuted(); end;
			end;
		end;
	end;
	
	-- Call the base class function.
	return self.BaseClass:Think();
end;

-- Called when a player begins typing.
function GM:StartChat(team) return true; end;

-- Called when a player says something or a message is received from the server.
function GM:ChatText(index, name, text, filter)
	if ( filter == "none" or filter == "joinleave" or (filter == "chat" and name == "Console") ) then
		cider.chatBox.chatText(index, name, text, filter);
	end;
	
	-- Return true because we handle this our own way.
	return true;
end;

-- Hook into when the player has initialized.
usermessage.Hook("cider.player.initialized", function() GAMEMODE.playerInitialized = true; end);