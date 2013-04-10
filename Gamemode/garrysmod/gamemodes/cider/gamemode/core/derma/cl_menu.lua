--[[
Name: "cl_menu.lua".
Product: "Cider (Roleplay)".
--]]

cider.menu = {};
cider.menu.open = nil;
cider.menu.width = 414;
cider.menu.height = 600;

-- Define a new panel.
local PANEL = {};

-- Called when the panel is initialized.
function PANEL:Init()
	self:SetTitle("Main Menu");
	self:SetBackgroundBlur(true);
	self:SetDeleteOnClose(false);
	
	-- Create the close button.
	self.close = vgui.Create("DButton", self);
	self.close:SetText("Close");
	self.close.DoClick = function(self) cider.menu.toggle(); end;
	
	-- Create the tabs property sheet.
	self.tabs = vgui.Create("DPropertySheet", self);
	
	-- Add the sheets for the other menus to the property sheet.
	self.tabs:AddSheet("Help", vgui.Create("cider_Help", self.tabs), "gui/silkicons/page");
	self.tabs:AddSheet("Rules", vgui.Create("cider_Rules", self.tabs), "gui/silkicons/exclamation");
	self.tabs:AddSheet("Character", vgui.Create("cider_Character", self.tabs), "gui/silkicons/user");
	self.tabs:AddSheet("Inventory", vgui.Create("cider_Inventory", self.tabs), "gui/silkicons/application_view_tile");
	self.tabs:AddSheet("Store", vgui.Create("cider_Store", self.tabs), "gui/silkicons/box");
	self.tabs:AddSheet("Donate", vgui.Create("cider_Donate", self.tabs), "gui/silkicons/heart");
end;

-- Called when the layout should be performed.
function PANEL:PerformLayout()
	self:SetVisible(cider.menu.open);
	self:SetSize(cider.menu.width, cider.menu.height);
	self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() / 2 - self:GetTall() / 2);
	
	-- Set the size and position of the close button.
	self.close:SetSize(48, 16);
	self.close:SetPos(self:GetWide() - self.close:GetWide() - 4, 3);
	
	-- Stretch the tabs to the parent.
	self.tabs:StretchToParent(4, 28, 4, 4);
	
	-- Size To Contents.
	self:SizeToContents();
	
	-- Perform the layout of the main frame.
	DFrame.PerformLayout(self);
end;

-- Register the panel.
vgui.Register("cider_Menu", PANEL, "DFrame");

-- A function to toggle the menu.
function cider.menu.toggle(msg)
	if (GAMEMODE.playerInitialized) then
		cider.menu.open = !cider.menu.open;
		
		-- Toggle the screen clicker.
		gui.EnableScreenClicker(cider.menu.open);
		
		-- Check if the main menu exists.
		if (cider.menu.panel) then
			cider.menu.panel:SetVisible(cider.menu.open);
		else
			cider.menu.panel = vgui.Create("cider_Menu");
			cider.menu.panel:MakePopup();
		end;
	end;
end;

-- Hook the usermessage to toggle the menu from the server.
usermessage.Hook("cider_Menu", cider.menu.toggle);