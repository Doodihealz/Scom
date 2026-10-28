-- ucl3501: Engineer
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonEngineerBuildAnimation"] = {
            ["animationKey"] = "build",
            ["authoredRate"] = 1,
            ["durationSeconds"] = 1.6666666269302368,
            ["restAnimationKey"] = "walk",
        },
        ["buildBeamBones"] = {
            [1] = "Muzzle",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 26,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 0.9,
                    ["z"] = 0.9,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAL0309/UAL0309_unit.bp",
            ["sourceBlueprintSha256"] = "f63765b2f4de5013503bbab1ea12d4462c9fb5b3965a3ffbc1f257f91b47bb29",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER3FACTORY",
                [3] = "CAPTURE",
                [4] = "CONSTRUCTION",
                [5] = "ENGINEER",
                [6] = "HOVER",
                [7] = "LAND",
                [8] = "MOBILE",
                [9] = "PATROLHELPER",
                [10] = "PRODUCTSC1",
                [11] = "RECLAIM",
                [12] = "RECLAIMABLE",
                [13] = "REPAIR",
                [14] = "SELECTABLE",
                [15] = "SHOWQUEUE",
                [16] = "TECH3",
                [17] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0.5,
            ["sourceId"] = "UAL0309",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 1.9,
            ["sourceMotionType"] = "RULEUMT_Hover",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl3501",
            ["weapons"] = {},
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -2.6014220996892036e-08,
                [2] = 0.2647562146186824,
                [3] = 1.2735171207884551e-08,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 3,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UAL0309",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 82214,
                ["entry"] = "units/UAL0309/UAL0309_lod0.scm",
                ["sha256"] = "7ae4257536144b234a69557e0c8f30ee44722387f4bbc8ead9b8ca50b3560bec",
            },
        },
        ["scoGameplayEngineerBeam"] = "1.0.0",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.09999999999999998,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
        },
    },
    ["audio"] = {
        ["engine"] = {
            ["looping"] = true,
            ["name"] = "aclu1410",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod1110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.09999999999999998,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.9,
            ["y"] = 0.7,
            ["z"] = 0.9,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Muzzle",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.05,
        },
        ["buildPower"] = 20,
        ["canBuild"] = "(Tags.CHOSEN * Tags.BUILDABLE_BY_T3_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 1180,
            ["regen"] = 0,
            ["value"] = 1180,
        },
    },
    ["economy"] = {
        ["buildTime"] = 2100,
        ["cost"] = {
            ["alloys"] = 490,
            ["energy"] = 3150,
        },
        ["storage"] = {
            ["alloys"] = 40,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 0.9,
        ["y"] = 0.9,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortEngineer",
        },
        ["displayName"] = "Engineer",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "engineer",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_land1_engineer.png",
        ["iconUIBuildSortPriority"] = 150,
        ["iconUIType"] = "amphibious",
        ["name"] = "Engineer",
        ["orders"] = {
            ["Assist"] = true,
            ["AttackMove"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Move"] = true,
            ["Patrol"] = true,
            ["Pause"] = false,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "ucl3501",
        ["unitTypeName"] = "Engineer",
    },
    ["intel"] = {
        ["visionRadius"] = 26,
    },
    ["movement"] = {
        ["acceleration"] = 1.9,
        ["altitudeJitterFactor"] = 0,
        ["bankFactor"] = 0,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
            [2] = "Sea",
        },
        ["deceleration"] = 1.9,
        ["maxBankDegrees"] = 0,
        ["orbitRange"] = 0,
        ["orbitSpeed"] = 0,
        ["preferredAltitude"] = 0.5,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 120,
        ["sortOrder"] = 6,
        ["speed"] = 1.9,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Hover",
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
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
        [1] = "BUILDABLE_BY_T3_FACTORY",
        [2] = "CHOSEN",
        [3] = "CONSTRUCTION",
        [4] = "ENGINEER",
        [5] = "HOVER",
        [6] = "LAND",
        [7] = "MOBILE",
        [8] = "TECH3",
        [9] = "SCFA_AEON",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYTIER3FACTORY",
        [12] = "SCFA_CAPTURE",
        [13] = "SCFA_CONSTRUCTION",
        [14] = "SCFA_ENGINEER",
        [15] = "SCFA_HOVER",
        [16] = "SCFA_LAND",
        [17] = "SCFA_MOBILE",
        [18] = "SCFA_PATROLHELPER",
        [19] = "SCFA_PRODUCTSC1",
        [20] = "SCFA_RECLAIM",
        [21] = "SCFA_RECLAIMABLE",
        [22] = "SCFA_REPAIR",
        [23] = "SCFA_SELECTABLE",
        [24] = "SCFA_SHOWQUEUE",
        [25] = "SCFA_TECH3",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimOpen",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl3501/LOD0/ucl3501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl3501/LOD0/ucl3501.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd1101_death_land_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.27499999999999997,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.22599999999999998,
                    ["z"] = 0.162,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18000000000000002,
                    ["y"] = 0.296,
                    ["z"] = 0.14400000000000002,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.162,
                    ["y"] = 0.39399999999999996,
                    ["z"] = -0.18000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.198,
                    ["y"] = 0.37999999999999995,
                    ["z"] = 0.162,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 66,
            ["lod1distance"] = 173,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.09999999999999998,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
            },
        },
    },
}
