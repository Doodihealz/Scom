local HierarchyTemplateLoader = Import("common/loading/hierarchyTemplateLoader.lua")
local prefabCache = {}

-- These client graphs are routed after the startup effect preload.
local aeonExplosionPaths = {
    ["VFX/SCOM/AeonExplosions/vcd0301_death_rdu.sanvfx"] = true,
    ["VFX/SCOM/AeonExplosions/vcd1101_death_land_small.sanvfx"] = true,
    ["VFX/SCOM/AeonExplosions/vcd2101_death_building_small.sanvfx"] = true,
    ["VFX/SCOM/AeonExplosions/vcd2201_death_building_medium.sanvfx"] = true,
    ["VFX/SCOM/AeonExplosions/vcd2301_death_building_large.sanvfx"] = true,
    ["VFX/SCOM/AeonExplosions/vcd3101_death_air_small.sanvfx"] = true,
    ["VFX/SCOM/AeonExplosions/vcd3301_death_air_large.sanvfx"] = true,
    ["VFX/SCOM/AeonExplosions/vcd7101_explosion_secondary_small.sanvfx"] = true,
    ["VFX/SCOM/AeonExplosions/vcd7301_explosion_secondary_large.sanvfx"] = true,
}

--- Create a prefab that plays the vfx at the given path
function GetOrCreateVFXPrefab(vfxPath)
    if prefabCache[vfxPath] ~= nil then
        return prefabCache[vfxPath]
    end

    if IsClient and aeonExplosionPaths[vfxPath] then
        assert(Engine.LoadEffect(vfxPath) == true,
            "SCOM Aeon explosion effect failed to load: " .. vfxPath)
    end
    
    local particleTemplates = {
        EngineClasses.ParticleTemplate(TemplateHeadEntityName,
            vfxPath,
            vfxPath ~= 'VFX/SCOM/Source/psf0136/impact.sanvfx',
            true
        )
    }

    local prefabTemplate = EngineClasses.PrefabTemplate(vfxPath,
        EngineClasses.HierarchyTemplate(HierarchyTemplateLoader.GetHierarchyEntities(nil)),
        EngineClasses.GlobalTemplate(),
        EngineClasses.LocalTemplate(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, particleTemplates)
    )

    local _, effectPrefabID = Engine.CreatePrefab(prefabTemplate)
    prefabCache[vfxPath] = effectPrefabID
    return effectPrefabID
end