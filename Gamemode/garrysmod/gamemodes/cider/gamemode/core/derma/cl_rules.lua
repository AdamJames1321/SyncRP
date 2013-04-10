--[[
Name: "cl_rules.lua".
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
	
	-- Create the text for this category.
	local text = vgui.Create("cider_Rules_Text", self);
	
	-- Set the help for this category.
	text:SetText( string.Explode("\n", cider.configuration["Rules"]) );
	
	-- Add the text to the item list.
	self.itemsList:AddItem(text);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.itemsList:StretchToParent(0, 0, 0, 0);
end;

-- Register the panel.
vgui.Register("cider_Rules", PANEL, "Panel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init() self.labels = {}; end;

-- Set Text.
function PANEL:SetText(text)
	for k, v in pairs(self.labels) do v:Remove(); end;
	
	-- Define our x and y positions.
	local y = 5;
	
	-- Loop through the text we're given.
	for k, v in pairs(text) do
		if (v != "") then
			local label = vgui.Create("DLabel", self);
			
			-- Set the text of the label.
			label:SetText(v);
			label:SetTextColor( Color(255, 255, 255, 255) );
			label:SizeToContents();
			
			-- Insert the label into our labels table.
			table.insert(self.labels, label);
			
			-- Increase the y position.
			y = y + label:GetTall() + 8
		end;
	end;
	
	-- Set the size of the panel.
	self:SetSize(cider.menu.width, y);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	local y = 5;
	
	-- Loop through all of our labels.
	for k, v in pairs(self.labels) do
		self.labels[k]:SetPos(self:GetWide() / 2 - self.labels[k]:GetWide() / 2, y);
		
		-- Increase the y position.
		y = y + self.labels[k]:GetTall() + 8
	end;
end;
	
-- Register the panel.
vgui.Register("cider_Rules_Text", PANEL, "DPanel");