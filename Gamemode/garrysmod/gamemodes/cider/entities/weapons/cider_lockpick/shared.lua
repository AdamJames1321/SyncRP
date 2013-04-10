--[[
Name: "shared.lua".
Product: "Cider (Roleplay)".
--]]

if (SERVER) then AddCSLuaFile("shared.lua"); end;

-- Check if we're running on the client.
if (CLIENT) then
	SWEP.PrintName = "Lockpick";
	SWEP.Slot = 3;
	SWEP.SlotPos = 3;
	SWEP.DrawAmmo = false;
	SWEP.DrawCrosshair = true;
else
	SWEP.TimesUsed = 0;
end;

-- Define some shared variables.
SWEP.Author	= "Kudomiku";
SWEP.Instructions = "Primary Fire: Pick Lock.";
SWEP.Contact = "http://kudomiku.com/forums/.";
SWEP.Purpose = "Opening doors by picking their lock.";

-- Set the view model and the world model to nil.
SWEP.ViewModel = "models/weapons/v_crowbar.mdl";
SWEP.WorldModel = "models/weapons/w_crowbar.mdl";

-- Set whether it's spawnable by players and by administrators.
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
	
	-- Set the animation of the owner to one of them attacking.
	self.Owner:SetAnimation(PLAYER_ATTACK1);
	
	-- Get an eye trace from the owner.
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

	-- Check the hit position of the trace to see if it's close to us.
	if (self.Owner:GetPos():Distance(trace.HitPos) <= 128) then
		if ( IsValid(trace.Entity) ) then
			if (cider.entity.isDoor(trace.Entity) or trace.Entity:GetClass() == "prop_dynamic") then
				if (trace.Entity._Unownable and trace.Entity:GetNetworkedString("cider_Name") == "Abandoned") then
					cider.player.notify(self.Owner, "This door cannot be lockpicked!", 1);
				else
					trace.Entity._Lockpick = trace.Entity._Lockpick or 0;
					
					-- Increase this entity's lockpick amount.
					trace.Entity._Lockpick = trace.Entity._Lockpick + 1;
					
					-- Check to see if the lockpick amount is greater or equal to 10.
					if (trace.Entity._Lockpick >= 5) then
						cider.entity.openDoor(trace.Entity, 0.5, true, true);
						
						-- Increase the amount of times that we've used this lockpick.
						self.TimesUsed = self.TimesUsed + 1;
						
						-- Check to see if we've used this lockpick more than the maximum uses.
						if ( self.TimesUsed == cider.configuration["Maximum Lockpick Uses"] ) then
							cider.player.notify(self.Owner, "This lockpick has reached it's maximum uses!", 1);
							
							-- Select the hands and strip the lockpick.
							self.Owner:SelectWeapon("cider_hands");
							self.Owner:StripWeapon("cider_lockpick");
						end;
						
						-- Reset this entity's lockpick amount.
						trace.Entity._Lockpick = 0;
					end;
				end;
			end;
		end;
	end;
end;

-- Called when the player attempts to secondary fire.
function SWEP:SecondaryAttack() end;