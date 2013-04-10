--[[
Name: "cl_inventory.lua".
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
	
	-- Set this to true to begin with so that we do one starting update.
	cider.inventory.updatePanel = true;
	
	-- We call think just once on initialize so that we can update.
	self:Think();
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:StretchToParent(0, 22, 0, 0);
	self.itemsList:StretchToParent(0, 0, 0, 0);
end;

-- Called every frame.
function PANEL:Think()
	if (cider.inventory.updatePanel) then
		cider.inventory.updatePanel = false;
		
		-- Clear the current list of items.
		self.itemsList:Clear();
		self.itemsList:AddItem( vgui.Create("cider_Inventory_Information", self) );
		
		-- Loop through the player's inventory and add the items.
		for k, v in pairs(cider.inventory.stored) do
			self.currentItem = k;
			
			-- Check if this item exists.
			if (cider.item.stored[k]) then
				self.itemsList:AddItem( vgui.Create("cider_Inventory_Item", self) ) ;
			end;
		end;
		
		-- Rebuild the items list.
		self.itemsList:Rebuild();
	end;
end;

-- Register the panel.
vgui.Register("cider_Inventory", PANEL, "Panel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self.itemFunctions = {};
	
	-- Set the size and position of the panel.
	self:SetSize(cider.menu.width, 75);
	self:SetPos(1, 5);
	
	-- Set the item that we are.
	self.item = self:GetParent().currentItem;
	
	-- Create a label for the name.
	self.name = vgui.Create("DLabel", self);
	self.name:SetText(cider.inventory.stored[self.item].." "..cider.item.stored[self.item].name.." (Size: "..cider.item.stored[self.item].size..")");
	self.name:SizeToContents();
	self.name:SetTextColor( Color(255, 255, 255, 255) );
	
	-- Check the amount that the player has.
	if (cider.inventory.stored[self.item] > 1) then
		self.name:SetText(cider.inventory.stored[self.item].." "..cider.item.stored[self.item].plural.." (Size: "..cider.item.stored[self.item].size..")");
	end;
	
	-- Create a label for the description.
	self.description = vgui.Create("DLabel", self); 
	self.description:SetText(cider.item.stored[self.item].description);
	self.description:SizeToContents();
	self.description:SetTextColor( Color(255, 255, 255, 255) );
	
	-- Create the spawn icon.
	self.spawnIcon = vgui.Create("SpawnIcon", self);
	
	-- Set the model of the spawn icon to the one of the item.
	self.spawnIcon:SetModel(cider.item.stored[self.item].model);
	self.spawnIcon:SetToolTip();
	self.spawnIcon.DoClick = function() return; end;
	self.spawnIcon.OnMousePressed = function() return; end;
	
	-- Check to see if the item has an on use callback.
	if (cider.item.stored[self.item].onUse) then table.insert(self.itemFunctions, "Use"); end;
	if (cider.item.stored[self.item].onDrop) then table.insert(self.itemFunctions, "Drop"); end;
	if (cider.item.stored[self.item].onDestroy) then table.insert(self.itemFunctions, "Destroy All"); end;
	
	-- Create the table to store the item buttons.
	self.itemButton = {};
	
	-- Loop through the item functions.
	for i = 1, #self.itemFunctions do
		if (self.itemFunctions[i]) then
			self.itemButton[i] = vgui.Create("DButton", self);
			self.itemButton[i]:SetText(self.itemFunctions[i]);
			
			-- Check what type of button it is.
			if (self.itemFunctions[i] == "Use") then
				self.itemButton[i].DoClick = function()
					RunConsoleCommand("cider", "inventory", self.item, "use");
				end;
			elseif (self.itemFunctions[i] == "Drop") then
				self.itemButton[i].DoClick = function()
					RunConsoleCommand("cider", "inventory", self.item, "drop");
					
					-- Close the main menu.
					cider.menu.toggle();
				end;
			elseif (self.itemFunctions[i] == "Destroy All") then
				self.itemButton[i].DoClick = function()
					local menu = DermaMenu();
					
					-- Add an option for yes and no.
					menu:AddOption("No", function() end);
					menu:AddOption("Yes", function()
						RunConsoleCommand("cider", "inventory", self.item, "destroy");
					end);
					
					-- Open the menu.
					menu:Open() ;
				end;
			end;
		end;
	end;
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self.spawnIcon:SetPos(4, 5);
	self.name:SizeToContents();
	self.description:SetPos(75, 24);
	self.description:SizeToContents();
	
	-- Define the x position of the item functions.
	local x = self.spawnIcon.x + self.spawnIcon:GetWide() + 8;
	
	-- Set the position of the name and description.
	self.name:SetPos(x, 4);
	self.description:SetPos(x, 24);
	
	-- Loop through the item functions and set the position of their button.
	for i = 1, #self.itemFunctions do
		if (self.itemButton[i]) then
			self.itemButton[i]:SetPos(x, 47);
			
			-- Increase the x position for the next item function.
			x = x + self.itemButton[i]:GetWide() + 4;
		end;
	end;
end;

-- Register the panel.
vgui.Register("cider_Inventory_Item", PANEL, "DPanel");

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	local maximumSpace = cider.inventory.getMaximumSpace();
	
	-- Create the space used label.
	self.spaceUsed = vgui.Create("DLabel", self);
	self.spaceUsed:SetText("Space Used: "..cider.inventory.getSize(true).."/"..maximumSpace);
	self.spaceUsed:SizeToContents();
	self.spaceUsed:SetTextColor( Color(255, 255, 255, 255) );
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	local maximumSpace = cider.inventory.getMaximumSpace();
	
	-- Set the position of the label.
	self.spaceUsed:SetPos( (self:GetWide() / 2) - (self.spaceUsed:GetWide() / 2), 5 );
	self.spaceUsed:SetText("Space Used: "..cider.inventory.getSize(true).."/"..maximumSpace);
end;
	
-- Register the panel.
vgui.Register("cider_Inventory_Information", PANEL, "DPanel");