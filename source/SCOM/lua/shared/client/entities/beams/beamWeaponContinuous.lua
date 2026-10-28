local ClientBeamWeapon = Import("client/entities/beams/beamWeapon.lua").ClientBeamWeapon
local ImpactEffects = Import("client/entities/beams/beamWeaponImpactEffects.lua")
local HierarchyTemplateLoader = Import("common/loading/hierarchyTemplateLoader.lua")

local TractorEffects = {
    start = "VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_start_glow.sanvfx",
    finish = "VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_end_glow.sanvfx",
    vacuum = "VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_vacuum_grab.sanvfx",
}
local TractorPrefabNames = {
    [TractorEffects.start] = "SCO.GC.TractorStart",
    [TractorEffects.finish] = "SCO.GC.TractorEnd",
    [TractorEffects.vacuum] = "SCO.GC.TractorVacuum",
}
local TractorPrefabs = _G.SCO_GalacticColossusEffectPrefabs or {}
_G.SCO_GalacticColossusEffectPrefabs = TractorPrefabs
local TractorScale = EngineClasses.float3(1, 1, 1)

local function IsTractorBeam(beam)
    local weapon = beam.muzzle and beam.muzzle.weapon
    return weapon ~= nil and weapon.unit.tpId == "ucl4004" and weapon.tp.scoTractor ~= nil
end

local function StopTractorEffect(localId)
    if localId ~= nil and Engine.IsValidLocalID(localId) then
        Engine.SetParticleCanEmit(localId, false)
        Engine.SetDestroyUponCompletion(localId, true)
    end
end

local function SpawnTractorEffect(path, position, orientation, persistent)
    local prefab = TractorPrefabs[path]
    if prefab == false then return nil end
    if prefab == nil then
        local particles = {
            EngineClasses.ParticleTemplate(TemplateHeadEntityName, path, true, true),
        }
        local template = EngineClasses.PrefabTemplate(
            TractorPrefabNames[path],
            EngineClasses.HierarchyTemplate(HierarchyTemplateLoader.GetHierarchyEntities(nil)),
            EngineClasses.GlobalTemplate(),
            EngineClasses.LocalTemplate(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, particles))
        local result
        result, prefab = Engine.CreatePrefab(template)
        if result ~= EngineErrorCode.Success or prefab == nil or prefab.Value == nil or prefab.Value == 65535 then
            TractorPrefabs[path] = false
            return nil
        end
        TractorPrefabs[path] = prefab
    end
    local result, localId = Engine.InstantiatePrefab(prefab, position, TractorScale, orientation)
    if result ~= EngineErrorCode.Success or localId == nil or not Engine.IsValidLocalID(localId) then
        StopTractorEffect(localId)
        return nil
    end
    Engine.SetParticleCanEmit(localId, true)
    Engine.SetDestroyUponCompletion(localId, not persistent)
    return localId
end

---@class ClientBeamWeaponContinuous: ClientBeamWeapon A weapon beam which raycasts while enabled.
---@field protected impactEffectCreated boolean Whether the current impact effect was created.
---@field protected impactEffectId LocalID|nil Tracked continuous impact effect.
ClientBeamWeaponContinuous = Class("ClientBeamWeaponContinuous", ClientBeamWeapon)

---@param muzzle ClientMuzzle Weapon muzzle.
function ClientBeamWeaponContinuous:__init(muzzle)
    local submeshes = {}
    for index, submeshTemplate in ipairs(muzzle.weapon.tp.beam.subMesh) do
        if submeshTemplate.model and submeshTemplate.material then
            table.insert(submeshes, muzzle.weapon.unit:GetBoneId(muzzle.boneName .. "_SubMesh" .. index))
        end
    end
    ClientBeamWeapon.__init(self, muzzle.localId, muzzle, submeshes)
    self.impactEffectCreated = false
    self.impactEffectId = nil
end

--- Update the beam geometry and start a visible continuous impact effect when needed.
---@protected
---@param origin float3 Raycast origin in world space.
---@param collisionEvent LocalRayCollisionEvent Raycast hit data.
function ClientBeamWeaponContinuous:OnRaycastImpact(origin, collisionEvent)
    self:SetBeamLength(collisionEvent.hitDistance)
    if not self.isIntelVisionVisible or self.impactEffectCreated then return end

    if IsTractorBeam(self) then
        local orientation = ImpactEffects.GetImpactOrientation(self.lastForward)
        self.impactEffectId = SpawnTractorEffect(TractorEffects.finish, collisionEvent.hitPosition, orientation, true)
        self.scoTractorVacuumEffectId = SpawnTractorEffect(TractorEffects.vacuum, collisionEvent.hitPosition, orientation, false)
    else
        self.impactEffectId = ImpactEffects.CreateImpactEffect(
            self.projectileTemplate,
            collisionEvent.hitPosition,
            ImpactEffects.GetImpactOrientation(self.lastForward)
        )
    end
    self.impactEffectCreated = true
    if self.impactEffectId ~= nil then
        Engine.SetParticleCanEmit(self.impactEffectId, true)
        Engine.SetDestroyUponCompletion(self.impactEffectId, false)
    end
end

---@param collisionEvent LocalRayCollisionEvent Current raycast hit data.
function ClientBeamWeaponContinuous:OnImpactUpdated(collisionEvent)
    if IsTractorBeam(self) and self.scoTractorVacuumEffectId ~= nil
        and Engine.IsValidLocalID(self.scoTractorVacuumEffectId)
    then
        Engine.SetLocalEntityLocalPosition(self.scoTractorVacuumEffectId, collisionEvent.hitPosition)
        Engine.SetLocalEntityLocalRotation(self.scoTractorVacuumEffectId, ImpactEffects.GetImpactOrientation(self.lastForward))
    end
    if self.impactEffectId == nil then return end

    Engine.SetLocalEntityLocalPosition(self.impactEffectId, collisionEvent.hitPosition)
    Engine.SetLocalEntityLocalRotation(self.impactEffectId, ImpactEffects.GetImpactOrientation(self.lastForward))
end

--- Restore missed-raycast geometry and stop the tracked continuous impact effect.
---@protected
---@param origin float3|nil Raycast origin; omitted for lifecycle cleanup.
---@param rangeMax number|nil Maximum range; required when origin is supplied.
function ClientBeamWeaponContinuous:OnImpactLost(origin, rangeMax)
    if origin ~= nil and rangeMax ~= nil then
        self:SetBeamLength(rangeMax)
    end

    self.impactEffectCreated = false
    if IsTractorBeam(self) then
        StopTractorEffect(self.scoTractorVacuumEffectId)
        self.scoTractorVacuumEffectId = nil
    end
    if self.impactEffectId ~= nil then
        Engine.SetParticleCanEmit(self.impactEffectId, false)
        Engine.SetDestroyUponCompletion(self.impactEffectId, true)
        self.impactEffectId = nil
    end
end

function ClientBeamWeaponContinuous:OnIntelVisibilityChanged()
    if self.impactEffectId ~= nil then
        Engine.SetParticleCanEmit(self.impactEffectId, self.isIntelVisionVisible)
    end
    if IsTractorBeam(self) then
        if self.enabled and self.isIntelVisionVisible and self.scoTractorStartEffectId == nil then
            self:OnEnabled()
        end
        for _, localId in pairs({self.scoTractorStartEffectId, self.scoTractorVacuumEffectId}) do
            if Engine.IsValidLocalID(localId) then
                Engine.SetParticleCanEmit(localId, self.isIntelVisionVisible)
            end
        end
    end
end

-- The current native manager owns weapon beams. Keep tractor emitters on that
-- lifecycle so they follow raycasts and are released with their muzzle.
function ClientBeamWeaponContinuous:OnEnabled()
    if not IsTractorBeam(self) or not self.isIntelVisionVisible then return end
    StopTractorEffect(self.scoTractorStartEffectId)
    self.scoTractorStartEffectId = SpawnTractorEffect(
        TractorEffects.start, self.muzzle:GetPosition(), self.muzzle:GetOrientation(), true)
end

function ClientBeamWeaponContinuous:OnDisabled()
    if not IsTractorBeam(self) then return end
    StopTractorEffect(self.scoTractorStartEffectId)
    self.scoTractorStartEffectId = nil
end

function ClientBeamWeaponContinuous:OnDeleted()
    if IsTractorBeam(self) then
        StopTractorEffect(self.scoTractorStartEffectId)
        self.scoTractorStartEffectId = nil
    end
    ClientBeamWeapon.OnDeleted(self)
end

function ClientBeamWeaponContinuous:OnUpdateStart()
    ClientBeamWeapon.OnUpdateStart(self)
    local localId = self.scoTractorStartEffectId
    if IsTractorBeam(self) and localId ~= nil and Engine.IsValidLocalID(localId) then
        Engine.SetLocalEntityLocalPosition(localId, self.muzzle:GetPosition())
        Engine.SetLocalEntityLocalRotation(localId, self.muzzle:GetOrientation())
    end
end

return { ClientBeamWeaponContinuous = ClientBeamWeaponContinuous }
