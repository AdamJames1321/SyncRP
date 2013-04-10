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
	self:SetModel("models/weapons/w_c4_planted.mdl");
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

-- A function to set the door for the entity to breach.
function ENT:SetDoor(door, trace)
	self._Door = door;
	self._Door:DeleteOnRemove(self);
	
	-- Set the position and angles of the entity.
	self:SetPos(trace.HitPos);
	self:SetAngles( trace.HitNormal:Angle() + Angle(90, 0, 0) );
	
	if (door:GetClass() != "prop_dynamic") then
		constraint.Weld(door, self, 0, 0);
	else
		if ( IsValid( self:GetPhysicsObject() ) ) then
			self:GetPhysicsObject():EnableMotion(false);
		end;
	end;
	
	-- Set the health of the entity.
	self:SetHealth(100);
end;

-- Called every frame.
function ENT:Think()
	self:SetNetworkedInt( "cider_Health", math.Round( self:Health() ) );
end;

-- Explode the entity.
function ENT:Explode()
	local effectData = EffectData();
	
	-- Set the information for the effect.
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(1);
	
	-- Create the effect from the data.
	util.Effect("Explosion", effectData);
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	-- Check if the entity has run out of health.
	if (self:Health() <= 0) then
		self:Explode();
		self:Remove();
		
		-- Open the door instantly as if it's been blown open.
		cider.entity.openDoor(self._Door, 0, true, true);
	end;
end;