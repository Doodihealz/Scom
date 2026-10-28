local SCOM_EditableUnits = Import("scom/editableUnits.lua")
-- This file handles loading and reloading of templates.
-- Templates are loaded by Lua, verified and sent to the engine using FFI structs.

local wreckTemplate = Import("common/props/propsTemplates/defaultWreckage.santp").PropTemplate
local DefaultTemplates = Import("common/systems/templateControl.lua").DefaultTemplates
local AvailableUnits = Import("common/units/availableUnits.lua").AvailableUnits
local QuickLaunchUnits = Import("common/units/QuickLaunchUnits.lua").QuickLaunchUnits

local Layers = Import("common/layers.lua")

local UnitLoader = Import("common/loading/unitTemplateLoader.lua")
local PlacementGhostLoader = Import("common/loading/placementGhostTemplateLoader.lua")
local PropLoader = Import("common/loading/propTemplateLoader.lua")
local ProjectileTemplateLoader = Import("common/loading/projectileTemplateLoader.lua")
local VFXTemplateLoader = Import("common/loading/vfxTemplateLoader.lua")
local DecalTemplateLoader = Import("common/loading/decalTemplateLoader.lua")
local BeamLoader = Import("common/loading/beamLoader.lua")

local VisualMarkerLoader = Import("common/loading/visualMarkerLoader.lua")
local AdjacencyConnectorLoader = Import("common/loading/adjacencyConnectorLoader.lua")
local OrderLineNodeLoader = Import("common/loading/orderLineNodeLoader.lua")

local UIUtils = Import("client/ui/uiUtils.lua")

local RangeRingMaterials = Import("client/rangeRingMaterials.lua")

local PlayableAreaBarrierLoader = Import("common/loading/playableAreaBarrierLoader.lua")
local WaterLoader = Import("common/loading/waterLoader.lua")

-- Restricts unfinished units from loading, according to AvailableUnits list.
local useAvailableUnitsList = false
local useQuickLaunchUnitsList = Engine.GetQuickLaunchUnitsEnabled()

local Templates = __Templates
local PrefabIDs = __PrefabIDs
local Classes = __Classes

_G.TemplateHeadEntityName = "__Head"

local ShieldImpactEffects = {
    { tag = "CHOSEN", paths = {
        "VFX/Impact/vci6101_chosen_shield_impact_small.sanvfx",
        "VFX/Impact/vci6201_chosen_shield_impact_medium.sanvfx",
        "VFX/Impact/vci6301_chosen_shield_impact_large.sanvfx",
        "VFX/Impact/vci6401_chosen_shield_impact_huge.sanvfx",
    } },
    { tag = "EDA", paths = {
        "VFX/Impact/vei6101_eda_shield_impact_small.sanvfx",
        "VFX/Impact/vei6201_eda_shield_impact_medium.sanvfx",
        "VFX/Impact/vei6301_eda_shield_impact_large.sanvfx",
        "VFX/Impact/vei6401_eda_shield_impact_huge.sanvfx",
    } },
    { tag = "GUARD", paths = {
        "VFX/Impact/vgi6101_guard_shield_impact_small.sanvfx",
        "VFX/Impact/vgi6201_guard_shield_impact_medium.sanvfx",
        "VFX/Impact/vgi6301_guard_shield_impact_large.sanvfx",
        "VFX/Impact/vgi6401_guard_shield_impact_huge.sanvfx",
    } },
}

local ScorchmarkPaths = {
    "Environment/Common/Decals/scorchmark_default.sandecal",
    "Environment/Common/Decals/scorchmark_hit_diffuse.sandecal",
    "Environment/Common/Decals/scorchmark_liquid_burns_diffuse.sandecal",
    "Environment/Common/Decals/scorchmark_radial_diffuse.sandecal",
    "Environment/Common/Decals/scorchmark_shrapnel_diffuse.sandecal",
}

--- Opens the tp file from the folder location, "tpId/tpId.santp".
-- @param tpType "projectileTemplate", "unitTemplate", "propTemplate"
local function getTemplateFromLocation(fileLocation, tpType)
    local tpId = string.lower(string.match(fileLocation, '[^/]+$'))
    local tp = Import(fileLocation.."/"..tpId..".santp")[tpType]
    if tp.general and tp.general.tpId and tp.general.tpId ~= tpId then
        Warn(string.format("getTemplateFromLocation: Missmatch between folder/file name: %s, and tpId field in the template: %s", tpId, tp.general.tpId))
    end

    return tp, tpId
end

--- First time load of all available templates.
-- Projectiles need to be loaded before units, since unit weapons are referencing projectiles.
-- Units need to be loaded before props, since wreckage templates are generated based on units.
function LoadAllTemplates()
    local faultyTemplates = {}

    -- Load projectile templates
    local tpsFolders = ScanDir("common/projectiles/projectilesTemplates/")
    for _, folder in pairs(tpsFolders) do
        local result, tp, tpId = xpcall(getTemplateFromLocation, ErrorHandler, folder, "ProjectileTemplate")
        if not result then
            table.insert(faultyTemplates, folder)
        else
            ReadProjectileTemplate(tp, tpId)
        end
    end

    -- Load unit templates
    tpsFolders = ScanDir("common/units/unitsTemplates/")
    for _, folder in pairs(tpsFolders) do
        local result, tp, tpId = xpcall(getTemplateFromLocation, ErrorHandler, folder, "UnitTemplate")
        if not result then
            table.insert(faultyTemplates, folder)
        else
            ReadUnitTemplate(tp, tpId)
        end
    end

    -- Load prop templates
    tpsFolders = ScanDir("common/props/propsTemplates/")
    for _, folder in pairs(tpsFolders) do
        local result, tp, tpId = xpcall(getTemplateFromLocation, ErrorHandler, folder, "PropTemplate")
        if not result then
            table.insert(faultyTemplates, folder)
        else
            ReadPropTemplate(tp, tpId)
        end
    end

    local collisionWorldID = Engine.CreateCollisionWorld(VolumeCollisionEventMode.EnterExit)

    local environmentCollisionWorldID = Engine.CreateCollisionWorld(VolumeCollisionEventMode.EnterExit)

    local selectionWorldID = -1
    if IsClient then
        selectionWorldID = Engine.CreateCollisionWorld(VolumeCollisionEventMode.EnterExit)
    end

    local intelVisionWorldID = -1
    local intelRadarWorldID = -1
    local intelSonarWorldID = -1
    local targetingWorldID = -1
    local constructionWorldID = -1
    if IsHost then
        intelVisionWorldID = Engine.CreateCollisionWorld(VolumeCollisionEventMode.Disabled)
        intelRadarWorldID = Engine.CreateCollisionWorld(VolumeCollisionEventMode.Disabled)
        intelSonarWorldID = Engine.CreateCollisionWorld(VolumeCollisionEventMode.Disabled)
        targetingWorldID = Engine.CreateCollisionWorld(VolumeCollisionEventMode.Disabled)
        constructionWorldID = Engine.CreateCollisionWorld(VolumeCollisionEventMode.EnterExit)
    end
    
    _G.CollisionWorld = {
        Collision = collisionWorldID,
        EnvironmentCollision = environmentCollisionWorldID,
        Selection = selectionWorldID,
        IntelVision = intelVisionWorldID,
        IntelRadar = intelRadarWorldID,
        IntelSonar = intelSonarWorldID,
        Targeting = targetingWorldID,
        Construction = constructionWorldID,
    }

    if IsClient then
        UIUtils.InitializeTextures()

        local errorCode
        errorCode, _G.localBuildingPlacementGridID = Engine.CreateLocalGrid(1)
    else
        local errorCode
        errorCode, _G.globalBuildingPlacementGridID = Engine.CreateGlobalGrid(1)
    end

    LoadProjectileEffects()
    LoadUnitEffects(Templates.Units)
    LoadHardcodedVfx()

    LoadProjectileTemplates(Templates.Projectiles)
    LoadUnitTemplates(Templates.Units)
    LoadPropTemplates(Templates.Props)

    _G.DashChargeEffectPrefab = VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/Unit/vcu8301_dash_charge_up.sanvfx")
    _G.DashStartEffectPrefab = VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/Unit/vcu8302_dash_start.sanvfx")
    _G.DashEndEffectPrefab = VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/Unit/vcu8303_dash_end.sanvfx")

    ---@type BeamTemplate 
    _G.DashBeamTemplate = {
        cullDistance = 500,
        fadeInTime = 0.01,
        fadeOutTime = 1,
        renderLifetime = 0.5,
        subMesh = {
            {
                material = "VFX/Materials/Beam/Beam ucl0000_01.sanmaterial",
                model = "VFX/Models/Beams/BeamBasicLongSingle.sanmodel",
            },
            {
                material = "VFX/Materials/Beam/Beam ucl0000_02.sanmaterial",
                model = "VFX/Models/Beams/BeamBasicLongSingle_2X.sanmodel",
            },
        },
    }
    _G.DashBeamPrefab = BeamLoader.CreateBeamPrefab("CommanderDashBeam", DashBeamTemplate)

    _G.DissolveSmallEffectPrefab = VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/Impact/vci0101_chosen_experimental_impact_small.sanvfx")
    _G.DissolveMediumEffectPrefab = VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/Impact/vci0201_chosen_experimental_impact_medium.sanvfx")
    _G.DissolveLargeEffectPrefab = VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/Impact/vci0301_chosen_experimental_impact_large.sanvfx")
    _G.DissolveHugeEffectPrefab = VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/Impact/vci0401_chosen_experimental_impact_huge.sanvfx")
    _G.DissolveExtremeEffectPrefab = VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/Impact/vci0501_chosen_experimental_impact_extreme.sanvfx")

    _G.ShieldImpactEffectPrefabs = {}
    for _, faction in ipairs(ShieldImpactEffects) do
        local prefabs = {}
        for size, path in ipairs(faction.paths) do
            prefabs[size] = VFXTemplateLoader.GetOrCreateVFXPrefab(path)
        end
        ShieldImpactEffectPrefabs[faction.tag] = prefabs
    end

    _G.OrderLinePrefabID = OrderLineNodeLoader.CreateOrderLinePrefab()
    _G.OrderNodePrefabID = OrderLineNodeLoader.CreateOrderNodePrefab()

    _G.PlacementGridTilePrefabIDOn = PlacementGhostLoader.CreatePlacementGridTilePrefab("On")
    _G.PlacementGridTilePrefabIDOff = PlacementGhostLoader.CreatePlacementGridTilePrefab("Off")
    _G.PlacementGridTilePrefabIDNeutral = PlacementGhostLoader.CreatePlacementGridTilePrefab("Neutral")

    _G.NukeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/Death/vcd0301_death_rdu.sanvfx")

-- SCOM Field Fix: Apocalypse impact VFX and commander audio prefabs 1.1.0
_G.SCO_ApocalypseNukeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/SCOM/Apocalypse/apoc_impact.sanvfx")
local SCOApocalypseAudioPrefabLoader = Import("common/loading/audioPrefabLoader.lua")
_G.SCO_ApocalypseCommanderExplosionAudioPrefabID = SCOApocalypseAudioPrefabLoader.CreateOneShotAudioPrefab("SCOM_Apocalypse_CommanderExplosion", "acod0000", "impacts")
    _G.TarmacEDAPrefabID = DecalTemplateLoader.CreateDecalPrefab("Environment/Common/Decals/tarmac_eda.sandecal")
    _G.TarmacChosenPrefabID = DecalTemplateLoader.CreateDecalPrefab("Environment/Common/Decals/tarmac_chosen.sandecal")
    _G.TarmacGuardPrefabID = DecalTemplateLoader.CreateDecalPrefab("Environment/Common/Decals/tarmac_guard.sandecal")
-- SCOM faction tarmacs 1.0.0
    Import("common/systems/scoFactionTarmacs.lua").Initialize()
    _G.ScorchmarkDecalPrefabIDs = {}
    for index, path in ipairs(ScorchmarkPaths) do
        _G.ScorchmarkDecalPrefabIDs[index] =
            DecalTemplateLoader.CreateDecalPrefab(path)
    end

    _G.PlayableAreaBarrierPrefabID, _G.PlayableAreaBarrierLayers = PlayableAreaBarrierLoader.CreatePlayableAreaBarrierPrefab()

    _G.WaterGlobalPrefabID = WaterLoader.CreateWaterGlobalPrefab()
    _G.WaterLocalPrefabID = WaterLoader.CreateWaterLocalPrefab()

    local formationBracketTemplate = Import("common/markers/markerTemplates/formationBracket/formationBracket.santp")["MarkerTemplate"]
    _G.DragFormationMarkerPrefabID = VisualMarkerLoader.CreateVisualMarkerPrefab(formationBracketTemplate)

    -- Do Unit -> Unit hierarchy mapping to allow Engine.CopyHierarchy() from units -> units (capture)
    CreateUnitHierarchyMaps(Templates.Units)

    -- Do Unit -> Wreck hierarchy mapping to allow Engine.CopyHierarchy() from units -> wrecks.
    CreateUnitWreckHierarchyMaps(Templates.Units, Templates.Props)

    -- SCOM Field Fix: shared strategic nuke impact prefab 1.0.0
    if IsClient then
        Engine.LoadEffect("VFX/Impact/vei2401_missile_nuclear_impact.sanvfx")
    end
    _G.SCO_StrategicNukeImpactVFXPrefabID =
        VFXTemplateLoader.GetOrCreateVFXPrefab("VFX/Impact/vei2401_missile_nuclear_impact.sanvfx")

    if #faultyTemplates > 0 then
        Warn("Templates not loaded:\n" .. repr(faultyTemplates))
    end
end

-- Reads, verifies and saves a projectile santp file.
function ReadProjectileTemplate(tp, tpId)
    if not VerifyTemplate(tp, "projectile") then
        return
    end

    -- TODO: Hotreloading need to be reimplemented with the new templates system. 
    -- See function ReloadTemplates for more info on executing that.

    -- New tp, assign engine ID
    if not Templates.Projectiles[tpId] then
    else
        -- Reloaded tp, assign the old ID
        --tp.general.engineId = Templates.Projectiles[tpId].general.engineId
    end

    -- Save the template to the global tables
    Templates.Projectiles[tpId] = tp
end

-- Reads, verifies and saves a unit santp file.
function ReadUnitTemplate(tp, tpId)
    if (useAvailableUnitsList and not AvailableUnits[tpId]) or not VerifyTemplate(tp, "unit") then
        return
    end
    if (useQuickLaunchUnitsList and not QuickLaunchUnits[tpId]) or not VerifyTemplate(tp, "unit") then
        return
    end

    -- Generate range rings data into a single table
    ModUnitTemplate(tp)
    -- Load unit tags
    Tags(tp)

    -- TODO: Hotreloading need to be reimplemented with the new templates system. 
    -- See function ReloadTemplates for more info on executing that.

    -- New tp, assign engine ID
    if not Templates.Units[tpId] then
    else
        -- Reloaded tp, assign the old ID
        --tp.general.engineId = Templates.Units[tpId].general.engineId
    end

    -- Save the template to the global tables
    Templates.Units[tpId] = tp
    -- Save the class to load later
    Classes.Units[tpId] = tp.general.class

    GenerateUnitWreckage(tp, tpId)
end

-- Reads, verifies and saves a prop santp file.
function ReadPropTemplate(tp, tpId)
    if not VerifyTemplate(tp, "prop") then
        return
    end

    -- TODO: Hotreloading need to be reimplemented with the new templates system. 
    -- See function ReloadTemplates for more info on executing that.

    -- New tp, assign engine ID
    if not Templates.Props[tpId] then
    else
        -- Reloaded tp, assign the old ID
        --tp.general.engineId = Templates.Props[tpId].general.engineId
    end

    -- Save the template to the global tables
    Templates.Props[tpId] = tp
    -- Save the class to load later
    Classes.Props[tpId] = tp.general.class
end

--- Sort templates before registration. They must be registered in the same order for both host and client engine otherwise desyncs will occure.
local function GetSortedKeys(t)
    local keys = {}
    for k in pairs(t) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

--- Converts loaded projectile template to and sends it to the engine.
-- @param templates Table of templates proccessed by Lua, ready to be sent to the engine.
function LoadProjectileTemplates(templates)
    local sortedKeys = GetSortedKeys(templates)
    for _, key in ipairs(sortedKeys) do
        local tp = templates[key]

        local errorCode, projectilePrefabID = ProjectileTemplateLoader.CreateProjectilePrefab(tp)

        if errorCode == EngineErrorCode.Success then
            PrefabIDs.Projectiles[projectilePrefabID.Value] = tp.general.tpId
            tp.general.prefabID = projectilePrefabID
            tp.general.engineId = projectilePrefabID

            if tp.visuals and tp.visuals.onImpactEffects then
                for _, onImpactEffects in ipairs(tp.visuals.onImpactEffects) do
                    for _, effect in ipairs(onImpactEffects.effects) do
                        if effect.particleName then
                            effect.particlePrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(effect.particleName)
                        end
                    end
                end
            end

            if tp.visuals and tp.visuals.onWaterImpactEffects then
                for _, onWaterImpactEffects in ipairs(tp.visuals.onWaterImpactEffects) do
                    for _, effect in ipairs(onWaterImpactEffects.effects) do
                        if effect.particleName then
                            effect.particlePrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(effect.particleName)
                        end
                    end
                end
            end

        end
    end
end

--- Converts loaded unit template to ffi and sends it to the engine.
-- @param templates Table of templates proccessed by Lua, ready to be sent to the engine.
function LoadUnitTemplates(templates)
    local sortedKeys = GetSortedKeys(templates)
    for _, key in ipairs(sortedKeys) do
        local tp = templates[key]

        local errorCode, unitPrefabID = UnitLoader.CreateUnitPrefab(tp)
    
        -- These are required for UI, so we always assign these values even if we failed to create the prefab
        if Tags.TECH4[tp.general.tpId] then
            tp.general.techNumber = 4
        elseif Tags.TECH3[tp.general.tpId] then
            tp.general.techNumber = 3
        elseif Tags.TECH2[tp.general.tpId] then
            tp.general.techNumber = 2
        else
            tp.general.techNumber = 1
        end

        tp.general.placementDomain = Layers.GetPlacementDomainFromTemplate(tp)

        if IsClient then
            tp.general.foregroundIconID = UIUtils.UnitTemplateIDToIconID[tp.general.tpId]
            tp.general.backgroundIconID = UIUtils.UnitIconUITypeToBackgroundIcon[tp.general.iconUIType]
            tp.general.strategicIconID = UIUtils.GetStrategicIconForUI(tp)
            tp.general.strategicIconGlowColor = UIUtils.GetStrategicIconGlowColorForUI(tp)
        end

        if errorCode == EngineErrorCode.Success then

            PrefabIDs.Units[unitPrefabID.Value] = tp.general.tpId
            tp.general.prefabID = unitPrefabID
            tp.general.engineId = unitPrefabID

            tp.hasTags = CreateHasTagTable(tp.tags)
	    
            tp.general.navigationLayer = Layers.GetDefaultNavigationLayerFromTemplate(tp)

            -- NOTE: This must come after we create the UnitPrefab because the placement ghost must read tp.general.prefabID when creating the placement ghost prefab.
            local errorCode, placementGhostPrefabID = PlacementGhostLoader.CreatePlacementGhostPrefab(tp)

            if errorCode == EngineErrorCode.Success then
                tp.general.placementGhostPrefabID = placementGhostPrefabID
            end

            if tp.visuals and tp.visuals.effectsInstant and tp.visuals.effectsInstant.onDeath then
                for _, effect in ipairs(tp.visuals.effectsInstant.onDeath) do
                    if effect.particleName then
                        effect.particlePrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(effect.particleName)
                    end
                end
            end

            if tp.weapons then
                for _, weapon in ipairs(tp.weapons) do
                    if weapon.effects and weapon.effects.onFire then 
                        weapon.effects.onFirePrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(weapon.effects.onFire)
                    end
                end
            end

-- SCOM Field Fix: Aeon mint death smoke 1.0.0
            local buildingSmokeVFXPath = "VFX/Death/vxd2321_death_building_large_smoke.sanvfx"
            local unitSmokeVFXPath = "VFX/Death/vxd1321_death_unit_large_smoke.sanvfx"
            if tp.hasTags.SCFA_AEON then
                buildingSmokeVFXPath = "VFX/SCOM/FieldFixes/AeonDeathSmoke/building_large_smoke.sanvfx"
                unitSmokeVFXPath = "VFX/SCOM/FieldFixes/AeonDeathSmoke/unit_large_smoke.sanvfx"
            end
            tp.buildingSmokeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(buildingSmokeVFXPath)
            tp.unitSmokeVFXPrefabID = VFXTemplateLoader.GetOrCreateVFXPrefab(unitSmokeVFXPath)
        end
    end
end

--- Converts loaded prop template to ffi and sends it to the engine.
-- @param templates Table of templates proccessed by Lua, ready to be sent to the engine.
function LoadPropTemplates(templates)
    local sortedKeys = GetSortedKeys(templates)
    for _, key in ipairs(sortedKeys) do
        local tp = templates[key]

        local errorCode, propPrefabID = PropLoader.CreatePropPrefab(tp)

        if errorCode == EngineErrorCode.Success then
            PrefabIDs.Props[propPrefabID.Value] = tp.general.tpId
            tp.general.prefabID = propPrefabID
            tp.general.engineId = propPrefabID
        end
    end
end

--- Uses unit's tp to generate and load it's wreck tp.
function GenerateUnitWreckage(tp, tpId)
    local wTp = table.deepCopy(wreckTemplate)

    local harvestAlloyMultiplier = 0.6 -- Wrecks give 60% the resources needed to create the unit.
    local harvestTimeDiscount = 0.6 -- Wrecks get reclaimed 60% faster than the unit takes to build.

    if tp.collisionInfo then
        wTp.collisionInfo = tp.collisionInfo
    end

    if tp.defence and tp.defence.health then
        wTp.defence.health = tp.defence.health
    end

    if tp.economy then
        if tp.economy.buildTime then
            wTp.economy.harvestTime = tp.economy.buildTime * (1.0 - harvestTimeDiscount)
        end

        -- Wrecks give half the resources for now
        if tp.economy.cost and tp.economy.cost.alloys then
            wTp.economy.harvest.alloys = math.max(1, math.floor(tp.economy.cost.alloys * (1 - harvestAlloyMultiplier)))
        end
    end

    if tp.footprint then
        wTp.footprint = tp.footprint
    end

    if tp.general then
        if tp.general.name then
            wTp.general.name = tp.general.name .. '_Wreckage'
        end

        if tp.general.tpId then
            wTp.general.tpId = tp.general.tpId .. '_Wreckage'
            -- Save the original tpId of the unit
            wTp.general.unitTpId = tp.general.tpId
        else
            Warn("Can't generate unit wreck for unit: " .. (tpId or "UNKNOWN ID"))
            return
        end
    else
        Warn("Can't generate unit wreck for unit: " .. (tpId or "UNKNOWN ID"))
        return
    end
    
    wTp.visuals = {
        skeleton = "Units/"..tpId.."/LOD0/"..tpId..".sanskeleton",
        isWreckage = true,
        lods = {
            {
                distance = 100.0,
                shadowCastingMode = 1,
                model = "Units/"..tpId.."/LOD0/"..tpId.."_lod0.sanmodel",
                material = "Units/"..tpId.."/LOD0/"..tpId.."_lod0.sanmaterial"
            }
        }
    }

    ReadPropTemplate(wTp, wTp.general.tpId)
end

-- Creates Unit -> Unit hierarchy maps for identical unit prefabs.
-- This enables Engine.CopyHierarchy(oldUnitId, newUnitId) for capture/respawn without visual popping.
function CreateUnitHierarchyMaps(unitTemplates)
    if not unitTemplates then
        return
    end

    local processedPrefabIds = {}
    for _, unitTemplate in pairs(unitTemplates) do
        if unitTemplate and unitTemplate.general and unitTemplate.general.prefabID and unitTemplate.general.tpId then
            local prefabId = unitTemplate.general.prefabID
            if not processedPrefabIds[prefabId] then
                processedPrefabIds[prefabId] = true

                local unitPath = "Units/"..unitTemplate.general.tpId.."/LOD0/"..unitTemplate.general.tpId
                local unitSkeletonPath = unitPath..".sanskeleton"

                local _, skeletonBones = Engine.GetSkeletonBones(unitSkeletonPath)

                -- TODO: As long as some units are missing skeleton data, we need to check for the presence of skeletonBones.
                if next(skeletonBones) then
                    local prefabHierarchyMapTemplate = {}
                    prefabHierarchyMapTemplate.sourcePrefabID = prefabId
                    prefabHierarchyMapTemplate.destinationPrefabID = prefabId
                    prefabHierarchyMapTemplate.prefabHierarchyMap = {}

                    for i, skeletonBone in pairs(skeletonBones) do
                        prefabHierarchyMapTemplate.prefabHierarchyMap[i] = {
                            sourceEntityName = skeletonBone.boneName,
                            destinationEntityName = skeletonBone.boneName
                        }
                    end

                    Engine.CreateHierarchyMap(prefabHierarchyMapTemplate)
                end
            end
        end
    end
end

-- Creates a HierarchyMap from all wreck props to their units
-- Required by the engine when calling Engine.CopyHierarchy so the engine understands how to do the copy.
function CreateUnitWreckHierarchyMaps(unitTemplates, propTemplates)
    for _, propTemplate in pairs(propTemplates) do

        if propTemplate.general.unitTpId ~= nil then

            local unitTemplate = GetTemplate(propTemplate.general.unitTpId, "Units")
            local unitPath = "Units/"..unitTemplate.general.tpId.."/LOD0/"..unitTemplate.general.tpId
            local unitSkeletonPath = unitPath..".sanskeleton"
            
            -- TODO: Currently only works for mapping hierarchies which are identical. 
            -- Identical hierarchies just map identical entities (sourceEntityName and destinationEntityName have the same name)
            if unitSkeletonPath == propTemplate.visuals.skeleton and unitTemplate.general.prefabID then

                -- Both unit and prop have identical hierarchies. So we only need one of them.
                local _, skeletonBones = Engine.GetSkeletonBones(propTemplate.visuals.skeleton)
                
                local prefabHierarchyMapTemplate = {}
                prefabHierarchyMapTemplate.sourcePrefabID = unitTemplate.general.prefabID
                prefabHierarchyMapTemplate.destinationPrefabID = propTemplate.general.prefabID
                prefabHierarchyMapTemplate.prefabHierarchyMap = {}

                for i, skeletonBone in ipairs(skeletonBones) do
                    prefabHierarchyMapTemplate.prefabHierarchyMap[i] = {
                        sourceEntityName = skeletonBone.boneName,
                        destinationEntityName = skeletonBone.boneName
                    }
                end

                Engine.CreateHierarchyMap(prefabHierarchyMapTemplate)
            else
                Warn("Unit: "..propTemplate.general.unitTpId.." has a different skeleton path than its wreck. Unit: "..propTemplate.visuals.skeleton.." Wreck: "..unitSkeletonPath..". We have not created a hierarchy map meaning we cannot call CopyHierarchy.")
            end

        end
    end
end

function ModUnitTemplate(tp)
    if SCOM_EditableUnits.IsEditable(tp) then
        assert(type(tp.ranges) == "table", "SCOM editable unit requires explicit range-ring data")
        return
    end
    --[[ -- Availabe range categories
        "DirectFire",
        "IndirectFire",
        "AntiAir",
        "AntiNaval",
        "Countermeasures",
        "Engineering",
        "Vision",
        "Radar",
        "Sonar",
    --]]
    local ranges = {}

    if tp.construction and tp.construction.range then
        ranges[RangeRingMaterial.Build] = { outerRadius = tp.construction.range, innerRadius = 0 }
    end

    if tp.intel then
        if tp.intel.visionRadius then
            ranges[RangeRingMaterial.Vision] = { outerRadius = tp.intel.visionRadius, innerRadius = 0 }
            ranges[RangeRingMaterial.FogOfWar] = { outerRadius = tp.intel.visionRadius, innerRadius = 0 }
        end
        if tp.intel.radarRadius then
            ranges[RangeRingMaterial.IntelRadar] = { outerRadius = tp.intel.radarRadius, innerRadius = 0 }
        end
        if tp.intel.sonarRadius then
            ranges[RangeRingMaterial.IntelSonar] = { outerRadius = tp.intel.sonarRadius, innerRadius = 0 }
        end
    end

    if tp.weapons then
        -- Go over the weapons and find out what range catogory they are and the longest range from that category.
        for i, weapon in pairs(tp.weapons) do
            if weapon.rangeRingType and weapon.rangeMax then
                local material = RangeRingMaterials.GetRangeRingMaterialByType(weapon.rangeRingType)
                local currentRange = ranges[material]
                -- SCOM Field Fix: longest range ring per material 1.0.0
                if not currentRange or weapon.rangeMax > currentRange.outerRadius then
                    ranges[material] = { outerRadius = weapon.rangeMax, innerRadius = weapon.rangeMin }
                end
            else
                Warn("TemplateLoader: Unit: "..(tp.general and tp.general.name or "UNKNOWN NAME").." ID: "..(tp.general and tp.general.tpId or "UNKNOWN ID").." is missing rangeRingType or rangeMax field in turret: "..i)
            end
        end
    end

    tp.ranges = ranges
end

local function GetControlTemplate(tpType)
    if not DefaultTemplates[tpType] then
        Warn("GetControlTemplate: unknown template type: "..tpType)
        return {}
    end

    return DefaultTemplates[tpType]
end

-- Converts an array-based tag table into a set-style lookup table.
-- Example: {"ENGINEER"} -> {ENGINEER = true}
function CreateHasTagTable(tags)
    local hasTag = {}
    for index, tagName in ipairs(tags) do
        hasTag[tagName] = true
    end
    return hasTag
end

function VerifyTemplate(template, tpType)
    local controlTemp = GetControlTemplate(tpType)

    local function scanTemplate(control, template)
        for k, v in pairs(control) do
            if not template[k] then
                return false, k
            end
            if type(v) == "table" then
                local result, missingField = scanTemplate(control[k], template[k])
                if not result then
                    return result, k.."."..missingField
                end
            end
        end
        return true
    end

    local result, missingField = scanTemplate(controlTemp, template)
    if not result then
        Warn("Template: "..((template.general and template.general.tpId) or "UNKNOWN ID").." is missing field: "..missingField)
    end
    return result
end

function ReloadTemplate(filePath)
    Log("Reloading template: " .. filePath)

    --local tpId = string.match(filePath, ".*/(.*)%.")
    local file = Import(filePath)

    -- TODO: Hotreloading need to be reimplemented with the new templates system.
    -- For this to work we register the new prefab with the engine and override the old prefabID and engineId of the template with the new prefabID.
    -- We also must update the __PrefabIDs global table.
    -- Once that is done, everything should work as before.

    -- if file.ProjectileTempalte then
    --     local tp = file.ProjectileTempalte
    --     ReadProjectileTemplate(tp, tp.general.tpId)

    --     LoadProjectileTemplates({tp}, 1)
    -- elseif file.UnitTemplate then
    --     local tp = file.UnitTemplate
    --     ReadUnitTemplate(tp, tp.general.tpId)

    --     LoadUnitTemplates({tp}, 1)
    -- elseif file.PropTemplate then
    --     local tp = file.PropTemplate
    --     ReadPropTemplate(tp, tp.general.tpId)

    --     LoadPropTemplates({tp}, 1)
    -- end
end

function LoadProjectileEffects()
    for _, tp in pairs(Templates.Projectiles) do
        
        if IsClient then
            for _, impactEffect in pairs(tp.visuals.onImpactEffects or {}) do
                for _, effect in pairs(impactEffect.effects or {}) do
                    LoadEffect(effect.particleName)
                end
            end
            for _, impactEffect in pairs(tp.visuals.onWaterImpactEffects or {}) do
                for _, effect in pairs(impactEffect.effects or {}) do
                    LoadEffect(effect.particleName)
                end
            end
            for _, impactEffect in pairs(tp.visuals.persistantEffects or {}) do
                for _, effect in pairs(impactEffect.effects or {}) do
                    LoadEffect(effect.particleName)
                end
            end
        end
    end
end

function LoadUnitEffects(templates)
    for _, tp in pairs(templates) do

        if IsClient then
            local data = tp.visuals and tp.visuals.effectsInstant and tp.visuals.effectsInstant.onDeath or {}
            for _, effect in pairs(data) do
                LoadEffect(effect.particleName)
            end
            
            for _, persistentEffect in pairs(tp.visuals.effectsPersistent or {}) do
                LoadEffect(persistentEffect.particleName)
            end

            for _, persistentEffect in pairs(tp.visuals.effectsWhenActive or {}) do
                LoadEffect(persistentEffect.particleName)
            end
            
            local shieldTps = tp.defence and tp.defence.shields
            for _, shieldTp in ipairs(shieldTps or {}) do
                for _, persistentEffect in pairs(shieldTp.effectsPersistent or {}) do
                    LoadEffect(persistentEffect.particleName)
                end
            end
            
            if tp.weapons then
                for _, weaponTemplate in ipairs(tp.weapons) do
                    if weaponTemplate.effects then
                        for _, effect in pairs(weaponTemplate.effects) do
                            LoadEffect(effect)
                        end
                    end
                end
            end
        end
    end
end

function LoadHardcodedVfx()
    local effects = {
        "VFX/Death/vxd2321_death_building_large_smoke.sanvfx", -- used by unit base class
        "VFX/Death/vxd1321_death_unit_large_smoke.sanvfx", -- used by unit base class
        "VFX/Death/vcd0301_death_rdu.sanvfx", -- used by nukeathome on perftest scenario
        "VFX/Unit/vcu8301_dash_charge_up.sanvfx", -- chosen commander dash effect.
        "VFX/Unit/vcu8302_dash_start.sanvfx",  -- chosen commander dash effect.
        "VFX/Unit/vcu8303_dash_end.sanvfx",  -- chosen commander dash effect.
        "VFX/Impact/vci0101_chosen_experimental_impact_small.sanvfx",
        "VFX/Impact/vci0201_chosen_experimental_impact_medium.sanvfx",
        "VFX/Impact/vci0301_chosen_experimental_impact_large.sanvfx",
        "VFX/Impact/vci0401_chosen_experimental_impact_huge.sanvfx",
        "VFX/Impact/vci0501_chosen_experimental_impact_extreme.sanvfx"
    }

    if IsClient then
        for _, particleName in pairs(effects) do
            LoadEffect(particleName)
        end

        for _, faction in ipairs(ShieldImpactEffects) do
            for _, path in ipairs(faction.paths) do
                LoadEffect(path)
            end
        end
    end
end

function LoadEffect(effectName)
    Engine.LoadEffect(effectName)
end
-- SCOM typed effect preload 2.1.88.5
do
    local previousLoadUnitEffects = LoadUnitEffects
    local previousLoadEffect = LoadEffect
    assert(type(previousLoadUnitEffects) == "function" and type(previousLoadEffect) == "function",
        "SCOM typed effect preload: native loader functions are unavailable")

    local function copy(value)
        local result = {}
        for key, item in pairs(value) do result[key] = item end
        return result
    end
    local function requirePath(value, context)
        if type(value) ~= "string" or #value == 0 or string.find(value, "\0", 1, true) then
            error("SCOM effect asset must be a nonempty string at " .. context .. "; received " .. type(value), 0)
        end
        return value
    end
    local function scalarDescriptor(value, context)
        if type(value) == "string" then return requirePath(value, context) end
        if type(value) ~= "table" then return requirePath(value, context) end
        -- Only lossless single-path wrappers are convertible. Multiple effects,
        -- transform descriptors and arbitrary tables are not silently discarded.
        local key, path = next(value)
        if key ~= nil and next(value, key) == nil
            and (key == 1 or key == "particleName" or key == "path") then
            return requirePath(path, context .. "." .. tostring(key))
        end
        error("SCOM unsupported effect descriptor at " .. context .. "; an actual asset path is required", 0)
    end

    LoadEffect = function(path)
        return previousLoadEffect(requirePath(path, "LoadEffect"))
    end

    LoadUnitEffects = function(templates)
        assert(type(templates) == "table", "SCOM effect preload requires a template table")
        local views, pending = {}, {}
        for id, tp in pairs(templates) do
            assert(type(tp) == "table", "SCOM effect preload found a non-table template: " .. tostring(id))
            local unitId = tp.general and tp.general.tpId or tostring(id)
            local view = copy(tp)
            if tp.weapons ~= nil then
                assert(type(tp.weapons) == "table", "SCOM invalid weapons table: " .. unitId)
                local weapons = {}
                for index, weapon in ipairs(tp.weapons) do
                    assert(type(weapon) == "table", "SCOM invalid weapon: " .. unitId .. ":" .. index)
                    local weaponView = copy(weapon)
                    if weapon.effects ~= nil then
                        assert(type(weapon.effects) == "table", "SCOM invalid weapon effects: " .. unitId .. ":" .. index)
                        local effectView, actualEffects = {}, nil
                        for key, value in pairs(weapon.effects) do
                            local context = unitId .. ".weapons[" .. index .. "].effects." .. tostring(key)
                            local runtimeId = type(key) == "string" and string.sub(key, -8) == "PrefabID"
                            local event = type(key) == "string" and string.sub(key, 1, 2) == "on"
                            if runtimeId then
                                -- GetOrCreateVFXPrefab writes LocalID handles into this
                                -- same dictionary. These are never resource filenames.
                            elseif type(value) == "string" then
                                effectView[key] = requirePath(value, context)
                            elseif event and value ~= false then
                                local path = scalarDescriptor(value, context)
                                effectView[key] = path
                                actualEffects = actualEffects or copy(weapon.effects)
                                actualEffects[key] = path
                            elseif event or type(value) == "table" or type(value) == "number"
                                or type(value) == "boolean" or type(value) == "cdata" then
                                -- Disabled events and non-event source metadata stay on
                                -- the real template, but do not cross the UTF-8 FFI API.
                            else
                                error("SCOM unsupported effect field at " .. context .. ": " .. type(value), 0)
                            end
                        end
                        if actualEffects then
                            pending[#pending + 1] = { weapon = weapon, effects = actualEffects }
                        end
                        weaponView.effects = effectView
                    end
                    weapons[index] = weaponView
                end
                view.weapons = weapons
            end
            -- Validate the native visual paths with a precise unit/slot context.
            local visuals = tp.visuals or {}
            local deaths = visuals.effectsInstant and visuals.effectsInstant.onDeath or {}
            for index, effect in pairs(deaths) do
                requirePath(type(effect) == "table" and effect.particleName,
                    unitId .. ".visuals.effectsInstant.onDeath[" .. tostring(index) .. "]")
            end
            for _, slot in ipairs({ "effectsPersistent", "effectsWhenActive" }) do
                for index, effect in pairs(visuals[slot] or {}) do
                    requirePath(type(effect) == "table" and effect.particleName,
                        unitId .. ".visuals." .. slot .. "[" .. tostring(index) .. "]")
                end
            end
            views[id] = view
        end
        -- Keep the native traversal and all its additional preload behavior.
        -- Commit lossless event unwrapping only after every input was validated
        -- and the native preload succeeded. Do not swallow native load failures.
        local result = previousLoadUnitEffects(views)
        for _, update in ipairs(pending) do update.weapon.effects = update.effects end
        return result
    end
end
