---@type ProjectileTemplate
ProjectileTemplate = {
    audio = { onImpact = { looping = false, name = "agoi1130" } },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_URB2303_Molecular_Resonance_Shell",
        tpId = "pcg203",
    },
    -- Supreme Commander Overhaul FA Cybran Artillery Pair 1.0.0
    -- CIFMolecularResonanceShell01: UniformScale=.25, LeadTarget=false,
    -- TurnRate=360, VelocityAlign=true, DestroyOnWater=true.  The FA mesh and
    -- emitter graph are not loadable as a Sanctuary projectile template, so
    -- explicit Guard artillery effects are the non-Aeon compatibility path.
    nonUniformScale = { x = 0.25, y = 0.25, z = 0.25 },
    visuals = {
        mesh = { lod0distance = 150 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx" } } },
        },
    },
}