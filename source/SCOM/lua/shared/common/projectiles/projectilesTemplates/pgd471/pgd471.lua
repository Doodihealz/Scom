---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = {
            x = 0,
            y = 0.5,
            z = 0,
        },
        collisionSize = {
            x = 1,
            y = 1,
            z = 1,
        },
    },
    general = {
        name = "Guard_Beam_Plasma_Huge",
        tpId = "pgd471",
    },
    nonUniformScale = {
        x = 1,
        y = 1,
        z = 1,
    },
    visuals = {
        beamEffectName = "VFX/Beams/vgb7401_beam_plasma_huge_beam.sanvfx",
        mesh = {
            lod0distance = 60,
        },
        onImpactEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Impact/vgi7401_beam_plasma_huge_impact_loop.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Beams/vgi7401_beam_plasma_huge_impact_loop.sanvfx",
                    },
                },
            },
        },
    },
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.pgd471.lua
-- Correct one existing prefab asset path; preserve the approved Monkeylord beam.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=='pgd471','Monkeylord endpoint identity mismatch')
local effect=assert(tp.visuals.persistantEffects[1].effects[1],'Monkeylord endpoint effect missing')
assert(effect.particleName=='VFX/Beams/vgi7401_beam_plasma_huge_impact_loop.sanvfx' or effect.particleName=='VFX/Impact/vgi7401_beam_plasma_huge_impact_loop.sanvfx','Monkeylord endpoint path drift')
effect.particleName='VFX/Impact/vgi7401_beam_plasma_huge_impact_loop.sanvfx'
end
