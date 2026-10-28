---@type ProjectileTemplate
ProjectileTemplate = {
    audio = { onImpact = { looping = false, name = "aeoi1110" } },
    collisionInfo = { centerOffset = { x = 0, y = 0.5, z = 0 }, collisionSize = { x = 1, y = 1, z = 1 } },
    general = { icon = "projectile", name = "UEF_TDFGauss01", tpId = "peu201g" },
    nonUniformScale = { x = 0.2, y = 0.2, z = 0.2 },
    source = {
        blueprint = "projectiles/TDFGauss01/TDFGauss01_proj.bp",
        blueprintSha256 = "7b4cf765e643ae78c849338be82943eaba000aa10d03565dcd717182aed63460",
        script = "projectiles/TDFGauss01/TDFGauss01_script.lua",
        scriptSha256 = "c86e59eee38b6a52d483617e59ab14d08eb51d84dbdbcb61b3be2d1b55e7b1b7",
        destroyOnWaterDelaySupported = false,
    },
    visuals = {
        mesh = { lod0distance = 120 },
        onImpactEffects = { { effects = { { particleName = "VFX/Impact/vei1101_cannon_small_impact.sanvfx" } } } },
        persistantEffects = { { effects = { { particleName = "VFX/Trails/vet1101_cannon_small_trail.sanvfx" } } } },
    },
}

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
