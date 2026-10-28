-- SCOM Field Fixes 1.0.0: dedicated visible-left Ythotha Sinn-Uthe presentation.
-- FA source projectile: projectiles/SDFSinnuntheWeapon01/SDFSinnuntheWeapon01_proj.bp
-- The FA projectile is emitter-only. Sanctuary uses its reviewed Chosen large
-- plasma trail/impact as a compatibility presentation; no FA mesh is claimed.
---@type ProjectileTemplate
ProjectileTemplate = {
    audio = {
        onImpact = {
            looping = false,
            name = "acoi2130",
        },
    },
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        name = "Ythotha Sinn-Uthe Compatibility Projectile",
        tpId = "psu404s",
    },
    -- Stock Sanctuary currently ignores this field at projectile instantiation.
    -- It remains the exact scale contract for a presentation-only loader child;
    -- the root ray/intel colliders must stay at scale one.
    nonUniformScale = { x = 3, y = 3, z = 3 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        boneName = "SCO_Ythotha_Projectile_Visual",
                        particleName = "VFX/Trails/vct1301_cannon_plasma_large_trail.sanvfx",
                    },
                },
            },
        },
    },
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psu404s.lua
-- Retained projectile identity; only source render fields and threat metadata change.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psu404s",'Retained projectile identity mismatch')
tp.visuals=tp.visuals or {}
local visuals={
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Combat/ythotha_left_arm_impact.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["boneName"] = "SCO_Ythotha_Projectile_Visual",
["particleName"] = "VFX/SCOM/Source/psf0134/trail.sanvfx",
} },
} },
}
for key,value in pairs(visuals) do tp.visuals[key]=value end
tp.additions=tp.additions or {}
tp.additions.scoSourceVisualIdentity={
["blueprintSha256"] = "5fd91d2d4cf835ff44072a55399c843ec1865f123543863a82c6c3c3582893fe",
["dedicatedTemplate"] = "psf0134",
["sourceId"] = "sdfsinnuntheweapon01",
}
tp.additions.scoSourceThreat={
["blueprintSha256"] = "5fd91d2d4cf835ff44072a55399c843ec1865f123543863a82c6c3c3582893fe",
["categories"] = { "SERAPHIM", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["sourceId"] = "sdfsinnuntheweapon01",
}
end
