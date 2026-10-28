ProjectileTemplate = {["nonUniformScale"]={["x"]=1,["y"]=1,["z"]=1},["additions"]={["scoSourceProjectile"]={["blueprintSha256"]="b84908f5217b35518177a358c24a4081f9d3300da9d762d8b34b429083447577",["categories"]={"UEF","PROJECTILE","DIRECTFIRE"},["defense"]={},["physics"]={["DestroyOnWater"]=true,["InitialSpeed"]=13,["UseGravity"]=false,["VelocityAlign"]=true},["sourceId"]="tdfriot01",["version"]="1.0.0"}},["collisionInfo"]={["centerOffset"]={["x"]=0,["y"]=0,["z"]=0},["collisionSize"]={["x"]=1,["y"]=1,["z"]=1}},["general"]={["name"]="tdfriot01",["tpId"]="psf0034"},["visuals"]={["mesh"]={["lod0distance"]=60},["onImpactEffects"]={{["effects"]={{["particleName"]="VFX/Impact/vei1321_autocannon_large_impact.sanvfx"}}}},["persistantEffects"]={{["effects"]={{["particleName"]="VFX/Trails/vet1321_autocannon_large_trail.sanvfx"}}}}}}
-- SCOM optional roster resource ScomFieldFixes.Roster.ProjectileVisuals.psf0034.lua
-- Stinger requested native Hyena presentation; retain source projectile simulation.
do
local tp=ProjectileTemplate
assert(tp.general.tpId=="psf0034")
assert(tp.additions.scoSourceProjectile.sourceId=="tdfriot01")
tp.visuals={["mesh"]={["lod0distance"]=60},["onImpactEffects"]={{["effects"]={{["particleName"]="VFX/Impact/vei1321_autocannon_large_impact.sanvfx"}}}},["persistantEffects"]={{["effects"]={{["particleName"]="VFX/Trails/vet1321_autocannon_large_trail.sanvfx"}}}}}
end
