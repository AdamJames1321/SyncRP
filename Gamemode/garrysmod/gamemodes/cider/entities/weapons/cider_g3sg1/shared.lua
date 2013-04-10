--[[
Name: "shared.lua".
Product: "Cider (Roleplay)".
--]]

if (SERVER) then
	AddCSLuaFile("shared.lua");
else
	SWEP.DrawAmmo = true;
	SWEP.DrawCrosshair = false;
	SWEP.ViewModelFlip = true;
	SWEP.CSMuzzleFlashes = true;
	SWEP.CustomCrosshair = false;
	SWEP.Slot = 3;
	SWEP.SlotPos = 4;
	SWEP.IconLetter = "n";
	SWEP.DrawWeaponInfoBox = true;
end;

-- Set the base and category.
SWEP.Base = "rg_base";
SWEP.Category = "Cider";

-- Set some shared information.
SWEP.PrintName = "G3SG1";
SWEP.Author = "Kudomiku";
SWEP.Purpose = "A very high powered sniper rifle with a silencer.";
SWEP.Instructions = "Primary Fire: Shoot.\nUse + Secondary Fire: Change the fire mode.";
SWEP.Spawnable = false;
SWEP.AdminSpawnable = false;
SWEP.Weight = 5;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false;
SWEP.HoldType = "smg";
SWEP.FiresUnderwater = false;
SWEP.HasLaser = true;
SWEP.HasSilencer = false;
SWEP.CanPenetrate = true;
SWEP.CanPenetrateWorld = true;
SWEP.BulletTracer = 1;

-- Set some information for the primary fire.
SWEP.Primary.Sound = Sound("Weapon_M4A1.Silenced");
SWEP.Primary.Damage = 100;
SWEP.Primary.NumShots = 1;
SWEP.Primary.ClipSize = 10;
SWEP.Primary.DefaultClip = 10;
SWEP.Primary.Ammo = "smg1";

-- Set some information for the secondary fire.
SWEP.Secondary.ClipSize = -1;
SWEP.Secondary.DefaultClip = -1;

-- Set some information about the recoil and spray.
SWEP.RecoverTime = 1;
SWEP.MinSpread = 0.5;
SWEP.MaxSpread = 5;
SWEP.DeltaSpread = 0.5;
SWEP.MinRecoil = 5;
SWEP.MaxRecoil = 5;
SWEP.DeltaRecoil = 2;
SWEP.MinSpray = 0;
SWEP.MaxSpray = 2;
SWEP.DeltaSpray = 0.5;

-- Set some information about the iron sights.
SWEP.IronSightsPos = Vector(5.4341, -6.4904, 2.0689);
SWEP.IronSightsAng = Vector(3.6868, 1.1562, 0.9656);
SWEP.IronSightZoom = 1;
SWEP.UseScope = true;
SWEP.ScopeScale = 0.4;
SWEP.ScopeZooms = {5, 15};
SWEP.DrawSniperSights = true;
SWEP.DrawRifleSights = false;

-- Set some information about the model and visual effects.
SWEP.ViewModel = "models/weapons/v_snip_g3sg1.mdl";
SWEP.WorldModel = "models/weapons/w_snip_g3sg1.mdl";
SWEP.MuzzleEffect = "rg_muzzle_highcal";
SWEP.ShellEffect = "rg_shelleject_rifle";
SWEP.MuzzleAttachment = "1";
SWEP.ShellEjectAttachment = "2";

-- Set some modifier information.
SWEP.CrouchModifier = 0.75;
SWEP.IronSightModifier = 0;
SWEP.RunModifier = 1.5;
SWEP.JumpModifier = 2;

-- Set some information about the available fire modes and RPM.
SWEP.AvailableFireModes = {"Semi"};
SWEP.SemiRPM = 100;