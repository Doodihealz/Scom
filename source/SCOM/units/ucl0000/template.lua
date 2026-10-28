-- ucl0000: Armored Command Unit
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoOvercharge"] = {
            ["version"] = "1.0.0",
            ["projectileTemplate"] = "pocaeon",
        },
        ["buildBeamBones"] = {
            [1] = "Left_Turret_Muzzle",
        },
        ["buildBeamEffectName"] = "beam1",
        ["displayWreckOnDeath"] = false,
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -8.613288144973831e-09,
                [2] = 1.884772780897653,
                [3] = -0.10399187933587459,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = false,
            ["cargoClass"] = 3,
            ["commander"] = true,
            ["foldDuration"] = 2.6666667461395264,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UAL0001",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 425765,
                ["entry"] = "units/UAL0001/UAL0001_LOD0.scm",
                ["sha256"] = "d0495f99c76b1a79eed7f234f11d699e09ed70392415c7b0f9650fbaf2d7e414",
            },
            ["unfoldDuration"] = 0.5333333611488342,
        },
        ["scoCommanderEnhancementBaseWeaponIndex"] = 1,
        ["scoCommanderEnhancementShields"] = {
            ["aeonPersonal"] = 1,
        },
        ["scoCommanderEnhancements"] = {
            ["baseBuildCategory"] = "Tags.CHOSEN * Tags.BUILDABLE_BY_T1_ENGINEER",
            ["capabilities"] = {
                ["chronoStun"] = false,
                ["cloak"] = "visual-aura",
                ["manualMissiles"] = false,
                ["omni"] = false,
                ["sonar"] = false,
                ["spawnPods"] = false,
                ["stealth"] = "visual-aura",
                ["teleport"] = true,
            },
            ["faction"] = "Aeon",
            ["patchVersion"] = "1.0.4",
            ["radarPredeclared"] = false,
            ["sourceId"] = "UAL0001",
            ["version"] = "1.0.0",
        },
        ["scoGameplayCommanderBeam"] = "1.3.0",
        ["scoGroundFootfalls"] = {
            ["feet"] = {
                [1] = {
                    ["boneName"] = "Right_Exhaust",
                    ["contactOffset"] = {
                        ["x"] = 7.92227931047107e-05,
                        ["y"] = -0.010054137630828004,
                        ["z"] = -0.21780179167791208,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = 2.6906260334302834e-08,
                        ["y"] = 2.6822090169142963e-06,
                        ["z"] = -0.9999999999964027,
                    },
                    ["length"] = 0.4643963426351547,
                    ["liftHeight"] = 0.1113211687638121,
                    ["minimumHeight"] = -0.02629316515362648,
                    ["plantHeight"] = 0.01870683484637352,
                    ["right"] = {
                        ["x"] = -0.9999999999999885,
                        ["y"] = -1.5099579486514416e-07,
                        ["z"] = -2.690666533668182e-08,
                    },
                    ["width"] = 0.2557948976755142,
                },
                [2] = {
                    ["boneName"] = "Left_Exhaust",
                    ["contactOffset"] = {
                        ["x"] = -0.00042307628114221507,
                        ["y"] = -0.010054420948947825,
                        ["z"] = -0.21780177131267558,
                    },
                    ["decalPath"] = "Environment/SCOM/Footsteps/commander.sandecal",
                    ["forward"] = {
                        ["x"] = 2.7586053974714265e-07,
                        ["y"] = 2.6822090357098197e-06,
                        ["z"] = -0.9999999999963649,
                    },
                    ["length"] = 0.46439631283283234,
                    ["liftHeight"] = 0.11117536738485144,
                    ["minimumHeight"] = -0.026553660082430115,
                    ["plantHeight"] = 0.018446339917569884,
                    ["right"] = {
                        ["x"] = -0.9999999999999507,
                        ["y"] = -1.5099578784109348e-07,
                        ["z"] = -2.758609447503983e-07,
                    },
                    ["width"] = 0.2557949051260948,
                },
            },
            ["groundOffset"] = 0,
            ["modelPath"] = "Units/ucl0000/LOD0/ucl0000_lod0.sanmodel",
            ["referenceAltitude"] = "Ground",
            ["unit"] = "ucl0000",
        },
        ["scoIdleResetLocomotion"] = true,
        ["scomRestoredAnimations"] = {
            ["assetSha256"] = "c1e02b3567bc5369cdf62836291d004b1eac57ca63a4d821c17b53ce52cffb9b",
            ["runtimeRate"] = 1,
            ["sourceDeathRateRandomization"] = false,
            ["sourceId"] = "UAL0001",
            ["transportEventBinding"] = "source cargo load/unload lifecycle",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = -0.004,
                ["y"] = 0.958,
                ["z"] = 0.22,
            },
            ["size"] = {
                ["x"] = 1.3,
                ["y"] = 1.5,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1305",
        },
        ["onDamagedAlert"] = {
            ["looping"] = false,
            ["name"] = "dx_uni_evaf_Pxx_Sc",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod0000",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = -0.004,
            ["y"] = 0.958,
            ["z"] = 0.22,
        },
        ["collisionSize"] = {
            ["x"] = 1.1,
            ["y"] = 1.92,
            ["z"] = 1.3,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Left_Turret_Muzzle",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.CHOSEN * Tags.BUILDABLE_BY_T1_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 10,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 11000,
            ["regen"] = 10,
            ["value"] = 11000,
        },
        ["shields"] = {
            [1] = {
                ["boneName"] = "Root",
                ["entityName"] = "SCOAeonPersonalShieldEntity",
                ["max"] = 1,
                ["name"] = "Commander Enhancement Shield",
                ["offset"] = {
                    ["x"] = -0.004,
                    ["y"] = 0.15,
                    ["z"] = 0.22,
                },
                ["radii"] = {
                    ["x"] = 1.5,
                    ["y"] = 1.5,
                    ["z"] = 1.5,
                },
                ["rechargeHPRatio"] = 1,
                ["rechargeTime"] = 5,
                ["regen"] = 0,
                ["regenDelay"] = 1,
                ["scoCommanderEnhancementShieldId"] = "aeonPersonal",
                ["type"] = "Bubble",
                ["value"] = 1,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 80000,
        ["cost"] = {
            ["alloys"] = 10000,
            ["energy"] = 100000,
        },
        ["initial"] = {
            ["alloys"] = 650,
            ["energy"] = 4000,
        },
        ["production"] = {
            ["alloys"] = 1,
            ["energy"] = 20,
        },
        ["storage"] = {
            ["alloys"] = 650,
            ["energy"] = 5000,
        },
    },
    ["footprint"] = {
        ["x"] = 1.2,
        ["y"] = 1.4,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "ChosenCommander",
        },
        ["displayName"] = "Armored Command Unit",
        ["icon"] = {
            ["shape"] = "bot2",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_bot2_direct.png",
        ["iconUIBuildSortPriority"] = 1000,
        ["iconUIType"] = "land",
        ["name"] = "Armored Command Unit",
        ["orders"] = {
            ["Assist"] = true,
            ["Attack"] = true,
            ["AttackMove"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Pause"] = true,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 989.4,
            ["WaterSurface"] = 989.4,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["Shield"] = true,
        },
        ["tpId"] = "ucl0000",
        ["unitTypeName"] = "ChosenCommander",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 1.7,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
            [2] = "SeabedSmall",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
            [2] = "SeabedSmall",
        },
        ["hullWaterSensor"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 2.8,
                ["z"] = 0,
            },
        },
        ["referenceAltitude"] = "Ground",
        ["rotationSpeed"] = 90,
        ["sortOrder"] = 1,
        ["speed"] = 1.7,
        ["terrainAlignmentFactor"] = 1,
        ["type"] = "LegsLand",
        ["walkAnimation"] = {
            ["authoredSpeed"] = 0.68,
        },
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 10,
        },
        [6] = {
            ["innerRadius"] = 1,
            ["outerRadius"] = 22,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 26,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 26,
        },
    },
    ["tags"] = {
        [1] = "ALLOYS_PRODUCTION",
        [2] = "ALLOYS_STORAGE",
        [3] = "ANTI_SURFACE",
        [4] = "CAPTURE",
        [5] = "CHOSEN",
        [6] = "COMMAND",
        [7] = "CONSTRUCTION",
        [8] = "DIRECT_FIRE",
        [9] = "ECONOMIC",
        [10] = "ENERGY_PRODUCTION",
        [11] = "ENERGY_STORAGE",
        [12] = "HARVEST",
        [13] = "LAND",
        [14] = "MOBILE",
        [15] = "SEABED",
        [16] = "TECH1",
        [17] = "SCFA_AEON",
        [18] = "SCFA_ALLUNITS",
        [19] = "SCFA_CAPTURE",
        [20] = "SCFA_COMMAND",
        [21] = "SCFA_CONSTRUCTION",
        [22] = "SCFA_DIRECTFIRE",
        [23] = "SCFA_ECONOMIC",
        [24] = "SCFA_ENERGYPRODUCTION",
        [25] = "SCFA_ENGINEER",
        [26] = "SCFA_LAND",
        [27] = "SCFA_MASSFABRICATION",
        [28] = "SCFA_MASSPRODUCTION",
        [29] = "SCFA_MOBILE",
        [30] = "SCFA_OVERLAYDIRECTFIRE",
        [31] = "SCFA_OVERLAYOMNI",
        [32] = "SCFA_PATROLHELPER",
        [33] = "SCFA_PRODUCTSC1",
        [34] = "SCFA_RECLAIM",
        [35] = "SCFA_REPAIR",
        [36] = "SCFA_SELECTABLE",
        [37] = "SCFA_SHOWQUEUE",
        [38] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["cargoFold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl0000/LOD0/ucl0000.sananimation",
            },
            ["cargoUnfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl0000/LOD0/ucl0000.sananimation",
            },
            ["fold"] = {
                ["clipName"] = "AnimFold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl0000/LOD0/ucl0000.sananimation",
            },
            ["run"] = {
                ["authoredSpeed"] = 0.68,
                ["clipName"] = "AnimWalk01",
                ["sanAnimationPath"] = "Units/ucl0000/LOD0/ucl0000.sananimation",
                ["startSpeed"] = 0.05,
            },
            ["unfold"] = {
                ["clipName"] = "AnimUnfold",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl0000/LOD0/ucl0000.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl0000/LOD0/ucl0000.sananimation",
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
                    ["particleName"] = "VFX/AeonProjectiles/Death/vcd0301_death_rdu.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.194,
                    ["y"] = 1.438,
                    ["z"] = -0.04000000000000001,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.24600000000000002,
                    ["y"] = 1.3035999999999999,
                    ["z"] = 0.45399999999999996,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.21600000000000003,
                    ["y"] = 1.4956,
                    ["z"] = 0.42800000000000005,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.194,
                    ["y"] = 1.7643999999999997,
                    ["z"] = -0.04000000000000001,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.24600000000000002,
                    ["y"] = 1.726,
                    ["z"] = 0.45399999999999996,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 72,
            ["lod1distance"] = 189,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = -0.004,
                ["y"] = 0.958,
                ["z"] = 0.22,
            },
            ["size"] = {
                ["x"] = 1.3,
                ["y"] = 1.5,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["aimControllers"] = {
                [1] = {
                    ["aimBone"] = "Right_Turret_Muzzle",
                    ["aimGravity"] = {
                        ["x"] = 0,
                        ["y"] = -4.9,
                        ["z"] = 0,
                    },
                    ["aimTolerance"] = 2,
                    ["defaultPitchAdjustment"] = 0,
                    ["defaultYawAdjustment"] = 0,
                    ["leadTarget"] = true,
                    ["pitchBone"] = "Right_Turret",
                    ["pitchMax"] = 90,
                    ["pitchMin"] = -90,
                    ["pitchSpeed"] = 90,
                    ["poseResetTime"] = 3,
                    ["projectileSpeed"] = 35,
                    ["solverType"] = "LowArc",
                    ["yawBone"] = "Torso",
                    ["yawMax"] = 180,
                    ["yawMin"] = -180,
                    ["yawSpeed"] = 90,
                },
            },
            ["audio"] = {
                ["onFire"] = {
                    ["looping"] = false,
                    ["name"] = "acom1120",
                },
            },
            ["collideFriendly"] = false,
            ["damage"] = 100,
            ["damageFriendly"] = false,
            ["damageRadius"] = 0,
            ["damageType"] = "Normal",
            ["effects"] = {
                ["onFire"] = "VFX/SCOM/Source/CommanderBrightness/8303b30e7ac4b7642b08.sanvfx",
            },
            ["firingRandomness"] = 0,
            ["layerTargetLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["layerWeaponLimits"] = {
                [1] = "Land",
                [2] = "WaterSurface",
            },
            ["muzzleGroupChargeDelay"] = 0,
            ["muzzleGroupTimeOut"] = -1,
            ["muzzleGroups"] = {
                [1] = {
                    ["muzzles"] = {
                        [1] = "Right_Turret_Muzzle",
                    },
                },
            },
            ["muzzleSalvoDelay"] = 0,
            ["muzzleSalvoSize"] = 1,
            ["muzzles"] = {
                ["Right_Turret_Muzzle"] = {
                    ["aimController"] = "Right_Turret_Muzzle",
                },
            },
            ["projectileLifetime"] = 1,
            ["projectileTemplate"] = "psf0165",
            ["rangeMax"] = 22,
            ["rangeMin"] = 1,
            ["rangeRingType"] = "DirectFire",
            ["rangeTracking"] = 1.1,
            ["reloadTime"] = 1,
            ["scoCommanderEnhancementBaseWeapon"] = true,
            ["scoFaProjectileIdentity"] = {
                ["sourceBlueprintSha256"] = "2bf0ec1910fb2ca15841927ced82fefd0b01d8b25ab7f0e34921f64c475bef21",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "RightDisruptor",
                ["sourceProjectile"] = "/projectiles/ADFQuantumDisruptor01/ADFQuantumDisruptor01_proj.bp",
            },
            ["targetWaterLimits"] = "Above",
            ["waterSensor"] = {
                ["bone"] = "Right_Turret_Muzzle",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        [2] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 5000,
            ["damageFriendly"] = true,
            ["damageRadius"] = 15,
            ["damageType"] = "Normal",
        },
    },
}
