---@type ProjectileTemplate
ProjectileTemplate = {
    ["additions"] = {
    ["scoTacticalProjectile"] = {
    ["acceleration"] = 15,
    ["child"] = true,
    ["collisionRadius"] = 2.5,
    ["destroyOnWater"] = false,
    ["health"] = 1,
    ["interceptor"] = false,
    ["invincibleSeconds"] = 0.3,
    ["lifetime"] = 30,
    ["maxSpeed"] = 25,
    ["sourceId"] = "CIFMissileTacticalSplit01",
    ["split"] = false,
    ["steppedTurn"] = false,
    ["tactical"] = true,
    ["track"] = false,
    ["turnRate"] = 0,
    ["version"] = "1.0.0",
},
},
    ["collisionInfo"] = {
    ["centerOffset"] = {
    ["x"] = 0,
    ["y"] = 0,
    ["z"] = 0,
},
    ["collisionSize"] = {
    ["x"] = 0.1,
    ["y"] = 0.1,
    ["z"] = 0.1,
},
},
    ["general"] = {
    ["name"] = "CIFMissileTacticalSplit01",
    ["tpId"] = "pst005",
},
    ["movement"] = {
    ["acceleration"] = 15,
    ["alignToVelocity"] = true,
    ["gravityMultiplier"] = 0,
    ["rotationSpeed"] = 0,
    ["speedMax"] = 25,
    ["type"] = "LeadStaticPosition",
},
    ["nonUniformScale"] = {
    ["x"] = 1,
    ["y"] = 1,
    ["z"] = 1,
},
    ["visuals"] = {
    ["mesh"] = {
    ["lod0distance"] = 150,
},
    ["onImpactEffects"] = { {
    ["effects"] = { {
    ["particleName"] = "VFX/SCOM/Source/pst005/impact_land.sanvfx",
} },
} },
    ["persistantEffects"] = { {
    ["effects"] = { {
    ["particleName"] = "VFX/SCOM/Source/pst005/trail.sanvfx",
} },
} },
    ["scoProjectileMesh"] = {
    ["material"] = "Projectiles/pst005/LOD0/pst005.sanmaterial",
    ["model"] = "Projectiles/pst005/LOD0/pst005.sanmodel",
    ["scale"] = {
    ["x"] = 1,
    ["y"] = 1,
    ["z"] = 1,
},
},
},
}
