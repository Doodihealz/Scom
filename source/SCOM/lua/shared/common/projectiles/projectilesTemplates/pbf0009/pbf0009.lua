-- Source beam endpoint carrier; native beams never spawn this as a moving projectile.
ProjectileTemplate = {
nonUniformScale = { x = 1, y = 1, z = 1 },
    general = { tpId = "pbf0009", name = "UltraChromaticBeamGeneratorCollisionBeam02 endpoint" },
    collisionInfo = { centerOffset = { x = 0, y = 0, z = 0 }, collisionSize = { x = 0.01, y = 0.01, z = 0.01 } },
    additions = { scoSourceBeam = { sourceClass = "UltraChromaticBeamGeneratorCollisionBeam02", rendererOnly = true } },
    visuals = {
        mesh = { lod0distance = 150 },
        onImpactEffects = { { effects = { { particleName = "VFX/SCOM/Source/bfa_ultra02/beam_end.sanvfx" } } } },
    },
}
