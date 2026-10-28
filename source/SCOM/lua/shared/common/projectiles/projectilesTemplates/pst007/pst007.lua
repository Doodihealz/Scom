---@type ProjectileTemplate
ProjectileTemplate = {
    ["additions"] = {
    ["scoTacticalProjectile"] = {
    ["acceleration"] = 1,
    ["collisionRadius"] = 1,
    ["destroyOnWater"] = true,
    ["flareRadius"] = 15,
    ["health"] = 1,
    ["interceptor"] = true,
    ["lifetime"] = 4,
    ["maxSpeed"] = 5,
    ["persistOnMissileImpact"] = true,
    ["sourceId"] = "AIMAntiMissile01",
    ["split"] = false,
    ["steppedTurn"] = false,
    ["tactical"] = false,
    ["track"] = true,
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
    ["name"] = "AIMAntiMissile01",
    ["tpId"] = "pst007",
},
    ["movement"] = {
    ["acceleration"] = 1,
    ["alignToVelocity"] = true,
    ["gravityMultiplier"] = 0,
    ["rotationSpeed"] = 0,
    ["speedMax"] = 5,
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
    ["particleName"] = "VFX/SCOM/Source/pst007/impact_none.sanvfx",
} },
} },
    ["persistantEffects"] = { {
    ["effects"] = { {
    ["particleName"] = "VFX/SCOM/Source/pst007/trail.sanvfx",
} },
} },
},
}
