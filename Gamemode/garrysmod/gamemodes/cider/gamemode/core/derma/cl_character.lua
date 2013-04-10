--[[
Name: "cl_character.lua".
Product: "Cider (Roleplay)".
--]]

local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetSize(cider.menu.width, cider.menu.height - 8);
	
	-- Create a panel list to store the items.
	self.itemsList = vgui.Create("DPanelList", self);
 	self.itemsList:SizeToContents();
 	self.itemsList:SetPadding(2);
 	self.itemsList:SetSpacing(3);
	self.itemsList:StretchToParent(4, 4, 12, 44);
	self.itemsList:EnableVerticalScrollbar();
	
	-- Create the job control.
	self.job = vgui.Create("cider_Character_TextEntry", self);
	self.job.label:SetText("Job");
	self.job.label:SizeToContents();
	self.job.button:SetText("Change");
	self.job.button.DoClick = function()
		RunConsoleCommand( "cider", "job", self.job.textEntry:GetValue() );
	end;
	
	-- Create the clan control.
	self.clan = vgui.Create("cider_Character_TextEntry", self);
	self.clan.label:SetText("Clan");
	self.clan.label:SizeToContents();
	self.clan.button:SetText("Change");
	self.clan.button.DoClick = function()
		RunConsoleCommand( "cider", "clan", self.clan.textEntry:GetValue() );
	end;
	
	-- Create the gender control.
	self.gender = vgui.Create("cider_Character_Gender", self);
	self.gender.label:SetText("Gender");
	self.gender.label:SizeToContents();
	self.gender.button:SetText("Change");
	
	-- Add the controls to the item list.
	self.itemsList:AddItem(self.job);
	self.itemsList:AddItem(self.clan);
	self.itemsList:AddItem(self.gender);
	
	-- Store the list of teams here sorted by their index.
	local teams = {};
	
	-- Loop through the available teams.
	for k, v in pairs(cider.team.stored) do teams[v.index] = v; end;
	
	-- Loop through our sorted teams.
	for k, v in pairs(teams) do
		self.currentTeam = v.name;
		
		-- Create the team panel.
		local panel = vgui.Create("cider_Character_Team", self);
		
		-- Set the text of the label.
		panel.label:SetText(v.name.." ("..team.NumPlayers(v.index).."/"..v.limit..")");
		panel.label.Think = function()
			panel.label:SetText(v.name.." ("..team.NumPlayers(v.index).."/"..v.limit..")");
			panel.label:SizeToContents();
		end;
		panel.description:SetText(v.description);
		panel.button:SetText("Become");
		panel.button.Think = function()
			if (LocalPlayer():Team() == v.index) then
				panel.button:SetDisabled(true);
			else
				if (team.NumPlayers(v.index) >= v.limit) then
					panel.button:SetDisabled(true);
				else
					panel.button:SetDisabled(false);
				end;
			end;
		end;
		panel.button.DoClick = function()
			RunConsoleCommand("cider", "team", v.index);
		end;
		
		-- Add the controls to the item list.
		self.itemsList:AddItem(panel);
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.itemsList:StretchToParent(0, 0, 0, 0);
end;

-- Register the panel.
vgui.Register("cider_Character", PANEL, "Panel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SizeToContents();
	self.label:SetTextColor( Color(255, 255, 255, 255) );
	self.textEntry = vgui.Create("DTextEntry", self);
	
	-- Create the button.
	self.button = vgui.Create("DButton", self);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.label:SetPos(8, 5);
	self.label:SizeToContents();
	self.button:SizeToContents();
	self.button:SetTall(16);
	self.button:SetWide(self.button:GetWide() + 16);
	self.textEntry:SetSize(self:GetWide() - self.button:GetWide() - self.label:GetWide() - 32, 16);
	self.textEntry:SetPos(self.label.x + self.label:GetWide() + 8, 5);
	self.button:SetPos(self.textEntry.x + self.textEntry:GetWide() + 8, 5);
end;
	
-- Register the panel.
vgui.Register("cider_Character_TextEntry", PANEL, "DPanel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SizeToContents();
	self.label:SetTextColor( Color(255, 255, 255, 255) );
	self.textButton = vgui.Create("DButton", self);
	self.textButton:SetDisabled(true);
	
	-- Create the button.
	self.button = vgui.Create("DButton", self);
	self.button.DoClick = function()
		local menu = DermaMenu();
		
		-- Add male and female options to the menu.
		menu:AddOption("Male", function() RunConsoleCommand("cider", "gender", "male"); end);
		menu:AddOption("Female", function() RunConsoleCommand("cider", "gender", "female"); end);
		
		-- Open the menu and set it's position.
		menu:Open();
	end;
end;

-- Called every frame.
function PANEL:Think()
	self.textButton:SetText(LocalPlayer()._Gender or "Male");
	self.textButton:SetContentAlignment(5);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.label:SetPos(8, 5);
	self.label:SizeToContents();
	self.button:SizeToContents();
	self.button:SetTall(16);
	self.button:SetWide(self.button:GetWide() + 16);
	self.textButton:SetSize(self:GetWide() - self.button:GetWide() - self.label:GetWide() - 32, 16);
	self.textButton:SetPos(self.label.x + self.label:GetWide() + 8, 5);
	self.button:SetPos(self.textButton.x + self.textButton:GetWide() + 8, 5);
end;
	
-- Register the panel.
vgui.Register("cider_Character_Gender", PANEL, "DPanel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SetTextColor( Color(255, 255, 255, 255) );
	
	-- The description of the team.
	self.description = vgui.Create("DLabel", self);
	self.description:SetTextColor( Color(255, 255, 255, 255) );
	
	-- Set the size of the panel.
	self:SetSize(cider.menu.width, 75);
	
	-- Create the button and the spawn icon.
	self.button = vgui.Create("DButton", self);
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	
	-- Get the team from the parent and set the gender of the spawn icon.
	self.team = self:GetParent().currentTeam;
	self.gender = "Male";
	
	-- Get a random model from the table.
	local models = cider.team.stored[self.team].models.male
	local model = models[ math.random(1, #models) ];
	
	-- Set the model of the spawn icon to the one of the team.
	self.spawnIcon:SetModel(model);
	self.spawnIcon:SetToolTip();
	self.spawnIcon.DoClick = function() return; end;
	self.spawnIcon.OnMousePressed = function() return; end;
end;

-- Called every frame.
function PANEL:Think()
	local _Gender = LocalPlayer()._NextSpawnGender or "";
	
	-- Check if the next spawn gender is valid.
	if (_Gender == "") then _Gender = LocalPlayer()._Gender or "Male"; end;
	if (_Gender == "") then _Gender = "Male"; end;
	
	-- Check if our gender is different.
	if (self.gender != _Gender) then
		local models = cider.team.stored[self.team].models[ string.lower(_Gender) ];
		local model = models[ math.random(1, #models) ];
		
		-- Set the model to our randomly selected one.
		self.spawnIcon:SetModel(model);
		
		-- We've changed our gender now so set it to this one.
		self.gender = _Gender;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.spawnIcon:SetPos(4, 5);
	self.label:SetPos(self.spawnIcon.x + self.spawnIcon:GetWide() + 8, 5);
	self.label:SizeToContents();
	self.description:SetPos(self.spawnIcon.x + self.spawnIcon:GetWide() + 8, 24);
	self.description:SizeToContents();
	self.button:SetPos( self.spawnIcon.x + self.spawnIcon:GetWide() + 8, self.spawnIcon.y + self.spawnIcon:GetTall() - self.button:GetTall() );
end;
	
-- Register the panel.
vgui.Register("cider_Character_Team", PANEL, "DPanel");