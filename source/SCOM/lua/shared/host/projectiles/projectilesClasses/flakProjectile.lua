local HostProjectile = Import("host/projectiles/projectilesClasses/projectilesBaseClass.lua").HostProjectile
local CollisionUpdate = Import("host/collisionUpdate.lua")
local SCOMEditableUnits = Import("scom/editableUnits.lua")

---Anti-air shell that bursts when it passes within its damage radius of its target, or when its lifetime runs out.
---@class HostFlakProjectile: HostProjectile
HostFlakProjectile = Class("FlakProjectile", HostProjectile)

---@protected
---@param globalId GlobalID
---@param armyId ArmyId
---@param template ProjectileTemplate
---@param damage number
---@param damageRadius number
---@param lifetime number
---@param muzzleId? GlobalID
---@param targetBoneId? GlobalID Bone the shot was aimed at; without it the shell only bursts at the end of its lifetime.
function HostFlakProjectile:__init(globalId, armyId, template, damage, damageRadius, lifetime, muzzleId, targetBoneId)
    -- Keep the native eighth argument as targetBoneId. The source is resolved
    -- from the exact firing muzzle so SCOM blast kills retain their instigator.
    local muzzle = muzzleId and __Muzzles[muzzleId.index]
    local source = muzzle and muzzle.id.version == muzzleId.version
        and muzzle.weapon and muzzle.weapon.unit
    if not (source and SCOMEditableUnits.IsEditable(source.tp)) then source = nil end
    HostProjectile.__init(self, globalId, armyId, template, damage, damageRadius, lifetime, muzzleId, source)

    self.targetBoneId = targetBoneId
    local _, position = Engine.GetGlobalEntityWorldPosition(globalId)
    self.previousPosition = position
end

---Deals area damage at the position and destroys the shell, so the client plays its impact effects mid-air.
---@param position float3
function HostFlakProjectile:Burst(position)
    CollisionUpdate.ProcessAreaDamage(position, self.damageRadius, self.damage, Armies[self.armyId], false, self.sourceUnit)
    
    -- TODO: Get the actual impact time for the flack explosion.
    self:Destroy(Constants.TickTimeStep - 0.001)
end

function HostFlakProjectile:Update()
    local _, position = Engine.GetGlobalEntityWorldPosition(self.id)
    position = { x = position.x, y = position.y, z = position.z }

    if self.spawnTime + self.lifetime < _G.Time then
        self:Burst(position)
        return
    end

    -- The shell moves several units per tick, so check the closest point of this tick's path, not just its end.
    if self.targetBoneId then
        local errorCode, targetPosition = Engine.GetGlobalEntityWorldPosition(self.targetBoneId)
        if errorCode == EngineErrorCode.Success then
            local path = math3D.sub(position, self.previousPosition)
            local pathLengthSquared = math3D.lengthSquared(path)
            local fraction = 0
            if pathLengthSquared > 0 then
                fraction = math.clamp(math3D.dot(math3D.sub(targetPosition, self.previousPosition), path) / pathLengthSquared, 0, 1)
            end
            local closestPoint = math3D.add(self.previousPosition, math3D.scale(path, fraction))
            if math3D.distance(closestPoint, targetPosition) <= self.damageRadius then
                self:Burst(closestPoint)
                return
            end
        else
            self.targetBoneId = nil
        end
    end

    self.previousPosition = position
    HostProjectile.Update(self)
end
