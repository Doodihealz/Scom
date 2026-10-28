ProjectileTemplate = {
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "af6d6d5a993f916fce71159d06b894d8e1269fe8621913b4064fc668f402ac6b",
["categories"] = { "CYBRAN", "PROJECTILE", "DIRECTFIRE" },
["defense"] = {

},
["physics"] = {
["DestroyOnWater"] = true,
["InitialSpeed"] = 22,
["Lifetime"] = 2.5,
["UseGravity"] = true,
},
["sourceId"] = "cdflaserheavy01",
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
["name"] = "cdflaserheavy01",
["tpId"] = "psf0017",
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
["particleName"] = "VFX/SCOM/Source/psf0017/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["boneName"] = "SCO_HeavyLaser_Red",
["particleName"] = "VFX/SCOM/Source/psf0017/trail.sanvfx",
}, {
["boneName"] = "SCO_HeavyLaser_Core",
["particleName"] = "VFX/SCOM/Source/psf0017/trail_core.sanvfx",
} },
} },
},
}
