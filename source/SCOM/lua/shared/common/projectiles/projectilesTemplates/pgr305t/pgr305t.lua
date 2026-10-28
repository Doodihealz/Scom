---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = { icon = "projectile", name = "Cybran_Brick_Nanite_Torpedo", tpId = "pgr305t" },
    movement = { acceleration = 5, gravityMultiplier = 0, rotationSpeed = 230, speedMax = 18, type = "TargetEntity" },
    nonUniformScale = { x = 0.65, y = 0.65, z = 0.65 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = { { effects = { { particleName = "VFX/Impact/vgi1241_cannon_artillery_medium_impact.sanvfx" } } } },
        persistantEffects = { { effects = { { particleName = "VFX/Trails/vgt1241_cannon_artillery_medium_trail.sanvfx" } } } },
    },
}

-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CANTorpedoNanite01
-- Source blueprint: projectiles/CANTorpedoNanite01/CANTorpedoNanite01_proj.bp
-- Source blueprint SHA-256: 90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f
-- Source script: projectiles/CANTorpedoNanite01/CANTorpedoNanite01_script.lua
-- Source script SHA-256: c7c65750ec3af15cae005c29dddde03f43095700a98ab3285fc3bad9e26e7e9d
-- Source physics profile: HomingTorpedo
-- Limitation: FA emitter graphs and DestroyOnWater/StayUnderwater flags are not native sanvfx/template inputs.
-- Supreme Commander Overhaul FA Cybran T3 Roles 1.0.0
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.pgr305t.lua
-- Retained projectile identity; only source render fields and threat metadata change.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="pgr305t",'Retained projectile identity mismatch')
tp.visuals=tp.visuals or {}
local visuals={
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0012/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0012/trail.sanvfx",
} },
} },
["scoProjectileMesh"] = {
["material"] = "Projectiles/psf0012/LOD0/psf0012.sanmaterial",
["model"] = "Projectiles/psf0012/LOD0/psf0012.sanmodel",
["scale"] = {
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
}
for key,value in pairs(visuals) do tp.visuals[key]=value end
tp.additions=tp.additions or {}
tp.additions.scoSourceVisualIdentity={
["blueprintSha256"] = "90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f",
["dedicatedTemplate"] = "psf0012",
["sourceId"] = "cantorpedonanite01",
}
tp.additions.scoSourceThreat={
["blueprintSha256"] = "90ed85157713b241bcc0a73062dcbd998f8dc7765ecc4d830397ba8985cfba0f",
["categories"] = { "CYBRAN", "PROJECTILE", "ANTINAVY", "TORPEDO", "NOSPLASHDAMAGE" },
["defense"] = {
["Health"] = 1,
},
["sourceId"] = "cantorpedonanite01",
}
end
