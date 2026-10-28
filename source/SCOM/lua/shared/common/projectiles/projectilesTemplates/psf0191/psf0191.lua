ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
["additions"] = {
["scoSourceProjectile"] = {
["blueprintSha256"] = "c6c840e4814c21ddb1488ac041b1da5efa26bc8123e64f9197cae13cecdc85e6",
["categories"] = { "SERAPHIM", "PROJECTILE", "ANTINAVY", "TORPEDO" },
["defense"] = {

},
["physics"] = {
["Acceleration"] = 10,
["CollideSurface"] = false,
["DestroyOnWater"] = false,
["InitialSpeed"] = 5,
["MaxSpeed"] = 12,
["StayUnderwater"] = true,
["TrackTarget"] = false,
["TurnRate"] = 230,
["UseGravity"] = false,
["VelocityAlign"] = true,
},
["sourceId"] = "sanheavycavitationtorpedo03",
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
["name"] = "sanheavycavitationtorpedo03",
["tpId"] = "psf0191",
},
["movement"] = {
["acceleration"] = 10,
["rotationSpeed"] = 230,
["speedMax"] = 12,
["type"] = "TargetEntity",
},
["visuals"] = {
["mesh"] = {
["lod0distance"] = 150,
},
["onImpactEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0191/impact_land.sanvfx",
} },
} },
["persistantEffects"] = { {
["effects"] = { {
["particleName"] = "VFX/SCOM/Source/psf0191/trail.sanvfx",
} },
} },
},
}
-- SCOM optional roster resource ScomFieldFixes.Roster.Interception.psf0191.lua
ProjectileTemplate.additions=ProjectileTemplate.additions or {}
ProjectileTemplate.additions.scoSourceThreat={["sourceId"]="sanheavycavitationtorpedo03",["blueprintSha256"]="c6c840e4814c21ddb1488ac041b1da5efa26bc8123e64f9197cae13cecdc85e6",["categories"]={"SERAPHIM","PROJECTILE","ANTINAVY","TORPEDO"},["defense"]={},["collisionRadius"]=1}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0191.lua
-- Source ribbon owner repair; projectile simulation and impact fields preserved.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0191")
tp.visuals.persistantEffects={ {
["effects"] = { {
["boneName"] = "SCO_SourceRibbon_0",
["particleName"] = "VFX/SCOM/Source/psf0191/ribbon_0.sanvfx",
}, {
["boneName"] = "SCO_SourceRibbon_1",
["particleName"] = "VFX/SCOM/Source/psf0191/ribbon_1.sanvfx",
} },
} }
tp.visuals.scoTrailOwners={
["SCO_SourceRibbon_0"] = "VFX/SCOM/Source/psf0191/ribbon_0.sanvfx",
["SCO_SourceRibbon_1"] = "VFX/SCOM/Source/psf0191/ribbon_1.sanvfx",
}
end
