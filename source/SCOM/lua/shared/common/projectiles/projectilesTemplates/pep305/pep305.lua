---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "UEF_Percival_Ionized_Plasma",
        tpId = "pep305",
    },
    movement = { gravityMultiplier = 0 },
    nonUniformScale = { x = 0.8, y = 0.8, z = 0.8 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vei1301_cannon_large_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vet1301_cannon_large_trail.sanvfx" } } },
        },
    },
}

-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: TDFIonizedPlasmaGatlingCannon01
-- Source blueprint: projectiles/TDFIonizedPlasmaGatlingCannon01/TDFIonizedPlasmaGatlingCannon01_proj.bp
-- Source blueprint SHA-256: 4abb26c07e031a20c0e0584298a7ae22bdb21e4b824abdd9d635d24874555e28
-- Source script: projectiles/TDFIonizedPlasmaGatlingCannon01/TDFIonizedPlasmaGatlingCannon01_script.lua
-- Source script SHA-256: c2fcafc8d9f64ccb03572654dc510d91e0d2f637e0ba981e41ac50632f47c247
-- Source physics: initial speed 14.6, speed-reduce distance 30, turn rate 360,
-- velocity alignment true, no target lead, DestroyOnWater true.
-- Limitations: FA emitter graphs and DestroyOnWater are unavailable; pinned
-- compatibility UEF sanvfx and the unit's above-water physical gate are used.
-- Supreme Commander Overhaul UEF Percival 1.0.0
-- SCOM Field Fix: Percival commander-plasma projectile 1.0.0
if not ProjectileTemplate.general
    or ProjectileTemplate.general.tpId ~= "pep305"
    or not ProjectileTemplate.movement
    or ProjectileTemplate.movement.gravityMultiplier ~= 0
then
    error("PEP305 Percival projectile source contract drifted")
end

-- Keep Percival's isolated projectile/gameplay route, but present it with the
-- stock commander's blue plasma trail and impact at 2.5x linear thickness.
ProjectileTemplate.nonUniformScale = { x = 2.5, y = 2.5, z = 2.5 }
ProjectileTemplate.visuals = ProjectileTemplate.visuals or {}
ProjectileTemplate.visuals.onImpactEffects = {
    {
        effects = {
            {
                particleName = "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx",
            },
        },
    },
}
ProjectileTemplate.visuals.persistantEffects = {
    {
        effects = {
            {
                particleName = "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx",
            },
        },
    },
}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.pep305.lua
-- Retained projectile identity; only source render fields and threat metadata change.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="pep305",'Retained projectile identity mismatch')
tp.visuals=tp.visuals or {}
local visuals={
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0168/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["boneName"] = "SCO_Zephyr_01",
["particleName"] = "VFX/SCOM/Source/psf0168/trail.sanvfx",
}, {
["boneName"] = "SCO_Zephyr_02",
["particleName"] = "VFX/SCOM/Source/psf0168/trail_core.sanvfx",
}, {
["boneName"] = "SCO_Zephyr_03",
["particleName"] = "VFX/SCOM/Source/psf0168/trail_white.sanvfx",
}, {
["boneName"] = "SCO_Zephyr_Particles",
["particleName"] = "VFX/SCOM/Source/psf0168/trail_particles.sanvfx",
} },
} },
}
for key,value in pairs(visuals) do tp.visuals[key]=value end
tp.additions=tp.additions or {}
tp.additions.scoSourceVisualIdentity={
["blueprintSha256"] = "52c3df44df89d8dcea319e60a35ec7c5068a9fe2cfa51d78b81d1972ea694b4d",
["dedicatedTemplate"] = "psf0158",
["sourceId"] = "tdfplasmaheavy04",
}
tp.additions.scoSourceThreat={
["blueprintSha256"] = "52c3df44df89d8dcea319e60a35ec7c5068a9fe2cfa51d78b81d1972ea694b4d",
["categories"] = { "UEF", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["sourceId"] = "tdfplasmaheavy04",
}
end
