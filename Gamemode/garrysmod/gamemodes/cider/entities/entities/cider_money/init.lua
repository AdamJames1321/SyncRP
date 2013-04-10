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
	self:SetModel("models/props_c17/briefcase001a.mdl");
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

-- A function to set the amount of money.
function ENT:SetAmount(amount)
	self._Amount = amount;
	
	-- Set the networked variables so the client can get the information.
	self:SetNetworkedInt("cider_Amount", self._Amount);
end;

-- Called when the entity is used.
function ENT:Use(activator, caller)
	if ( activator:IsPlayer() ) then
		cider.player.giveMoney(activator, self._Amount);
		
		-- Remove the entity.
		self:Remove();
		
		-- Notify them about how much they picked up.
		cider.player.notify(activator, "You picked up $"..self._Amount..".", 0);
	end;
end;