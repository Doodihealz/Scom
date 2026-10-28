---@type ProjectileTemplate
-- Supreme Commander Overhaul FA Cybran Megalith Physical Port 1.0.1
-- Dedicated compatibility projectile; gameplay damage remains unit-weapon owned.
ProjectileTemplate = {
    additions = {
        faSourceContract = {
            sourceId = "CANTorpedoNanite01",
            targetId = "pmg402",
            sourceArchiveSha256 = "60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12",
            sourceBlueprint = "projectiles/CANTorpedoNanite01/CANTorpedoNanite01_proj.bp",
            sourceBlueprintSha256 = "90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f",
            sourceScript = "projectiles/CANTorpedoNanite01/CANTorpedoNanite01_script.lua",
            sourceScriptSha256 = "c7c65750ec3af15cae005c29dddde03f43095700a98ab3285fc3bad9e26e7e9d",
            limitation = "StayUnderwater, air-to-water gravity switching, and FA emitter graph are unsupported; host weapon gates launch and target depths.",
        },
    },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.25, z = 0 },
        collisionSize = { x = 0.5, y = 0.5, z = 0.5 },
    },
    general = { icon = "projectile", name = "Megalith_Nanite_Torpedo", tpId = "pmg402" },
    movement = {
        acceleration = 5,
        alignToVelocity = true,
        gravityMultiplier = 0,
        rotationSpeed = 230,
        speedMax = 18,
        type = "TargetEntity",
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Environment/vxi5201_water_splash_medium_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt8321_plasma_stream_large_trail.sanvfx" } } },
        },
    },
}
