local CollisionLayer = Import("common/layers.lua").CollisionLayer
local IntelBitMask = Import("common/intelBitMask.lua").IntelBitMask
local Units = __Entities.Units
local Shields = __Entities.Shields

---@class ClientBeam
---@field protected submeshes LocalID[] Local IDs of the beam sub-meshes (renderer instances).
---@field protected muzzle ClientMuzzle Parent muzzle of the beam entity.
---@field protected enabled boolean Sim-side enable gate.
---@field protected pendingEnable boolean 1-frame arming gate after enable (prevents raycast/impact/visuals on the enable frame)
---@field protected projectileTemplate ProjectileTemplate Projectile template used for impact visuals.
---@field protected length number Current beam length (world units).
---@field protected fadeInTime number Fade-in duration in seconds (0 = no fade).
---@field protected fadeOutTime number Fade-out duration in seconds (0 = no fade).
---@field protected isRendering boolean Render lifetime tracking gate.
---@field protected enableTime number Timestamp when the beam was enabled (seconds).
---@field protected disableTime number Timestamp when the beam was disabled (seconds).
---@field protected hasImpact boolean Cached sim result: whether we have an impact this tick.
---@field protected impactPosition float3 Cached sim result: impact position.
---@field protected lastForward float3 Cached sim result: last muzzle forward.
---@field protected impactEffectCreated boolean Tracks whether we have created an impact effect for the current impact.
---@field protected impactEffectId LocalID|nil Tracked impact effect localID (or nil).
---@field protected isIntelVisionVisible boolean If the beam is visible to the player on vision.
---@field protected visibilityMask IntelBitMask The armies which can see the beam.
ClientBeam = Class("ClientBeam")

---Construct a beam instance for a muzzle + its beam submesh renderers.
---@param submeshes LocalID[]|nil Local IDs of the beam sub-meshes.
---@param muzzle ClientMuzzle Parent muzzle of the beam entity.
---@protected
function ClientBeam:__init(submeshes, muzzle)
    self.submeshes = submeshes or {}
    self.muzzle = muzzle

    -- Sim-side enable gate
    self.enabled = false
    self.pendingEnable = false

    -- Impact effect data comes from projectile template
    local projectileTemplateId = self.muzzle.weapon.tp.projectileTemplate
    self.projectileTemplate = GetTemplate(projectileTemplateId, "Projectiles")

    -- Current beam length (world units)
    self.length = 0

    -- Fade settings (seconds, or 0 for no fade)
    local beamTemplate = self.muzzle.weapon.tp.beam
    self.fadeInTime  = beamTemplate and beamTemplate.fadeInTime  or 0
    self.fadeOutTime = beamTemplate and beamTemplate.fadeOutTime or 0

    -- Render lifetime tracking
    self.isRendering = false
    self.enableTime = _G.Time
    self.disableTime = 999999

    -- Cached sim results used for render frames
    self.hasImpact = false
    self.impactPosition = EngineClasses.float3()
    self.lastForward = EngineClasses.float3(0, 0, 1)

    -- Impact effect instance tracking
    self.impactEffectCreated = false
    self.impactEffectId = nil

    self.isIntelVisionVisible = false
    self.visibilityMask = IntelBitMask.FromArmyId(self.muzzle.weapon.unit.armyId)
    self:RecalculateIntel()

    self:ResetVisuals()
end


---@public Update the beam's intel visibility mask. Will show or hide the beam if the intel state changed to the player.
---@param visionDetectionMask IntelBitMask
function ClientBeam:UpdateIntelVisionDetection(visionDetectionMask)
    self.visibilityMask = visionDetectionMask
    self:RecalculateIntel()
end

function ClientBeam:RecalculateIntel()

    local focusArmyID = GetFocusArmy()

    if focusArmyID == nil then
        return
    end

    -- If focusArmyID == -1 then we are allowed to see all armies.
    if focusArmyID == -1 then
        self.isIntelVisionVisible = true
    else
        self.isIntelVisionVisible = self.visibilityMask:IsVisible(Armies[focusArmyID].intelMask)
    end

    if self.impactEffectId ~= nil then
        Engine.SetParticleCanEmit(self.impactEffectId, self.isIntelVisionVisible)
    end
end

---@public Enable or disable the beam (enable is a trigger; disable stops sim + fades out visuals).
---@param enabled boolean
function ClientBeam:SetBeamEnabled(enabled)
    if enabled then
        -- If we get re-enabled while still active, don't orphan an existing effect.
        if self.impactEffectId ~= nil then
            self:CleanupImpactEffect()
        end

        self.enabled = true

        self.enableTime = _G.Time
        self.disableTime = 999999
        self.isRendering = true

        self.length = 0
        self.hasImpact = false
        self.impactEffectCreated = false
        self.impactEffectId = nil

        self.pendingEnable = true
        self:SetRenderersEnabled(false)
        return
    end

    if not self.enabled then return end

    self.enabled = false
    self.disableTime = _G.Time

    self:CleanupImpactEffect()
    self:ResetVisuals()
end

---@public Simulation tick update: raycast + subclass sim hook.
function ClientBeam:SimUpdate()
    if not self.enabled then return end

    if self.pendingEnable then
        self.pendingEnable = false
        return
    end

    self:Raycast()
    self:OnEnabledSimTick()
end

---@public Render-frame update: update impact transform + instance data + fade-out shutdown.
function ClientBeam:RenderUpdate()
    if not self.isRendering then return end

    if self.pendingEnable then
        return
    end

    self:SetRenderersEnabled(self.isIntelVisionVisible)

    if self.hasImpact then
        self:RenderImpactEffect()
    end

    local lifetime = _G.Time - self.enableTime
    local afterlife = self:GetAfterlife(lifetime)

    self:UpdateInstanceData(lifetime, afterlife)

    if self.fadeOutTime <= 0 or afterlife >= self.fadeOutTime then
        self.isRendering = false
        self:SetRenderersEnabled(false)
    end
end

---@protected Subclass hook called once per sim tick while enabled.
function ClientBeam:OnEnabledSimTick()
    -- optional in subclass
end

---@protected Subclass hook: called once when the first impact is detected (create impact effects).
---@param impactPosition any Impact position (EngineClasses.float3).
---@param orientation any Impact orientation (EngineClasses.quaternion).
function ClientBeam:OnFirstImpactEffect(impactPosition, orientation)
    -- optional in subclass
end

---@public Subclass hook: computes how long we have been "disabled" for fade-out purposes.
---@param lifetime number Seconds since enableTime.
---@return number afterlife Seconds since disableTime (or equivalent).
function ClientBeam:GetAfterlife(lifetime)
    -- optional in subclass
    return 0
end

---@protected Enable/disable all submesh renderers.
---@param enabled boolean
function ClientBeam:SetRenderersEnabled(enabled)
    for _, id in ipairs(self.submeshes) do
        Engine.SetRendererEnabled(id, enabled)
    end
end

---@protected Build renderer instance data0 payload (length, lifetime, fade-in alpha, fade-out alpha).
---@param length number
---@param lifetime number
---@param fadeInAlpha number
---@param fadeOutAlpha number
---@return any instanceData0 EngineClasses.float4
function ClientBeam:BuildInstanceData0(length, lifetime, fadeInAlpha, fadeOutAlpha)
    local d = EngineClasses.float4()
    d.x = length
    d.y = lifetime
    d.z = fadeInAlpha
    d.w = fadeOutAlpha
    return d
end

---@protected Reset beam visuals to a fully "off" state (instance data zeroed; renderers disabled).
function ClientBeam:ResetVisuals()
    self.length = 0
    self.hasImpact = false

    local instanceData0 = self:BuildInstanceData0(0, 0, 0, 0)

    for _, id in ipairs(self.submeshes) do
        Engine.SetRendererInstanceData0(id, instanceData0)
        Engine.SetRendererEnabled(id, false)
    end
end

---@protected Update per-renderer instance data for the current frame.
---@param lifetime number Seconds since enableTime.
---@param afterlife number Seconds since disableTime (or equivalent).
function ClientBeam:UpdateInstanceData(lifetime, afterlife)
    local fadeInAlpha = (self.fadeInTime > 0) and math.clamp(lifetime / self.fadeInTime, 0, 1) or 1
    local fadeOutAlpha = (self.fadeOutTime > 0) and (1.0 - math.clamp(afterlife / self.fadeOutTime, 0, 1)) or 1

    local instanceData0 = self:BuildInstanceData0(self.length, lifetime, fadeInAlpha, fadeOutAlpha)

    for _, id in ipairs(self.submeshes) do
        Engine.SetRendererInstanceData0(id, instanceData0)
    end
end

---@protected Sim tick: raycast forward, cache length/impact for render frames, and ensure impact effect exists.
function ClientBeam:Raycast()
    local weaponTemplate = self.muzzle.weapon.tp
    local rangeMax = weaponTemplate.scoSpecialOrbital and weaponTemplate.scoSpecialOrbital.maximumLength or weaponTemplate.rangeMax
    local army = self.muzzle.weapon.unit.army

    local _, origin  = Engine.GetLocalEntityWorldPosition(self.muzzle.localId)
    local _, forward = Engine.GetLocalEntityForwardDirection(self.muzzle.localId)

    self.lastForward = forward
    self.length = rangeMax
    self.hasImpact = false

    local collisionEvents = Engine.RayCast(
        CollisionWorld.Collision,
        origin,
        forward,
        rangeMax,
        CollisionLayer.Shields + CollisionLayer.Units
    )

    local impactPosition = EngineClasses.float3()

    for _, collisionEvent in ipairs(collisionEvents) do
        if collisionEvent.colliderLocalID.index == 0 then
            self.length = collisionEvent.hitDistance
            impactPosition = collisionEvent.hitPosition
            self.hasImpact = true
            break
        end

        if Engine.IsValidLocalID(collisionEvent.colliderLocalID) then
            local _, globalID = Engine.GetLocalEntityGlobalID(collisionEvent.colliderLocalID)

            local otherUnit = Units[globalID.index]
            if otherUnit and army:IsEnemy(otherUnit.army) then
                self.length = collisionEvent.hitDistance
                impactPosition = collisionEvent.hitPosition
                self.hasImpact = true
                break
            end

            local shield = Shields[globalID.index]
            if shield and shield.enabled and army:IsEnemy(shield.army) then
                self.length = collisionEvent.hitDistance
                impactPosition = collisionEvent.hitPosition
                self.hasImpact = true
                break
            end
        end
    end

    if self.hasImpact then
        self.impactPosition = impactPosition
        self:SimEnsureImpactEffectExists()
    end
end

---@protected Sim tick: create an impact effect once (subclass decides what to spawn / what to store).
function ClientBeam:SimEnsureImpactEffectExists()

    if not self.isIntelVisionVisible then return end

    local orientation = self:GetImpactOrientation(self.lastForward)

    if self.impactEffectCreated and self.impactEffectId ~= nil then
        return
    end

    if not self.impactEffectCreated then
        self:OnFirstImpactEffect(self.impactPosition, orientation)
        self.impactEffectCreated = true
    end
end

---@protected Spawn an impact effect from projectile visuals (returns spawned localID or nil).
---@param position any Spawn position (EngineClasses.float3).
---@param orientation any Spawn orientation (EngineClasses.quaternion).
---@return any|nil localID Spawned localID (or nil if none spawned).
function ClientBeam:CreateImpactEffects(position, orientation)
    local data = self.projectileTemplate.visuals and self.projectileTemplate.visuals.onImpactEffects
    if data then
        local effectData = table.random(data)
        local effects = table.random(effectData.effects)
        local particlePrefabID = effects.particlePrefabID
        if particlePrefabID then
            local _, localID = Engine.InstantiatePrefab(
                particlePrefabID,
                position,
                EngineClasses.float3(1, 1, 1),
                orientation
            )
            return localID
        end
    end
    return nil
end

---@protected Stop and dispose a tracked impact effect instance (if present).
function ClientBeam:CleanupImpactEffect()
    self.impactEffectCreated = false
    if self.impactEffectId ~= nil then
        Engine.SetParticleCanEmit(self.impactEffectId, false)
        Engine.SetDestroyUponCompletion(self.impactEffectId, true)
        self.impactEffectId = nil
    end
end

---@protected Render frame: keep impact effect transform in sync (if effect is tracked).
function ClientBeam:RenderImpactEffect()
    if not (self.impactEffectCreated and self.impactEffectId ~= nil) then
        return
    end

    local orientation = self:GetImpactOrientation(self.lastForward)
    Engine.SetLocalEntityLocalPosition(self.impactEffectId, self.impactPosition)
    Engine.SetLocalEntityLocalRotation(self.impactEffectId, orientation)
end

---@protected Build an orientation that faces opposite the beam forward direction.
---@param forward float3 Beam forward direction. This sohuld be normalized.
---@return any orientation quaternion
function ClientBeam:GetImpactOrientation(forward)
    local orientation = EngineClasses.quaternion()
    Engine.QuaternionLookRotation(
        EngineClasses.float3(-forward.x, -forward.y, -forward.z),
        EngineClasses.float3(0, 1, 0),
        orientation
    )
    return orientation
end


-- Guard Cybran Monkeylord Cache Patcher 1.4.0
local scoMonkeylordStockClientBeamInit = ClientBeam.__init
local scoMonkeylordStockClientBeamSetEnabled = ClientBeam.SetBeamEnabled
local scoMonkeylordStockClientBeamSimUpdate = ClientBeam.SimUpdate
local scoMonkeylordStockClientBeamRenderUpdate = ClientBeam.RenderUpdate

function ClientBeam:__init(submeshes, muzzle)
    scoMonkeylordStockClientBeamInit(self, submeshes, muzzle)
    local config = self.muzzle.weapon.tp.scoMonkeylordMicrowave
    self.scoMonkeylordSliderConfig = config
    if config == nil then
        return
    end

    local sliderId = self.muzzle.weapon.unit:GetBoneId(config.sliderBone)
    if sliderId == nil or not Engine.IsValidLocalID(sliderId) then
        error("Monkeylord microwave slider bone is missing")
    end
    local base = EngineClasses.float3()
    local result = Engine.GetLocalEntityLocalPosition(sliderId, base)
    if result ~= EngineErrorCode.Success then
        error("Monkeylord microwave slider bind position is unavailable")
    end
    self.scoMonkeylordSliderId = sliderId
    self.scoMonkeylordSliderBase = EngineClasses.float3(base.x, base.y, base.z)
    self.scoMonkeylordSliderOffset = 0
    self.scoMonkeylordSliderTarget = 0
    self.scoMonkeylordSliderLastTime = _G.Time
end

function ClientBeam:SetBeamEnabled(enabled)
    scoMonkeylordStockClientBeamSetEnabled(self, enabled)
    local config = self.scoMonkeylordSliderConfig
    if config == nil then
        return
    end
    self.scoMonkeylordSliderTarget = enabled and config.sliderGoal or 0
    self.scoMonkeylordSliderLastTime = _G.Time
end

function ClientBeam:SimUpdate()
    if self.scoMonkeylordSliderConfig ~= nil
        and self.enabled and self.pendingEnable
    then
        -- The existing muzzle is ready; let its first sim tick raycast and render.
        self.pendingEnable = false
    end
    return scoMonkeylordStockClientBeamSimUpdate(self)
end

local function scoMonkeylordMoveToward(current, target, distance)
    local delta = target - current
    if math.abs(delta) <= distance then
        return target
    end
    return current + (delta < 0 and -distance or distance)
end

function ClientBeam:RenderUpdate()
    scoMonkeylordStockClientBeamRenderUpdate(self)
    local config = self.scoMonkeylordSliderConfig
    if config == nil then
        return
    end

    local now = _G.Time
    local elapsed = math.max(now - self.scoMonkeylordSliderLastTime, 0)
    self.scoMonkeylordSliderLastTime = now
    local speed = self.enabled
        and config.sliderFireSpeed
        or config.sliderReturnSpeed
    self.scoMonkeylordSliderOffset = scoMonkeylordMoveToward(
        self.scoMonkeylordSliderOffset,
        self.scoMonkeylordSliderTarget,
        speed * elapsed)
    local base = self.scoMonkeylordSliderBase
    local result = Engine.SetLocalEntityLocalPosition(
        self.scoMonkeylordSliderId,
        EngineClasses.float3(
            base.x,
            base.y,
            base.z + self.scoMonkeylordSliderOffset))
    if result ~= EngineErrorCode.Success then
        error("Monkeylord microwave slider update failed")
    end
end
-- Source beam endpoints have source-owned infinite emitters. Track their native
-- instances through the beam lifetime, including pulse beams, then release them.
local function SCOM_SourceEndpointBeam(beam)
    local tp = beam.muzzle and beam.muzzle.weapon and beam.muzzle.weapon.tp
    local source = tp and (tp.scoFaBeam or tp.scoFaContinuousBeam)
    return source and source.endpointEffects
        and type(tp.projectileTemplate) == "string"
        and string.sub(tp.projectileTemplate, 1, 3) == "pbf"
end

local function SCOM_StopSourceBeamStart(beam)
    if beam.scomStartEffectId then
        Engine.SetParticleCanEmit(beam.scomStartEffectId, false)
        Engine.SetDestroyUponCompletion(beam.scomStartEffectId, true)
        beam.scomStartEffectId = nil
    end
end

local SCOM_BeamCleanup = ClientBeam.CleanupImpactEffect
function ClientBeam:CleanupImpactEffect()
    if SCOM_SourceEndpointBeam(self) then SCOM_StopSourceBeamStart(self) end
    return SCOM_BeamCleanup(self)
end

local SCOM_BeamImpact = ClientBeam.CreateImpactEffects
function ClientBeam:CreateImpactEffects(position, orientation)
    local id = SCOM_BeamImpact(self, position, orientation)
    if SCOM_SourceEndpointBeam(self) and id ~= nil then
        -- PulseBeam normally leaves impact effects untracked. Source loops
        -- instead need the same cleanup ownership as continuous beam impacts.
        self.impactEffectId = id
        Engine.SetDestroyUponCompletion(id, false)
        Engine.SetParticleCanEmit(id, self.isIntelVisionVisible)
    end
    return id
end

local SCOM_BeamEnable = ClientBeam.SetBeamEnabled
function ClientBeam:SetBeamEnabled(enabled)
    local owned = SCOM_SourceEndpointBeam(self)
    if owned then SCOM_StopSourceBeamStart(self) end
    local result = SCOM_BeamEnable(self, enabled)
    if owned and enabled then
        local effects = self.muzzle.weapon.tp.effects
        local prefab = effects and effects.onFirePrefabID
        if prefab then
            local _, id = Engine.InstantiatePrefab(prefab, self.muzzle:GetPosition(),
                EngineClasses.float3(1, 1, 1), self.muzzle:GetOrientation())
            self.scomStartEffectId = id
            Engine.SetDestroyUponCompletion(id, false)
            Engine.SetParticleCanEmit(id, self.isIntelVisionVisible)
        end
    end
    return result
end

local SCOM_BeamRender = ClientBeam.RenderUpdate
function ClientBeam:RenderUpdate()
    local result = SCOM_BeamRender(self)
    if SCOM_SourceEndpointBeam(self) then
        if not self.isRendering then
            self:CleanupImpactEffect()
        elseif self.scomStartEffectId then
            local id = self.scomStartEffectId
            Engine.SetLocalEntityLocalPosition(id, self.muzzle:GetPosition())
            Engine.SetLocalEntityLocalRotation(id, self.muzzle:GetOrientation())
            Engine.SetParticleCanEmit(id, self.isIntelVisionVisible)
        end
    end
    return result
end

return { ClientBeam = ClientBeam }