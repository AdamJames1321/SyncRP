--[[
Name: "cl_donate.lua".
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
	local text = vgui.Create("cider_Donate_Text", self);
	
	-- Set the help for this category.
	text:SetText( {
		"When donating you can choose from a variety of different",
		"services. When you donate money you must include your",
		"in-game name and your Steam ID and the service number(s)",
		"that you are purchasing.",
		"",
		"> Service #1 ($5) 30 Day Donator Status.",
		"\t- The ability to spawn props.",
		"\t- Double salary on all teams.",
		"\t- Access to most of GMod's standard tools.",
		"\t- Access to Wire Mod and most of it's tools.",
		"\t- Half the waiting time for spawning.",
		"\t- A heart icon next to your name in OOC.",
		"\t- Half the waiting time for becoming conscious.",
		"\t- Half the waiting time for getting unarrested.",
		"\t- Double the duration of your spawn immunity.",
		"\t- The ability to kill an extra 4 people per hour.",
		"",
		"> Service #2 ($10) Money.",
		"\t- You will get $75000 of in-game money.",
		"",
		"> Service #3 ($10) Extra Inventory Space.",
		"\t- You will be given 2 extra small pockets.",
		"",
		"> Service #4 ($20) Price Saver Deal.",
		"\t- Get Donator status for 30 days.",
		"\t- Get $150000 of in-game money.",
		"\t- Save $5 with this service.",
		"",
		"> Please goto http://kudomiku.com/donate/ to donate!",
		"",
		"If you put your name instead of your Steam ID then",
		"I will not accept it and you will not be refunded!",
		"",
		"> It can take up to 2-3 days to get gain your services.",
		"> If you file a dispute because it has taken any less than",
		"> this time, you will be permanently banned from the server.",
		"> However, if I take longer than this time then I fully understand",
		"> you filing a dispute against me."
	} );
	
	-- Add the text to the item list.
	self.itemsList:AddItem(text);
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.itemsList:StretchToParent(0, 0, 0, 0);
end;

-- Register the panel.
vgui.Register("cider_Donate", PANEL, "Panel");

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
		local label = vgui.Create("DLabel", self);
		
		-- Set the text of the label.
		label:SetText( string.Replace(v, "> ", "") );
		label:SetTextColor( Color(255, 255, 255, 255) );
		label:SizeToContents();
		
		-- Check if the text is supposed to be red.
		if ( string.find(v, "> ") ) then
			label:SetTextColor( Color(150, 255, 100, 255) );
		end;
		
		-- Insert the label into our labels table.
		table.insert(self.labels, label);
		
		-- Increase the y position.
		y = y + label:GetTall() + 8
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
vgui.Register("cider_Donate_Text", PANEL, "DPanel");