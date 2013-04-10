--[[
Name: "init.lua".
Product: "Cider (Roleplay)".
--]]

include("sh_init.lua");

-- Add the files that need to be sent to the client.
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("sh_init.lua");

-- This is called when the entity initializes.
function ENT:Initialize()
	self:SetModel(self.Model);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);

	-- Get the physics object of the entity.
	local physicsObject = self:GetPhysicsObject();
	
	-- Check if the physics object is a valid entity.
	if ( IsValid(physicsObject) ) then
		physicsObject:Wake();
		physicsObject:EnableMotion(true);
	end;
	
	-- Get the contraband table.
	local contraband = cider.configuration["Contraband"][ self:GetClass() ];
	
	-- Check if the contraband table is valid.
	if (contraband) then
		self:SetHealth(contraband.health);
		
		-- Set the energy of the entity.
		self._Energy = contraband.energy;
		
		-- Set the networked int so that clients can get the energy.
		self:SetNetworkedInt("cider_Energy", self._Energy);
	else
		timer.Simple(1, function() self:Remove(); end);
	end;
end;

-- Called when the entity takes damage.
function ENT:OnTakeDamage(damageInfo)
	self:SetHealth( math.max(self:Health() - damageInfo:GetDamage(), 0) );
	
	-- Check if the entity has run out of health.
	if (self:Health() <= 0) then
		local killer = damageInfo:GetInflictor();
		
		-- Check if the killer is valid and is a player.
		if ( IsValid(killer) and killer:IsPlayer() )then
			cider.plugin.call("playerDestroyContraband", killer, self);
		end;
		
		-- Explode the contraband and then remove it.
		self:Explode();
		self:Remove();
	end;
end;

-- Explode the entity.
function ENT:Explode()
	local effectData = EffectData();
	
	-- Set the information for the effect.
	effectData:SetStart( self:GetPos() );
	effectData:SetOrigin( self:GetPos() );
	effectData:SetScale(2);
	
	-- Create the effect from the data.
	util.Effect("Explosion", effectData);
end;

-- Called when a player uses the entity.
function ENT:Use(player, caller)
	if (self._Energy < 5) then
		self._Energy = 5;
		
		-- Get some new effect data.
		local effectData = EffectData();
		
		-- Set the information for the effect.
		effectData:SetOrigin( self:GetPos() );
		effectData:SetMagnitude(2);
		effectData:SetScale(2);
		effectData:SetRadius(2);
		
		-- Create the effect from the data.
		util.Effect("Sparks", effectData, true, true);
	end;
	
	-- Set the networked int so that clients can get the energy.
	self:SetNetworkedInt("cider_Energy", self._Energy);
end;