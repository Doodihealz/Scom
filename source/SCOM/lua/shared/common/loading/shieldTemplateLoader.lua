--- Create a new shield entity in the hierarchy. Creates the templates required to render the shield -- nothing else.
function CreateShieldEntity(tp, shield, shieldEntityName, hierarchyEntities, meshTemplates, cullingTemplates)
    -- New entity for the shield.
    table.insert(hierarchyEntities, EngineClasses.EntityTemplate(shieldEntityName,
        shield.boneName,
        EngineClasses.float3(shield.offset.x or 0, shield.offset.y or 0, shield.offset.z or 0),
        1.0,
        GetIdentityQuaternion(),
        false
    ))

    -- Culling for the shield.
    table.insert(cullingTemplates, EngineClasses.CullingTemplate(shieldEntityName,
        math.max(shield.radii.x, shield.radii.y, shield.radii.z)
    ))

    -- Mesh for the shield
    local shieldMaterialPath
    if table.find(tp.tags, "EDA") then
        shieldMaterialPath = "VFX/SCOM/FieldFixes/Shields/uef_forcefield.sanmaterial"
    elseif table.find(tp.tags, "CHOSEN") then
        shieldMaterialPath = "VFX/SCOM/FieldFixes/Shields/aeon_forcefield.sanmaterial"
    elseif table.find(tp.tags, "SERAPHIM") then
        shieldMaterialPath = "VFX/SCOM/FieldFixes/Shields/seraphim_forcefield.sanmaterial"
    elseif table.find(tp.tags, "GUARD") then
        shieldMaterialPath = "VFX/SCOM/FieldFixes/Shields/cybran_forcefield.sanmaterial"
    else
        Engine.Error("UnitTemplate:"..tp.general.tpId.." did not have a faction tag. Shields materials will use the default EDA material.")
        shieldMaterialPath = "VFX/SCOM/FieldFixes/Shields/uef_forcefield.sanmaterial"
    end

    table.insert(meshTemplates, EngineClasses.MeshTemplate(shieldEntityName,
        "VFX/Shields/Models/Sphere_hipol.sanmodel",
        shieldMaterialPath,
        EngineClasses.float3(shield.radii.x, shield.radii.y, shield.radii.z),
        ShadowCastingMode.Off,
        EngineClasses.float4(),
        EngineClasses.float4(),
        true
    ))

    -- New entity for the glow around the shield. This entity is parented to the shield entity.
    local shieldGlowEntityName = shieldEntityName.."_Glow"

    table.insert(hierarchyEntities, EngineClasses.EntityTemplate(shieldGlowEntityName,
        shieldEntityName,
        EngineClasses.float3(0, 0, 0),
        1.0,
        GetIdentityQuaternion(),
        false
    ))

     -- Culling for the glow.
    table.insert(cullingTemplates, EngineClasses.CullingTemplate(shieldGlowEntityName,
        math.max(shield.radii.x, shield.radii.y, shield.radii.z)
    ))

    -- Mesh for the glow
    local glowMaterialPath
    if table.find(tp.tags, "EDA") then
        glowMaterialPath = "VFX/SCOM/FieldFixes/Shields/uef_edge.sanmaterial"
    elseif table.find(tp.tags, "CHOSEN") then
        glowMaterialPath = "VFX/SCOM/FieldFixes/Shields/aeon_edge.sanmaterial"
    elseif table.find(tp.tags, "SERAPHIM") then
        glowMaterialPath = "VFX/SCOM/FieldFixes/Shields/seraphim_edge.sanmaterial"
    elseif table.find(tp.tags, "GUARD") then
        glowMaterialPath = "VFX/SCOM/FieldFixes/Shields/cybran_edge.sanmaterial"
    else
        Engine.Error("UnitTemplate:"..tp.general.tpId.."did did not have a faction tag. Shields materials will use default EDA material.")
        glowMaterialPath = "VFX/SCOM/FieldFixes/Shields/uef_edge.sanmaterial"
    end

    table.insert(meshTemplates, EngineClasses.MeshTemplate(shieldGlowEntityName,
        "VFX/Shields/Models/Sphere_hipol.sanmodel",
        glowMaterialPath,
        EngineClasses.float3(shield.radii.x, shield.radii.y, shield.radii.z),
        ShadowCastingMode.Off,
        EngineClasses.float4(),
        EngineClasses.float4(),
        true
    ))
end

-- Supreme Commander Overhaul true fourth Seraphim faction 2.0.0
-- SCOM faction shield palettes 1.0.0
