local CollisionUpdate = Import("host/collisionUpdate.lua")
local CollisionWorld = Import("common/layers.lua").CollisionWorld
local CollisionLayer = Import("common/layers.lua").CollisionLayer
local IntelCommands = Import("common/commands/definitions/intel.lua")
local HostCollider = Import("host/managers/colliders/collider.lua")
local IntelLayer = Import("host/managers/intel/intelLayer.lua").IntelLayer
local Water = Import("common/water.lua")
local Shields = __Entities.Shields
local Units = __Entities.Units

---@param id GlobalID
---@param muzzle HostMuzzle
---@return HostBeam
function CreateHostBeam(id, muzzle)
    return HostBeam(id, muzzle)
end

-- The smallest 
local MinimumIntelSize = 1

---@class HostBeam
---@field private id GlobalID
---@field private unit HostUnit
---@field private damage number
---@field private rangeMax number
---@field private penetratesWater boolean
---@field private enabled boolean
---@field private signatureColliderId GlobalID The box fitted over the beam so it can be detected.
---@field private intelLayer IntelLayer Tracks which armies can see the beam.
HostBeam = Class("HostBeam")

---@param id GlobalID
---@param muzzle HostMuzzle
function HostBeam:__init(id, muzzle)
    self.id = id
    self.muzzle = muzzle

    self.enabled = false

    local weapon = muzzle.weapon
    local weaponTemplate = weapon.tp

    self.unit = weapon.unit
    self.damage = weaponTemplate.damage
    self.rangeMax = weaponTemplate.rangeMax
    self.damageRadius = weaponTemplate.damageRadius
    self.penetratesWater = weaponTemplate.penetratesWater == true
    self.damageFriendly = weaponTemplate.damageFriendly == true

    self:SetUpIntel()
end

function HostBeam:SetUpIntel()
    self.signatureColliderId = self.unit:GetBoneId(self.muzzle.boneName.."IntelVisionSignatureCollider")

    self.intelLayer = IntelLayer.new(HostCollider.CreateHostCollider(self.signatureColliderId), CollisionWorld.IntelVision, function(mask)
        IntelCommands.SetBeamIntel.Send(self.id, mask)
    end)

    self.intelLayer:SetOwnerArmy(self.unit.army.id) -- Always visible to its own army.
    self:SetBeamLength(0)
end

function HostBeam:Delete()
    self.intelLayer:Delete()
end

---@private Fits the intel signature box over the beam.
---@param length number How far the beam travels before it is stopped.
function HostBeam:SetBeamLength(length)
    length = math.max(length, MinimumIntelSize)

    local size = EngineClasses.float3(MinimumIntelSize, MinimumIntelSize, length)
    local offset = EngineClasses.float3(0, 0, length * 0.5)
    self.intelLayer:SetSignitureSizeOffset(size, offset)
end

---@param enabled boolean
function HostBeam:SetBeamEnabled(enabled)
    self.enabled = enabled

    if not enabled then
        self:SetBeamLength(0)
    end
end

function HostBeam:Update()
    if not self.enabled then return end

    local range = self:Raycast()

    self:SetBeamLength(range)
end

---@return number maxRange
function HostBeam:Raycast()
    -- Gravity claws kill at the capture point; their visible beam does no chip damage.
    local tractor = self.unit.tpId == "ucl4004" and self.muzzle.weapon.tp.scoTractor ~= nil
    local _, origin = Engine.GetGlobalEntityWorldPosition(self.id)
    local _, forward = Engine.GetGlobalEntityForwardDirection(self.id)

    local range = self.rangeMax
    if not self.penetratesWater then
        range = Water.GetDistance(origin, forward, range) or range
    end

    local army = self.unit.army
    local collisionEvents = Engine.RayCast(CollisionWorld.Collision, origin, forward, range, CollisionLayer.Shields + CollisionLayer.Units)

    for _, collisionEvent in ipairs(collisionEvents) do
        if collisionEvent.otherGlobalID.index == 0 then
            if self.damageRadius > 0 then
                CollisionUpdate.ProcessAreaDamage(collisionEvent.hitPosition, self.damageRadius, self.damage, self.unit.army, self.damageFriendly, self.unit)
            end
            
            -- # hit the terrain
            return collisionEvent.hitDistance
        end

        if Engine.IsValidGlobalID(collisionEvent.otherGlobalID) then
            local unit = Units[collisionEvent.otherGlobalID.index]
            local shield = Shields[collisionEvent.otherGlobalID.index]

            if unit and army:IsEnemy(unit.army) then
                if self.damageRadius > 0 then
                    CollisionUpdate.ProcessAreaDamage(collisionEvent.hitPosition, self.damageRadius, self.damage, self.unit.army, self.damageFriendly, self.unit)
                elseif not tractor then
                    unit:TakeDamage(self.damage, DestroyType.Kinetic, self.unit)
                end
                
                return collisionEvent.hitDistance
            end

            if shield and shield.enabled and army:IsEnemy(shield.army) then
                if self.damageRadius > 0 then
                    CollisionUpdate.ProcessAreaDamage(collisionEvent.hitPosition, self.damageRadius, self.damage, self.unit.army, self.damageFriendly, self.unit)
                elseif not tractor then
                    shield:TakeDamage(self.damage)
                end
                
                return collisionEvent.hitDistance
            end
        end
    end

    return range
end


-- Guard Cybran Monkeylord Cache Patcher 1.4.0
local scoMonkeylordStockBeamInit = HostBeam.__init
local scoMonkeylordStockSetBeamEnabled = HostBeam.SetBeamEnabled
local scoMonkeylordStockBeamRaycast = HostBeam.Raycast
local scoMonkeylordCollisionUpdate =
    Import("host/collisionUpdate.lua")
local scoMonkeylordUnits = __Entities.Units
local scoMonkeylordShields = __Entities.Shields

function HostBeam:__init(id, muzzle)
    scoMonkeylordStockBeamInit(self, id, muzzle)
    local weaponTemplate = muzzle.weapon.tp
    self.scoMonkeylordMicrowave =
        weaponTemplate.scoMonkeylordMicrowave
    if self.scoMonkeylordMicrowave
        and ((self.scoMonkeylordMicrowave.damageRadius or 0) <= 0
            or (self.scoMonkeylordMicrowave.collisionTicks or 0) < 1)
    then
        error("Monkeylord microwave radius/cadence must be positive")
    end
    self.scoMonkeylordCollisionTicksRemaining = 0
end

function HostBeam:SetBeamEnabled(enabled, sendCommand)
    scoMonkeylordStockSetBeamEnabled(self, enabled, sendCommand)
    local config = self.scoMonkeylordMicrowave
    if config == nil
        or self.scoMonkeylordSpinActive == enabled
    then
        return
    end
    self.scoMonkeylordCollisionTicksRemaining = enabled
        and config.collisionTicks - 1 or 0
    if self.scoMonkeylordSpinBone == nil then
        self.scoMonkeylordSpinBone =
            self.unit:GetBoneId(config.spinBone)
        if self.scoMonkeylordSpinBone == nil then
            error("Monkeylord microwave spin bone is missing")
        end
    end
    self.scoMonkeylordSpinActive = enabled
    Engine.SetRotatorSpeed(
        self.scoMonkeylordSpinBone,
        EngineClasses.float3(0, 0, config.spinSpeed))
    Engine.SetRotatorEnabled(
        self.scoMonkeylordSpinBone,
        enabled)
end

function HostBeam:Raycast()
    local config = self.scoMonkeylordMicrowave
    if config == nil then return scoMonkeylordStockBeamRaycast(self) end
    if not self.enabled then return self.rangeMax end
    local applyDamage = self.scoMonkeylordCollisionTicksRemaining <= 0
    if applyDamage then
        self.scoMonkeylordCollisionTicksRemaining = config.collisionTicks - 1
    else
        self.scoMonkeylordCollisionTicksRemaining = self.scoMonkeylordCollisionTicksRemaining - 1
    end
    local _, origin = Engine.GetGlobalEntityWorldPosition(self.id)
    local _, forward = Engine.GetGlobalEntityForwardDirection(self.id)
    local collisions = Engine.RayCast(CollisionWorld.Collision, origin, forward,
        self.rangeMax, CollisionLayer.Shields + CollisionLayer.Units)
    local army = self.unit.army
    for _, collision in ipairs(collisions) do
        local id = collision.otherGlobalID
        local terrain = id.index == 0
        local valid = not terrain and Engine.IsValidGlobalID(id)
        local unit = valid and scoMonkeylordUnits[id.index]
        local shield = valid and scoMonkeylordShields[id.index]
        if terrain or (unit and army:IsEnemy(unit.army))
            or (shield and shield.enabled and army:IsEnemy(shield.army)) then
            if applyDamage then
                scoMonkeylordCollisionUpdate.ProcessAreaDamage(collision.hitPosition, config.damageRadius,
                    self.damage, army, false, self.unit)
            end
            return collision.hitDistance
        end
    end
    return self.rangeMax
end

-- Supreme Commander Overhaul commander enhancements 1.0.0
-- Scoped FA microwave collision cadence for the Cybran ACU. Sanctuary's
-- native HostBeam applies damage every simulation tick; FA's MLG applies its
-- authored 800 damage every other tick. This wrapper leaves every other beam,
-- including the separately patched Monkeylord, on its existing behavior.

local SCOCommanderEnhancementBeamVersion = "1.0.0"
local SCOCommanderEnhancementBeamEnvironment =
    type(getfenv) == "function" and getfenv(1) or _ENV
local SCOCommanderEnhancementBeamMarker = rawget(
    SCOCommanderEnhancementBeamEnvironment,
    "SCO_CommanderEnhancementBeamInstalled")
if SCOCommanderEnhancementBeamMarker ~= nil
    and SCOCommanderEnhancementBeamMarker ~= SCOCommanderEnhancementBeamVersion
then
    error("Unsupported SCOM commander-enhancement beam marker "
        .. tostring(SCOCommanderEnhancementBeamMarker))
end

if SCOCommanderEnhancementBeamMarker == nil then
    if type(HostBeam) ~= "table"
        or type(HostBeam.__init) ~= "function"
        or type(HostBeam.SetBeamEnabled) ~= "function"
        or type(HostBeam.Update) ~= "function"
    then
        error("SCOM commander enhancement could not resolve HostBeam")
    end

    local SCOCommanderBeamPreviousInit = HostBeam.__init
    local SCOCommanderBeamPreviousSetEnabled = HostBeam.SetBeamEnabled
    local SCOCommanderBeamPreviousRaycast = HostBeam.Raycast
    local SCOCommanderBeamCollisionUpdate =
        Import("host/collisionUpdate.lua")
    local SCOCommanderBeamUnits = __Entities.Units
    local SCOCommanderBeamShields = __Entities.Shields

    function HostBeam:__init(id, muzzle)
        SCOCommanderBeamPreviousInit(self, id, muzzle)
        local weaponTemplate = muzzle.weapon.tp
        self.scoCommanderMicrowave = weaponTemplate.scoCommanderMicrowave
        local config = self.scoCommanderMicrowave
        if config ~= nil
            and (type(config.collisionTicks) ~= "number"
                or config.collisionTicks ~= math.floor(config.collisionTicks)
                or config.collisionTicks < 1
                or type(config.damageRadius) ~= "number"
                or config.damageRadius <= 0)
        then
            error("Commander microwave radius/cadence must be positive")
        end
        self.scoCommanderCollisionTicksRemaining = 0
    end

    function HostBeam:SetBeamEnabled(enabled, ...)
        SCOCommanderBeamPreviousSetEnabled(self, enabled, ...)
        if self.scoCommanderMicrowave ~= nil then
            self.scoCommanderCollisionTicksRemaining = 0
        end
    end

    function HostBeam:Raycast()
        local config = self.scoCommanderMicrowave
        if config == nil then return SCOCommanderBeamPreviousRaycast(self) end
        if not self.enabled then return self.rangeMax end
        local applyDamage = self.scoCommanderCollisionTicksRemaining <= 0
        if applyDamage then
            self.scoCommanderCollisionTicksRemaining = config.collisionTicks - 1
        else
            self.scoCommanderCollisionTicksRemaining = self.scoCommanderCollisionTicksRemaining - 1
        end
        local _, origin = Engine.GetGlobalEntityWorldPosition(self.id)
        local _, forward = Engine.GetGlobalEntityForwardDirection(self.id)
        local collisions = Engine.RayCast(CollisionWorld.Collision, origin, forward,
            self.rangeMax, CollisionLayer.Shields + CollisionLayer.Units)
        local army = self.unit.army
        for _, collision in ipairs(collisions) do
            local id = collision.otherGlobalID
            local terrain = id.index == 0
            local valid = not terrain and Engine.IsValidGlobalID(id)
            local unit = valid and SCOCommanderBeamUnits[id.index]
            local shield = valid and SCOCommanderBeamShields[id.index]
            if terrain or (unit and army:IsEnemy(unit.army))
                or (shield and shield.enabled and army:IsEnemy(shield.army)) then
                if applyDamage then
                    SCOCommanderBeamCollisionUpdate.ProcessAreaDamage(collision.hitPosition, config.damageRadius,
                        self.damage, army, false, self.unit)
                end
                return collision.hitDistance
            end
        end
        return self.rangeMax
    end

    rawset(
        SCOCommanderEnhancementBeamEnvironment,
        "SCO_CommanderEnhancementBeamInstalled",
        SCOCommanderEnhancementBeamVersion)
end

-- SCOM source beam runtime installation 1.0.0
Import('common/systems/scoSourceWeaponRuntime.lua').InstallBeam(HostBeam)
Import('common/systems/scoSourceSpecialWeapons.lua').InstallBeam(HostBeam)
Import('common/systems/scoSourceContinuousBeams.lua').InstallBeam(HostBeam)

return {
    CreateHostBeam = CreateHostBeam
}


-- Supreme Commander Overhaul Forged Alliance Veterancy 1.0.0
