-- uss2001: Uttaushala
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 2.3333332538604736,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.375,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 1.25,
            ["z"] = 1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 2100,
            ["regen"] = 0,
            ["value"] = 2100,
        },
    },
    ["economy"] = {
        ["buildTime"] = 480,
        ["cost"] = {
            ["alloys"] = 528,
            ["energy"] = 3648,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimStructure",
        },
        ["displayName"] = "Uttaushala",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Uttaushala",
        ["orders"] = {
            ["Attack"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 1503,
            ["WaterSurface"] = 1626.2,
        },
        ["tpId"] = "uss2001",
        ["unitTypeName"] = "UnknownT2PointDefence",
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
        [6] = "LAND",
        [7] = "SCFA_ALLUNITS",
        [8] = "SCFA_BUILTBYTIER2COMMANDER",
        [9] = "SCFA_BUILTBYTIER2ENGINEER",
        [10] = "SCFA_BUILTBYTIER3COMMANDER",
        [11] = "SCFA_BUILTBYTIER3ENGINEER",
        [12] = "SCFA_DEFENSE",
        [13] = "SCFA_DIRECTFIRE",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_OVERLAYDIRECTFIRE",
        [16] = "SCFA_PRODUCTFA",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SERAPHIM",
        [20] = "SCFA_SIZE4",
        [21] = "SCFA_SORTDEFENSE",
        [22] = "SCFA_STRUCTURE",
        [23] = "SCFA_TECH2",
        [24] = "SCFA_VISIBLETORECON",
        [25] = "SERAPHIM",
        [26] = "STRUCTURE",
        [27] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2001/LOD0/uss2001.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2001/LOD0/uss2001.sananimation",
            },
        },
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
                    ["particleName"] = "VFX/Death/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.6875,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.6,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.7250000000000001,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.9,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.875,
                    ["z"] = 0.18,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 70,
            ["lod1distance"] = 182,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.375,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 0.1,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = false,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 30,
                    ["pitchMin"] = -30,
                    ["pitchSpeed"] = 44,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "NoArc",
                    ["yawBone"] = "Turret",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 60,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom2124",
                },
            },
            ["beam"] = {
                ["cullDistance"] = 400,
                ["fadeInTime"] = 0,
                ["fadeOutTime"] = 0.01,
                ["renderLifetime"] = 0.9,
                ["impactEffect"] = "VFX/SCOM/Combat/uss2001/impact.sanvfx",
                ["subMesh"] = {
                    [1] = {
                        ["material"] = "VFX/SCOM/Combat/uss2001/gold_beam.sanmaterial",
                        ["model"] = "VFX/SCOM/Source/Beams/bfa_ultra_0.sanmodel",
                    },
                },
            },
            ["beamLifetime"] = 9,
            ["collideFriendly"] = false,
            ["damage"] = 220,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {},
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
                        [1] = "Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle"] = {
                    ["aimController"] = "Turret_Muzzle",
                },
            },
            ["name"] = "MainGun",
            ["projectileTemplate"] = "pbf0008",
            ["rangeMax"] = 50,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.25,
            ["reloadTime"] = 4,
            ["scoFaBeam"] = {
                ["beamClassLineage"] = {
                    [1] = {
                        ["className"] = "CollisionBeam",
                        ["path"] = "lua/sim/CollisionBeam.lua",
                        ["sha256"] = "783a6b97ac37bf34559236fb6df0e563b3671c09806a00f5a0a829341dd4a8da",
                    },
                    [2] = {
                        ["className"] = "SCCollisionBeam",
                        ["path"] = "lua/defaultcollisionbeams.lua",
                        ["sha256"] = "4fb6ca75d85e11659ce77dbf3480510eab47e442178dcb654ec78c463524c0e2",
                    },
                    [3] = {
                        ["className"] = "UltraChromaticBeamGeneratorCollisionBeam",
                        ["path"] = "lua/defaultcollisionbeams.lua",
                        ["sha256"] = "4fb6ca75d85e11659ce77dbf3480510eab47e442178dcb654ec78c463524c0e2",
                    },
                },
                ["collisionIntervalTicks"] = 3,
                ["damageFriendly"] = false,
                ["damageRadius"] = 0,
                ["endpointEffects"] = {
                    ["beam_end"] = "VFX/SCOM/Combat/uss2001/impact.sanvfx",
                },
                ["lifetimeTicks"] = 9,
                ["sourceClass"] = "UltraChromaticBeamGeneratorCollisionBeam",
                ["sourceId"] = "XSB2301",
                ["sourceScript"] = {
                    ["archive"] = "units.scd",
                    ["bytes"] = 703,
                    ["entry"] = "units/XSB2301/XSB2301_Script.lua",
                    ["sha256"] = "375dd2f4c34487967c1082c343c0e49bd6c0917783b9895784213314230547b2",
                },
                ["sourceWeaponIndex"] = 1,
            },
            ["scoFaSourceWeapon"] = {
                ["AboveWaterTargetsOnly"] = true,
                ["Audio"] = {
                    ["BeamLoop"] = {
                        ["Bank"] = "XSB_Weapon",
                        ["Cue"] = "XSB2301_Ultrachromatic_Beam",
                        ["LodCutoff"] = "Weapon_LodCutoff",
                    },
                    ["BeamStart"] = {
                        ["Bank"] = "XSB_Weapon",
                        ["Cue"] = "XSB2301_Ultrachromatic_Beam_Start",
                        ["LodCutoff"] = "Weapon_LodCutoff",
                    },
                    ["BeamStop"] = {
                        ["Bank"] = "XSB_Weapon",
                        ["Cue"] = "XSB2301_Ultrachromatic_Beam_Stop",
                        ["LodCutoff"] = "Weapon_LodCutoff",
                    },
                },
                ["BallisticArc"] = "RULEUBA_None",
                ["BeamCollisionDelay"] = 0.3,
                ["BeamLifetime"] = 0.9,
                ["CollideFriendly"] = false,
                ["Damage"] = 220,
                ["DamageRadius"] = 0,
                ["DamageType"] = "Normal",
                ["DisplayName"] = "Ultrachromatic Beam Generator",
                ["FireTargetLayerCapsTable"] = {
                    ["Land"] = "Land|Water|Seabed",
                    ["Water"] = "Land|Water|Seabed",
                },
                ["FiringRandomness"] = 0,
                ["FiringTolerance"] = 0,
                ["Label"] = "MainGun",
                ["LeadTarget"] = false,
                ["MaxRadius"] = 50,
                ["MuzzleChargeDelay"] = 0,
                ["MuzzleSalvoDelay"] = 0,
                ["MuzzleSalvoSize"] = 1,
                ["ProjectileLifetimeUsesMultiplier"] = 1.15,
                ["RackBones"] = {
                    [1] = {
                        ["MuzzleBones"] = {
                            [1] = "Turret_Muzzle",
                        },
                        ["RackBone"] = "Turret_Barrel",
                    },
                },
                ["RackFireTogether"] = false,
                ["RackRecoilDistance"] = -1,
                ["RackReloadTimeout"] = 10,
                ["RackSalvoChargeTime"] = 0,
                ["RackSalvoFiresAfterCharge"] = false,
                ["RackSalvoReloadTime"] = 0,
                ["RackSalvoSize"] = 1,
                ["RackSlavedToTurret"] = false,
                ["RangeCategory"] = "UWRC_DirectFire",
                ["RateOfFire"] = 0.25,
                ["TargetCheckInterval"] = 1,
                ["TargetPriorities"] = {
                    [1] = "SPECIALHIGHPRI",
                    [2] = "MOBILE",
                    [3] = "STRUCTURE DEFENSE",
                    [4] = "SPECIALLOWPRI",
                    [5] = "ALLUNITS",
                },
                ["TargetRestrictDisallow"] = "UNTARGETABLE",
                ["TrackingRadius"] = 1.15,
                ["TurretBoneMuzzle"] = "Turret_Muzzle",
                ["TurretBonePitch"] = "Turret_Barrel",
                ["TurretBoneYaw"] = "Turret",
                ["TurretDualManipulators"] = false,
                ["TurretPitch"] = 0,
                ["TurretPitchRange"] = 30,
                ["TurretPitchSpeed"] = 44,
                ["TurretYaw"] = 0,
                ["TurretYawRange"] = 180,
                ["TurretYawSpeed"] = 60,
                ["Turreted"] = true,
                ["WeaponCategory"] = "Direct Fire",
                ["WeaponUnpacks"] = false,
            },
            ["scoFaSourceWeaponIndex"] = 1,
        },
    },
}
