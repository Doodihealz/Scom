---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = { centerOffset = { x = 0, y = 0.5, z = 0 }, collisionSize = { x = 1, y = 1, z = 1 } },
    general = { icon = "projectile", name = "UEF_TDFMachineGun01", tpId = "peu106m" },
    nonUniformScale = { x = 0.1, y = 0.1, z = 0.1 },
    source = {
        blueprint = "projectiles/TDFMachineGun01/TDFMachineGun01_proj.bp",
        blueprintSha256 = "8b7851d08f385f9ecd28d546d7cb601ced695eb66eeabfb08b01ac4427a7277d",
        script = "projectiles/TDFMachineGun01/TDFMachineGun01_script.lua",
        scriptSha256 = "dd2b588301736e6598027336a511b9a0eb7f5895a9ac94a27bd26dc95a2b184e",
    },
    visuals = {
        mesh = { lod0distance = 90 },
        onImpactEffects = { { effects = { { particleName = "VFX/Impact/vei1121_autocannon_small_impact.sanvfx" } } } },
        persistantEffects = { { effects = { { particleName = "VFX/Trails/vet1121_autocannon_small_trail.sanvfx" } } } },
    },
}
-- Native Sanctuary Hyena (uel3002/ped331) presentation, privately scaled for the Marine.
assert(ProjectileTemplate.general.tpId == "peu106m", "Mech Marine projectile scope drift")
assert(ProjectileTemplate.source.blueprintSha256 == "8b7851d08f385f9ecd28d546d7cb601ced695eb66eeabfb08b01ac4427a7277d", "Mech Marine source projectile drift")
local scoMechMarineScale = assert(ProjectileTemplate.nonUniformScale, "Mech Marine projectile scale missing")
assert(scoMechMarineScale.x == 0.1 and scoMechMarineScale.y == 0.1 and scoMechMarineScale.z == 0.1, "Mech Marine projectile scale drift")
ProjectileTemplate.visuals.onImpactEffects = { { effects = { { particleName = "VFX/SCOM/Source/uel1002/hyena_small_impact.sanvfx" } } } }
ProjectileTemplate.visuals.persistantEffects = { { effects = { { particleName = "VFX/SCOM/Source/uel1002/hyena_small_trail.sanvfx" } } } }
ProjectileTemplate.source.nativeHyenaPresentation = { unit = "uel3002", projectile = "ped331", scale = 0.1, trail = "VFX/Trails/vet1321_autocannon_large_trail.sanvfx", trailSha256 = "fd7c5a3aa036718280543be46c821c6e44a952e7993448a27bc51e4a2dd60d2c", impact = "VFX/Impact/vei1321_autocannon_large_impact.sanvfx", impactSha256 = "16c0aed575218fbcb416f892fe582850ecfa869e04e1ca3833b4356fc7ffe20f" }

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
