ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "36bb2a12d4669530267e0dd45b98eae01db6685631f4e74edacae4454fce9d62",
["categories"] = { "SERAPHIM", "PROJECTILE", "ANTINAVY", "TORPEDO" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 0,
["DestroyOnWater"] = false,
["InitialSpeed"] = 14,
["MaxSpeed"] = 14,
["StayUnderwater"] = true,
["TrackTarget"] = false,
["TurnRate"] = 360,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "sanheavycavitationtorpedo04",
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
["name"] = "sanheavycavitationtorpedo04",
["tpId"] = "psf0192",
},
["movement"] = {
["acceleration"] = 0,
["rotationSpeed"] = 360,
["speedMax"] = 14,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0192/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0192/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0192.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="sanheavycavitationtorpedo04",["blueprintSha256"]="36bb2a12d4669530267e0dd45b98eae01db6685631f4e74edacae4454fce9d62",["categories"]={"SERAPHIM","PROJECTILE","ANTINAVY","TORPEDO"},["defense"]={},["collisionRadius"]=1}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0192.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0192")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0192/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0192/ribbon_1.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0192/ribbon_0.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0192/ribbon_1.sanvfx",
}
end
