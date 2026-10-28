---@type ProjectileTemplate
ProjectileTemplate = {
    audio = { onImpact = { looping = false, name = "agoi1110" } },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_URL0103_EMP_Grenade",
        tpId = "pcg103",
    },
    -- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0
    -- CIFGrenade01: UniformScale=.05, InitialSpeed=14.6, range=3,
    -- reduce-distance=30, LeadTarget=false, TurnRate=360,
    -- VelocityAlign=true, DestroyOnWater=true. Sanctuary's weapon solver owns
    -- the ballistic launch; compatible Guard effects stand in for the FA-only
    -- projectile mesh and emitters without sharing an Aeon projectile route.
    nonUniformScale = { x = 0.05, y = 0.05, z = 0.05 },
    visuals = {
        mesh = { lod0distance = 150 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1141_cannon_artillery_small_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1141_cannon_artillery_small_trail.sanvfx" } } },
        },
    },
}