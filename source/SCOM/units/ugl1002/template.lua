-- ugl1002: Mantis
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Turret_Muzzle_01",
            [2] = "Turret_Muzzle_02",
        },
        ["faDeathAnimation"] = {
            ["class"] = {
                ["name"] = "GuardLandUnit",
                ["owner"] = "unitsDefaultGuard",
                ["source"] = "CWalkingLandUnit",
            },
            ["clips"] = {
                ["death01"] = {
                    ["duration"] = 1,
                    ["frames"] = 31,
                    ["sha256"] = "f99f5ce7448b4fd17434fe118a53ca857eb7d886dd0f6ccc63c1997d5eca2e13",
                    ["source"] = "units/URL0107/URL0107_Adeath01.sca",
                    ["weight"] = 1,
                },
                ["death02"] = {
                    ["duration"] = 1,
                    ["frames"] = 31,
                    ["sha256"] = "3470f69d514164aa7a24be626e9da3c9584ad1510673cadafb4bfe5a12e7a152",
                    ["source"] = "units/URL0107/URL0107_Adeath02.sca",
                    ["weight"] = 1,
                },
            },
            ["existingSanAnimationSha256"] = "09b4bf91da58156c74204723ce6cfe0c7fdccd820252a0a3b32e51a77f2c1825",
            ["limitations"] = {
                ["hostPlayAnimationThirdArgument"] = "cross-fade time, not playback speed",
                ["sourceDeathRateRandomization"] = "0.75-1.25 unavailable; nominal rate used",
            },
            ["mapping"] = "URL0107 -> ugl1002",
            ["runtimeRate"] = 1,
            ["sanAnimationSha256"] = "e0c883e2a7ecc249443a217c863fbbab5d4b3c3595d5a09fb9b6b045c1f03695",
            ["selection"] = "deterministic equal-weight unit-index parity",
            ["sourceBlueprint"] = "units/URL0107/URL0107_unit.bp",
            ["sourceBlueprintSha256"] = "303c473d3df0a0f0697dcaa7c102295ce3e615c89c3e69083fb84d13086d4b09",
            ["sourceCybranUnitsLuaSha256"] = "f126ce26875ef8b51f240296af8bd0d86ff07e3fc4b2a5ebf0a5ba4478687411",
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceRate"] = {
                ["maximum"] = 1.25,
                ["minimum"] = 0.75,
            },
            ["sourceScript"] = "units/URL0107/URL0107_script.lua",
            ["sourceScriptSha256"] = "aeb8eb831f99832ed2b35a060beac1f836700b2b8cd28428c66f3bea8155c640",
            ["sourceUnitLuaSha256"] = "ced522e17b204aedfe196706fd3f3421af5f041cf692248ef56d43c97b52cd67",
            ["sourceUnitsArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -4.439913077192159e-09,
                [2] = 0.5863432989439387,
                [3] = -0.1260541607353014,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["foldDuration"] = 1.6666666269302368,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "URL0107",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 75977,
                ["entry"] = "units/URL0107/URL0107_LOD0.scm",
                ["sha256"] = "579d2e944df441cd965b4c453e4b76c069fb2a54cfa6e7d5934c6c02c703860a",
            },
            ["unfoldDuration"] = 1.6666666269302368,
        },
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Leg_Lower_01",
                    ["contactOffset"] = {
                        ["x"] = 5.7999094176669486e-08,
                        ["y"] = 0.016322412262111452,
                        ["z"] = 0.38308110967162334,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.7071067826204933,
                        ["y"] = 0.5792281000561723,
                        ["z"] = 0.4055795927773135,
                    },
                    ["length"] = 0.014577507972717285,
                    ["liftHeight"] = 0.3087731421777018,
                    ["minimumHeight"] = -0.01844654641505103,
                    ["plantHeight"] = 0.02655345358494897,
                    ["right"] = {
                        ["x"] = 0.707106779752589,
                        ["y"] = 0.579227992826818,
                        ["z"] = 0.40557975091680726,
                    },
                    ["width"] = 0.014577507972717285,
                },
                [2] = {
                    ["boneName"] = "Leg_Lower_02",
                    ["contactOffset"] = {
                        ["x"] = 1.1950040081434854e-07,
                        ["y"] = 0.016322366877140948,
                        ["z"] = 0.38308109095153603,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.7071070944328853,
                        ["y"] = 0.5792277645090974,
                        ["z"] = 0.4055795283596998,
                    },
                    ["length"] = 0.014577478170394897,
                    ["liftHeight"] = 0.3175427742169927,
                    ["minimumHeight"] = -0.018276035892181547,
                    ["plantHeight"] = 0.02672396410781845,
                    ["right"] = {
                        ["x"] = 0.7071064679400676,
                        ["y"] = -0.5792282205360448,
                        ["z"] = -0.40557996934263085,
                    },
                    ["width"] = 0.014577537775039673,
                },
                [3] = {
                    ["boneName"] = "Leg_Lower_04",
                    ["contactOffset"] = {
                        ["x"] = 7.749849174898404e-08,
                        ["y"] = 0.016322325817915095,
                        ["z"] = 0.3830811223386925,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = -0.7071067835833512,
                        ["y"] = -0.57922786758612,
                        ["z"] = -0.4055799231002988,
                    },
                    ["length"] = 0.014577537775039673,
                    ["liftHeight"] = 0.2028658765690701,
                    ["minimumHeight"] = -0.020306807336611915,
                    ["plantHeight"] = 0.024693192663388083,
                    ["right"] = {
                        ["x"] = -0.7071067787897118,
                        ["y"] = 0.5792276988018055,
                        ["z"] = 0.40558017250650036,
                    },
                    ["width"] = 0.014577537775039673,
                },
                [4] = {
                    ["boneName"] = "Leg_Lower_03",
                    ["contactOffset"] = {
                        ["x"] = 8.681139137059479e-08,
                        ["y"] = 0.01632237502228706,
                        ["z"] = 0.38308113603085925,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/contact.sandecal",
                    ["forward"] = {
                        ["x"] = 0.7071066203168204,
                        ["y"] = -0.5792280490058026,
                        ["z"] = -0.4055799486526128,
                    },
                    ["length"] = 0.014577537775039673,
                    ["liftHeight"] = 0.18106623290405302,
                    ["minimumHeight"] = -0.020088892293345345,
                    ["plantHeight"] = 0.024911107706654653,
                    ["right"] = {
                        ["x"] = -0.7071069420561815,
                        ["y"] = -0.5792275549951218,
                        ["z"] = -0.4055800932372419,
                    },
                    ["width"] = 0.014577537775039673,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/ugl1002/LOD0/ugl1002_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "ugl1002",
        },
        ["scoIdleResetLocomotion"] = true,
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.32,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 0.9,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aglu1310",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "agod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.15,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.7,
            ["y"] = 0.5,
            ["z"] = 0.9,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Turret_Muzzle_01",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 1,
        },
        ["buildPower"] = 1,
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 270,
            ["regen"] = 0,
            ["value"] = 270,
        },
    },
    ["economy"] = {
        ["buildTime"] = 260,
        ["cost"] = {
            ["alloys"] = 52,
            ["energy"] = 273,
        },
    },
    ["footprint"] = {
        ["x"] = 0.7,
        ["y"] = 0.9,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultGuard",
            [2] = "GuardLandUnit",
        },
        ["displayName"] = "Mantis",
        ["icon"] = {
            ["shape"] = "bot1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_bot1_direct.png",
        ["iconUIBuildSortPriority"] = 90,
        ["iconUIType"] = "land",
        ["name"] = "Mantis",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 36.8,
            ["WaterSurface"] = 50.5,
        },
        ["tpId"] = "ugl1002",
        ["unitTypeName"] = "GuardT1Bot",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["movement"] = {
        ["acceleration"] = 3.6,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["deceleration"] = 3.6,
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 80,
        ["sortOrder"] = 1,
        ["speed"] = 3.6,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 0.45,
        },
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
        [6] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
    },
    ["tags"] = {
        [1] = "ANTI_SURFACE",
        [2] = "BOT",
        [3] = "BUILDABLE_BY_T1_FACTORY",
        [4] = "BUILDABLE_BY_T2_FACTORY",
        [5] = "BUILDABLE_BY_T3_FACTORY",
        [6] = "DIRECT_FIRE",
        [7] = "GUARD",
        [8] = "LAND",
        [9] = "MOBILE",
        [10] = "RAIDER",
        [11] = "TECH1",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_BOT",
        [14] = "SCFA_BUILTBYTIER1FACTORY",
        [15] = "SCFA_BUILTBYTIER2FACTORY",
        [16] = "SCFA_BUILTBYTIER3FACTORY",
        [17] = "SCFA_CYBRAN",
        [18] = "SCFA_DIRECTFIRE",
        [19] = "SCFA_LAND",
        [20] = "SCFA_MOBILE",
        [21] = "SCFA_OVERLAYDIRECTFIRE",
        [22] = "SCFA_PRODUCTSC1",
        [23] = "SCFA_RECLAIMABLE",
        [24] = "SCFA_REPAIR",
        [25] = "SCFA_SELECTABLE",
        [26] = "SCFA_TECH1",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimCargoFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl1002/LOD0/ugl1002.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimCargoUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl1002/LOD0/ugl1002.sananimation",
            },
            ["death01"] = {
                ["clipName"] = "AnimDeath01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl1002/LOD0/ugl1002.sananimation",
            },
            ["death02"] = {
                ["clipName"] = "AnimDeath02",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ugl1002/LOD0/ugl1002.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 0.45,
                ["clipName"] = "AnimWalk01",
                ["sanAnimationPath"] = "Units/ugl1002/LOD0/ugl1002.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ugl1002/LOD0/ugl1002.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.5,
                ["y"] = 0.5,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 15,
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
                    ["audioName"] = "Sounds/videvo.net_royalFree_soundEffects/Explosions/mi explosion 03 hpx.ogg",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vgd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.275,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.24,
                    ["z"] = 0.162,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.13999999999999999,
                    ["y"] = 0.29000000000000004,
                    ["z"] = 0.14400000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.126,
                    ["y"] = 0.36,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.154,
                    ["y"] = 0.35,
                    ["z"] = 0.162,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 64,
            ["lod1distance"] = 166,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.32,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.85,
                ["y"] = 0.9,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Turret_Muzzle_01",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Turret_Barrel",
                    ["pitchMax"] = 45,
                    ["pitchMin"] = -45,
                    ["pitchSpeed"] = 100,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 25,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Torso",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 80,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "agom1116",
                },
            },
            ["damage"] = 8,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/ugl1002/muzzle_laserarms.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_01",
                    },
                },
                [2] = {
                    ["muzzles"] = {
                        [1] = "Turret_Muzzle_02",
                    },
                },
            },
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Turret_Muzzle_01"] = {
                    ["aimController"] = "Turret_Muzzle_01",
                },
                ["Turret_Muzzle_02"] = {
                    ["aimController"] = "Turret_Muzzle_01",
                },
            },
            ["projectileLifetime"] = 2.875,
            ["projectileTemplate"] = "psf0017",
            ["rangeMax"] = 18,
            ["rangeMin"] = 0,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.15,
            ["reloadTime"] = 0.3333333333333333,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "af6d6d5a993f916fce71159d06b894d8e1269fe8621913b4064fc668f402ac6b",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "LaserArms",
                ["sourceProjectile"] = "/projectiles/CDFLaserHeavy01/CDFLaserHeavy01_proj.bp",
            },
            ["scoSourceMuzzle"] = {
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "LaserArms",
            },
            ["targetWaterLimits"] = "Above",
        },
    },
}
