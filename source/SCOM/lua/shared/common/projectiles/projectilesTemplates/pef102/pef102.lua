---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "UEF_Cyclone_Linked_Railgun",
        tpId = "pef102",
    },
    -- FA TAARailgun01 is a gravity-free, velocity-aligned
    -- direct projectile at InitialSpeed=120. Omitting movement makes
    -- Sanctuary use the weapon's exact 120-speed NoArc solution. The
    -- FA emitter graph is not a supported sanvfx input, so this private
    -- template uses an explicit same-faction native small-AA fallback;
    -- it never routes through Aeon projectile assets.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/TAARailgun01/TAARailgun01_proj.bp
    -- Source blueprint SHA-256: 27f4839a8b5b048073055a42fc728537303e8fae0a28266fe6674fbdb18bbc8f
    -- Source script: projectiles/TAARailgun01/TAARailgun01_script.lua
    -- Source script SHA-256: 36c2417368fb105b30325e2ee1fa1f63f51c79ddf18e0fece8842108333cd92e
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vei1121_autocannon_small_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vet1121_autocannon_small_trail.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0