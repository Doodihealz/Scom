---@type ProjectileTemplate
ProjectileTemplate = {
    ["additions"] = {
    ["scoTacticalProjectile"] = {
    ["acceleration"] = 3,
    ["collisionRadius"] = 2,
    ["destroyOnWater"] = true,
    ["health"] = 2,
    ["interceptor"] = false,
    ["lifetime"] = 30,
    ["maxSpeed"] = 12,
    ["sourceId"] = "TIFMissileCruise01",
    ["split"] = false,
    ["steppedTurn"] = true,
    ["tactical"] = true,
    ["track"] = true,
    ["turnRate"] = 8,
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
    ["name"] = "TIFMissileCruise01",
    ["tpId"] = "pst001",
},
    ["movement"] = {
    ["acceleration"] = 3,
    ["alignToVelocity"] = true,
    ["gravityMultiplier"] = 0,
    ["rotationSpeed"] = 8,
    ["speedMax"] = 12,
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
    ["particleName"] = "VFX/SCOM/Source/pst001/impact_land.sanvfx",
} },
} },
    ["persistantEffects"] = { {
    ["effects"] = { {
    ["particleName"] = "VFX/SCOM/Source/pst001/trail.sanvfx",
} },
} },
    ["scoProjectileMesh"] = {
    ["material"] = "Projectiles/pst001/LOD0/pst001.sanmaterial",
    ["model"] = "Projectiles/pst001/LOD0/pst001.sanmodel",
    ["scale"] = {
    ["x"] = 1,
    ["y"] = 1,
    ["z"] = 1,
},
},
},
}
