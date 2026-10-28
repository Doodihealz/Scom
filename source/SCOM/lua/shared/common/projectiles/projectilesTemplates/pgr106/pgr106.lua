---@type ProjectileTemplate
ProjectileTemplate = {
    collisionInfo = {
        centerOffset = { x = 0, y = 0.5, z = 0 },
        collisionSize = { x = 1, y = 1, z = 1 },
    },
    general = {
        icon = "projectile",
        name = "Cybran_Hunter_Light_Pulse_Laser",
        tpId = "pgr106",
    },
    nonUniformScale = { x = 0.65, y = 0.65, z = 0.65 },
    visuals = {
        mesh = { lod0distance = 60 },
        onImpactEffects = {
            { effects = { { particleName = "VFX/Impact/vgi1101_cannon_small_impact.sanvfx" } } },
        },
        persistantEffects = {
            { effects = { { particleName = "VFX/Trails/vgt1101_cannon_small_trail.sanvfx" } } },
        },
    },
}

-- Source projectile archive SHA-256: 60d2732597cde9ef046a663c8d439e60844f967147e14737c7ad5a08c641be12
-- Source ID: CDFLaserLight01
-- Source blueprint: projectiles/CDFLaserLight01/CDFLaserLight01_proj.bp
-- Source blueprint SHA-256: 8cf98d148dd150fe40afc5fb53c20e071a69aeaf5bd67ba22664f3136202ab14
-- Source script: projectiles/CDFLaserLight01/CDFLaserLight01_script.lua
-- Source script SHA-256: ba5e37cd799d302d7efdcff955212f139f21e7adcf5c77181af4c9002beb1d43
-- Source physics: UseGravity=true, DestroyOnWater=true, InitialSpeed=22, Lifetime=2.5.
-- Weapon overrides speed to 25 and lifetime to range/speed*1.15 = 0.644.
-- Limitation: FA CLaserLaserProjectile emitters/DestroyOnWater have no native sanvfx/template input;
-- the isolated projectile uses explicit Guard small-cannon VFX and the weapon's physical water gate.
-- Supreme Commander Overhaul FA Cybran Hunter 1.0.0