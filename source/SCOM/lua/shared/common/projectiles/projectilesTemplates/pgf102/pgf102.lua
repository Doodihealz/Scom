---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Prowler_Electron_Autocannon",
        tpId = "pgf102",
    },
    -- FA CAAAutocannon02 is a gravity-free, velocity-aligned
    -- direct projectile at InitialSpeed=120. Omitting movement makes
    -- Sanctuary use the weapon's exact 120-speed NoArc solution. The
    -- FA emitter graph is not a supported sanvfx input, so this private
    -- template uses an explicit same-faction native small-AA fallback;
    -- it never routes through Aeon projectile assets.
    -- Source projectile archive: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
    -- Source blueprint: projectiles/CAAAutocannon02/CAAAutocannon02_proj.bp
    -- Source blueprint SHA-256: 196d6739b1349438378aab28cdef2df8a1c5a346cebf1bbe290071786abb4957
    -- Source script: projectiles/CAAAutocannon02/CAAAutocannon02_script.lua
    -- Source script SHA-256: 57f5695e460493503a05a77dcd7e7a0524c545c19e9ec9d63b3f48f0ff843dca
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1121_autocannon_plasma_small_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1121_autocannon_plasma_small_trail.sanvfx" } } },
        },
    },
}

-- Supreme Commander Overhaul FA Air Fighter Gameplay 1.0.0