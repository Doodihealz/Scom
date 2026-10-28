---@type ProjectileTemplate
-- Supreme Commander Overhaul FA Cybran Megalith Physical Port 1.0.1
-- Dedicated compatibility projectile; gameplay damage remains unit-weapon owned.
ProjectileTemplate = {
    additions = {
        faSourceContract = {
            sourceId = "CDFProtonCannon05",
            targetId = "pmg401",
            sourceArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            sourceBlueprint = "projectiles/CDFProtonCannon05/CDFProtonCannon05_proj.bp",
            sourceBlueprintSha256 = "0959ce9c2e49b07c5bd967009b564e1cab22cc47e18ffa8498d2ec409b408395",
            sourceScript = "projectiles/CDFProtonCannon05/CDFProtonCannon05_script.lua",
            sourceScriptSha256 = "eeaaa007d3c592abd2df8b487667cc889779e66bde45d98e7e0cd4138eddf8e2",
            limitation = "FA proton camera shake and emitter graph are visual-only and unsupported; DestroyOnWater has no public transition field.",
        },
    },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.25, z = 0 },
        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },
    },
    general = { icon = "projectile", name = "Megalith_Proton_Cannon", tpId = "pmg401" },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1281_cannon_plasma_medium_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1281_cannon_plasma_medium_trail.sanvfx" } } },
        },
    },
}
