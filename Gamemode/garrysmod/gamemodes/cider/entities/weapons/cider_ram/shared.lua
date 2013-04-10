--[[
Name: "shared.lua".
Product: "Cider (Roleplay)".
--]]

if (SERVER) then AddCSLuaFile("shared.lua"); end;

-- Check if we're running on the client.
if (CLIENT) then
	SWEP.PrintName = "Ram";
	SWEP.Slot = 3;
	SWEP.SlotPos = 2;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = false;
end

-- Define some shared variables.
SWEP.Author	= "Kudomiku";
SWEP.Instructions = "Primary Fire: Ram.";
SWEP.Contact = "http://kudomiku.com/forums/.";
SWEP.Purpose = "Ramming open doors with permission.";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/weapons/v_rpg.mdl";
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl";

-- Set the animation prefix and some other settings.
SWEP.AnimPrefix	= "rpg";
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
	if (SERVER) then self:SetWeaponHoldType("rpg"); end;
end;

-- Called when the player attempts to primary fire.
function SWEP:PrimaryAttack()
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay);
	
	-- Set the animation of the owner to one of them attacking.
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	
	-- Check if we're on the client.
	if (CLIENT) then return; end;
	
	-- Get an eye trace from the owner.
	local trace = self.Owner:GetEyeTrace();
	
	-- Check the hit position of the trace to see if it's close to us.
	if (self.Owner:GetPos():Distance(trace.HitPos) <= 128) then
		if ( IsValid(trace.Entity) ) then
			if (cider.entity.isDoor(trace.Entity) or trace.Entity:GetClass() == "prop_dynamic") then
				if ( hook.Call("PlayerCanRamDoor", GAMEMODE, self.Owner, trace.Entity) ) then
					cider.entity.openDoor(trace.Entity, 0.25, true, true);
				end;
			end;
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack() end;