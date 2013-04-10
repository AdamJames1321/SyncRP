--[[
Name: "cl_store.lua".
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
	
	-- Create a table to store the teams.
	local teams = { none = {} };
	
	-- Loop through the items.
	for k, v in pairs(cider.item.stored) do
		if (v.store and v.cost and v.batch) then
			if (v.team) then
				teams[v.team] = teams[v.team] or {};
				
				-- Insert the item into the team table.
				table.insert(teams[v.team], k);
			else
				table.insert(teams.none, k);
			end;
		end;
	end;
	
	-- Loop through the teams.
	for k, v in pairs(teams) do
		if (k == "none") then
			table.sort(v, function(a, b) return cider.item.stored[a].cost > cider.item.stored[b].cost end)
			
			-- Loop through the items.
			for k2, v2 in pairs(v) do
				self.currentItem = v2;
				
				-- Add the item to the item list.
				self.itemsList:AddItem( vgui.Create("cider_Store_Item", self) );
			end;
		end;
	end;
	
	-- Loop through the teams.
	for k, v in pairs(teams) do
		if (k != "none") then
			local header = vgui.Create("cider_Store_Header", self);
			
			-- Set the text of the header.
			header.label:SetText( team.GetName(k) );
			
			-- Add the item to the item list.
			self.itemsList:AddItem(header);
			
			-- Sort the items by cost.
			table.sort(v, function(a, b) return cider.item.stored[a].cost > cider.item.stored[b].cost end)
			
			-- Loop through the items.
			for k2, v2 in pairs(v) do
				self.currentItem = v2;
				
				-- Add the item to the item list.
				self.itemsList:AddItem( vgui.Create("cider_Store_Item", self) );
			end;
		end;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.itemsList:StretchToParent(0, 0, 0, 0);
end;

-- Register the panel.
vgui.Register("cider_Store", PANEL, "Panel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.item = self:GetParent().currentItem;
	
	-- Get the cost of the item in total.
	local cost = cider.item.stored[self.item].cost * cider.item.stored[self.item].batch;
	
	-- The name of the item.
	self.label = vgui.Create("DLabel", self);
	self.label:SetTextColor( Color(255, 255, 255, 255) );
	
	-- Check if it is not a single batch.
	if (cider.item.stored[self.item].batch > 1) then
		self.label:SetText(cider.item.stored[self.item].batch.." "..cider.item.stored[self.item].plural.." ($"..cost..")");
	else
		self.label:SetText(cider.item.stored[self.item].batch.." "..cider.item.stored[self.item].name.." ($"..cost..")");
	end;
	
	-- The description of the item.
	self.description = vgui.Create("DLabel", self);
	self.description:SetTextColor( Color(255, 255, 255, 255) );
	self.description:SetText(cider.item.stored[self.item].description);
	
	-- Set the size of the panel.
	self:SetSize(cider.menu.width, 75);
	
	-- Create the button and the spawn icon.
	self.button = vgui.Create("DButton", self);
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	
	-- Set the text of the button.
	self.button:SetText("Manufacture");
	self.button:SetSize(80, 22);
	self.button.DoClick = function()
		RunConsoleCommand("cider", "manufacture", self.item);
	end;
	
	-- Set the model of the spawn icon to the one of the item.
	self.spawnIcon:SetModel(cider.item.stored[self.item].model);
	self.spawnIcon:SetToolTip();
	self.spawnIcon.DoClick = function() return; end;
	self.spawnIcon.OnMousePressed = function() return; end;
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
vgui.Register("cider_Store_Item", PANEL, "DPanel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.label = vgui.Create("DLabel", self);
	self.label:SetText("N/A");
	self.label:SizeToContents();
	self.label:SetTextColor( Color(255, 255, 255, 255) );
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.label:SetPos( (self:GetWide() / 2) - (self.label:GetWide() / 2), 5 );
	self.label:SizeToContents();
end;
	
-- Register the panel.
vgui.Register("cider_Store_Header", PANEL, "DPanel");