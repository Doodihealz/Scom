-- The residual's source weapon intentionally attacks friendly and enemy LAND
-- units, or random ground positions. Ordinary native and FA weapons stay intact.
local M={}
function M.InstallWeapon(HostWeapon)
    local previous=HostWeapon.Update
    local previousInit=HostWeapon.__init
    local previousRange=HostWeapon.IsTargetInRange
    local previousTargeting=HostWeapon.UpdateTargeting
    local Commands=Import("common/commands/definitions/projectiles.lua")
    local Map=Import("common/mapUtils.lua")
    function HostWeapon:__init(...)
        previousInit(self,...)
        local orbital=self.tp.scoSpecialOrbital
        if orbital then
            for _,id in ipairs(self.aimControllerIds) do Engine.SetAimControllerMaxRange(id,orbital.maximumLength) end
        end
    end
    function HostWeapon:IsTargetInRange(unit)
        local orbital=self.tp.scoSpecialOrbital
        if not orbital then return previousRange(self,unit) end
        local a,b=self.unit:GetPosition(),unit:GetPosition()
        local distance=(a.x-b.x)^2+(a.z-b.z)^2
        return distance>=self.tp.rangeMin^2 and distance<=orbital.horizontalRange^2
    end
    function HostWeapon:UpdateTargeting()
        local orbital=self.tp.scoSpecialOrbital
        if not orbital then return previousTargeting(self) end
        local chosen=self.preferredTarget
        if chosen and self:CanShootAt(chosen) and self:IsTargetInRange(chosen) then self:SetAimTarget(chosen);return end
        if self.targetUnit and self:CanShootAt(self.targetUnit) and self:IsTargetInRange(self.targetUnit) then return end
        local candidates={}
        for _,other in pairs(__Entities.Units) do
            if self:CanShootAt(other) and self:IsTargetInRange(other) then
                local tags={ALLUNITS=true}
                for _,tag in ipairs(other.tp.tags or {}) do tags[tag]=true;tags[tag:gsub("^SCFA_","")]=true end
                local rank=#orbital.targetPriorities+1
                for i,expression in ipairs(orbital.targetPriorities) do
                    local match=true
                    for tag in expression:gmatch("%S+") do if not tags[tag] then match=false end end
                    if match then rank=i;break end
                end
                candidates[#candidates+1]={unit=other,rank=rank}
            end
        end
        table.sort(candidates,function(a,b)if a.rank~=b.rank then return a.rank<b.rank end return a.unit.id.index<b.unit.id.index end)
        self:SetAimTarget(candidates[1] and candidates[1].unit or nil)
    end
    local function Eligible(unit,other)
        if other==unit or other.dead or other.isTargetable~=true then return false end
        local land=false
        for _,tag in ipairs(other.tp.tags or {}) do
            if tag=="SCFA_UNTARGETABLE" then return false end
            if tag=="LAND" or tag=="SCFA_LAND" then land=true end
        end
        return land
    end
    function HostWeapon:SCOSpecialResidualTarget()
        local position=self.unit:GetPosition()
        local candidates={}
        for _,other in pairs(__Entities.Units) do
            if Eligible(self.unit,other) then
                local point=other:GetPosition()
                local distance=(point.x-position.x)^2+(point.z-position.z)^2
                if distance>=self.tp.rangeMin^2 and distance<=self.tp.rangeMax^2 then candidates[#candidates+1]=other end
            end
        end
        table.sort(candidates,function(a,b)return a.id.index<b.id.index end)
        local point
        if #candidates>0 then
            self.targetUnit=candidates[math.random(1,#candidates)]
            point=self.targetUnit:GetPosition()
        else
            self.targetUnit=nil
            point=EngineClasses.float3(position.x+(math.random()*2-1)*self.tp.rangeMax,position.y,
                position.z+(math.random()*2-1)*self.tp.rangeMax)
            if not Map.IsPositionOnMap(point) then point=position end
            local status,height=Engine.SampleTerrainHeight(point)
            if status==EngineErrorCode.Success then point.y=height end
        end
        self.scoResidualTargetPoint=point
    end
    function HostWeapon:SCOSpecialResidualAim()
        if self.targetUnit and not self.targetUnit.dead then
            self:SetAimTarget(self.targetUnit)
            return
        end
        local point=self.scoResidualTargetPoint
        local marker=self.unit:GetBoneId(self.tp.scoFaResidual.groundTargetEntity)
        if not point or not marker then return end
        -- The helper marker has no animation, mesh, collider, or unit identity.
        -- Native aim-controller evaluation owns the actual source Muzzle pose.
        Engine.SetGlobalEntityPosition(marker,point)
        for _,id in ipairs(self.aimControllerIds) do
            Engine.SetAimControllerTarget(id,marker)
        end
    end
    function HostWeapon:Update()
        local source=self.tp.scoFaResidual
        if not source then return previous(self) end
        if self.unit.dead or not self.enabled then self:SetMuzzlesFiring(false);self.scoResidualPhase=nil;return end
        if not self.scoResidualPhase then
            self:SCOSpecialResidualTarget()
            self.scoResidualPhase="aim"
            self.scoResidualTicks=source.targetDelayTicks
            self:SCOSpecialResidualAim()
            return
        end
        self:SCOSpecialResidualAim()
        self.scoResidualTicks=self.scoResidualTicks-1
        if self.scoResidualTicks>0 then return end
        if self.scoResidualPhase=="aim" then
            self.scoResidualPhase="fire"
            self.scoResidualTicks=source.lifetimeTicks
            for _,muzzle in ipairs(self.muzzleGroups[1]) do
                __Muzzles[muzzle.id.index]:SetFiring(true)
                Commands.FireMuzzle.Send(muzzle.id)
            end
        else
            self:SetMuzzlesFiring(false)
            self.scoResidualPhase=nil
            -- RequireTime=0: choose the next source target in this same tick.
            return self:Update()
        end
    end
end

function M.InstallBeam(HostBeam)
    local previous=HostBeam.Raycast
    local previousInit=HostBeam.__init
    local Damage=Import("host/collisionUpdate.lua")
    local Layers=Import("common/layers.lua")
    function HostBeam:__init(id, muzzle)
        previousInit(self,id,muzzle)
        local tp = muzzle.weapon.tp
        if tp.scoSpecialOrbital then self.rangeMax=tp.scoSpecialOrbital.maximumLength end
    end
    function HostBeam:Raycast()
        local source=self.scoFaBeam
        if not source or not source.residual then return previous(self) end
        local _,origin=Engine.GetGlobalEntityWorldPosition(self.id)
        local _,forward=Engine.GetGlobalEntityForwardDirection(self.id)
        local events=Engine.RayCast(Layers.CollisionWorld.Collision,origin,forward,self.rangeMax,
            Layers.CollisionLayer.Shields+Layers.CollisionLayer.Units)
        self.scoFaCollisionTick=self.scoFaCollisionTick+1
        for _,event in ipairs(events) do
            local id=event.otherGlobalID
            local terrain=id.index==0
            local valid=not terrain and Engine.IsValidGlobalID(id)
            local unit=valid and __Entities.Units[id.index]
            local shield=valid and __Entities.Shields[id.index]
            if terrain or (unit and unit~=self.unit and not unit.dead) or (shield and shield.enabled) then
                if self.scoFaCollisionTick%source.collisionIntervalTicks==0 then
                    local point=EngineClasses.float3(origin.x+forward.x*event.hitDistance,
                        origin.y+forward.y*event.hitDistance,origin.z+forward.z*event.hitDistance)
                    Damage.ProcessAreaDamage(point,source.damageRadius,self.damage,self.unit.army,true,self.unit)
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
