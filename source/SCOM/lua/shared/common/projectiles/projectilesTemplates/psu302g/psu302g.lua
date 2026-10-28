-- SCOM Sea Parity 1.0.0: dedicated Summit projectile psu302g
-- source-blueprint-path=projectiles/TDFGauss03/TDFGauss03_proj.bp
-- source-blueprint-sha256=070115A33AC8C75EA6BB6E3E649E02B9BC784DE222051C2E7F63ADE00006A2E4
-- source-script-path=projectiles/TDFGauss03/TDFGauss03_script.lua
-- source-script-sha256=4A4C3035DC78DF3DFEF9C6D9108D73473A7886F9779AAEFF99FA166DDBCDE336
-- Sanctuary renders projectiles through compatibility VFX; no FA mesh is claimed.
---@type ProjectileTemplate
ProjectileTemplate = {
    audio = {
        onImpact = {
            looping = false,
            name = "aeoi3232",
        },
    },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        name = "Summit TDFGauss03 Compatibility Shell",
        tpId = "psu302g",
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            {
                effects = {
                    {
                        audioName = "eda_projectile_impact_cannon_small",
                        particleName = "VFX/Impact/vei1301_cannon_large_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Trails/vet1301_cannon_large_trail.sanvfx",
                    },
                },
            },
        },
    },
}
