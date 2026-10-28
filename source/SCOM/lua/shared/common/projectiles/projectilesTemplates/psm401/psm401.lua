---@type ProjectileTemplate
ProjectileTemplate = {
    additions = {
        scoFaArtillery = {
            version = "1.0.0",
            sourceId = "TIFHETacticalNuclearShell01",
            sourceArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            sourceBlueprintSha256 = "9b03d8d92f76cfcf9472cc01aa74c4e4e3edacc33177b27aaeeab39bffbcc3be",
            destroyOnWater = true,
            sourceForcePulseCount = 2,
            sourceForcePulseDamage = 1,
            sourceForcePulseRadius = 7,
            sourceForcePulseFriendly = true,
            sourceUniformScale = 1,
        },
    },
    audio = {
        onImpact = { looping = false, name = "aeoi3232" },
    },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = { name = "UEF_Anti_Matter_Artillery", tpId = "psm401" },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = {
                { particleName = "VFX/Impact/vei1301_cannon_large_impact.sanvfx" },
            } },
        },
        persistantEffects = {
            { effects = {
                { particleName = "VFX/Trails/vet1301_cannon_large_trail.sanvfx" },
            } },
        },
    },
}
