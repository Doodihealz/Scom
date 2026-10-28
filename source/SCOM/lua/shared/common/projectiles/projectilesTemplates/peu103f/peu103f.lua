---@type ProjectileTemplate
ProjectileTemplate = {
    audio = { onImpact = { looping = false, name = "aeoi3210" } },
    collisionInfo = { centerOffset = { x = 0, y = 0.5, z = 0 }, collisionSize = { x = 1, y = 1, z = 1 } },
    general = { icon = "projectile", name = "UEF_TIFFragmentationSensorShell01", tpId = "peu103f" },
    nonUniformScale = { x = 0.1, y = 0.1, z = 0.1 },
    source = {
        blueprint = "projectiles/TIFFragmentationSensorShell01/TIFFragmentationSensorShell01_proj.bp",
        blueprintSha256 = "b6ffd27313b8e94956dbf454fe524028bec8c8e6b406924a0b0cba3228fd4833",
        script = "projectiles/TIFFragmentationSensorShell01/TIFFragmentationSensorShell01_script.lua",
        scriptSha256 = "d1b6d440b29f8d10a1091549a944f34ace3ec2b123783ce1a2c7912eca578215",
        childFragmentCount = 5, childFragmentsSupported = false, sensorMarkerSupported = false,
    },
    visuals = {
        mesh = { lod0distance = 120 },
        onImpactEffects = { { effects = { { particleName = "VFX/Impact/vei2141_rocket_artillery_small_impact.sanvfx" } } } },
        persistantEffects = { { effects = { { particleName = "VFX/Trails/vet2141_rocket_artillery_small_trail.sanvfx" } } } },
    },
}

-- Supreme Commander Overhaul EDA UEF Land/Power Cache Patcher 3.0.0
