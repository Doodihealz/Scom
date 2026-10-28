-- Native beam endpoint carrier; never a moving projectile.
ProjectileTemplate={
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceBeam"] = {
["rendererOnly"] = true,
["sourceClass"] = "MicrowaveLaserCollisionBeam02",
},
},
["collisionInfo"] = {
["centerOffset"] = {
["x"] = 0,
["y"] = 0,
["z"] = 0,
},
["collisionSize"] = {
["x"] = 0.01,
["y"] = 0.01,
["z"] = 0.01,
},
},
["general"] = {
["name"] = "MicrowaveLaserCollisionBeam02 endpoint",
["tpId"] = "pxd003",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/pxd003/beam_end.sanvfx",
} },
} },
},
}
