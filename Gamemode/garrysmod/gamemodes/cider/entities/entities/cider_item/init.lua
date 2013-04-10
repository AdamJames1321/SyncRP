--[[
Name: "cl_init.lua".
Product: "Cider (Roleplay)".
--]]

include("sh_init.lua");

-- Add the files that need to be sent to the client.
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("sh_init.lua");

-- This is called when the entity initializes.
function ENT:Initialize()
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	
	-- Get the physics object of the entity.
	local physicsObject = self:GetPhysicsObject();
	
	-- Check if the physics object is a valid entity.
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
end;

-- A function to set the item of the entity.
function ENT:SetItem(item)
	if (cider.item.stored[item]) then
		self._UniqueID = cider.item.stored[item].uniqueID;
		self._Name = cider.item.stored[item].name;
		self._Size = cider.item.stored[item].size;
		
		-- Set the model of the entity.
		self:SetModel(cider.item.stored[item].model);
		
		-- Set the networked variables so the client can get the information.
		self:SetNetworkedString("cider_Name", self._Name);
		self:SetNetworkedInt("cider_Size", self._Size);
	end;
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if ( activator:IsPlayer() ) then
		if (self._Size) then
			local success, fault = cider.inventory.update(activator, self._UniqueID, 1);
			
			-- Check if we didn't succeed.
			if (!success) then
				cider.player.notify(activator, fault, 1);
				
				-- Return here because we can't use it.
				return;
			end;
			
			-- Remove the entity.
			self:Remove();
		end;
	end;
end;