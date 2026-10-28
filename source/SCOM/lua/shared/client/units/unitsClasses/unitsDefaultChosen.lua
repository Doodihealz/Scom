--- This file contains default Chosen units classes.

-- Default Chosen units classes definitions
local unitsDefault = Import("client/units/unitsClasses/unitsDefault.lua")
Structure = unitsDefault.ClientStructure
TechCentre = unitsDefault.ClientTechCentre
NavalStructure = unitsDefault.ClientNavalStructure
NavalTechCentre = unitsDefault.ClientNavalTechCentre
EngineeringStation = unitsDefault.ClientEngineeringStation
Storage = unitsDefault.ClientStorage
AirFactory = unitsDefault.ClientAirFactory
LandFactory = unitsDefault.ClientLandFactory
NavalFactory = unitsDefault.ClientNavalFactory
AlloyExtractor = unitsDefault.ClientAlloyExtractor
EnergyGenerator = unitsDefault.ClientEnergyGenerator
MobileUnit = unitsDefault.ClientMobileUnit
AirUnit = unitsDefault.ClientAirUnit
LandUnit = unitsDefault.ClientLandUnit
NavalUnit = unitsDefault.ClientNavalUnit
Engineer = unitsDefault.ClientEngineer
Submarine = unitsDefault.ClientSubmarineUnit
Commander = unitsDefault.ClientCommander



-------------------------
-- Chosen Structure class
-------------------------
ClientChosenStructure = Class("ChosenStructure", Structure)



-------------------------------
-- Chosen Naval Structure class
-------------------------------
ClientChosenNavalStructure = Class("ChosenNavalStructure", NavalStructure)



-------------------------
-- Chosen Structure class
-------------------------
ClientChosenTechCentre = Class("ChosenTechCentre", TechCentre)



--------------------------------
-- Chosen Naval TechCentre class
--------------------------------
ClientChosenNavalTechCentre = Class("ChosenNavalTechCentre", NavalTechCentre)



-----------------------------------
-- Chosen Engineering Station class
-----------------------------------
ClientChosenEngineeringStation = Class("ChosenEngineeringStation", EngineeringStation)



-----------------------
-- Chosen Storage class
-----------------------
ClientChosenStorage = Class("Storage", Storage)



---------------------------
-- Chosen Air Factory class
---------------------------
ClientChosenAirFactory = Class("ChosenAirFactory", AirFactory)



----------------------------
-- Chosen Land Factory class
----------------------------
ClientChosenLandFactory = Class("ChosenLandFactory", LandFactory)



-----------------------------
-- Chosen Naval Factory class
-----------------------------
ClientChosenNavalFactory = Class("ChosenNavalFactory", NavalFactory)



------------------------
-- Chosen Alloy Extractor
------------------------
ClientChosenAlloyExtractor = Class("ChosenAlloyExtractor", AlloyExtractor)



-------------------------
-- Chosen Energy Generator
-------------------------
ClientChosenEnergyGenerator = Class("ChosenEnergyGenerator", EnergyGenerator)



------------------------
-- Chosen Air Unit class
------------------------
ClientChosenAirUnit = Class("ChosenAirUnit", AirUnit)



-------------------------
-- Chosen Land Unit class
-------------------------
ClientChosenLandUnit = Class("ChosenLandUnit", LandUnit)



--------------------------
-- Chosen Naval Unit class
--------------------------
ClientChosenNavalUnit = Class("ChosenNavalUnit", NavalUnit)



--------------------------
-- Chosen Submarine class
--------------------------
ClientChosenSubmarine = Class("ChosenSubmarine", Submarine)



------------------------
-- Chosen Engineer class
------------------------
ClientChosenEngineer = Class("ChosenEngineer", Engineer)



-------------------------
-- Chosen Commander class
-------------------------
ClientChosenCommander = Class("ChosenCommander", Commander)


-- Supreme Commander Overhaul one-for-one Aeon Chosen replacement 2.2.0
-- The stock Chosen module exports realm-prefixed classes. Keep the
-- established short names local to this generated appendix so every
-- Aeon port and its later lifecycle delegates resolve the Client class.
local ChosenStructure = ClientChosenStructure
local ChosenEngineeringStation = ClientChosenEngineeringStation
local ChosenStorage = ClientChosenStorage
local ChosenAirFactory = ClientChosenAirFactory
local ChosenLandFactory = ClientChosenLandFactory
local ChosenNavalFactory = ClientChosenNavalFactory
local ChosenAlloyExtractor = ClientChosenAlloyExtractor
local ChosenEnergyGenerator = ClientChosenEnergyGenerator
local ChosenAirUnit = ClientChosenAirUnit
local ChosenLandUnit = ClientChosenLandUnit
local ChosenNavalUnit = ClientChosenNavalUnit
local ChosenEngineer = ClientChosenEngineer

ClientAeonPortLandUnit = Class("AeonPortLandUnit", ChosenLandUnit)
ClientAeonPortAirUnit = Class("AeonPortAirUnit", ChosenAirUnit)
ClientAeonPortNavalUnit = Class("AeonPortNavalUnit", ChosenNavalUnit)
ClientAeonPortEngineer = Class("AeonPortEngineer", ChosenEngineer)
ClientAeonPortStructure = Class("AeonPortStructure", ChosenStructure)
ClientAeonPortStorage = Class("AeonPortStorage", ChosenStorage)
ClientAeonPortAlloyExtractor = Class("AeonPortAlloyExtractor", ChosenAlloyExtractor)
ClientAeonPortEnergyGenerator = Class("AeonPortEnergyGenerator", ChosenEnergyGenerator)
ClientAeonPortEngineeringStation = Class("AeonPortEngineeringStation", ChosenEngineeringStation)
ClientAeonPortLandFactory = Class("AeonPortLandFactory", ChosenLandFactory)
ClientAeonPortAirFactory = Class("AeonPortAirFactory", ChosenAirFactory)
ClientAeonPortNavalFactory = Class("AeonPortNavalFactory", ChosenNavalFactory)

local AeonPortLandUnit = ClientAeonPortLandUnit
local AeonPortAirUnit = ClientAeonPortAirUnit
local AeonPortNavalUnit = ClientAeonPortNavalUnit
local AeonPortEngineer = ClientAeonPortEngineer
local AeonPortStructure = ClientAeonPortStructure
local AeonPortStorage = ClientAeonPortStorage
local AeonPortAlloyExtractor = ClientAeonPortAlloyExtractor
local AeonPortEnergyGenerator = ClientAeonPortEnergyGenerator
local AeonPortEngineeringStation = ClientAeonPortEngineeringStation
local AeonPortLandFactory = ClientAeonPortLandFactory
local AeonPortAirFactory = ClientAeonPortAirFactory
local AeonPortNavalFactory = ClientAeonPortNavalFactory

-- The uc* target IDs select Chosen tarmac prefabs in the stock
-- Structure implementation. No owned Aeon decal is packaged here,
-- so suppress that incorrect faction art instead of stretching it.
function AeonPortLandFactory:CreateTarmac()
end

function AeonPortAirFactory:CreateTarmac()
end

function AeonPortNavalFactory:CreateTarmac()
end

-- Sanctuary keeps both full factory models at the same position
-- throughout an upgrade. Match the source behavior by keeping the
-- animated source factory visible and hiding its replacement target
-- until the upgrade completes.
local function scoHideAeonFactoryUpgradeTarget(factoryClass)
    local stockOnStartUpgrade = factoryClass.OnStartUpgrade
    local stockOnEndUpgrade = factoryClass.OnEndUpgrade
    local stockOnEndUpgrading = factoryClass.OnEndUpgrading
    local stockOnIntelVision = factoryClass.OnIntelVision

    factoryClass.OnStartUpgrade = function(self, upgrader)
        stockOnStartUpgrade(self, upgrader)
        self.scoUpgradeTargetHidden = true
        Engine.SetRendererEnabled(self.localId, false)
        if self.tarmac then
            self.tarmac:SetEnabled(false)
        end
    end

    factoryClass.OnEndUpgrade = function(self, upgrader)
        local completed =
            self:IsCompleted() and upgrader and not upgrader.dead
        stockOnEndUpgrade(self, upgrader)
        if not completed then
            return
        end

        self.scoUpgradeTargetHidden = false
        self:RecalculateIntel(true)
    end

    factoryClass.OnEndUpgrading = function(self, upgrade)
        stockOnEndUpgrading(self, upgrade)
        if upgrade and upgrade:IsCompleted() then
            Engine.SetRendererEnabled(self.localId, false)
            if self.tarmac then
                self.tarmac:SetEnabled(false)
            end
        end
    end

    factoryClass.OnIntelVision = function(self)
        stockOnIntelVision(self)
        if self.scoUpgradeTargetHidden then
            Engine.SetRendererEnabled(self.localId, false)
            if self.tarmac then
                self.tarmac:SetEnabled(false)
            end
        end
    end
end

scoHideAeonFactoryUpgradeTarget(AeonPortLandFactory)
scoHideAeonFactoryUpgradeTarget(AeonPortAirFactory)
scoHideAeonFactoryUpgradeTarget(AeonPortNavalFactory)

local scoCzarVFXTemplateLoader =
    Import("common/loading/vfxTemplateLoader.lua")
local scoCzarImpactEffectPath =
    "VFX/SupremeCommanderOverhaul/Czar/Impact/czar_quantum_impact.sanvfx"
local scoCzarMuzzleEffectPath =
    "VFX/SupremeCommanderOverhaul/Czar/Muzzle/czar_quantum_muzzle.sanvfx"
local scoCzarEffectPrefabs = {}

local function scoCzarGetEffectPrefab(path)
    if scoCzarEffectPrefabs[path] == nil then
        Engine.LoadEffect(path)
        scoCzarEffectPrefabs[path] =
            scoCzarVFXTemplateLoader.GetOrCreateVFXPrefab(path)
    end
    return scoCzarEffectPrefabs[path]
end
local scoCzarScale = EngineClasses.float3(1, 1, 1)
local scoCzarUp = EngineClasses.float3(0, 1, 0)
local scoCzarOrientationUp = EngineClasses.float3(0, 0, 1)
local scoCzarImpactRotation = EngineClasses.quaternion()
Engine.QuaternionLookRotation(
    scoCzarUp,
    scoCzarOrientationUp,
    scoCzarImpactRotation)

local function scoCzarTerrainImpact(centerBone)
    local _, origin = Engine.GetLocalEntityWorldPosition(centerBone)
    local _, terrainHeight = Engine.SampleTerrainHeight(origin)
    local impactY = math.max(
        origin.y - 50,
        terrainHeight)
    impactY = math.min(origin.y, impactY)
    local impact = EngineClasses.float3(
        origin.x,
        impactY,
        origin.z)
    return impact, math.max(0, origin.y - impactY)
end

local function scoCzarStopEffect(localId)
    if localId and Engine.IsValidLocalID(localId) then
        Engine.SetParticleCanEmit(localId, false)
        Engine.SetDestroyUponCompletion(localId, true)
    end
end

local function scoCzarSetLocalVolumeColliderEnabled(
    globalId,
    enabled)
    local localId = EngineClasses.LocalID()
    local errorCode = Engine.GetGlobalEntityPairedLocalID(
        globalId,
        localId)
    if errorCode == EngineErrorCode.Success
        and Engine.IsValidLocalID(localId)
    then
        Engine.SetVolumeColliderEnabled(localId, enabled)
    end
end

ClientAeonPortCzar = Class("AeonPortCzar", ChosenAirFactory)
local AeonPortCzar = ClientAeonPortCzar

function AeonPortCzar:__init(
    globalId,
    localId,
    armyId,
    template,
    fractionComplete)
    ChosenAirFactory.__init(
        self,
        globalId,
        localId,
        armyId,
        template,
        fractionComplete)

    self.scoCzarCenterMuzzle = self:GetBoneId(
        "Center_Muzzle")
    if not Engine.IsValidLocalID(self.scoCzarCenterMuzzle) then
        error("Czar requires exact Center_Muzzle; no Root fallback is allowed.")
    end

    local weapon = self.weapons and self.weapons[1]
    local muzzle = weapon and weapon.muzzles and weapon.muzzles[1]
    local beam = muzzle and muzzle.beam
    if not beam then
        error("Czar primary Center_Muzzle client beam was not created.")
    end

    local beamContract = template.additions
        and template.additions.czarCenterDownBeam
    local beamWidthScales = beamContract and {
        beamContract.visualCoreWidthScale,
        beamContract.visualPlasmaWidthScale,
        beamContract.visualHaloWidthScale,
    }
    if not beamWidthScales or #beam.submeshes ~= 3 then
        error("Czar inner-hole beam-width contract is invalid.")
    end
    for index, submeshId in ipairs(beam.submeshes) do
        local widthScale = beamWidthScales[index]
        if type(widthScale) ~= "number" or widthScale <= 0 then
            error("Czar beam submesh width is invalid.")
        end
        local beamScale = EngineClasses.float3(
            widthScale,
            widthScale,
            1)
        if not Engine.IsValidLocalID(submeshId)
            or Engine.SetMeshRendererScale(submeshId, beamScale)
                ~= EngineErrorCode.Success
        then
            error("Czar beam submesh width scaling failed.")
        end
    end

    -- This beam owns its muzzle and terrain contact effects. Suppress the
    -- native projectile impact so it cannot create a second endpoint.
    beam.projectileTemplate = {}
    self.scoCzarBeam = beam
    self.scoCzarImpactEffect = nil
    self.scoCzarMuzzleEffect = nil

    -- The native beam manager raycasts and uploads renderer data after the
    -- per-unit render pass. Update this beam after its raycast, before upload.
    local czar = self
    local updateStart = beam.OnUpdateStart
    local disabled = beam.OnDisabled
    local deleted = beam.OnDeleted
    local visibilityChanged = beam.OnIntelVisibilityChanged
    function beam:OnUpdateStart(...)
        local result = updateStart(self, ...)
        czar:ScoCzarUpdateBeamVisuals()
        return result
    end
    function beam:OnDisabled(...)
        local result = disabled(self, ...)
        czar:ScoCzarStopBeamEffects()
        return result
    end
    function beam:OnDeleted(...)
        local result = deleted(self, ...)
        czar:ScoCzarStopBeamEffects()
        return result
    end
    function beam:OnIntelVisibilityChanged(...)
        local result = visibilityChanged(self, ...)
        if not self.isIntelVisionVisible then
            czar:ScoCzarStopBeamEffects()
        end
        return result
    end
end

function AeonPortCzar:CreateTarmac()
end

function AeonPortCzar:OnPromoteToUnit()
    ChosenAirUnit.OnPromoteToUnit(self)
end

function AeonPortCzar:OnCompleted()
    ChosenAirUnit.OnCompleted(self)
end

function AeonPortCzar:IsHighlightable()
    return ChosenAirUnit.IsHighlightable(self)
end

function AeonPortCzar:IsSelectable()
    return ChosenAirUnit.IsSelectable(self)
end

function AeonPortCzar:OnIntelHidden()
    ChosenAirUnit.OnIntelHidden(self)
end

function AeonPortCzar:OnIntelVision()
    ChosenAirUnit.OnIntelVision(self)
end

function AeonPortCzar:OnIntelRadar()
    ChosenAirUnit.OnIntelRadar(self)
    self:RecalculateConstructionBeamState()
end

function AeonPortCzar:ClientOnStopBuilding()
    local targetUnit = self.buildTarget
    ChosenAirFactory.ClientOnStopBuilding(self)
    if targetUnit and not targetUnit:IsCompleted() then
        targetUnit:SetSelectionEnabled(false)
        scoCzarSetLocalVolumeColliderEnabled(
            targetUnit.id,
            false)
    end
end

local function scoCzarStartEffect(path, position, rotation)
    local prefab = scoCzarGetEffectPrefab(path)
    if prefab == nil then
        error("Czar beam effect failed to load: " .. path)
    end
    local result, effect = Engine.InstantiatePrefab(
        prefab, position, scoCzarScale, rotation)
    if result ~= EngineErrorCode.Success or not Engine.IsValidLocalID(effect) then
        scoCzarStopEffect(effect)
        error("Czar beam effect failed to instantiate: " .. path)
    end
    Engine.SetDestroyUponCompletion(effect, false)
    Engine.SetParticleCanEmit(effect, true)
    return effect
end

function AeonPortCzar:ScoCzarStopBeamEffects()
    scoCzarStopEffect(self.scoCzarMuzzleEffect)
    scoCzarStopEffect(self.scoCzarImpactEffect)
    self.scoCzarMuzzleEffect = nil
    self.scoCzarImpactEffect = nil
end

function AeonPortCzar:ScoCzarUpdateBeamVisuals()
    local beam = self.scoCzarBeam
    if not beam.enabled or beam.deleted or not beam.isIntelVisionVisible
        or self.dead or self.deleted
    then
        self:ScoCzarStopBeamEffects()
        return
    end

    local impact, length = scoCzarTerrainImpact(self.scoCzarCenterMuzzle)
    beam:SetBeamLength(length)
    local muzzlePosition = beam.muzzle:GetPosition()
    local muzzleRotation = beam.muzzle:GetOrientation()
    if not self.scoCzarMuzzleEffect then
        self.scoCzarMuzzleEffect = scoCzarStartEffect(
            scoCzarMuzzleEffectPath, muzzlePosition, muzzleRotation)
    end
    if not self.scoCzarImpactEffect then
        self.scoCzarImpactEffect = scoCzarStartEffect(
            scoCzarImpactEffectPath, impact, scoCzarImpactRotation)
    end
    Engine.SetLocalEntityLocalPosition(self.scoCzarMuzzleEffect, muzzlePosition)
    Engine.SetLocalEntityLocalRotation(self.scoCzarMuzzleEffect, muzzleRotation)
    Engine.SetLocalEntityLocalPosition(self.scoCzarImpactEffect, impact)
    Engine.SetLocalEntityLocalRotation(self.scoCzarImpactEffect, scoCzarImpactRotation)
end

function AeonPortCzar:OnDestroy(isDelete)
    self:ScoCzarStopBeamEffects()
    return ChosenAirFactory.OnDestroy(self, isDelete)
end

function AeonPortCzar:OnDelete()
    self:ScoCzarStopBeamEffects()
    return ChosenAirFactory.OnDelete(self)
end

-- SCO_CzarCrashScorchContact_v1: completed Czar wrecks mark ground at contact.
function AeonPortCzar:CreateRandomScorchmark()
    if not self:IsCompleted() then
        return ChosenAirFactory.CreateRandomScorchmark(self)
    end
end
-- SCOM Field Fixes 1.0.8 - Fervor selection owned by measured prefab bounds.
local SCO_FieldFixChosenClientVersion = "1.0.8"
local SCO_FieldFixColossusRetargetContinuityVersion = "1.0.2"
local SCO_FieldFixChosenClientInstalled = _G.SCO_FieldFixChosenClientInstalled
if SCO_FieldFixChosenClientInstalled ~= nil
    and SCO_FieldFixChosenClientInstalled ~= SCO_FieldFixChosenClientVersion
then
    error("SCOM Field Fixes found an unsupported Chosen client consumer version")
end
if SCO_FieldFixChosenClientInstalled == nil then

    if type(AeonPortLandUnit) ~= "table"
        or type(AeonPortLandUnit.__init) ~= "function"
    then
        error("SCOM Field Fixes could not resolve AeonPortLandUnit client constructor")
    end

    local SCO_FieldFixChosenLandInit = AeonPortLandUnit.__init
    local SCO_FieldFixColossusScaleLogged = false
    local SCO_FieldFixFervorColliderSize =
        EngineClasses.float3(0.55, 0.32, 0.90)
    local SCO_FieldFixFervorColliderOffset =
        EngineClasses.float3(0, 0.16, 0.084)

    function AeonPortLandUnit:__init(
        globalId,
        localId,
        armyId,
        template,
        fractionComplete)
        SCO_FieldFixChosenLandInit(
            self,
            globalId,
            localId,
            armyId,
            template,
            fractionComplete)

        if self.tpId == "ucl1101" then
            if Engine.SetVolumeColliderSize(
                self.localId,
                SCO_FieldFixFervorColliderSize) ~= EngineErrorCode.Success
                or Engine.SetVolumeColliderOffset(
                    self.localId,
                    SCO_FieldFixFervorColliderOffset)
                    ~= EngineErrorCode.Success
            then
                error("Fervor measured gameplay collider policy could not be applied")
            end
        end

        local additions = template and template.additions
        local hasTemplateContract = additions
            and (additions.scoFieldFixAeonSeraphim == "1.0.0"
                or additions.scoFieldFixGalacticColossusEye == "1.0.1")
        local contract = hasTemplateContract
            and additions.scoFieldFixColossusEye
        if type(contract) ~= "table" or contract.version ~= "1.0.1" then
            return
        end

        local weapon = self.weapons and self.weapons[1]
        local muzzle = weapon and weapon.muzzles and weapon.muzzles[1]
        local beam = muzzle and muzzle.beam
        local submeshes = beam and beam.submeshes
        local widthScale = contract.beamWidthScale
        if type(submeshes) ~= "table" or #submeshes ~= 2
            or widthScale ~= 0.6
            or contract.coreIntensity ~= 2000
            or contract.auraIntensity ~= 250
            or beam.fadeOutTime ~= 0.6
        then
            error("Galactic Colossus eye beam contract does not match its two-submesh client beam")
        end
        for _, submeshId in ipairs(submeshes) do
            if not Engine.IsValidLocalID(submeshId) then
                error("Galactic Colossus eye beam has an invalid client submesh")
            end
        end

        local continuityVersion =
            beam.scoFieldFixColossusRetargetContinuity
        if continuityVersion ~= nil
            and continuityVersion
                ~= SCO_FieldFixColossusRetargetContinuityVersion
        then
            error("Galactic Colossus eye beam has an unsupported retarget continuity version")
        end
        -- The native beam manager now owns Update/OnImpactLost and fading.
        -- Only legacy beams need the RenderUpdate/CleanupImpactEffect adapter.
        local nativeBeamLifecycle = type(beam.Update) == "function"
            and type(beam.OnImpactLost) == "function"
            and type(beam.Delete) == "function"
            and type(beam.SetBeamEnabled) == "function"
            and type(beam.GetAfterlife) == "function"
            and type(beam.ResetVisuals) == "function"
            and beam.RenderUpdate == nil
            and beam.CleanupImpactEffect == nil
        if continuityVersion == nil and not nativeBeamLifecycle then
            local stockSetBeamEnabled = beam.SetBeamEnabled
            local stockGetAfterlife = beam.GetAfterlife
            local stockRenderUpdate = beam.RenderUpdate
            local stockCleanupImpactEffect = beam.CleanupImpactEffect
            local stockMuzzleCleanup = muzzle.Cleanup
            if type(stockSetBeamEnabled) ~= "function"
                or type(stockGetAfterlife) ~= "function"
                or type(stockRenderUpdate) ~= "function"
                or type(stockCleanupImpactEffect) ~= "function"
                or type(stockMuzzleCleanup) ~= "function"
                or type(beam.ResetVisuals) ~= "function"
            then
                error("Galactic Colossus eye beam cannot install retarget continuity")
            end

            local function clearResumeFade(eyeBeam)
                eyeBeam.scoFieldFixColossusResumeFadeStart = nil
                eyeBeam.scoFieldFixColossusResumeAfterlife = nil
            end

            local function getResumeAfterlife(eyeBeam, now)
                local start = eyeBeam.scoFieldFixColossusResumeFadeStart
                local afterlife =
                    eyeBeam.scoFieldFixColossusResumeAfterlife
                if type(start) ~= "number"
                    or type(afterlife) ~= "number"
                then
                    return 0
                end
                local remaining = afterlife - (now - start)
                return remaining > 0 and remaining or 0
            end

            local function hardStopEyeBeam(eyeBeam)
                eyeBeam.scoFieldFixColossusRetargetHolding = nil
                clearResumeFade(eyeBeam)
                eyeBeam.enabled = false
                eyeBeam.pendingEnable = false
                eyeBeam.isRendering = false
                eyeBeam:CleanupImpactEffect()
                eyeBeam:ResetVisuals()
            end

            function beam:CleanupImpactEffect()
                local effectId = self.impactEffectId
                if effectId == nil then
                    self.impactEffectCreated = false
                    return
                end
                if Engine.IsValidLocalID(effectId) then
                    return stockCleanupImpactEffect(self)
                end
                self.impactEffectCreated = false
                self.impactEffectId = nil
            end

            function beam:GetAfterlife(lifetime)
                local start = self.scoFieldFixColossusResumeFadeStart
                local afterlife =
                    self.scoFieldFixColossusResumeAfterlife
                if type(start) == "number"
                    and type(afterlife) == "number"
                    and type(_G.Time) == "number"
                then
                    local remaining = afterlife - (_G.Time - start)
                    if remaining > 0 then
                        return remaining
                    end
                    clearResumeFade(self)
                    return 0
                end
                clearResumeFade(self)
                return stockGetAfterlife(self, lifetime)
            end

            function beam:RenderUpdate()
                -- The final sim raycast already cached the shaft length. Never
                -- read a native muzzle handle after disable: teardown or debug
                -- hotkeys may invalidate it before the Lua unit leaves the
                -- render table.
                local result = stockRenderUpdate(self)
                if self.scoFieldFixColossusRetargetHolding == true
                    and not self.enabled
                    and not self.isRendering
                then
                    hardStopEyeBeam(self)
                end
                return result
            end

            function beam:SetBeamEnabled(enabled)
                local weaponOwner = self.muzzle and self.muzzle.weapon
                local owner = weaponOwner and weaponOwner.unit
                local weaponTemplate = weaponOwner and weaponOwner.tp
                if owner == nil
                    or owner.dead
                    or owner.deleted
                    or owner.tpId ~= "ucl4004"
                    or type(weaponTemplate) ~= "table"
                    or weaponTemplate.scoSourceLabel ~= "EyeWeapon"
                    or weaponTemplate.scoFieldFixGalacticColossusEye ~= "1.0.1"
                then
                    hardStopEyeBeam(self)
                    if owner and (owner.dead or owner.deleted) then
                        self.scoFieldFixColossusTerminalCleanup = true
                    end
                    return
                end

                if enabled then
                    if self.enabled then
                        return
                    end
                    local now = _G.Time
                    local fadeOutTime = self.fadeOutTime
                    local afterlife = type(now) == "number"
                        and stockGetAfterlife(self, 0)
                    if self.scoFieldFixColossusRetargetHolding == true
                        and type(now) == "number"
                        and type(fadeOutTime) == "number"
                        and type(afterlife) == "number"
                        and afterlife >= 0
                        and afterlife < fadeOutTime
                        and self.isRendering == true
                        and type(self.length) == "number"
                        and self.length > 0
                    then
                        self.enabled = true
                        self.pendingEnable = false
                        self.disableTime = 999999
                        self.scoFieldFixColossusRetargetHolding = nil
                        if afterlife > 0 then
                            self.scoFieldFixColossusResumeFadeStart = now
                            self.scoFieldFixColossusResumeAfterlife =
                                afterlife
                        else
                            clearResumeFade(self)
                        end
                        return
                    end
                    self.scoFieldFixColossusRetargetHolding = nil
                    clearResumeFade(self)
                    return stockSetBeamEnabled(self, true)
                end

                if not self.enabled then
                    return
                end
                local now = _G.Time
                local fadeOutTime = self.fadeOutTime
                if type(now) ~= "number"
                    or type(fadeOutTime) ~= "number"
                    or fadeOutTime <= 0
                    or self.isRendering ~= true
                    or type(self.length) ~= "number"
                    or self.length <= 0
                then
                    hardStopEyeBeam(self)
                    return
                end

                -- Preserve the last rendered shaft while the authored fade
                -- runs. Host damage is already disabled.
                local resumeAfterlife = getResumeAfterlife(self, now)
                clearResumeFade(self)
                -- Impact particles own separate native handles and are not
                -- needed for accessibility continuity. Release them while the
                -- firing muzzle is known-live; the tail retains only the shaft.
                self:CleanupImpactEffect()
                self.enabled = false
                self.pendingEnable = false
                self.disableTime = now - resumeAfterlife
                self.scoFieldFixColossusRetargetHolding = true
            end

            function muzzle:Cleanup()
                local cleanupOwner = self.weapon and self.weapon.unit
                if self.beam == beam
                    and cleanupOwner
                    and (cleanupOwner.dead or cleanupOwner.deleted)
                    and beam.scoFieldFixColossusTerminalCleanup ~= true
                then
                    hardStopEyeBeam(beam)
                    beam.scoFieldFixColossusTerminalCleanup = true
                end
                return stockMuzzleCleanup(self)
            end

            beam.scoFieldFixColossusRetargetContinuity =
                SCO_FieldFixColossusRetargetContinuityVersion
        end

        local scale = EngineClasses.float3(widthScale, widthScale, 1)
        for _, submeshId in ipairs(submeshes) do
            if Engine.SetMeshRendererScale(submeshId, scale)
                ~= EngineErrorCode.Success
            then
                error("Galactic Colossus eye beam width scaling failed")
            end
        end
        self.scoFieldFixColossusBeamScaled = true
        if not SCO_FieldFixColossusScaleLogged and type(Log) == "function" then
            Log("[SCOM Field Fixes] Applied Galactic Colossus eye scale 0.6 to both client beam layers.")
            SCO_FieldFixColossusScaleLogged = true
        end
    end

    if type(AeonPortLandUnit.CreateDeathEffects) == "function" then
        local SCO_FieldFixChosenCreateDeathEffects =
            AeonPortLandUnit.CreateDeathEffects
        function AeonPortLandUnit:CreateDeathEffects()
            if self.tpId == "ucl4004" and self:IsCompleted() then
                if self:IsIntelVisionVisible() then
                    self:CreateOnDestroyedAudioEffect()
                end
                return
            end
            return SCO_FieldFixChosenCreateDeathEffects(self)
        end
    end

    if type(Import) == "function" and type(__Entities) == "table" then
        -- script.lua loads networking through require(), so Import sees a
        -- boolean package-cache entry. Its listener API is already global.
        local SCO_FieldFixChosenRegisterListener = RegisterListener
        if type(SCO_FieldFixChosenRegisterListener) ~= "function" then
            error("SCOM Field Fixes could not resolve client networking")
        end
        local SCO_FieldFixChosenVFXLoader =
            Import("common/loading/vfxTemplateLoader.lua")
        local SCO_FieldFixColossusDeathVFXCommand =
            "SCOFieldFixColossusDeathVFX"
        local SCO_FieldFixColossusWreckCommand =
            "SCOFieldFixColossusWreckBounds"
        local SCO_FieldFixColossusDeathPrefabs = {}
        local SCO_FieldFixColossusDeathPaths = {
            small = "VFX/SCOM/AeonExplosions/vcd7101_explosion_secondary_small.sanvfx",
            large = "VFX/SCOM/AeonExplosions/vcd7301_explosion_secondary_large.sanvfx",
        }

        local function SCO_FieldFixChosenFiniteNumber(value)
            return type(value) == "number"
                and value == value
                and value > -math.huge
                and value < math.huge
        end

        local function SCO_FieldFixChosenFiniteVector(value)
            return type(value) == "table"
                and SCO_FieldFixChosenFiniteNumber(value.x)
                and SCO_FieldFixChosenFiniteNumber(value.y)
                and SCO_FieldFixChosenFiniteNumber(value.z)
        end

        local function SCO_FieldFixChosenIdentityMatches(entity, index, version, tpId)
            local id = entity and entity.id
            return entity ~= nil
                and not entity.deleted
                and id ~= nil
                and id.index == index
                and id.version == version
                and entity.tpId == tpId
        end

        local function SCO_FieldFixColossusDeathVFX(data)
            if type(data) ~= "table"
                or data.tpId ~= "ucl4004"
                or (data.kind ~= "small" and data.kind ~= "large")
                or not SCO_FieldFixChosenFiniteNumber(data.scale)
                or data.scale <= 0
                or not SCO_FieldFixChosenFiniteVector(data.position)
                or type(data.orientation) ~= "table"
                or not SCO_FieldFixChosenFiniteNumber(data.orientation.x)
                or not SCO_FieldFixChosenFiniteNumber(data.orientation.y)
                or not SCO_FieldFixChosenFiniteNumber(data.orientation.z)
                or not SCO_FieldFixChosenFiniteNumber(data.orientation.w)
            then
                return
            end
            local unit = __Entities.Units
                and __Entities.Units[data.unitIndex]
            if not SCO_FieldFixChosenIdentityMatches(
                unit,
                data.unitIndex,
                data.unitVersion,
                "ucl4004")
                or not unit:IsIntelVisionVisible()
            then
                return
            end

            local prefab = SCO_FieldFixColossusDeathPrefabs[data.kind]
            if prefab == nil then
                prefab = SCO_FieldFixChosenVFXLoader.GetOrCreateVFXPrefab(
                    SCO_FieldFixColossusDeathPaths[data.kind])
                SCO_FieldFixColossusDeathPrefabs[data.kind] = prefab
            end
            if prefab == nil then
                return
            end

            local result, effectId = Engine.InstantiatePrefab(
                prefab,
                EngineClasses.float3(
                    data.position.x,
                    data.position.y,
                    data.position.z),
                EngineClasses.float3(
                    data.scale,
                    data.scale,
                    data.scale),
                EngineClasses.quaternion(EngineClasses.float4(
                    data.orientation.x,
                    data.orientation.y,
                    data.orientation.z,
                    data.orientation.w)))
            if result == EngineErrorCode.Success
                and effectId ~= nil
                and Engine.IsValidLocalID(effectId)
            then
                Engine.SetParticleCanEmit(effectId, true)
                Engine.SetDestroyUponCompletion(effectId, true)
            end
        end

        local function SCO_FieldFixColossusApplyWreckBounds(data)
            local prop = __Entities.Props
                and __Entities.Props[data.propIndex]
            if not SCO_FieldFixChosenIdentityMatches(
                prop,
                data.propIndex,
                data.propVersion,
                "ucl4004_Wreckage")
            then
                return false
            end
            local size = EngineClasses.float3(
                data.size.x,
                data.size.y,
                data.size.z)
            local offset = EngineClasses.float3(
                data.offset.x,
                data.offset.y,
                data.offset.z)
            if Engine.SetVolumeColliderSize(prop.localId, size)
                ~= EngineErrorCode.Success
                or Engine.SetVolumeColliderOffset(prop.localId, offset)
                    ~= EngineErrorCode.Success
            then
                error("Galactic Colossus wreck selection collider adjustment failed")
            end
            if prop.selectionBracketID ~= nil then
                Engine.SetLocalEntityLocalPosition(
                    prop.selectionBracketID,
                    EngineClasses.float3(
                        data.offset.x,
                        0,
                        data.offset.z))
                Engine.SetMeshRendererScale(
                    prop.selectionBracketID,
                    EngineClasses.float3(data.size.x, 1, data.size.z))
            end
            return true
        end

        local function SCO_FieldFixColossusWreckBoundsThread(data)
            for _ = 1, 3 do
                if SCO_FieldFixColossusApplyWreckBounds(data) then
                    return
                end
                WaitTicks(1)
            end
        end

        local function SCO_FieldFixColossusWreckBounds(data)
            if type(data) ~= "table"
                or data.tpId ~= "ucl4004_Wreckage"
                or not SCO_FieldFixChosenFiniteVector(data.size)
                or not SCO_FieldFixChosenFiniteVector(data.offset)
                or data.size.x <= 0
                or data.size.y <= 0
                or data.size.z <= 0
            then
                return
            end
            if not SCO_FieldFixColossusApplyWreckBounds(data) then
                NewThread(SCO_FieldFixColossusWreckBoundsThread, data)
            end
        end

        SCO_FieldFixChosenRegisterListener(
            "client_" .. SCO_FieldFixColossusDeathVFXCommand,
            SCO_FieldFixColossusDeathVFX)
        SCO_FieldFixChosenRegisterListener(
            "client_" .. SCO_FieldFixColossusWreckCommand,
            SCO_FieldFixColossusWreckBounds)
    end

    -- The public renderer API exposes beam mesh scale but no reviewed material
    -- emission/intensity parameter. The two owned material assets therefore
    -- carry the exact 2000/250 core/aura calibration.
    _G.SCO_FieldFixChosenClientInstalled = SCO_FieldFixChosenClientVersion
end
