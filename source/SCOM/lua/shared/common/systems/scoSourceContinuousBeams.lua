-- FA BeamLifetime=0 means an indefinitely sustained beam. Metadata is distinct
-- from the positive-pulse hook and preserves its existing scoped behavior.
local M={}
function M.InstallWeapon(HostWeapon,WeaponState)
    local previous=HostWeapon.Update
    local previousOnTarget=HostWeapon.IsWeaponOnTarget
    local Commands=Import("common/commands/definitions/projectiles.lua")
    function HostWeapon:IsWeaponOnTarget()
        local source=self.tp.scoFaContinuousBeam
        if source and source.fixedMuzzle then
            -- Source Czar is explicitly Turreted=false; its authored muzzle
            -- points down. Native no-controller weapons otherwise never fire.
            return self.targetUnit~=nil and self:CanShootAt(self.targetUnit) and self:IsTargetInRange(self.targetUnit)
        end
        return previousOnTarget(self)
    end
    function HostWeapon:Update()
        local source=self.tp.scoFaContinuousBeam
        if not source then return previous(self) end
        self.scoContinuousReload=math.max(0,(self.scoContinuousReload or 0)-1)
        if self.enabled and not self.unit.dead then self:UpdateTargeting() end
        local active=self.enabled and not self.unit.dead and self:IsWeaponOnTarget()
        if self.scoContinuousFiring and not active then
            self:SetMuzzlesFiring(false)
            self.scoContinuousFiring=false
            self.currentState=WeaponState.WaitingForReload
        elseif active and not self.scoContinuousFiring and self.scoContinuousReload==0 then
            self.scoContinuousFiring=true
            self.scoContinuousReload=math.max(1,math.ceil(self.tp.reloadTime/Constants.TickTimeStep-1e-7))
            self.currentState=WeaponState.WaitingPersistentBeamLifetime
            for _,muzzle in ipairs(self.muzzleGroups[self.currentMuzzleGroupIndex]) do
                __Muzzles[muzzle.id.index]:SetFiring(true)
                Commands.FireMuzzle.Send(muzzle.id)
            end
        end
        self.reloadTimer=self.scoContinuousReload*Constants.TickTimeStep
    end
end

function M.InstallBeam(HostBeam)
    local previousInit=HostBeam.__init
    local previousEnable=HostBeam.SetBeamEnabled
    local previousFire=HostBeam.Raycast
    local Layers=Import("common/layers.lua")
    local Damage=Import("host/collisionUpdate.lua")
    function HostBeam:__init(id, muzzle)
        previousInit(self,id,muzzle)
        local tp = muzzle.weapon.tp
        self.scoContinuous=tp.scoFaContinuousBeam
        if self.scoContinuous then
            self.rangeMax=self.scoContinuous.maximumLength or self.rangeMax
            self.scoContinuousTick=0
        end
    end
    function HostBeam:SetBeamEnabled(enabled)
        if self.scoContinuous and enabled and not self.enabled then self.scoContinuousTick=0 end
        return previousEnable(self,enabled)
    end
    function HostBeam:Raycast()
        local source=self.scoContinuous
        if not source then return previousFire(self) end
        self.scoContinuousTick=self.scoContinuousTick+1
        local apply=self.scoContinuousTick%source.collisionIntervalTicks==0
        local _,origin=Engine.GetGlobalEntityWorldPosition(self.id)
        local _,forward=Engine.GetGlobalEntityForwardDirection(self.id)
        local events=Engine.RayCast(Layers.CollisionWorld.Collision,origin,forward,self.rangeMax,
            Layers.CollisionLayer.Shields+Layers.CollisionLayer.Units)
        for _,event in ipairs(events) do
            local id=event.otherGlobalID
            local terrain=id.index==0
            local valid=not terrain and Engine.IsValidGlobalID(id)
            local unit=valid and __Entities.Units[id.index]
            local shield=valid and __Entities.Shields[id.index]
            local enemyUnit=unit and self.unit.army:IsEnemy(unit.army)
            local enemyShield=shield and shield.enabled and self.unit.army:IsEnemy(shield.army)
            if terrain or enemyUnit or enemyShield then
                if apply then
                    if source.damageRadius>0 then
                        local point=EngineClasses.float3(origin.x+forward.x*event.hitDistance,
                            origin.y+forward.y*event.hitDistance,origin.z+forward.z*event.hitDistance)
                        Damage.ProcessAreaDamage(point,source.damageRadius,self.damage,self.unit.army,source.damageFriendly,self.unit)
                    elseif enemyUnit then unit:TakeDamage(self.damage,DestroyType.Kinetic,self.unit)
                    elseif enemyShield then shield:TakeDamage(self.damage) end
                end
                return event.hitDistance
            end
        end
        return self.rangeMax
    end
end
-- Native Import returns this module environment; plain Lua loaders keep the return API.
local moduleEnvironment = getfenv(1)
for name, value in pairs(M) do moduleEnvironment[name] = value end
return M
