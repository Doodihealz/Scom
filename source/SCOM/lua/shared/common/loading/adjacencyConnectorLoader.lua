local adjacencyConnectorMaterials = {
    EDA = {
        Small  = "VFX/Materials/Adjacency/effect_adjacency_guard_small01.sanmaterial",
        Medium = "VFX/Materials/Adjacency/effect_adjacency_guard_medium01.sanmaterial",
    },
    CHOSEN = {
        Small  = "VFX/Materials/Adjacency/effect_adjacency_chosen_small01.sanmaterial",
    },
    GUARD = {
        Small  = "VFX/Materials/Adjacency/effect_adjacency_eda_small01.sanmaterial",
        Medium = "VFX/Materials/Adjacency/effect_adjacency_eda_medium01.sanmaterial",
    },
}

local defaultMaterial = "VFX/Materials/Adjacency/effect_adjacency_eda_small01.sanmaterial"

-- Faction: EDA, CHOSEN or GUARD. Size: Small or Medimum. Chosen faction only has Small.
function CreateAdjacencyConnectorPrefab(faction, size)
    
    local materialPath = adjacencyConnectorMaterials[faction] and adjacencyConnectorMaterials[faction][size]
    if materialPath == nil then 
        Engine.Error("AdjacencyLoader: Faction: "..faction.." Size: "..size.." was not a valid connector. Connector will use default connector material.")
        materialPath = defaultMaterial
    end

    local headEntityTemplate = EngineClasses.EntityTemplate(TemplateHeadEntityName,
        nil,
        EngineClasses.float3(0, 0, 0),
        2.6,
        GetIdentityQuaternion(),
        false
    )

    local meshTemplate = EngineClasses.MeshTemplate(TemplateHeadEntityName,
        "VFX/Models/Static/PlanePathSanc.sanmodel",
        materialPath,
        EngineClasses.float3(1, 1, 1),
        ShadowCastingMode.Off,
        EngineClasses.float4(),
        EngineClasses.float4(),
        false
    )
    
    local prefabTemplate = EngineClasses.PrefabTemplate("AdjacencyConnector_"..faction.."_"..size,
        EngineClasses.HierarchyTemplate({ headEntityTemplate }),
        EngineClasses.GlobalTemplate(),
        EngineClasses.LocalTemplate({ meshTemplate })
    )
    
    local prefabID = {}
    Engine.CreatePrefab(prefabTemplate, prefabID)
    return prefabID
end

-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0
-- Reuse the existing Chosen connector material until a dedicated Seraphim
-- connector asset is authored.  This avoids the loader's default/invalid path.
adjacencyConnectorMaterials.SERAPHIM = adjacencyConnectorMaterials.CHOSEN