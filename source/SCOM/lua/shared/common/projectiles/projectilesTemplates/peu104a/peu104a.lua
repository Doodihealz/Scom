---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = { centerOffset = { x = 0, y = 0.5, z = 0 }, collisionSize = { x = 1, y = 1, z = 1 } },
    general = { icon = "projectile", name = "UEF_TAARailgun01", tpId = "peu104a" },
    nonUniformScale = { x = 0.1, y = 0.1, z = 0.1 },
    source = {
        blueprint = "projectiles/TAARailgun01/TAARailgun01_proj.bp",
        blueprintSha256 = "27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f",
        script = "projectiles/TAARailgun01/TAARailgun01_script.lua",
        scriptSha256 = "36c2417368fb105b30325e2ee1fa1f63f51c79ddf18e0fece8842108333cd92e",
    },
    visuals = {
        mesh = { lod0distance = 100 },
        onImpactEffects = { { effects = { { particleName = "VFX/Impact/vei1121_autocannon_small_impact.sanvfx" } } } },
        persistantEffects = { { effects = { { particleName = "VFX/Trails/vet1121_autocannon_small_trail.sanvfx" } } } },
    },
}

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
