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
	SWEP.PrintName = "Keys";
	SWEP.Slot = 1;
	SWEP.SlotPos = 2;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
end

-- Define some shared variables.
SWEP.Author	= "Kudomiku";
SWEP.Instructions = "Primary Fire: Lock.\nSecondary Fire: Unlock.";
SWEP.Contact = "http://kudomiku.com/forums/.";
SWEP.Purpose = "Locking and unlocking doors you have access to.";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/weapons/v_fists.mdl";
SWEP.WorldModel = "models/weapons/w_fists.mdl";

-- Set the animation prefix and some other settings.
SWEP.AnimPrefix	= "admire";
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;
  
-- Set the primary fire settings.
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
	
	-- Check if we're on the client.
	if (CLIENT) then return; end;
	
	-- Get an eye trace from the owner.
	local trace = self.Owner:GetEyeTrace();
	
	-- Check the hit position of the trace to see if it's close to us.
	if (self.Owner:GetPos():Distance( trace.HitPos ) <= 128) then
		if ( IsValid(trace.Entity) and ( cider.entity.isDoor(trace.Entity) ) ) then
			if ( cider.player.hasDoorAccess(self.Owner, trace.Entity) ) then
				trace.Entity:Fire("lock", "", 0);
				
				-- Set the animation of the weapon and play the sound.
				self.Owner:EmitSound("doors/door_latch3.wav");
				self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
			else
				cider.player.notify(self.Owner, "You do not have access to this door!", 1);
			end;
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 1);
	
	-- Check if we're on the client.
	if (CLIENT) then return; end;
	
	-- Get an eye trace from the owner.
	local trace = self.Owner:GetEyeTrace();
	
	-- Check the hit position of the trace to see if it's close to us.
	if (self.Owner:GetPos():Distance( trace.HitPos ) <= 128) then
		if ( IsValid(trace.Entity) and ( cider.entity.isDoor(trace.Entity) ) ) then
			if ( cider.player.hasDoorAccess(self.Owner, trace.Entity) ) then
				trace.Entity:Fire("unlock", "", 0);
				
				-- Set the animation of the weapon and play the sound.
				self.Owner:EmitSound("doors/door_latch3.wav");
				self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
			else
				cider.player.notify(self.Owner, "You do not have access to this door!", 1);
			end;
		end;
	end;
end;