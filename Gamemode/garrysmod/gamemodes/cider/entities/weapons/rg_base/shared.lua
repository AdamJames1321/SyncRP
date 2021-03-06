

if SERVER then

	AddCSLuaFile("shared.lua")
	AddCSLuaFile("cl_init.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end


SWEP.Author			= "Teta_Bonita"
SWEP.Contact		= ""
SWEP.Purpose		= "To crush your enemies."
SWEP.Instructions	= "Aim away from face."

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.Primary.Sound			= Sound("Weapon_TMP.Single")
SWEP.Primary.Damage			= 40
SWEP.Primary.NumShots		= 1
SWEP.AutoRPM				= 200
SWEP.SemiRPM				= 200
SWEP.BurstRPM				= 200
SWEP.MuzzleVelocity 		= 1000
SWEP.AvailableFireModes		= {}
SWEP.FiresUnderwater 		= false
SWEP.HasSilencer			= false
SWEP.IsHolster				= true
SWEP.CanPenetrate           = false
SWEP.CanPenetrateWorld      = false
SWEP.BulletTracer           = 1

SWEP.MuzzleEffect			= "rg_muzzle_pistol"
SWEP.ShellEjectEffect		= "rg_shelleject"
SWEP.MuzzleAttachment		= "1"
SWEP.ShellEjectAttachment	= "2"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Sound		= Sound("Weapon_AR2.Double") -- For grenade launching
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false -- Best left at false, as secondary is used for ironsights/switching firemodes
SWEP.Secondary.Ammo			= "none"

SWEP.IronSightZoom 			= 1.2
SWEP.ScopeZooms				= {5,10}
SWEP.UseScope				= false
SWEP.ScopeScale 			= 0.4
SWEP.DrawSniperSights		= false
SWEP.DrawRifleSights		= false
SWEP.LaserRespawnTime 		= 0.9
SWEP.LaserLastRespawn 		= 0
SWEP.HasLaser				= false
SWEP.HasSilencer			= true

SWEP.MinRecoil			= 0.1
SWEP.MaxRecoil			= 0.5
SWEP.DeltaRecoil		= 0.1

SWEP.RecoverTime 		= 1
SWEP.MinSpread			= 0
SWEP.MaxSpread			= 0
SWEP.DeltaSpread		= 0

SWEP.MinSpray			= 0.2
SWEP.MaxSpray			= 1.5
SWEP.DeltaSpray			= 0.2

SWEP.CrouchModifier		= 0.7
SWEP.IronSightModifier 	= 0.7
SWEP.RunModifier 		= 1.5
SWEP.JumpModifier 		= 1.5



---------------------------------------------------------
--------------------Firemodes------------------------
---------------------------------------------------------
SWEP.FireModes = {}

---------------------------------------
-- Firemode: Semi Automatic --
---------------------------------------
SWEP.FireModes.Semi = {}
SWEP.FireModes.Semi.FireFunction = function(self)

	self:BaseAttack()

end

SWEP.FireModes.Semi.InitFunction = function(self)

	self.Primary.Automatic = false
	self.Primary.Delay = 60/self.SemiRPM

end

-- We don't need to do anything for these revert functions, as self.Primary.Automatic, self.Primary.Delay, self.FireModeDrawTable.x, and self.FireModeDrawTable.y are set in every init function
SWEP.FireModes.Semi.RevertFunction = function(self)

	return

end

---------------------------------------
-- Firemode: Fully Automatic --
---------------------------------------
SWEP.FireModes.Auto = {}
SWEP.FireModes.Auto.FireFunction = function(self)

	self:BaseAttack()

end

SWEP.FireModes.Auto.InitFunction = function(self)

	self.Primary.Automatic = true
	self.Primary.Delay = 60/self.AutoRPM
	
end

SWEP.FireModes.Auto.RevertFunction = function(self)

	return

end

-------------------------------------------
-- Firemode: Three-Round Burst --
-------------------------------------------
SWEP.FireModes.Burst = {}
SWEP.FireModes.Burst.FireFunction = function(self)

	local clip = self.Weapon:Clip1()
	if not self:CanFire(clip) then return end

	self:BaseAttack()
	timer.Simple(self.BurstDelay, self.BaseAttack, self)
	
	if clip > 1 then
		timer.Simple(2*self.BurstDelay, self.BaseAttack, self)
	end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + 1 )

end

SWEP.FireModes.Burst.InitFunction = function(self)

	self.Primary.Automatic = true
	self.Primary.Delay = 60/self.SemiRPM + 3*self.BurstDelay -- Burst delay is derived from self.BurstRPM

end

SWEP.FireModes.Burst.RevertFunction = function(self)

	return

end


---------------------------------------------------------
-----------------Init Functions----------------------
---------------------------------------------------------

local sndZoomIn = Sound("Weapon_AR2.Special1")
local sndZoomOut = Sound("Weapon_AR2.Special2")
local sndCycleZoom = Sound("Default.Zoom")
local sndCycleFireMode = Sound("Weapon_Pistol.Special2")

function SWEP:Initialize()

	if SERVER then
		-- This is so NPCs know wtf they are doing
		self:SetWeaponHoldType(self.HoldType)
		self:SetNPCMinBurst(3)
		self:SetNPCMaxBurst(6)
		self:SetNPCFireRate(60/self.AutoRPM)
	end
	
	self.CurFireMode		= 1 -- This is just an index to get the firemode from the available firemodes table
	
	if CLIENT then
	
		-- We need to get these so we can scale everything to the player's current resolution.
		local iScreenWidth = surface.ScreenWidth()
		local iScreenHeight = surface.ScreenHeight()
		
		-- The following code is only slightly riped off from Night Eagle
		-- These tables are used to draw things like scopes and crosshairs to the HUD.
		self.ScopeTable = {}
		self.ScopeTable.l = iScreenHeight*self.ScopeScale
		self.ScopeTable.x1 = 0.5*(iScreenWidth + self.ScopeTable.l)
		self.ScopeTable.y1 = 0.5*(iScreenHeight - self.ScopeTable.l)
		self.ScopeTable.x2 = self.ScopeTable.x1
		self.ScopeTable.y2 = 0.5*(iScreenHeight + self.ScopeTable.l)
		self.ScopeTable.x3 = 0.5*(iScreenWidth - self.ScopeTable.l)
		self.ScopeTable.y3 = self.ScopeTable.y2
		self.ScopeTable.x4 = self.ScopeTable.x3
		self.ScopeTable.y4 = self.ScopeTable.y1
				
		self.ParaScopeTable = {}
		self.ParaScopeTable.x = 0.5*iScreenWidth - self.ScopeTable.l
		self.ParaScopeTable.y = 0.5*iScreenHeight - self.ScopeTable.l
		self.ParaScopeTable.w = 2*self.ScopeTable.l
		self.ParaScopeTable.h = 2*self.ScopeTable.l
		
		self.ScopeTable.l = (iScreenHeight + 1)*self.ScopeScale -- I don't know why this works, but it does.

		self.QuadTable = {}
		self.QuadTable.x1 = 0
		self.QuadTable.y1 = 0
		self.QuadTable.w1 = iScreenWidth
		self.QuadTable.h1 = 0.5*iScreenHeight - self.ScopeTable.l
		self.QuadTable.x2 = 0
		self.QuadTable.y2 = 0.5*iScreenHeight + self.ScopeTable.l
		self.QuadTable.w2 = self.QuadTable.w1
		self.QuadTable.h2 = self.QuadTable.h1
		self.QuadTable.x3 = 0
		self.QuadTable.y3 = 0
		self.QuadTable.w3 = 0.5*iScreenWidth - self.ScopeTable.l
		self.QuadTable.h3 = iScreenHeight
		self.QuadTable.x4 = 0.5*iScreenWidth + self.ScopeTable.l
		self.QuadTable.y4 = 0
		self.QuadTable.w4 = self.QuadTable.w3
		self.QuadTable.h4 = self.QuadTable.h3

		self.LensTable = {}
		self.LensTable.x = self.QuadTable.w3
		self.LensTable.y = self.QuadTable.h1
		self.LensTable.w = 2*self.ScopeTable.l
		self.LensTable.h = 2*self.ScopeTable.l

		self.CrossHairTable = {}
		self.CrossHairTable.x11 = 0
		self.CrossHairTable.y11 = 0.5*iScreenHeight
		self.CrossHairTable.x12 = iScreenWidth
		self.CrossHairTable.y12 = self.CrossHairTable.y11
		self.CrossHairTable.x21 = 0.5*iScreenWidth
		self.CrossHairTable.y21 = 0
		self.CrossHairTable.x22 = 0.5*iScreenWidth
		self.CrossHairTable.y22 = iScreenHeight
		
	end

	self.BulletSpeed	= self.MuzzleVelocity*50 -- phoenix - 39.37 -- Assuming source units are in inches per second
	self.BurstDelay		= 60/self.BurstRPM
	self.Primary.Delay	= 60/self.SemiRPM

	self.FireFunction		= self.FireModes[self.AvailableFireModes[self.CurFireMode]].FireFunction
	self.Weapon:SetNetworkedInt("rg_firemode", 1)
	self.Weapon:SetNetworkedBool("Ironsights", false)
	self.Weapon:SetNWBool( "silenced", false ) -- PC Camp add
	
	self.ScopeZooms 		= self.ScopeZooms or {5}
	if self.UseScope then
		self.CurScopeZoom	= 1 -- Another index, this time for ScopeZooms
	end
	
	self:ResetVars()
	
end


function SWEP:Deploy()
	if (SERVER) then
		if (!self.DrawCrosshair or self.CustomCrosshair) then self.Owner:CrosshairDisable() end
		if (self.Owner._Ammo[self.Classname]) then
			self.Weapon:SetClip1(self.Owner._Ammo[self.Classname]);
		end;
	end
	
	if ( self.Weapon:GetNWBool("silenced") ) then
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE_SILENCED);
	else
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE);
	end;
end


-- This function resets spread, recoil, ironsights, etc.
function SWEP:ResetVars()

	self.NextSecondaryAttack = 0
	
	self.CurrentSpread = self.MinSpread
	self.CurrentRecoil	= self.MinRecoil
	self.CurrentSpray 	= self.MinSpray
	self.SprayVec 		= Vector(0,0,0)
	
	self.bLastIron = false
	self.Weapon:SetNetworkedBool("Ironsights", false)
	--self.Weapon:SetNWBool( "silenced", false )
	
	if ( self.Weapon:GetNWBool("silenced") ) then
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE_SILENCED);
	else
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE);
	end;
	
	if self.UseScope then
		self.CurScopeZoom = 1
		self.fLastScopeZoom = 1
		self.bLastScope = false
		self.Weapon:SetNetworkedBool("Scope", false)
		self.Weapon:SetNetworkedBool("ScopeZoom", self.ScopeZooms[1])
	end
	
	if self.Owner and self.Owner:IsValid() then
		self.OwnerIsNPC = self.Owner:IsNPC() -- This ought to be better than getting it every time we fire
		self:SetIronsights(false,self.Owner) -- phoenix - placed in SWEP:Deply()
		self:SetScope(false,self.Owner) -- phoenix - placed in SWEP:Deply()
		self:SetFireMode() -- phoenix - placed in SWEP:Deply()
	end
	
end

-- do ammo stuff.
function SWEP:DoAmmoStuff()
	if (SERVER) then
		if ( IsValid(self.previousOwner) ) then
			self.previousOwner:CrosshairEnable()
			if (!self.previousOwner._Ammo) then self.previousOwner._Ammo = {}; end;
			self.previousOwner._Ammo[self.Classname] = self.Weapon:Clip1();
			if (self.previousOwner._Ammo[self.Classname] == 0) then
				if (self.previousOwner:GetAmmoCount(self.Primary.Ammo) == 0) then
					if ( self.previousOwner:Alive() ) then
						if (cider.item.stored[self.Classname]) then
							if (!self.doneAmmoStuff) then
								local owner = self.previousOwner
								local classname = self.Classname
								timer.Simple(FrameTime() * 0.5, function()
									if (IsValid(owner)) then
										if (owner:HasWeapon(classname)) then
											if ( hook.Call("PlayerCanHolster", GAMEMODE, owner, classname, true) ) then
												if ( cider.inventory.update(owner, classname, 1) ) then
													owner:StripWeapon(classname);
												end;
											end;
										end
									end;
								end)
								self.doneAmmoStuff = true
							end
						end;
					end;
				end;
			end;
		end;
	end
end

-- We need to call ResetVars() on these functions so we don't whip out a weapon with scope mode or insane recoil right of the bat or whatnot
function SWEP:Holster(wep)
	self:DoAmmoStuff()
	self:ResetVars()
	return true
end
function SWEP:Equip(NewOwner) self:ResetVars() return true end
function SWEP:OnRemove()
	self:DoAmmoStuff()
	self:ResetVars()
	
	return true
end
function SWEP:OnDrop()
	self:DoAmmoStuff()
	self:ResetVars()
	
	return true
end
function SWEP:OwnerChanged() self:ResetVars() return true end
function SWEP:OnRestore() self:ResetVars() return true end


---------------------------------------------------------
----------Attack Helper Functions----------------
---------------------------------------------------------

-- Generic attack function
SWEP.LastAttack = CurTime()
SWEP.LastDeltaSprayVec = Vector(0,0,0)
function SWEP:BaseAttack()
	
	if not self:CanFire(self.Weapon:Clip1()) then return end
	
	-- Calculate recover (cool down) scale
	local fCurTime = CurTime()
	local DeltaTime = fCurTime - self.LastAttack
	local RecoverScale = (1 - DeltaTime/self.RecoverTime)
	self.LastAttack = fCurTime
	
	-- Apply cool-down to spread, spray, and recoil
	self.CurrentSpread = math.Clamp(self.CurrentSpread*RecoverScale, self.MinSpread, self.MaxSpread)
	self.CurrentRecoil = math.Clamp(self.CurrentRecoil*RecoverScale, self.MinRecoil, self.MaxRecoil)
	self.CurrentSpray = math.Clamp(self.CurrentSpray*RecoverScale, self.MinSpray, self.MaxSpray)
	self.SprayVec = self.SprayVec*((self.CurrentSpray - self.MinSpray)/(self.MaxSpray - self.MinSpray))
	
	-- Calculate modifiers/take ammo
	local modifier = 1
	if not self.OwnerIsNPC then -- NPCs don't get modifiers
	
		modifier = self:CalculateModifiers(self.RunModifier,self.CrouchModifier,self.JumpModifier,self.IronSightModifier)
		
	end
	self:TakePrimaryAmmo(1)
	self.Weapon:EmitSound(self.Primary.Sound)
	local NewSpray 		= self.CurrentSpray*modifier

	self:RGShootBulletCheap(self.Primary.Damage, 
						self.BulletSpeed, 
						self.CurrentSpread*modifier, 
						NewSpray, 
						self.SprayVec)

	-- Apply recoil and spray
	self:ApplyRecoil(self.CurrentRecoil*modifier,NewSpray)

	-- Update spread, spray, and recoil
	self.CurrentRecoil 	= math.Clamp(self.CurrentRecoil + self.DeltaRecoil, self.MinRecoil, self.MaxRecoil)
	self.CurrentSpread 	= math.Clamp(self.CurrentSpread + self.DeltaSpread, self.MinSpread, self.MaxSpread)
	self.CurrentSpray 	= math.Clamp(self.CurrentSpray + self.DeltaSpray, self.MinSpray, self.MaxSpray)
	
	local DeltaSprayVec = VectorRand()*0.02 -- Change in spray vector
	self.SprayVec = self.SprayVec + DeltaSprayVec + self.LastDeltaSprayVec -- This "smooths out" the motion of the spray vector
	self.LastDeltaSprayVec = DeltaSprayVec

	-- Shoot Effects
	self:ShootEffects()

end

-- The penetrating callback.
function SWEP:PenetrateCallback(pl, trace)
	if (trace.Hit) then
		if (self.CanPenetrate) then
			self.PenetrateInfo.Force = self.PenetrateInfo.Force / 16
			self.PenetrateInfo.Damage = self.PenetrateInfo.Damage / 2
			
			local bullet = {}
			bullet.Num = self.PenetrateInfo.Num
			bullet.Spread = self.PenetrateInfo.Spread
			bullet.Tracer = self.PenetrateInfo.Tracer
			bullet.Force = self.PenetrateInfo.Force
			bullet.Damage = self.PenetrateInfo.Damage
			bullet.Src = trace.HitPos
			
			if (!trace.HitWorld or self.CanPenetrateWorld) then
				bullet.Dir = self.PenetrateInfo.Dir
				bullet.Src = bullet.Src + (16 * bullet.Dir)
				
				self.Owner:FireBullets( bullet )
				
				for i = 1, self.PenetrateInfo.Num do
					local _trace = {}
					_trace.start = bullet.Src
					_trace.endpos = _trace.start + ( ( ( self.PenetrateInfo.Dir + ( VectorRand() * (i / 2) ) ) ) * -32)
					_trace = util.TraceLine(_trace)
					
					local matTypes = {
						[MAT_CONCRETE] = {"Impact.Concrete", "MetalSpark"},
						[MAT_METAL] = {"Impact.Metal", "MetalSpark"},
						[MAT_WOOD] = {"Impact.Wood", "MetalSpark"},
						[MAT_GLASS] = {"Impact.Glass", "GlassImpact"}
					}
					
					if (_trace.Hit or _trace.HitWorld) then
						if ( !IsValid(_trace.Entity) or ( !_trace.Entity:IsPlayer() and !_trace.Entity:IsNPC() ) ) then
							if (_trace.Entity == trace.Entity) then
								if (matTypes[_trace.MatType]) then
									util.Decal(matTypes[_trace.MatType][1], _trace.HitPos + _trace.HitNormal, _trace.HitPos - _trace.HitNormal)
									local effectData = EffectData()
										effectData:SetStart(_trace.HitPos)
										effectData:SetOrigin(_trace.HitPos)
									util.Effect(matTypes[_trace.MatType][2], effectData)
								end
							end
						end
					end
				end
			end
		end
	end
end

-- You don't like my physically simulated bullets? : (
function SWEP:RGShootBulletCheap(dmg, speed, spread, spray, sprayvec, numbul)

	local PlayerAim = self.Owner:GetAimVector()
	local PlayerPos = self.Owner:GetShootPos()
	
	numbul = numbul or 1
	
	self.PenetrateInfo = {
		Num = numbul,
		_Spread = Vector(spread, spread, 0),
		Spread = Vector(spread, spread, 0),
		Dir = ( PlayerAim + 0.04 * spray * sprayvec:GetNormalized() ):GetNormalized(),
		Damage = dmg,
		Force = 5 * dmg,
		Tracer = self.BulletTracer
	}
	
	local bullet = {}
	bullet.Num		= self.PenetrateInfo.Num
	bullet.Src		= PlayerPos
	bullet.Dir		= self.PenetrateInfo.Dir -- phoenix - PlayerAim
	bullet.Spread	= self.PenetrateInfo.Spread -- phoenix - Vector(spread, spread, 0)
	bullet.Force	= self.PenetrateInfo.Force
	bullet.Damage	= self.PenetrateInfo.Damage
	bullet.Tracer	= self.PenetrateInfo.Tracer
	
	self.Owner:FireBullets( bullet )
	
	local trace = {}
	trace.start = PlayerPos
	trace.endpos = trace.start + (self.PenetrateInfo.Dir * 4096)
	trace.filter = self.Owner
	trace = util.TraceLine(trace)
	
	self:PenetrateCallback(self.Owner, trace)
end

function SWEP:ApplyRecoil(recoil,spray)

	if self.OwnerIsNPC or (SERVER and not self.Owner:IsListenServerHost()) then return end
	
	local EyeAng = Angle(
	recoil*math.Rand(-1,-0.7 + spray*0.4) + spray*math.Rand(-0.3,0.3), -- Up/Down recoil
	recoil*math.Rand(-0.4,0.4) + spray*math.Rand(-0.4,0.4), -- Left/Right recoil
	0)
	
	-- Punch the player's view
	self.Owner:ViewPunch(1.3*EyeAng) -- This smooths out the player's screen movement when recoil is applied
	self.Owner:SetEyeAngles(self.Owner:EyeAngles() + EyeAng)
	
end

-- Acuracy/recoil modifiers
function SWEP:CalculateModifiers(run,crouch,jump,iron)

	local modifier = 1

	if self.Owner:KeyDown(IN_FORWARD or IN_BACK or IN_MOVELEFT or IN_MOVERIGHT) then
		modifier = modifier*run
	end
	
	if self.Weapon:GetNetworkedBool("Ironsights", false) then 
		modifier = modifier*iron
	end
	
	if not self.Owner:IsOnGround() then
		return modifier*jump --You can't be jumping and crouching at the same time, so return here
	end
	
	if self.Owner:Crouching() then 
		modifier = modifier*crouch
	end
	
	return modifier

end

function SWEP:ShootEffects()

	local PlayerPos = self.Owner:GetShootPos()
	local PlayerAim = self.Owner:GetAimVector()
	
	self.Owner:MuzzleFlash()
	if self.Weapon:GetNWBool( "silenced" ) then
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)
		if (self.AnimationFix) then
			timer.Create("Animation Fix: "..tostring(self.Weapon), self.AnimationFix, 1, function()
				if ( IsValid(self.Weapon) ) then
					self.Weapon:SendWeaponAnim(ACT_VM_IDLE_SILENCED)
				end;
			end);
		end;
	else
		self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		if (self.AnimationFix) then
			timer.Create("Animation Fix: "..tostring(self.Weapon), self.AnimationFix, 1, function()
				if ( IsValid(self.Weapon) ) then
					self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
				end;
			end);
		end;
	end
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	
	local fx = EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetOrigin(PlayerPos)
	fx:SetNormal(PlayerAim)
	fx:SetAttachment(self.MuzzleAttachment)
	util.Effect(self.MuzzleEffect,fx)						-- Additional muzzle effects
	
	local fx = EffectData()
	fx:SetEntity(self.Weapon)
	fx:SetNormal(PlayerAim)
	fx:SetAttachment(self.ShellEjectAttachment)
	util.Effect(self.ShellEffect,fx)						-- Shell ejection
	
end

-- Clip can be any number, ideally a clip or ammo count
function SWEP:CanFire(clip)

	if not self.Weapon or not self.Owner or not (self.OwnerIsNPC or self.Owner:Alive()) then return end

	if clip <= 0 or (self.Owner:WaterLevel() >= 3 and not self.FiresUnderwater) then
	
		self.Weapon:EmitSound("Weapon_Pistol.Empty")
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.2)
		return false -- Note that we don't automatically reload.  The player has to do this manually.
		
	end
	
	return true

end


---------------------------------------------------------
----FireMode/IronSight Helper Functions----
---------------------------------------------------------

local IRONSIGHT_TIME = 0.35 -- How long it takes to raise our rifle
function SWEP:SetIronsights(b,player)

if CLIENT or (not player) or player:IsNPC() then return end

	-- Send the ironsight state to the client, so it can adjust the player's FOV/Viewmodel pos accordingly
	self.Weapon:SetNetworkedBool("Ironsights", b)
	
	if self.UseScope then -- If we have a scope, use that instead of ironsights
		if b then
			--Activate the scope after we raise the rifle
			timer.Simple(IRONSIGHT_TIME, self.SetScope, self, true, player)
		else
			self:SetScope(false, player)
		end
	end

end

function SWEP:SetScope(b,player)

if CLIENT or (not player) or player:IsNPC() then return end

	local PlaySound = b~= self.Weapon:GetNetworkedBool("Scope", not b) -- Only play zoom sounds when chaning in/out of scope mode
	self.CurScopeZoom = 1 -- Just in case...
	self.Weapon:SetNetworkedFloat("ScopeZoom",self.ScopeZooms[self.CurScopeZoom])

	if b then 
		player:DrawViewModel(false)
		if PlaySound then
			self.Weapon:EmitSound(sndZoomIn)
		end
	else
		player:DrawViewModel(true)
		if PlaySound then
			self.Weapon:EmitSound(sndZoomOut)
		end
	end
	
	-- Send the scope state to the client, so it can adjust the player's fov/HUD accordingly
	self.Weapon:SetNetworkedBool("Scope", b) 

end

function SWEP:SetFireMode()

	local FireMode = self.AvailableFireModes[self.CurFireMode]
	self.Weapon:SetNetworkedInt("FireMode",self.CurFireMode)
	
	if (self.FireModes[FireMode]) then
		self.FireFunction = self.FireModes[FireMode].FireFunction 
		
		-- Run the firemode's init function (for updating delay and other variables)
		self.FireModes[FireMode].InitFunction(self) 
	end

end

function SWEP:RevertFireMode()

	local FireMode = self.AvailableFireModes[self.CurFireMode]
	
	-- Run the firemode's revert function (for changing back variables that could interfere with other firemodes)
	self.FireModes[FireMode].RevertFunction(self)

end


---------------------------------------------------------
------------Main SWEP functions----------------
---------------------------------------------------------

function SWEP:PrimaryAttack()
	
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	if not self.Owner:KeyDown(IN_USE) then
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		-- Fire function is defined under SWEP:SetFireMode()
		self:FireFunction()
	else
		if self.HasSilencer then
			if self.Weapon:GetNWBool( "silenced" ) then
				self.Weapon:SendWeaponAnim(ACT_VM_DETACH_SILENCER)
				self.Weapon:SetNWBool( "silenced", false )
			else
				self.Weapon:SendWeaponAnim(ACT_VM_ATTACH_SILENCER)
				self.Weapon:SetNWBool( "silenced", true )
			end
			self.Weapon:SetNextPrimaryFire( CurTime() + 2.1 )
		end
	end
	if CLIENT then
		self.Weapon:SetNetworkedFloat( "LastShootTime", CurTime() )
	end
end

function SWEP:Think()
	if self.Weapon then
		if self.HasSilencer then
			if self.Weapon:GetNWBool( "silenced" ) then
				self.Primary.Sound = Sound("Weapon_M4A1.Silenced")
			else
				self.Primary.Sound = Sound("Weapon_M4A1.Single")
			end
		end
	end
	if self.HasLaser then
		if (self.LaserLastRespawn + self.LaserRespawnTime) < CurTime() then
			local effectdata = EffectData()
			
			effectdata:SetOrigin( self:GetOwner():GetShootPos() )
			effectdata:SetEntity( self.Weapon )
			util.Effect( "rg_reddot", effectdata ) 
			
			self.LaserLastRespawn = CurTime()
		end
	end
	if ( IsValid(self.Owner) ) then self.previousOwner = self.Owner; end;
end

-- Secondary attack is used to set ironsights/change firemodes
-- TODO: clean this function up
SWEP.NextSecondaryAttack = 0
function SWEP:SecondaryAttack()

	if self.NextSecondaryAttack > CurTime() or self.OwnerIsNPC then return end
	self.NextSecondaryAttack = CurTime() + 0.3
	
	if self.Owner:KeyDown(IN_USE) then
	
	local NumberOfFireModes = table.getn(self.AvailableFireModes)
	if NumberOfFireModes < 2 then return end -- We need at least 2 firemodes to change firemodes!
	
		self:RevertFireMode()
		self.CurFireMode = math.fmod(self.CurFireMode, NumberOfFireModes) + 1 -- This just cycles through all available fire modes
		self:SetFireMode()
		
		if (SERVER) then
			if (self.AvailableFireModes[self.CurFireMode]) then
				local fireMode = self.AvailableFireModes[self.CurFireMode];
				if (fireMode == "Semi") then
					self.Owner:PrintMessage(4, "Semi-Automatic Fire")
				elseif (fireMode == "Auto") then
					self.Owner:PrintMessage(4, "Automatic Fire")
				elseif (fireMode == "Burst") then
					self.Owner:PrintMessage(4, "Burst Fire")
				end
			end;
		end;
		
		self.Weapon:EmitSound(sndCycleFireMode)
	-- All of this is more complicated than it needs to be. Oh well.
	elseif self.IronSightsPos then
	
		local NumberOfScopeZooms = table.getn(self.ScopeZooms)

		if self.UseScope and self.Weapon:GetNetworkedBool("Scope", false) then
		
			self.CurScopeZoom = self.CurScopeZoom + 1
			if self.CurScopeZoom <= NumberOfScopeZooms then
		
				self.Weapon:SetNetworkedFloat("ScopeZoom",self.ScopeZooms[self.CurScopeZoom])
				self.Weapon:EmitSound(sndCycleZoom)
				
			else
				self:SetIronsights(false,self.Owner)
			end
			
		else
	
			local bIronsights = not self.Weapon:GetNetworkedBool("Ironsights", false)
			self:SetIronsights(bIronsights,self.Owner)
		
		end
		

	
	end
	
end


function SWEP:Reload()
	self:SetIronsights(false,self.Owner)
	if self.Weapon:GetNWBool( "silenced" ) then
		self.Weapon:DefaultReload(ACT_VM_RELOAD_SILENCED)
	else
		self.Weapon:DefaultReload(ACT_VM_RELOAD)
	end
	
end
