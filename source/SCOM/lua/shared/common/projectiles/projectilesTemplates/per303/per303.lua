---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "UEF_Titan_Commander_Plasma_Small",
        tpId = "per303",
    },
    -- Stock projectile loading does not apply this field to its root hierarchy.
    -- The canonical field-fix hierarchy dispatcher creates one presentation-only
    -- child at this scale while root collision and simulation remain scale one.
    nonUniformScale = { x = 0.65, y = 0.65, z = 0.65 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vci1301_cannon_plasma_large_impact.sanvfx" } } },
        },
        persistantEffects = {
            {
                effects = {
                    {
                        boneName = "SCO_Titan_Commander_Projectile_Visual",
                        particleName = "VFX/Trails/vct2101_rocket_antitank_small_trail.sanvfx",
                    },
                },
            },
        },
    },
}

-- Simulation source archive: gamedata/projectiles.scd
-- Simulation source archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Simulation source ID: TDFPlasmaHeavy04
-- Simulation source blueprint: projectiles/TDFPlasmaHeavy04/TDFPlasmaHeavy04_proj.bp
-- Simulation source blueprint SHA-256: 52c3df44df89d8dcea319e60a35ec7c5068a9fe2cfa51d78b81d1972ea694b4d
-- Simulation source script: projectiles/TDFPlasmaHeavy04/TDFPlasmaHeavy04_script.lua
-- Simulation source script SHA-256: 3c05c2f3388f867ad54f2e6708d324fbe09aac2d1e6735e44a18bb83bee5c00d
-- Presentation source unit: UEL0001 (RightZephyr)
-- Presentation source unit blueprint SHA-256: d23dfe5cd085a5d248dc0544bebbf9432316b16905ada26fe88a5280591dd406
-- Presentation source unit script SHA-256: b3118531641de2ddc4c30a1dd461913f83d6b13778cfb041d47a20c6b80f2169
-- Presentation source projectile: LaserBotTerran01
-- Presentation source projectile blueprint SHA-256: 4a1d33796c7896993dbee6f3a309a4ff56fa0c97900b1e3f702aafcf363437fe
-- Presentation source projectile script SHA-256: e89c5430b392baf89703bf926ff71b862a1dd4d4b6126e06af4f031bd5f9bcac
-- Current canonical UEF commander route: UEL0001 -> uel0000 -> pcd121
-- Sanctuary visual donor: LJ/lua/common/projectiles/projectilesTemplates/pcd121/pcd121.santp
-- Sanctuary visual donor SHA-256: 252536ffba44544195bde3ebfba00063a134b429801098c537559b1f6380773a
-- Presentation contract: dedicated per303 child at uniform scale 0.65.
-- Compatibility presentation only; this is not a 1:1 Forged Alliance visual-asset port.
-- Supreme Commander Overhaul FA Land Role Replacements 1.0.0