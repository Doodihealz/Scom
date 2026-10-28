---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaArtillery = {
            version = "1.0.0",
            sourceId = "TIFArtillery01",
            sourceArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            sourceBlueprintSha256 = "e78a6412e9e5ba16c9434a801189561f5b0be6a7da8cfd23b99e846ff5948e30",
            destroyOnWater = true,
            sourceForcePulseCount = 0,
            sourceUniformScale = 0.3,
        },
    },
    audio = {
        onImpact = { looping = false, name = "agoi1130" },
    },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = { name = "UEF_APDS_Artillery", tpId = "psk201" },
    nonUniformScale = { x = 0.3, y = 0.3, z = 0.3 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = {
                { particleName = "VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx" },
            } },
        },
        persistantEffects = {
            { effects = {
                { particleName = "VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx" },
            } },
        },
    },
}
