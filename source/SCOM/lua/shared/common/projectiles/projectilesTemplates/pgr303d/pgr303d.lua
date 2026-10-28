---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = { icon = "projectile", name = "Cybran_Loyalist_Disintegrator", tpId = "pgr303d" },
    nonUniformScale = { x = 0.7, y = 0.7, z = 0.7 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = { { effects = { { particleName = "VFX/Impact/vgi1101_cannon_small_impact.sanvfx" } } } },
        persistantEffects = { { effects = { { particleName = "VFX/Trails/vgt1101_cannon_small_trail.sanvfx" } } } },
    },
}

-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CDFLaserDisintegrator02
-- Source blueprint: projectiles/CDFLaserDisintegrator02/CDFLaserDisintegrator02_proj.bp
-- Source blueprint SHA-256: 67f49f2d714889a4a98af6bb6bac6a239ab9886f83801568f8bba4ff18702ed9
-- Source script: projectiles/CDFLaserDisintegrator02/CDFLaserDisintegrator02_script.lua
-- Source script SHA-256: 6dfe124794f944872bb8588d4fd3a0690d2ac2fbf8d76d34fbf40a72ae138bc4
-- Source physics profile: Gravity
-- Limitation: FA emitter graphs and DestroyOnWater/StayUnderwater flags are not native sanvfx/template inputs.
-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0