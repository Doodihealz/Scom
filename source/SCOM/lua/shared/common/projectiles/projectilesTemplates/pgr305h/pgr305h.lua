---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = { icon = "projectile", name = "Cybran_Brick_Heavy_Disintegrator", tpId = "pgr305h" },
    movement = { gravityMultiplier = 0 },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = { { effects = { { particleName = "VFX/Impact/vgi1141_cannon_artillery_small_impact.sanvfx" } } } },
        persistantEffects = { { effects = { { particleName = "VFX/Trails/vgt1141_cannon_artillery_small_trail.sanvfx" } } } },
    },
}

-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CDFHeavyDisintegratorPulseLaser01
-- Source blueprint: projectiles/CDFHeavyDisintegratorPulseLaser01/CDFHeavyDisintegratorPulseLaser01_proj.bp
-- Source blueprint SHA-256: 0e09b2070b5db8c5c788955fd03160bd412edfa5859698bb9217537da0fa6be5
-- Source script: projectiles/CDFHeavyDisintegratorPulseLaser01/CDFHeavyDisintegratorPulseLaser01_script.lua
-- Source script SHA-256: 7f9e35d410923aa832bec62bee46e37b7abafc70cdedad52dad8646b3c31dccd
-- Source physics profile: NoGravity
-- Limitation: FA emitter graphs and DestroyOnWater/StayUnderwater flags are not native sanvfx/template inputs.
-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0