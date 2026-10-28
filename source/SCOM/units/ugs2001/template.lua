-- ugs2001: Cerberus
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["donorRootPersistentLoopRetained"] = false,
            ["donorWeaponOnFireFallbackRetained"] = true,
            ["mapping"] = "URB2301 -> ugs2001",
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/URB2301/URB2301_unit.bp",
            ["sourceBlueprintSha256"] = "6f61e9f0f4d02f1dcf9ca03ecd2206dd15aa1476709d470f448c4af3e6e69c0f",
            ["sourcePrimaryWeapon"] = "beam (no FA ProjectileId)",
            ["sourceScript"] = "units/URB2301/URB2301_Script.lua",
            ["sourceScriptSha256"] = "8af1d38542249dcfec00b39de44407947dca5bad5f1e5514811faf4957894b22",
            ["sourceWeaponAudioBanksImported"] = false,
            ["sourceWeaponEmitterGraphSupported"] = false,
            ["sourceWeaponRuntimeParityApplied"] = true,
        },
        ["scoFieldFixCybran"] = "1.0.4",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.51,
                ["z"] = 0.01,
            },
            ["size"] = {
                ["x"] = 1.58,
                ["y"] = 1.59,
            },
        },
        ["tarmacSize"] = {
            ["x"] = 1.43,
            ["y"] = 1.44,
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.51,
            ["z"] = 0.01,
        },
        ["collisionSize"] = {
            ["x"] = 1.35,
            ["y"] = 2.01,
            ["z"] = 1.36,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2000,
            ["regen"] = 0,
            ["value"] = 2000,
        },
    },
    ["economy"] = {
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 480,
            ["energy"] = 3400,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardStructure",
        },
        ["displayName"] = "Cerberus",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Cerberus",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 1223.2,
            ["WaterSurface"] = 1629.8,
        },
        ["tpId"] = "ugs2001",
        ["unitTypeName"] = "GuardT2PointDefence",
    },
    ["intel"] = {
        ["visionRadius"] = 28,
    },
    ["ranges"] = {
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 50,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 28,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ANTI_SURFACE",
        [2] = "BUILDABLE_BY_T2_ENGINEER",
        [3] = "BUILDABLE_BY_T3_ENGINEER",
        [4] = "DEFENCE",
        [5] = "DIRECT_FIRE",
        [6] = "GUARD",
        [7] = "LAND",
        [8] = "STRUCTURE",
        [9] = "TECH2",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYTIER2COMMANDER",
        [12] = "SCFA_BUILTBYTIER2ENGINEER",
        [13] = "SCFA_BUILTBYTIER3COMMANDER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_CYBRAN",
        [16] = "SCFA_DEFENSE",
        [17] = "SCFA_DIRECTFIRE",
        [18] = "SCFA_DRAGBUILD",
        [19] = "SCFA_OVERLAYDIRECTFIRE",
        [20] = "SCFA_PRODUCTSC1",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_SELECTABLE",
        [23] = "SCFA_SIZE4",
        [24] = "SCFA_SORTDEFENSE",
        [25] = "SCFA_STRUCTURE",
        [26] = "SCFA_TECH2",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 20,
            },
            ["progressBars"] = {
                [1] = {
                    ["colorBackground"] = {
                        ["a"] = 1,
                        ["x"] = 0,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["colorEmpty"] = {
                        ["a"] = 1,
                        ["x"] = 1,
                        ["y"] = 0,
                        ["z"] = 0,
                    },
                    ["colorFull"] = {
                        ["a"] = 1,
                        ["x"] = 0,
                        ["y"] = 1,
                        ["z"] = 0,
                    },
                    ["mainBar"] = true,
                    ["name"] = "Health",
                    ["property"] = "Health_Current",
                    ["xOffset"] = 0,
                    ["xScale"] = 1,
                },
            },
            ["subBarDisplayScale"] = {
                ["x"] = 1,
                ["y"] = 1,
            },
            ["subBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 0,
            },
        },
        ["effectsInstant"] = {
            ["onDeath"] = {
                [1] = {
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vgd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.243,
                    ["y"] = 1.0125,
                    ["z"] = -0.262,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.29700000000000004,
                    ["y"] = 0.8717999999999999,
                    ["z"] = 0.2548,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27,
                    ["y"] = 1.0728,
                    ["z"] = 0.22760000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.243,
                    ["y"] = 1.3541999999999998,
                    ["z"] = -0.262,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.29700000000000004,
                    ["y"] = 1.314,
                    ["z"] = 0.2548,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 70,
            ["lod1distance"] = 184,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.51,
                ["z"] = 0.01,
            },
            ["size"] = {
                ["x"] = 1.58,
                ["y"] = 1.59,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_B02",
                    ["pitchMax"] = 55,
                    ["pitchMin"] = -55,
                    ["pitchSpeed"] = 60,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret_B01",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "agom1124",
                },
            },
            ["beam"] = {
                ["cullDistance"] = 400,
                ["fadeInTime"] = 0,
                ["fadeOutTime"] = 0.01,
                ["renderLifetime"] = 0.6,
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/SCOM/Source/Beams/bfa_rhino_0.sanmaterial",
                        ["model"] = "VFX/SCOM/Source/Beams/bfa_rhino_0.sanmodel",
                    },
                    [2] = {
                        ["material"] = "VFX/SCOM/Source/Beams/bfa_rhino_1.sanmaterial",
                        ["model"] = "VFX/SCOM/Source/Beams/bfa_rhino_1.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = 6,
            ["collideFriendly"] = false,
            ["damage"] = 11,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
                [3] = "Seabed",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle01",
                        [2] = "Turret_Muzzle02",
                        [3] = "Turret_Muzzle03",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle01"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
                ["Turret_Muzzle02"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
                ["Turret_Muzzle03"] = {
                    ["aimController"] = "Turret_Muzzle01",
                },
            },
            ["name"] = "MainGun",
            ["projectileTemplate"] = "pbf0001",
            ["rangeMax"] = 50,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 0.6666666666666666,
            ["scoFaBeam"] = {
                ["beamClassLineage"] = {
                    [1] = {
                        ["className"] = "SCCollisionBeam",
                        ["path"] = "lua/defaultcollisionbeams.lua",
                        ["sha256"] = "4fb6ca75d85e11659ce77dbf3480510eab47e442178dcb654ec78c463524c0e2",
                    },
                    [2] = {
                        ["className"] = "ParticleCannonCollisionBeam",
                        ["path"] = "lua/defaultcollisionbeams.lua",
                        ["sha256"] = "4fb6ca75d85e11659ce77dbf3480510eab47e442178dcb654ec78c463524c0e2",
                    },
                },
                ["collisionIntervalTicks"] = 2,
                ["damageFriendly"] = false,
                ["damageRadius"] = 0,
                ["endpointEffects"] = {
                    ["beam_end"] = "VFX/SCOM/Source/bfa_rhino/beam_end.sanvfx",
                },
                ["lifetimeTicks"] = 6,
                ["sourceClass"] = "ParticleCannonCollisionBeam",
                ["sourceId"] = "URB2301",
                ["sourceScript"] = {
                    ["archive"] = "units.scd",
                    ["bytes"] = 811,
                    ["entry"] = "units/URB2301/URB2301_Script.lua",
                    ["sha256"] = "8af1d38542249dcfec00b39de44407947dca5bad5f1e5514811faf4957894b22",
                },
                ["sourceWeaponIndex"] = 1,
            },
            ["scoFaSourceWeapon"] = {
                ["AboveWaterTargetsOnly"] = true,
                ["Audio"] = {
                    ["Fire"] = {
                        ["Bank"] = "URLWeapon",
                        ["Cue"] = "URB2301_Cannon_Sgl",
                        ["LodCutoff"] = "Weapon_LodCutoff",
                    },
                },
                ["BallisticArc"] = "RULEUBA_None",
                ["BeamCollisionDelay"] = 0.2,
                ["BeamLifetime"] = 0.6,
                ["CollideFriendly"] = false,
                ["Damage"] = 11,
                ["DamageFriendly"] = false,
                ["DamageType"] = "Normal",
                ["DisplayName"] = "Particle Cannon",
                ["FireTargetLayerCapsTable"] = {
                    ["Land"] = "Land|Water|Seabed",
                    ["Water"] = "Land|Water|Seabed",
                },
                ["FiringRandomness"] = 0,
                ["FiringTolerance"] = 2,
                ["Label"] = "MainGun",
                ["MaxRadius"] = 50,
                ["MuzzleSalvoDelay"] = 0,
                ["MuzzleSalvoSize"] = 1,
                ["ProjectileLifetimeUsesMultiplier"] = 1.15,
                ["RackBones"] = {
                    [1] = {
                        ["MuzzleBones"] = {
                            [1] = "Turret_Muzzle01",
                            [2] = "Turret_Muzzle02",
                            [3] = "Turret_Muzzle03",
                        },
                        ["RackBone"] = "Turret_B02",
                    },
                },
                ["RackFireTogether"] = false,
                ["RackRecoilDistance"] = -1,
                ["RackReloadTimeout"] = 10,
                ["RackSalvoChargeTime"] = 0,
                ["RackSalvoReloadTime"] = 0,
                ["RackSalvoSize"] = 1,
                ["RackSlavedToTurret"] = false,
                ["RangeCategory"] = "UWRC_DirectFire",
                ["RateOfFire"] = 1.5,
                ["ReTargetOnMiss"] = true,
                ["TargetCheckInterval"] = 0.3,
                ["TargetPriorities"] = {
                    [1] = "SPECIALHIGHPRI",
                    [2] = "MOBILE",
                    [3] = "STRUCTURE DEFENSE",
                    [4] = "SPECIALLOWPRI",
                    [5] = "ALLUNITS",
                },
                ["TargetRestrictDisallow"] = "UNTARGETABLE",
                ["TrackingRadius"] = 1.15,
                ["TurretBoneMuzzle"] = "Turret_Muzzle01",
                ["TurretBonePitch"] = "Turret_B02",
                ["TurretBoneYaw"] = "Turret_B01",
                ["TurretDualManipulators"] = false,
                ["TurretPitch"] = 10,
                ["TurretPitchRange"] = 55,
                ["TurretPitchSpeed"] = 60,
                ["TurretYaw"] = 0,
                ["TurretYawRange"] = 180,
                ["TurretYawSpeed"] = 60,
                ["Turreted"] = true,
                ["WeaponCategory"] = "Direct Fire",
            },
            ["scoFaSourceWeaponIndex"] = 1,
        },
    },
}
