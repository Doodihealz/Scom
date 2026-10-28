-- SCOM Sea Parity 1.0.0: dedicated Summit projectile psu302a
-- source-blueprint-path=projectiles/TAARailgun02/TAARailgun02_proj.bp
-- source-blueprint-sha256=2D5D6C90B778D3D52454D893BFD0D85F2CBFDA876474F85C0901373928D40558
-- source-script-path=projectiles/TAARailgun02/TAARailgun02_script.lua
-- source-script-sha256=17090FEB687A3907C45368CB8D940E74B7935513CDA45302DCD98F370DD580D6
-- Sanctuary renders projectiles through compatibility VFX; no FA mesh is claimed.
-- sanctuary-visibility-fallback=vet1121_autocannon_small_trail; FA TAARailgun02 has no flight trail.
---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        name = "Summit TAARailgun02 Compatibility Slug",
        tpId = "psu302a",
    },
    nonUniformScale = { x = 1, y = 1, z = 1 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Impact/vei7601_railgun_flak_medium_impact.sanvfx",
                    },
                },
            },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        particleName = "VFX/Trails/vet1121_autocannon_small_trail.sanvfx",
                    },
                },
            },
        },
    },
}
