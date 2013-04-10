--[[
Name: "shared.lua".
Product: "Cider (Roleplay)".
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
	
	-- Add the resource files for the fists.
	resource.AddFile("models/weapons/w_fists.dx80.vtx");
	resource.AddFile("models/weapons/w_fists.dx90.vtx");
	resource.AddFile("models/weapons/w_fists.mdl");
	resource.AddFile("models/weapons/w_fists.phy");
	resource.AddFile("models/weapons/w_fists.sw.vtx");
	resource.AddFile("models/weapons/w_fists.vvd");
	resource.AddFile("models/weapons/v_fists.dx80.vtx");
	resource.AddFile("models/weapons/v_fists.dx90.vtx");
	resource.AddFile("models/weapons/v_fists.mdl");
	resource.AddFile("models/weapons/v_fists.sw.vtx");
	resource.AddFile("models/weapons/v_fists.vvd");
	resource.AddFile("materials/models/weapons/v_models/brass_knuckles/map.vtf");
	resource.AddFile("materials/models/weapons/v_models/brass_knuckles/main.vmt");
end;

-- Check if we're running on the client.
if (CLIENT) then
	SWEP.PrintName = "Hands";
	SWEP.Slot = 1;
	SWEP.SlotPos = 1;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
end

-- Define some shared variables.
SWEP.Author	= "Kudomiku";
SWEP.Instructions = "Primary Fire: Punch.\nSecondary Fire: Knock.";
SWEP.Contact = "http://kudomiku.com/forums/.";
SWEP.Purpose = "Punching people and knocking on doors.";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/weapons/v_fists.mdl";
SWEP.WorldModel = "models/weapons/w_fists.mdl";

-- Set the animation prefix and some other settings.
SWEP.AnimPrefix	= "admire";
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;
  
-- Set the primary fire settings.
SWEP.Primary.Damage = 7.5;
SWEP.Primary.ClipSize = -1;
SWEP.Primary.DefaultClip = 0;
SWEP.Primary.Automatic = false;
SWEP.Primary.Ammo = "";

-- Set the secondary fire settings.
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = 0;
SWEP.Secondary.Automatic = false;
SWEP.Secondary.Ammo	= "";

-- Set the iron sight positions (pointless here).
SWEP.IronSightPos = Vector(0, 0, 0);
SWEP.IronSightAng = Vector(0, 0, 0);
SWEP.NoIronSightFovChange = true;
SWEP.NoIronSightAttack = true;

-- Called when the SWEP is initialized.
function SWEP:Initialize()
	if (SERVER) then self:SetWeaponHoldType("normal"); end;
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 1);
	
	-- Set the animation of the weapon and play the sound.
	self.Weapon:EmitSound("npc/vort/claw_swing2.wav");
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
	
	-- Get an eye trace from the owner.
	local trace = self.Owner:GetEyeTrace();
	
	-- Check the hit position of the trace to see if it's close to us.
	if (self.Owner:GetPos():Distance(trace.HitPos) <= 128) then
		if ( IsValid(trace.Entity)
		and (trace.Entity:IsPlayer() or trace.Entity:IsNPC() or trace.Entity:GetClass() == "prop_ragdoll") ) then
			if (trace.Entity:IsPlayer() and trace.Entity:Health() - self.Primary.Damage <= 15) then
				if (SERVER) then
					cider.player.knockOut(trace.Entity, true, cider.configuration["Knock Out Time"] / 2);
				end;
			else
				local bullet = {};
				
				-- Set some information for the bullet.
				bullet.Num = 1;
				bullet.Src = self.Owner:GetShootPos();
				bullet.Dir = self.Owner:GetAimVector();
				bullet.Spread = Vector(0, 0, 0);
				bullet.Tracer = 0;
				bullet.Force = 5;
				bullet.Damage = self.Primary.Damage;
				
				-- Fire bullets from the owner which will hit the trace entity.
				self.Owner:FireBullets(bullet);
			end;
		elseif ( IsValid(trace.Entity) ) then
			if ( IsValid( trace.Entity:GetPhysicsObject() ) ) then
				trace.Entity:GetPhysicsObject():ApplyForceOffset(self.Owner:GetAimVector() * 250, trace.HitPos);
			end;
		end;
		
		-- Check if the trace hit an entity or the world.
		if (trace.Hit or trace.HitWorld) then self.Weapon:EmitSound("weapons/crossbow/hitbod2.wav"); end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.25);
	
	-- Get a trace from the owner's eyes.
	local trace = self.Owner:GetEyeTrace();
	
	-- Check to see if the trace entity is valid and that it's a door.
	if (IsValid(trace.Entity) and (cider.entity.isDoor(trace.Entity) or trace.Entity:GetClass() == "prop_dynamic") ) then
		if (self.Owner:GetPos():Distance(trace.HitPos) <= 128) then
			self.Weapon:EmitSound("physics/wood/wood_crate_impact_hard2.wav");
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
		end;
	end;
end;