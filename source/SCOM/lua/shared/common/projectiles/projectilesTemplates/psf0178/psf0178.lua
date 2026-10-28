ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "3274ab7561e5c711d8cc204d565970f0ab56614a159a025842444ea5b015744c",
["categories"] = { "CYBRAN", "PROJECTILE", "ANTITORPEDO" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 10,
["DestroyOnWater"] = false,
["MaxSpeed"] = 3,
["StayUnderwater"] = false,
["TrackTarget"] = true,
["TurnRate"] = 720,
["UseGravity"] = true,
["VelocityAlign"] = true,
},
["sourceId"] = "cimantitorpedo02",
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
["x"] = 1,
["y"] = 1,
["z"] = 1,
},
},
["general"] = {
["name"] = "cimantitorpedo02",
["tpId"] = "psf0178",
},
["movement"] = {
["acceleration"] = 10,
["rotationSpeed"] = 720,
["speedMax"] = 3,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0178/impact_unit.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0178/trail.sanvfx",
} },
} },
},
}
