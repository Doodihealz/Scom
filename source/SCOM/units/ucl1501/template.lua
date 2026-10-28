-- ucl1501: Engineer
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
                    ["visionRadius"] = 18,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 0.8,
                    ["z"] = 0.8,
                },
                ["footprintSource"] = "Collision.SizeFallback",
                ["sourceSkirtPresent"] = false,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAL0105/UAL0105_unit.bp",
            ["sourceBlueprintSha256"] = "26a8ccae2bff7b45e5c41cbd44977fb3a6a9cc0ff32e71d1eeb7b25561c8aaf5",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER1FACTORY",
                [3] = "BUILTBYTIER2FACTORY",
                [4] = "BUILTBYTIER3FACTORY",
                [5] = "CAPTURE",
                [6] = "CONSTRUCTION",
                [7] = "ENGINEER",
                [8] = "HOVER",
                [9] = "LAND",
                [10] = "MOBILE",
                [11] = "PATROLHELPER",
                [12] = "PRODUCTSC1",
                [13] = "RECLAIM",
                [14] = "RECLAIMABLE",
                [15] = "REPAIR",
                [16] = "SELECTABLE",
                [17] = "SHOWQUEUE",
                [18] = "TECH1",
                [19] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0.5,
            ["sourceId"] = "UAL0105",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMaxBrake"] = 1.9,
            ["sourceMotionType"] = "RULEUMT_Hover",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucl1501",
            ["weapons"] = {},
        },
        ["scoCargo"] = {
            ["attachOffset"] = {
                [1] = -5.960464477539061e-09,
                [2] = 0.2740089416503903,
                [3] = 1.7054289477586181e-09,
            },
            ["attachmentReference"] = "source AttachPoint plus native .01 root clearance",
            ["canFire"] = true,
            ["cargoClass"] = 1,
            ["commander"] = false,
            ["portable"] = true,
            ["slots"] = {},
            ["sourceId"] = "UAL0105",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 73990,
                ["entry"] = "units/UAL0105/UAL0105_LOD0.scm",
                ["sha256"] = "544590d756ae7fa0ed522e6232688a74d315e32c5044e2a0dc07d132572f540b",
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
                ["x"] = 0.4,
                ["y"] = 0.4,
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
            ["x"] = 0.8,
            ["y"] = 0.7,
            ["z"] = 0.8,
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
        ["buildPower"] = 5,
        ["canBuild"] = "(Tags.CHOSEN * Tags.BUILDABLE_BY_T1_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 120,
            ["regen"] = 0,
            ["value"] = 120,
        },
    },
    ["economy"] = {
        ["buildTime"] = 260,
        ["cost"] = {
            ["alloys"] = 52,
            ["energy"] = 260,
        },
        ["storage"] = {
            ["alloys"] = 10,
            ["energy"] = 0,
        },
    },
    ["footprint"] = {
        ["x"] = 0.8,
        ["y"] = 0.8,
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
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_engineer.png",
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
        ["tpId"] = "ucl1501",
        ["unitTypeName"] = "Engineer",
    },
    ["intel"] = {
        ["visionRadius"] = 18,
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
            ["outerRadius"] = 18,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 18,
        },
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T1_FACTORY",
        [2] = "BUILDABLE_BY_T2_FACTORY",
        [3] = "BUILDABLE_BY_T3_FACTORY",
        [4] = "CHOSEN",
        [5] = "CONSTRUCTION",
        [6] = "ENGINEER",
        [7] = "HOVER",
        [8] = "LAND",
        [9] = "MOBILE",
        [10] = "TECH1",
        [11] = "SCFA_AEON",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_BUILTBYTIER1FACTORY",
        [14] = "SCFA_BUILTBYTIER2FACTORY",
        [15] = "SCFA_BUILTBYTIER3FACTORY",
        [16] = "SCFA_CAPTURE",
        [17] = "SCFA_CONSTRUCTION",
        [18] = "SCFA_ENGINEER",
        [19] = "SCFA_HOVER",
        [20] = "SCFA_LAND",
        [21] = "SCFA_MOBILE",
        [22] = "SCFA_PATROLHELPER",
        [23] = "SCFA_PRODUCTSC1",
        [24] = "SCFA_RECLAIM",
        [25] = "SCFA_RECLAIMABLE",
        [26] = "SCFA_REPAIR",
        [27] = "SCFA_SELECTABLE",
        [28] = "SCFA_SHOWQUEUE",
        [29] = "SCFA_TECH1",
        [30] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["build"] = {
                ["clipName"] = "AnimAopen01",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucl1501/LOD0/ucl1501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["sanAnimationPath"] = "Units/ucl1501/LOD0/ucl1501.sananimation",
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
                    ["x"] = 0.144,
                    ["y"] = 0.27499999999999997,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.22599999999999998,
                    ["z"] = 0.144,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.16000000000000003,
                    ["y"] = 0.296,
                    ["z"] = 0.128,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.144,
                    ["y"] = 0.39399999999999996,
                    ["z"] = -0.16000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.17600000000000002,
                    ["y"] = 0.37999999999999995,
                    ["z"] = 0.144,
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
                ["x"] = 0.4,
                ["y"] = 0.4,
            },
        },
    },
}
