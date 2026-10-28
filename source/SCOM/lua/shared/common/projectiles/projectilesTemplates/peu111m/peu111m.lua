---@type ProjectileTemplate
ProjectileTemplate = {
    audio = { onImpact = { looping = false, name = "aeoi5221" } },
    collisionInfo = { centerOffset = { x = 0, y = 0.5, z = 0 }, collisionSize = { x = 2, y = 2, z = 2 } },
    general = { icon = "projectile", name = "UEF_TIFMissileCruise03", tpId = "peu111m" },
    movement = {
        acceleration = 3, alignToVelocity = true, gravityMultiplier = 0,
        rotationSpeed = 12, speedMax = 12, type = "TargetEntity",
    },
    nonUniformScale = { x = 0.2, y = 0.2, z = 0.2 },
    source = {
        blueprint = "projectiles/TIFMissileCruise03/TIFMissileCruise03_proj.bp",
        blueprintSha256 = "1d66eea3f9a50a802fc2ae554f067738495da05e69d1828ab2e98fe0a421be7c",
        script = "projectiles/TIFMissileCruise03/TIFMissileCruise03_script.lua",
        scriptSha256 = "84c74a8e345bcf4d053e4bff0f29f491110b2cc806c9473bd218239e37b09e08",
        distanceBasedTurnRateSupported = false,
    },
    visuals = {
        mesh = { lod0distance = 150 },
        onImpactEffects = { { effects = { { particleName = "VFX/Impact/vei2101_rocket_antitank_small_impact.sanvfx" } } } },
        persistantEffects = { { effects = { { particleName = "VFX/Trails/vet2101_rocket_antitank_small_trail.sanvfx" } } } },
    },
}

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
