--[[
Name: "shared.lua".
Product: "Cider (Roleplay)".
--]]

if (SERVER) then AddCSLuaFile("shared.lua"); end;

-- Check if we're running on the client.
if (CLIENT) then
	SWEP.PrintName = "Unarrest";
	SWEP.Slot = 4;
	SWEP.SlotPos = 3;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
end

-- Define some shared variables.
SWEP.Author	= "Kudomiku";
SWEP.Instructions = "Primary Fire: Break Out.";
SWEP.Contact = "http://kudomiku.com/forums/.";
SWEP.Purpose = "Breaking people out of jail.";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/weapons/v_crowbar.mdl";
SWEP.WorldModel = "models/weapons/w_crowbar.mdl";

-- Set the animation prefix and some other settings.
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;
  
-- Set the primary fire settings.
SWEP.Primary.Delay = 0.75;
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
	if (SERVER) then self:SetWeaponHoldType("melee"); end;
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	
	-- Set the animation of the owner and weapon and play the sound.
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	
	-- Get an eye trace from the player.
	local trace = self.Owner:GetEyeTrace();
	
	-- Check if the trace hit or it hit the world.
	if ( (trace.Hit or trace.HitWorld) and self.Owner:GetPos():Distance(trace.HitPos) <= 128 ) then
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
		self.Weapon:EmitSound("physics/flesh/flesh_impact_bullet3.wav");
	else
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER);
		self.Weapon:EmitSound("weapons/iceaxe/iceaxe_swing1.wav");
	end;
	
	-- Check if we're running on the client.
	if (CLIENT) then return; end;
	
	-- Check to see if the entity is a player and that it's close to the owner.
	if (trace.Entity and trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.HitPos) <= 128) then
		if (trace.Entity.cider._Arrested) then cider.player.arrest(trace.Entity, false); end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack() end;