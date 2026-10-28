local ClientBeam = Import("client/entities/beams/beamBase.lua").ClientBeam
local CollisionLayer = Import("common/layers.lua").CollisionLayer
local IntelBitMask = Import("common/intelBitMask.lua").IntelBitMask
local Water = Import("common/water.lua")
local Units = __Entities.Units
local Shields = __Entities.Shields

---@class ClientBeamWeapon: ClientBeam A visual beam aimed from a weapon muzzle.
---@field protected muzzle ClientMuzzle Weapon muzzle used as the beam's origin.
---@field protected projectileTemplate ProjectileTemplate Projectile template used for impact visuals.
---@field protected hasImpact boolean Whether the current raycast has an impact.
---@field protected lastForward float3 Last muzzle forward direction.
---@field protected isIntelVisionVisible boolean Whether the focus army can see this beam.
---@field protected visibilityMask IntelBitMask Armies which can see this beam.
---@field protected attachedToMuzzle boolean Whether the renderers belong to the unit hierarchy.
ClientBeamWeapon = Class("ClientBeamWeapon", ClientBeam)

---@param beamID LocalID Beam prefab root or muzzle ID.
---@param muzzle ClientMuzzle Weapon muzzle.
---@param submeshes LocalID[]|nil Renderers already attached to the muzzle.
function ClientBeamWeapon:__init(beamID, muzzle, submeshes)
    ClientBeam.__init(self, beamID, muzzle.weapon.tp.beam, submeshes)

    self.muzzle = muzzle
    self.attachedToMuzzle = submeshes ~= nil
    self.projectileTemplate = GetTemplate(muzzle.weapon.tp.projectileTemplate, "Projectiles")
    self.hasImpact = false
    self.lastForward = EngineClasses.float3(0, 0, 1)
    self.isIntelVisionVisible = false
    self.visibilityMask = rawget(muzzle, "beamVisibilityMask") or IntelBitMask.FromArmyId(muzzle.weapon.unit.armyId)
    self:RecalculateIntel()
end

---@param enabled boolean
function ClientBeamWeapon:SetBeamEnabled(enabled)
    if enabled then
        self:OnImpactLost()
        self.hasImpact = false
        self:SetBeamLength(0)
    elseif self.enabled then
        self:OnImpactLost()
    end

    ClientBeam.SetBeamEnabled(self, enabled)
end

function ClientBeamWeapon:OnDeleted()
    self:OnImpactLost()
    if not self.attachedToMuzzle then
        Engine.DeletePrefabInstance(self.localId)
    end
end

--- We update the raycast before we process the rendering. This ensures that the beam's visual representation is accurate based on the latest collision data.
function ClientBeamWeapon:OnUpdateStart()
    
    local collisionEvent = nil

    if self.enabled then
        collisionEvent = self:Raycast()
    end
    
    if self.hasImpact and collisionEvent then
        self:OnImpactUpdated(collisionEvent)
    end
end

---@param visionDetectionMask IntelBitMask
function ClientBeamWeapon:UpdateIntelVisionDetection(visionDetectionMask)
    self.visibilityMask = visionDetectionMask
    self:RecalculateIntel()
end

function ClientBeamWeapon:RecalculateIntel()
    local focusArmyID = GetFocusArmy()
    if focusArmyID == nil then return end

    if focusArmyID == -1 then
        self.isIntelVisionVisible = true
    else
        self.isIntelVisionVisible = self.visibilityMask:IsVisible(Armies[focusArmyID].intelMask)
    end

    self:OnIntelVisibilityChanged()
end

---@protected
function ClientBeamWeapon:OnIntelVisibilityChanged()
end

---@protected
---@param enabled boolean
function ClientBeamWeapon:SetRenderersEnabled(enabled)
    ClientBeam.SetRenderersEnabled(self, enabled and self.isIntelVisionVisible)
end

---@protected Raycast from the muzzle and dispatch the result to the impact hooks.
---@return LocalRayCollisionEvent|nil Hit event, including a water surface hit, or nil when the ray misses.
function ClientBeamWeapon:Raycast()
    local orbital = self.muzzle.weapon.tp.scoSpecialOrbital
    local rangeMax = orbital and orbital.maximumLength or self.muzzle.weapon.tp.rangeMax or 0
    local army = self.muzzle.weapon.unit.army
    local _, origin = Engine.GetLocalEntityWorldPosition(self.muzzle.localId)
    local _, forward = Engine.GetLocalEntityForwardDirection(self.muzzle.localId)

    self.lastForward = forward
    self.hasImpact = false
    local impactEvent

    local waterDistance = nil
    if not self.muzzle.weapon.tp.penetratesWater then
        waterDistance = Water.GetDistance(origin, forward, rangeMax)
    end

    local rayMaxDistance = waterDistance or rangeMax
    local collisionEvents = Engine.RayCast(
        CollisionWorld.Collision,
        origin,
        forward,
        rayMaxDistance,
        CollisionLayer.Shields + CollisionLayer.Units
    )

    for _, collisionEvent in ipairs(collisionEvents) do
        if collisionEvent.colliderLocalID.index == 0 then
            impactEvent = collisionEvent
            break
        end

        if Engine.IsValidLocalID(collisionEvent.colliderLocalID) then
            local _, globalID = Engine.GetLocalEntityGlobalID(collisionEvent.colliderLocalID)
            local otherUnit = Units[globalID.index]
            local shield = Shields[globalID.index]

            if otherUnit and army:IsEnemy(otherUnit.army) then
                impactEvent = collisionEvent
                break
            end

            if shield and shield.enabled and army:IsEnemy(shield.army) then
                impactEvent = collisionEvent
                break
            end
        end
    end

    -- Create a collision event for the water surface if the ray hits it. This is because we don't include water in the raycast mask.
    if impactEvent == nil and waterDistance ~= nil then
        local waterSurfaceLocalID = _G.WaterLocalID
        if waterSurfaceLocalID ~= nil and Engine.IsValidLocalID(waterSurfaceLocalID) then
            local hitPosition = math3D.add(origin, math3D.scale(forward, waterDistance))
            impactEvent = EngineClasses.LocalRayCollisionEvent(
                nil,
                waterSurfaceLocalID,
                origin,
                forward,
                waterDistance,
                hitPosition,
                EngineClasses.float3(0, 1, 0),
                waterDistance,
                0,
                1
            )
        end
    end

    if impactEvent == nil then
        self:OnImpactLost(origin, rayMaxDistance)
    else
        self.hasImpact = true
        self:OnRaycastImpact(origin, impactEvent)
    end

    return impactEvent
end

---@protected
---@param origin float3 Raycast origin in world space.
---@param collisionEvent LocalRayCollisionEvent Raycast hit data.
--- Subclass hook for reacting to a raycast impact.
function ClientBeamWeapon:OnRaycastImpact(origin, collisionEvent)
end

---@protected
---@param collisionEvent LocalRayCollisionEvent Current raycast hit data.
--- Subclass hook for updating an impact that remains on target.
function ClientBeamWeapon:OnImpactUpdated(collisionEvent)
end

---@protected
---@param origin float3|nil Raycast origin; omitted for lifecycle cleanup.
---@param rangeMax number|nil Maximum range; required when origin is supplied.
--- Subclass hook for reacting to a raycast miss or cleaning up impact effects.
function ClientBeamWeapon:OnImpactLost(origin, rangeMax)
end

return { ClientBeamWeapon = ClientBeamWeapon }
