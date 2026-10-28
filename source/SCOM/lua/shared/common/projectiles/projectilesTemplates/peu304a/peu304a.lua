---@type ProjectileTemplate
ProjectileTemplate = {
    audio = { onImpact = { looping = false, name = "aeoi3230" } },
    collisionInfo = { centerOffset = { x = 0, y = 0.5, z = 0 }, collisionSize = { x = 1, y = 1, z = 1 } },
    general = { icon = "projectile", name = "UEF_TIFAntiMatterShells02", tpId = "peu304a" },
    nonUniformScale = { x = 0.4, y = 0.4, z = 0.4 },
    source = {
        blueprint = "projectiles/TIFAntiMatterShells02/TIFAntiMatterShells02_proj.bp",
        blueprintSha256 = "f5adce36cb2944fa5ba10028e1ae35884bd2104fb0460b973b8267442bc2f28f",
        script = "projectiles/TIFAntiMatterShells02/TIFAntiMatterShells02_script.lua",
        scriptSha256 = "9b7daf5fed064d7cfbad58dae44aa7f7173d5101d9db26e3bfba5eb1496c8c7c",
    },
    visuals = {
        mesh = { lod0distance = 150 },
        onImpactEffects = { { effects = { { particleName = "VFX/Impact/vei2241_rocket_artillery_medium_impact.sanvfx" } } } },
        persistantEffects = { { effects = { { particleName = "VFX/Trails/vet2241_rocket_artillery_medium_trail.sanvfx" } } } },
    },
}

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
