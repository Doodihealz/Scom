local ClientBeam = Import("client/entities/beam.lua").ClientBeam

ClientContinuousBeam = Class("ClientContinuousBeam", ClientBeam)

function ClientContinuousBeam:__init(submeshes, muzzle)
    ClientBeam.__init(self, submeshes, muzzle)
end

function ClientContinuousBeam:OnFirstImpactEffect(impactPosition, orientation)
    self.impactEffectId = self:CreateImpactEffects(impactPosition, orientation)
    if self.impactEffectId ~= nil then
        Engine.SetParticleCanEmit(self.impactEffectId, true)
        Engine.SetDestroyUponCompletion(self.impactEffectId, false)
    end
end

function ClientContinuousBeam:OnDisabled()
    if self.impactEffectId ~= nil then
        Engine.SetParticleCanEmit(self.impactEffectId, false)
    end
end

function ClientContinuousBeam:GetAfterlife(lifetime)
    return _G.Time - self.disableTime
end


-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0
-- SCO_GalacticColossusTractorClientBeam
-- The stock continuous-beam lifecycle remains authoritative for
-- shaft enable/fade/raycast. This extension is gated only by the
-- ucl4004 scoTractor template contract and owns FA's persistent
-- start/end glows plus its finite vacuum-grab emitter.
local scoTractorHierarchyTemplateLoader =
    Import("common/loading/hierarchyTemplateLoader.lua")
local scoTractorEffectPrefabs =
    _G.SCO_GalacticColossusEffectPrefabs or {}
_G.SCO_GalacticColossusEffectPrefabs = scoTractorEffectPrefabs
local scoTractorUnitScale = EngineClasses.float3(1, 1, 1)
local scoTractorStartEffect =
    "VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_start_glow.sanvfx"
local scoTractorEndEffect =
    "VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_end_glow.sanvfx"
local scoTractorVacuumEffect =
    "VFX/AeonProjectiles/GalacticColossus/galactic_colossus_tractor_vacuum_grab.sanvfx"
local scoTractorPrefabNames = {
    [scoTractorStartEffect] = "SCO.GC.TractorStart",
    [scoTractorEndEffect] = "SCO.GC.TractorEnd",
    [scoTractorVacuumEffect] = "SCO.GC.TractorVacuum",
}

local scoTractorStockSetBeamEnabled = ClientBeam.SetBeamEnabled
local scoTractorStockRenderUpdate = ClientBeam.RenderUpdate
local scoTractorStockRenderImpactEffect = ClientBeam.RenderImpactEffect
local scoTractorStockCleanupImpactEffect = ClientBeam.CleanupImpactEffect
local scoTractorStockOnFirstImpactEffect =
    ClientContinuousBeam.OnFirstImpactEffect

local function scoTractorIsBeam(beam)
    local weapon = beam.muzzle and beam.muzzle.weapon
    return weapon ~= nil
        and weapon.tp ~= nil
        and weapon.tp.scoTractor ~= nil
end

local function scoTractorGetPrefab(path)
    local prefab = scoTractorEffectPrefabs[path]
    if prefab == false then
        return nil
    end
    if prefab ~= nil then
        return prefab
    end

    local prefabName = scoTractorPrefabNames[path]
    if prefabName == nil then
        scoTractorEffectPrefabs[path] = false
        return nil
    end
    local particleTemplates = {
        EngineClasses.ParticleTemplate(
            TemplateHeadEntityName,
            path,
            true,
            true)
    }
    local prefabTemplate = EngineClasses.PrefabTemplate(
        prefabName,
        EngineClasses.HierarchyTemplate(
            scoTractorHierarchyTemplateLoader.GetHierarchyEntities(nil)),
        EngineClasses.GlobalTemplate(),
        EngineClasses.LocalTemplate(
            nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil,
            particleTemplates))
    local result, createdPrefab = Engine.CreatePrefab(prefabTemplate)
    if result ~= EngineErrorCode.Success
        or createdPrefab == nil
        or createdPrefab.Value == nil
        or createdPrefab.Value == 65535
    then
        scoTractorEffectPrefabs[path] = false
        return nil
    end
    scoTractorEffectPrefabs[path] = createdPrefab
    return createdPrefab
end

local function scoTractorStopEffect(localId)
    if localId ~= nil and Engine.IsValidLocalID(localId) then
        Engine.SetParticleCanEmit(localId, false)
        Engine.SetDestroyUponCompletion(localId, true)
    end
end

local function scoTractorSpawnEffect(
    path,
    position,
    orientation,
    persistent)
    local prefab = scoTractorGetPrefab(path)
    if prefab == nil then
        return nil
    end
    local result, localId = Engine.InstantiatePrefab(
        prefab,
        position,
        scoTractorUnitScale,
        orientation)
    if result ~= EngineErrorCode.Success
        or localId == nil
        or not Engine.IsValidLocalID(localId)
    then
        scoTractorStopEffect(localId)
        return nil
    end
    Engine.SetParticleCanEmit(localId, true)
    Engine.SetDestroyUponCompletion(localId, not persistent)
    return localId
end

function ClientContinuousBeam:CleanupImpactEffect()
    if scoTractorIsBeam(self) then
        scoTractorStopEffect(self.scoTractorStartEffectId)
        scoTractorStopEffect(self.scoTractorVacuumEffectId)
        self.scoTractorStartEffectId = nil
        self.scoTractorVacuumEffectId = nil
    end
    return scoTractorStockCleanupImpactEffect(self)
end

function ClientContinuousBeam:SetBeamEnabled(enabled)
    if not scoTractorIsBeam(self) then
        return scoTractorStockSetBeamEnabled(self, enabled)
    end
    if enabled then
        -- A re-enable can arrive before the previous afterlife
        -- finishes. Stop every owned emitter before replacing it.
        self:CleanupImpactEffect()
    end
    scoTractorStockSetBeamEnabled(self, enabled)
    if not enabled then
        return
    end
    self.scoTractorStartEffectId = scoTractorSpawnEffect(
        scoTractorStartEffect,
        self.muzzle:GetPosition(),
        self.muzzle:GetOrientation(),
        true)
end

function ClientContinuousBeam:OnFirstImpactEffect(
    impactPosition,
    orientation)
    if not scoTractorIsBeam(self) then
        return scoTractorStockOnFirstImpactEffect(
            self,
            impactPosition,
            orientation)
    end
    self.impactEffectId = scoTractorSpawnEffect(
        scoTractorEndEffect,
        impactPosition,
        orientation,
        true)
    self.scoTractorVacuumEffectId = scoTractorSpawnEffect(
        scoTractorVacuumEffect,
        impactPosition,
        orientation,
        false)
end

function ClientContinuousBeam:RenderImpactEffect()
    scoTractorStockRenderImpactEffect(self)
    if scoTractorIsBeam(self)
        and self.scoTractorVacuumEffectId ~= nil
        and Engine.IsValidLocalID(self.scoTractorVacuumEffectId)
    then
        local orientation = self:GetImpactOrientation(self.lastForward)
        Engine.SetLocalEntityLocalPosition(
            self.scoTractorVacuumEffectId,
            self.impactPosition)
        Engine.SetLocalEntityLocalRotation(
            self.scoTractorVacuumEffectId,
            orientation)
    end
end

function ClientContinuousBeam:RenderUpdate()
    if scoTractorIsBeam(self)
        and self.scoTractorStartEffectId ~= nil
        and Engine.IsValidLocalID(self.scoTractorStartEffectId)
    then
        Engine.SetLocalEntityLocalPosition(
            self.scoTractorStartEffectId,
            self.muzzle:GetPosition())
        Engine.SetLocalEntityLocalRotation(
            self.scoTractorStartEffectId,
            self.muzzle:GetOrientation())
    end
    return scoTractorStockRenderUpdate(self)
end

return { ClientContinuousBeam = ClientContinuousBeam }