-- Install on HostUnit and HostWeapon; native weapon updates enforce work gates.
local M={}
local nativeWeaponState
local expected={ugl5001='URL0104',uel5010='XEL0209',uga5006='URA0303',uss5023='XSC9002',usl3801='XSL0305'}
local function config(unit)
    local c=unit.tp and unit.tp.additions and unit.tp.additions.scoSourceUnitModes
    if not c then return end
    assert(expected[unit.tpId]==c.sourceId and unit.tpId==c.targetId,'Source unit mode scope drift')
    return c
end
local function stopSniperFacing(unit)
    if unit.scoSniperOwnsFacing then
        unit.scoSniperOwnsFacing=nil
        unit:AlignBehaviorStop()
    end
end
function M.Allowed(weapon)
    local unit=weapon.unit
    local c=config(unit)
    if not c then return true end
    local name=weapon.tp.name or weapon.tp.scoSourceLabel
    if c.sniperWeapon and (name==c.normalWeapon or name==c.sniperWeapon) then
        return (unit.scoSourceSniperMode==true)==(name==c.sniperWeapon)
    end
    if c.airWeapon and (name==c.airWeapon or name==c.groundWeapon) then
        return (unit.scoSourceGroundMode==true)==(name==c.groundWeapon)
    end
    if c.workWeapon==name then
        if c.disableWhileBuilding and unit.IsBuildRoutineEnabled and unit:IsBuildRoutineEnabled() then return false end
        if c.disableWhileBuilding and unit.IsRepairRoutineEnabled and unit:IsRepairRoutineEnabled() then return false end
        if c.disableWhileReclaiming and unit.IsReclaimRoutineEnabled and unit:IsReclaimRoutineEnabled() then return false end
    end
    return true
end
function M.SetSniperMode(unit,enabled)
    local c=config(unit)
    if not c or not c.sniperWeapon or unit.dead or type(enabled)~='boolean' then return false end
    if enabled and unit.scoCargoCarrier then return false end
    stopSniperFacing(unit)
    unit.scoSourceSniperMode=enabled
    Engine.SetMovementMaxSpeed(unit.id,enabled and c.sniperSpeed or c.normalSpeed)
    unit.attackRange=enabled and c.sniperRange or c.normalRange
    if unit.attackBehaviorIsActive and unit.followBehaviorIsActive then
        unit.followBehaviorRange=unit.attackRange
    end
    for _,weapon in ipairs(unit.weapons or {}) do
        if not M.Allowed(weapon) then
            weapon:SetAimTarget(nil)
            weapon.scoSniperChargeRemaining=nil
            weapon.salvosRemaining=0
            weapon.currentState=assert(nativeWeaponState,'Sniper weapon states unavailable').WaitingForReload
        end
    end
    M.Update(unit)
    Import('common/commands/definitions/units.lua').SCOSourceSniperModeState.Send(unit.id,enabled)
    return true
end
function M.Update(unit)
    if not config(unit) then return end
    for _,weapon in ipairs(unit.weapons or {}) do weapon:RefreshEnabled() end
end
function M.CheckStealth(unit)
    local c=config(unit)
    if not c or not c.paidRadarStealth then return end
    local completed=unit.progress~=nil and unit:IsCompleted()
    local wanted=unit.scoSourceStealth==true and completed and not unit.dead
    local consumption=unit.resourceEntities and unit.resourceEntities.consumption
    if consumption then consumption:SetEnabled(wanted) end
    local active=wanted and unit.army and unit.army.economy and not unit.army.economy.isEnergyDown
    unit.scoSourceStealthActive=active==true
    if unit.radarLayer then
        -- This suppresses only radar detection. Direct vision remains authoritative.
        if unit.army then unit.radarLayer:SetOwnerArmy(unit.army.id) end
        unit.radarLayer:SetEnabled(unit.scoSourceIntelEnabled~=false and not active and not unit.dead)
    end
end
function M.SetStealth(unit,enabled)
    local c=config(unit)
    if not c or not c.paidRadarStealth or unit.dead or type(enabled)~='boolean' then return false end
    unit.scoSourceStealth=enabled
    M.CheckStealth(unit)
    Import('common/commands/definitions/units.lua').SCOSourceStealthState.Send(unit.id,enabled)
    return true
end
function M.SetGroundMode(unit,enabled)
    local c=config(unit)
    if not c or not c.airWeapon or unit.dead or type(enabled)~='boolean' then return false end
    if enabled and unit.scoCargoCarrier then return false end
    unit.scoSourceGroundMode=enabled
    M.Update(unit)
    Import('common/commands/definitions/units.lua').SCOSourceUnitModeState.Send(unit.id,enabled)
    return true
end
local function sniperDirection(weapon)
    local target=weapon.targetUnit
    if not target or target.dead then return end
    local origin,point=weapon.unit:GetPosition(),target:GetPosition()
    local x,z=point.x-origin.x,point.z-origin.z
    local length=math.sqrt(x*x+z*z)
    if length<1e-7 then return end
    return EngineClasses.float2(x/length,z/length)
end
local function sniperBodyAligned(unit,direction)
    local status,forward=Engine.GetGlobalEntityForwardDirection(unit.id)
    if status~=EngineErrorCode.Success then return false end
    local length=math.sqrt(forward.x*forward.x+forward.z*forward.z)
    return length>1e-7 and (forward.x*direction.x+forward.z*direction.y)/length>=math.cos(math.rad(5))
end
function M.InstallUnit(class)
    if class.scoSourceUnitModeInstalled then return end
    class.scoSourceUnitModeInstalled=true
    class.SCOSetGroundMode=function(self,value) return M.SetGroundMode(self,value) end
    class.SCOSetStealth=function(self,value) return M.SetStealth(self,value) end
    class.SCOSetSniperMode=function(self,value) return M.SetSniperMode(self,value) end
    -- A native face thread stops movement on completion. Cancel our idle-only
    -- thread before another order owns movement, never after that order starts.
    for _,name in ipairs({'MoveIntoRangeBehaviorStart','Destroy','Delete'}) do
        local previous=class[name]
        if previous then
            class[name]=function(self,...)
                stopSniperFacing(self)
                return previous(self,...)
            end
        end
    end
    local stopFacing=class.AlignBehaviorStop
    if stopFacing then
        class.AlignBehaviorStop=function(self,...)
            self.scoSniperOwnsFacing=nil
            return stopFacing(self,...)
        end
    end
    local previous=class.__init
    class.__init=function(self,...)
        previous(self,...)
        local c=config(self)
        if c and c.airWeapon then self.scoSourceGroundMode=false end
        if c and c.paidRadarStealth then self.scoSourceStealth=false end
        if c and c.sniperWeapon then M.SetSniperMode(self,false) end
        M.Update(self)
        M.CheckStealth(self)
    end
    for _,name in ipairs({'OnEnergyDown','OnEnergyUp','OnStopBeingBuilt','SetArmy'}) do
        local previous=class[name]
        class[name]=function(self,...)
            local result=previous(self,...)
            M.CheckStealth(self)
            return result
        end
    end
    local intel=class.SetIntelEnabled
    class.SetIntelEnabled=function(self,enabled,...)
        local result=intel(self,enabled,...)
        local c=config(self)
        if c and c.paidRadarStealth then
            self.scoSourceIntelEnabled=enabled
            M.CheckStealth(self)
        end
        return result
    end
    local capture=class.CaptureBehaviorIsValidFor
    class.CaptureBehaviorIsValidFor=function(self,target,...)
        local c=target and config(target)
        if c and c.capturable==false then return false end
        return capture(self,target,...)
    end
    for _,name in ipairs({'CanStartCaptureProcess','CanContinueCaptureProcess'}) do
        local previous=class[name]
        class[name]=function(self,...)
            local c=config(self)
            if c and c.capturable==false then return false end
            return previous(self,...)
        end
    end
end
function M.InstallWeapon(class,states)
    if class.scoSourceWeaponModeInstalled then return end
    class.scoSourceWeaponModeInstalled=true
    nativeWeaponState=states
    local canShoot=class.CanShootAt
    class.CanShootAt=function(self,...)
        local c=config(self.unit)
        if c and c.sniperWeapon and not M.Allowed(self) then return false end
        return canShoot(self,...)
    end
    local refresh,update=class.RefreshEnabled,class.Update
    class.RefreshEnabled=function(self,...)
        if not self.wantsEnabled or self.unit.dead then stopSniperFacing(self.unit) end
        -- Cargo sets its carrier before disabling weapons. Reset the source bit
        -- here even when a disabled weapon will no longer receive Update calls.
        if self.unit.scoCargoCarrier and self.unit.scoSourceSniperMode then
            M.SetSniperMode(self.unit,false)
        end
        local wanted=self.wantsEnabled
        if not M.Allowed(self) then self.wantsEnabled=false end
        local result=refresh(self,...)
        self.wantsEnabled=wanted
        return result
    end
    class.Update=function(self,...)
        local c=config(self.unit)
        if c then
            if self.unit.scoCargoCarrier and self.unit.scoSourceGroundMode then M.SetGroundMode(self.unit,false) end
            self:RefreshEnabled()
            if not self.enabled then return end
            if c.sniperWeapon and not self.unit.scoCargoCarrier then
                local direction=sniperDirection(self)
                if not direction then stopSniperFacing(self.unit) end
                if direction and not sniperBodyAligned(self.unit,direction)
                    and not self.unit.alignBehaviorIsActive
                    and not self.unit.moveIntoRangeBehaviorIsActive then
                    local status,speed=Engine.GetMovementCurrentSpeed(self.unit.id)
                    if status==EngineErrorCode.Success and speed==0 and self.unit.pendingMovement==nil then
                        self.unit.scoSniperOwnsFacing=true
                        self.unit:AlignBehaviorStart(direction)
                    end
                end
            end
        end
        return update(self,...)
    end
    local projectile=class.UpdateProjectile
    class.UpdateProjectile=function(self,isOnTarget,...)
        local c=config(self.unit)
        if c and c.sniperWeapon and c.sniperWeapon==self.tp.name
            and self.currentState==nativeWeaponState.ShootSalvo then
            if not isOnTarget then
                self.scoSniperChargeRemaining=nil
                self.currentState=nativeWeaponState.WaitingForTarget
                self.reloadTimer=0
                return
            end
            if self.scoSniperChargeRemaining==nil then
                self.scoSniperChargeRemaining=c.chargeSeconds
                return
            end
            self.scoSniperChargeRemaining=self.scoSniperChargeRemaining-Constants.TickTimeStep
            if self.scoSniperChargeRemaining>1e-7 then return end
            self.scoSniperChargeRemaining=nil
        end
        return projectile(self,isOnTarget,...)
    end
end
-- Native Import returns this module environment; plain Lua loaders keep the return API.
local moduleEnvironment = getfenv(1)
for name, value in pairs(M) do moduleEnvironment[name] = value end
return M
