local HierarchyTemplateLoader = Import("common/loading/hierarchyTemplateLoader.lua") 
local PlacementLayer = Import("common/layers.lua").PlacementLayer
local CollisionLayer = Import("common/layers.lua").CollisionLayer
local IconTypes = Import("client/entities/icon.lua").iconTypes

local PlacementGhostIconHeightCutoff = 100

--- Creates the prefab of one placement grid tile, which the construction preview instantiates for each skirt cell
---@param state string The tile state, which picks the material: "On", "Off" or "Neutral"
---@return PrefabID prefabID
function CreatePlacementGridTilePrefab(state)
    local meshPath = "VFX/Models/Static/Quad Up.sanmodel"

    local errorCode, meshBoundsCenter, meshBoundsSize = Engine.GetMeshBounds(meshPath)
    local cullingRadius = 10
    if errorCode == EngineErrorCode.Success then
        local maximumDistanceX = math.abs(meshBoundsCenter.x) + meshBoundsSize.x * 0.5
        local maximumDistanceY = math.abs(meshBoundsCenter.y) + meshBoundsSize.y * 0.5
        local maximumDistanceZ = math.abs(meshBoundsCenter.z) + meshBoundsSize.z * 0.5
        cullingRadius = math.sqrt(maximumDistanceX^2 + maximumDistanceY^2 + maximumDistanceZ^2)
    end

    local headEntity = EngineClasses.EntityTemplate(TemplateHeadEntityName,
        nil,
        EngineClasses.float3(0, 0, 0),
        1.0,
        GetIdentityQuaternion(),
        false
    )

    local meshTemplate = EngineClasses.MeshTemplate(TemplateHeadEntityName,
        meshPath,
        "VFX/Buildability/Materials/bGrid_"..state..".sanmaterial",
        EngineClasses.float3(1, 1, 1),
        ShadowCastingMode.Off,
        EngineClasses.float4(),
        EngineClasses.float4(),
        false
    )

    local prefabTemplate = EngineClasses.PrefabTemplate("PlacementGridTile"..state,
        EngineClasses.HierarchyTemplate({ headEntity }),
        EngineClasses.GlobalTemplate(),
        EngineClasses.LocalTemplate({ meshTemplate }, nil, nil, nil, nil, { EngineClasses.CullingTemplate(TemplateHeadEntityName, cullingRadius) })
    )

    local _, prefabID = Engine.CreatePrefab(prefabTemplate)
    return prefabID
end

--- Converts loaded unit template to a placement ghost prefab and registers it with the engine.
-- @param the unit template
function CreatePlacementGhostPrefab(tp)
    
    local meshTemplates = {}
    local localGridModifierTemplates = {}
    local globalGridModifierTemplates = {}
    local skinnedMeshTemplates = {}
    local skinnedMeshBoneTemplates = {}
    local localVolumeColliderTemplates = {}
    local iconsTemplates = {}
    local rangeRingsTemplates = {}

    -- Looks like: "Units/tpId/LOD0/tpId"
    local unitPath = "Units/"..tp.general.tpId.."/LOD0/"..tp.general.tpId

    local skeletonPath = unitPath..".sanskeleton"
    local meshPath = unitPath.."_lod0.sanmodel"
    local materialPath = unitPath.."_lod0.sanmaterial"

    local _, skeletonBones = Engine.GetSkeletonBones(skeletonPath)

    local hierarchyEntities = HierarchyTemplateLoader.GetHierarchyEntities(skeletonBones)
    
    if tp.visuals.selection ~= nil then
        -- Make selection box 30% bigger than selection brackets
        local x = math.round(tp.visuals.selection.size.x * 1.3, 3)
        local y = tp.collisionInfo.collisionSize.y
        local z = math.round(tp.visuals.selection.size.y * 1.3, 3)
        local selectionOffset = tp.visuals.selection.offset or {}

        table.insert(localVolumeColliderTemplates, EngineClasses.VolumeColliderTemplate(TemplateHeadEntityName,
            EngineClasses.float3(x, y, z),
            EngineClasses.float3(selectionOffset.x or 0, selectionOffset.y or 0, selectionOffset.z or 0),
            ColliderType.Box,
            CollisionWorld.Selection,
            CollisionLayer.PlacementGhost,
            CollisionLayer.None,
            ColliderFlags.EventsDisabled
        ))
    end

    local selectionSize
    if tp.visuals and tp.visuals.selection then
        selectionSize = tp.visuals.selection.size
    else
        Warn("Missing selection info in template.")
        selectionSize = tp.skirtSize or tp.footprint
    end

    table.insert(hierarchyEntities, EngineClasses.EntityTemplate("Selection Bracket",
        TemplateHeadEntityName,
        EngineClasses.float3(0, 0, 0),
        1.0,
        GetIdentityQuaternion(),
        false
    ))

    table.insert(meshTemplates, EngineClasses.MeshTemplate("Selection Bracket",
        "VFX/Models/Static/Quad Up.sanmodel",
        "VFX/Objective Markers/Visual Marker_Unit Default_Flat_Brackets 08.sanmaterial",
        EngineClasses.float3(selectionSize.x or 0, 1, selectionSize.y or 0),
        ShadowCastingMode.Off,
        EngineClasses.float4(),
        EngineClasses.float4(),
        true
    ))



    -- Supreme Commander Overhaul sea parity 1.0.0
    -- Water-built mobiles need a placement-only grid; never persist a skirt on the unit template.
    local SCOSeaParityGhostPlacementSize = tp.skirtSize
    local SCOSeaParityGhostRequiresWater = tp.general
        and tp.general.requiresWaterPlacement == true
    if SCOSeaParityGhostPlacementSize == nil
        and SCOSeaParityGhostRequiresWater
    then
        SCOSeaParityGhostPlacementSize = tp.footprint
    end
    if SCOSeaParityGhostRequiresWater
        and SCOSeaParityGhostPlacementSize == nil
    then
        error("Water placement ghost has neither skirt nor footprint.")
    end
    if SCOSeaParityGhostPlacementSize then
        if _G.IsClient then
            table.insert(localGridModifierTemplates, EngineClasses.GridModifierTemplate(TemplateHeadEntityName,
                EngineClasses.int2(SCOSeaParityGhostPlacementSize.x, SCOSeaParityGhostPlacementSize.y),
                EngineClasses.int2(0, 0),
                _G.localBuildingPlacementGridID,
                PlacementLayer.Default,
                PlacementLayer.None,
                true
            ))
        else
            table.insert(globalGridModifierTemplates, EngineClasses.GridModifierTemplate(TemplateHeadEntityName,
                EngineClasses.int2(SCOSeaParityGhostPlacementSize.x, SCOSeaParityGhostPlacementSize.y),
                EngineClasses.int2(0, 0),
                _G.globalBuildingPlacementGridID,
                PlacementLayer.Default,
                PlacementLayer.None,
                true
            ))
        end
    end

    -- Create skinned mesh renderer for placement ghost.
    table.insert(skinnedMeshTemplates, EngineClasses.SkinnedMeshTemplate(TemplateHeadEntityName,
        skeletonPath,
        meshPath,
        materialPath,
        ShadowCastingMode.Off,
        EngineClasses.float4(1, 1, 1, 1),
        EngineClasses.float4(-1, 0, 0, 0),
        false
    ))

    -- Create skinned mesh bones to tell the skinned mesh renderer which entities in the hierarchy are bones for our skinned mesh
    -- Iterate over the bones of our mesh and add a SkinnedMeshBoneTemplate for each one of them.
    for i, skeletonBone in ipairs(skeletonBones) do
        table.insert(skinnedMeshBoneTemplates, EngineClasses.SkinnedMeshBoneTemplate(skeletonBone.boneName,
            skinnedMeshTemplates[1].entityName,
            i - 1
        ))
    end

    local icons = {}
    local iconTp = tp.general.icon
    
    if iconTp then
        local imageName = string.format("%s_%s_%s_normal", iconTp.shape, iconTp.tech, iconTp.symbol)
        table.insert(icons, EngineClasses.IconTemplate(imageName, nil, nil, nil, 0.25, PlacementGhostIconHeightCutoff, IconTypes.Unit, 0, true, nil, 1.0, true))
    end
    
    -- TODO: Use special unit sorting...
    table.insert(iconsTemplates, EngineClasses.IconsTemplate(TemplateHeadEntityName, icons, 1.0, 0, true))

    local rangeRings = {}
    if tp.ranges then
        local blacklist = {
            [RangeRingMaterial.FogOfWar] = true,
            [RangeRingMaterial.Vision] = true,
            [RangeRingMaterial.WaterVision] = true
        }
        for material, range in pairs(tp.ranges) do
            if not blacklist[material] then
                table.insert(rangeRings, EngineClasses.RangeRingTemplate(material + Constants.HighlightedRangeRingMaterialOffset, range.outerRadius, range.innerRadius))
            end
        end
    end

    table.insert(rangeRingsTemplates, EngineClasses.RangeRingsTemplate(TemplateHeadEntityName, rangeRings, false))
    

    local prefabTemplate = EngineClasses.PrefabTemplate(tp.general.tpId.."PlacementGhost",
        EngineClasses.HierarchyTemplate(hierarchyEntities),
        EngineClasses.GlobalTemplate(nil, nil, nil, nil, nil, nil, nil, globalGridModifierTemplates),
        EngineClasses.LocalTemplate(meshTemplates, skinnedMeshTemplates, skinnedMeshBoneTemplates, nil, nil, nil, nil, iconsTemplates, rangeRingsTemplates, nil, nil, nil, nil, localGridModifierTemplates, localVolumeColliderTemplates)
    )

    return Engine.CreatePrefab(prefabTemplate)
end
