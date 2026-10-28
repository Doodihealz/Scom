local ClientBeamWeapon = Import("client/entities/beams/beamWeapon.lua").ClientBeamWeapon
local ImpactEffects = Import("client/entities/beams/beamWeaponImpactEffects.lua")

local function OwnsSourceEndpoint(beam)
    local tp = beam.muzzle.weapon.tp
    local source = tp.scoFaBeam or tp.scoFaContinuousBeam
    return source and source.endpointEffects
        and type(tp.projectileTemplate) == "string"
        and string.sub(tp.projectileTemplate, 1, 3) == "pbf"
end

local function StopSourceEndpoint(beam)
    local effectId = beam.scoSourceImpactEffectId
    beam.scoSourceImpactEffectId = nil
    if effectId ~= nil and Engine.IsValidLocalID(effectId) then
        Engine.SetParticleCanEmit(effectId, false)
        Engine.SetDestroyUponCompletion(effectId, true)
    end
end

local function StopSourceStart(beam)
    local effectId = beam.scoSourceStartEffectId
    beam.scoSourceStartEffectId = nil
    if effectId ~= nil and Engine.IsValidLocalID(effectId) then
        Engine.SetParticleCanEmit(effectId, false)
        Engine.SetDestroyUponCompletion(effectId, true)
    end
end

local function StartSourceEffect(beam)
    if not OwnsSourceEndpoint(beam) or not beam.isIntelVisionVisible then return end
    local effects = beam.muzzle.weapon.tp.effects
    local prefabId = effects and effects.onFirePrefabID
    if prefabId == nil then return end
    local result, effectId = Engine.InstantiatePrefab(prefabId,
        beam.muzzle:GetPosition(), EngineClasses.float3(1, 1, 1), beam.muzzle:GetOrientation())
    if result ~= EngineErrorCode.Success or effectId == nil or not Engine.IsValidLocalID(effectId) then return end
    beam.scoSourceStartEffectId = effectId
    Engine.SetDestroyUponCompletion(effectId, false)
    Engine.SetParticleCanEmit(effectId, true)
end

---@class ClientBeamWeaponPulse: ClientBeamWeapon A weapon beam which raycasts once and then fades out.
---@field protected lifetime number Seconds before fade-out starts.
---@field protected raycastPending boolean Whether the one-shot raycast is pending.
ClientBeamWeaponPulse = Class("ClientBeamWeaponPulse", ClientBeamWeapon)

---@param muzzle ClientMuzzle Weapon muzzle.
--- Create the pulse prefab at the muzzle's current transform before initializing its beam state.
function ClientBeamWeaponPulse:__init(muzzle)
    local _, beamID = Engine.InstantiatePrefab(
        muzzle.weapon.tp.beamPrefabID,
        muzzle:GetPosition(),
        EngineClasses.float3(1, 1, 1),
        muzzle:GetOrientation()
    )
    ClientBeamWeapon.__init(self, beamID, muzzle)

    local beamTemplate = muzzle.weapon.tp.beam
    self.lifetime = beamTemplate.renderLifetime or Constants.TickTimeStep * (muzzle.weapon.tp.beamLifetime or 1)
    self.raycastPending = false
end

---@param enabled boolean
function ClientBeamWeaponPulse:SetBeamEnabled(enabled)
    if not enabled then
        if self.muzzle.weapon.tp.scoSpecialOrbital then
            self.raycastPending = false
            ClientBeamWeapon.SetBeamEnabled(self, false)
        end
        return
    end

    self.enabled = false
    ClientBeamWeapon.SetBeamEnabled(self, true)
    self.raycastPending = true
end

function ClientBeamWeaponPulse:OnUpdateStart()
    if self.muzzle.weapon.tp.scoSpecialOrbital then
        -- Novax keeps aiming during its firing interval; it is not a single snapshot.
        if not self.enabled or _G.Time - self.enableTime >= self.lifetime then return end
    elseif not self.raycastPending then
        return
    end
    
    local collisionEvent = self:Raycast()
    self.raycastPending = false

    if self.hasImpact and collisionEvent ~= nil then
        self:OnImpactUpdated(collisionEvent)
    end
end

---@param lifetime number
---@return boolean
function ClientBeamWeaponPulse:HasFadeOutStarted(lifetime)
    if self.muzzle.weapon.tp.scoSpecialOrbital and not self.enabled then return true end
    return lifetime >= self.lifetime
end

---@param lifetime number
---@return number
function ClientBeamWeaponPulse:GetAfterlife(lifetime)
    if self.muzzle.weapon.tp.scoSpecialOrbital and not self.enabled then
        return math.max(_G.Time - self.disableTime, 0)
    end
    return math.max(lifetime - self.lifetime, 0)
end

--- Position the pulse at its impact and create the effect when visible.
---@protected
---@param origin float3 Raycast origin in world space.
---@param collisionEvent LocalRayCollisionEvent Raycast hit data.
function ClientBeamWeaponPulse:OnRaycastImpact(origin, collisionEvent)
    self:SetBeamEndpoints(origin, collisionEvent.hitPosition)
    if not self.isIntelVisionVisible then return end

    local existing = self.scoSourceImpactEffectId
    if existing ~= nil and Engine.IsValidLocalID(existing) then
        Engine.SetLocalEntityLocalPosition(existing, collisionEvent.hitPosition)
        Engine.SetLocalEntityLocalRotation(existing, ImpactEffects.GetImpactOrientation(self.lastForward))
        return
    end
    local effectId = ImpactEffects.CreateImpactEffect(
        self.projectileTemplate,
        collisionEvent.hitPosition,
        ImpactEffects.GetImpactOrientation(self.lastForward)
    )
    if OwnsSourceEndpoint(self) and effectId ~= nil then
        -- Source endpoint emitters loop until their owning pulse finishes.
        self.scoSourceImpactEffectId = effectId
        Engine.SetDestroyUponCompletion(effectId, false)
        Engine.SetParticleCanEmit(effectId, true)
    end
end

--- Extend a missed pulse to full range without repositioning it during lifecycle cleanup.
---@protected
---@param origin float3|nil Raycast origin; omitted for lifecycle cleanup.
---@param rangeMax number|nil Maximum range; required when origin is supplied.
function ClientBeamWeaponPulse:OnImpactLost(origin, rangeMax)
    StopSourceEndpoint(self)
    if not self.enabled then StopSourceStart(self) end
    if origin == nil or rangeMax == nil then return end

    self:SetBeamEndpoints(origin, math3D.add(origin, math3D.scale(self.lastForward, rangeMax)))
end

function ClientBeamWeaponPulse:OnIntelVisibilityChanged()
    local effectId = self.scoSourceImpactEffectId
    if effectId ~= nil and Engine.IsValidLocalID(effectId) then
        Engine.SetParticleCanEmit(effectId, self.isIntelVisionVisible)
    end
    local startId = self.scoSourceStartEffectId
    if startId ~= nil and Engine.IsValidLocalID(startId) then
        Engine.SetParticleCanEmit(startId, self.isIntelVisionVisible)
    elseif self.enabled and self.isIntelVisionVisible then
        StartSourceEffect(self)
    end
end

function ClientBeamWeaponPulse:OnEnabled()
    StopSourceStart(self)
    StartSourceEffect(self)
end

function ClientBeamWeaponPulse:OnDisabled()
    StopSourceStart(self)
end

function ClientBeamWeaponPulse:OnUpdatedEnd()
    local effectId = self.scoSourceStartEffectId
    if effectId ~= nil and Engine.IsValidLocalID(effectId) then
        Engine.SetLocalEntityLocalPosition(effectId, self.muzzle:GetPosition())
        Engine.SetLocalEntityLocalRotation(effectId, self.muzzle:GetOrientation())
    end
end

function ClientBeamWeaponPulse:OnFadeOutFinished()
    self:Delete()
end

return { ClientBeamWeaponPulse = ClientBeamWeaponPulse }
