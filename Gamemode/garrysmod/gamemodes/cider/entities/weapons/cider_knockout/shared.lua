--[[
Name: "shared.lua".
Product: "Cider (Roleplay)".
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
	
	-- Add the resource files for the stunstick.
	resource.AddFile("models/weapons/v_stunstick.dx80.vtx");
	resource.AddFile("models/weapons/v_stunstick.dx90.vtx");
	resource.AddFile("models/weapons/v_stunstick.mdl");
	resource.AddFile("models/weapons/v_stunstick.phy");
	resource.AddFile("models/weapons/v_stunstick.sw.vtx");
	resource.AddFile("models/weapons/v_stunstick.vvd");
	resource.AddFile("materials/models/weapons/v_stunstick/v_stunstick_diffuse.vmt");
	resource.AddFile("materials/models/weapons/v_stunstick/v_stunstick_diffuse.vtf");
	resource.AddFile("materials/models/weapons/v_stunstick/v_stunstick_normal.vtf");
end;

-- Check if we're running on the client.
if (CLIENT) then
	SWEP.PrintName = "Knock Out";
	SWEP.Slot = 4;
	SWEP.SlotPos = 4;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
end

-- Define some shared variables.
SWEP.Author	= "Kudomiku";
SWEP.Instructions = "Primary Fire: Knock Out.";
SWEP.Contact = "http://kudomiku.com/forums/.";
SWEP.Purpose = "Knocking people out for a short time.";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/weapons/v_stunstick.mdl";
SWEP.WorldModel = "models/weapons/w_stunbaton.mdl";

-- Set the animation prefix and some other settings.
SWEP.AnimPrefix	= "stunstick";
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
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER);
		self.Weapon:EmitSound("weapons/stunstick/stunstick_swing1.wav");
	end;
	
	-- Check if we're running on the client.
	if (CLIENT) then return; end;
	
	-- Check to see if the entity is a player and that it's close to the owner.
	if (trace.Entity and trace.Entity:IsPlayer() and self.Owner:GetPos():Distance(trace.HitPos) <= 128) then
		if (!trace.Entity._Ragdoll.entity) then
			if ( hook.Call("PlayerCanKnockOut", GAMEMODE, self.Owner, trace.Entity) ) then
				cider.player.knockOut(trace.Entity, true, trace.Entity._KnockOutTime);
				
				-- Let the administrators know that this happened.
				cider.player.printConsoleAccess(self.Owner:Name().." knocked out "..trace.Entity:Name()..".", "a");
				
				-- Call a hook.
				hook.Call("PlayerKnockOut", GAMEMODE, self.Owner, trace.Entity);
			end;
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack() end;