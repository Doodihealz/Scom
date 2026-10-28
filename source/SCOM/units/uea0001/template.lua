-- uea0001: Engineering Drone
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Root",
        },
        ["buildBeamEffectName"] = "beam1",
        ["faSourceContract"] = {
            ["sanctuaryDockingBridge"] = "host shoulder transform plus client render late-latch",
            ["sourceAircraftMaxAirspeed"] = 4,
            ["sourceAircraftMinAirspeed"] = 3,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UEA0001/UEA0001_unit.bp",
            ["sourceBlueprintSha256"] = "5d88d570504d583c35ab5683a62a5cb34fb26105ab990fc16ee3bd91e2f6d2e8",
            ["sourceBuildableCategory"] = "BUILTBYCOMMANDER UEF",
            ["sourceId"] = "UEA0001",
            ["sourceInitialAutoMode"] = true,
            ["sourcePhysicsMaxSpeed"] = 10,
            ["sourcePhysicsMinSpeedPercent"] = 0.85,
            ["sourcePodDockCommand"] = true,
            ["sourceSelectionThickness"] = 1.2,
            ["sourceStagingPlatformCategory"] = "PODSTAGINGPLATFORM",
            ["sourceTurnRadius"] = 100,
            ["sourceUniformScale"] = 0.1,
        },
        ["scoCargo"] = {
            ["airPortable"] = true,
            ["attachOffset"] = {
                [1] = 0,
                [2] = 0,
                [3] = 0,
            },
            ["canFire"] = false,
            ["cargoClass"] = 1,
            ["portable"] = false,
            ["slots"] = {},
            ["unfoldDuration"] = 0,
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.3,
                ["y"] = 0.3,
            },
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0,
            ["z"] = 0.07,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 0.5,
            ["z"] = 1,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.1,
        },
        ["buildPower"] = 5,
        ["canBuild"] = "(Tags.EDA * Tags.BUILDABLE_BY_T1_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 5,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 6,
            ["regen"] = 0,
            ["value"] = 6,
        },
    },
    ["economy"] = {
        ["buildTime"] = 400,
        ["cost"] = {
            ["alloys"] = 160,
            ["energy"] = 1600,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultEDA",
            [2] = "EDAAirUnit",
        },
        ["displayName"] = "Engineering Drone",
        ["icon"] = {
            ["shape"] = "land1",
            ["symbol"] = "engineer",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_land1_engineer.png",
        ["iconUIBuildSortPriority"] = 105,
        ["iconUIType"] = "air",
        ["name"] = "C-D1 \"Rover\"",
        ["orders"] = {
            ["Assist"] = true,
            ["Capture"] = true,
            ["Harvest"] = true,
            ["Move"] = true,
            ["Pause"] = true,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["threat"] = 0,
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "uea0001",
        ["unitTypeName"] = "EDACommanderEngineeringDrone",
    },
    ["intel"] = {
        ["visionRadius"] = 12,
    },
    ["movement"] = {
        ["acceleration"] = 10,
        ["air"] = true,
        ["airHover"] = false,
        ["altitudeJitterFactor"] = 0.25,
        ["bankFactor"] = 0.1,
        ["bankHalfLife"] = 0.075647079736603,
        ["collisionMaskDefault"] = {
            [1] = "Air",
        },
        ["collisionMaskSpawn"] = {
            [1] = "LandSmall",
        },
        ["maxBankDegrees"] = 3,
        ["minSpeed"] = 3,
        ["orbitRange"] = 1.7188733853924696,
        ["orbitSpeed"] = 3,
        ["patternBySituation"] = {
            ["assist"] = "circle",
            ["attack"] = "strafe",
            ["hold"] = "circle",
            ["move"] = "cruise",
        },
        ["patterns"] = {
            ["circle"] = {
                ["circle"] = {
                    ["radius"] = 1.7188733853924696,
                    ["speed"] = 3,
                },
                ["mode"] = "Circle",
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 2.5,
                        ["y"] = 10,
                    },
                    ["offset"] = {
                        ["x"] = -1,
                        ["y"] = 1,
                    },
                },
            },
            ["cruise"] = {
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 2.5,
                        ["y"] = 10,
                    },
                    ["offset"] = {
                        ["x"] = -1,
                        ["y"] = 1,
                    },
                },
            },
            ["strafe"] = {
                ["mode"] = "Strafe",
                ["strafe"] = {
                    ["matchTargetSpeed"] = true,
                    ["runOutLength"] = 14.324,
                },
                ["vertical"] = {
                    ["duration"] = {
                        ["x"] = 2.5,
                        ["y"] = 10,
                    },
                    ["offset"] = {
                        ["x"] = -1,
                        ["y"] = 1,
                    },
                },
            },
        },
        ["preferredAltitude"] = 3,
        ["referenceAltitude"] = "GroundOrWater",
        ["rotationSpeed"] = 100,
        ["sortOrder"] = 6,
        ["speed"] = 4,
        ["terrainAlignmentFactor"] = 0,
        ["type"] = "Plane",
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 5,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 12,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 12,
        },
    },
    ["tags"] = {
        [1] = "AIR",
        [2] = "CAPTURE",
        [3] = "CONSTRUCTION",
        [4] = "EDA",
        [5] = "ENGINEER",
        [6] = "HARVEST",
        [7] = "MOBILE",
        [8] = "POD",
        [9] = "REPAIR",
        [10] = "TECH1",
        [11] = "SCFA_AIR",
        [12] = "SCFA_ALLUNITS",
        [13] = "SCFA_CAPTURE",
        [14] = "SCFA_ENGINEER",
        [15] = "SCFA_MOBILE",
        [16] = "SCFA_POD",
        [17] = "SCFA_RECLAIM",
        [18] = "SCFA_RECLAIMABLE",
        [19] = "SCFA_REPAIR",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_TECH1",
        [22] = "SCFA_UEF",
        [23] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.3,
                ["y"] = 0.3,
            },
            ["mainBarOffSet"] = {
                ["x"] = 0,
                ["y"] = 3,
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
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.125,
                    ["z"] = -0.13,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.09,
                    ["z"] = 0.25,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.14,
                    ["z"] = 0.23,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.21,
                    ["z"] = -0.13,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.2,
                    ["z"] = 0.25,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 150,
            ["lod1distance"] = 150,
        },
        ["selection"] = {
            ["size"] = {
                ["x"] = 0.3,
                ["y"] = 0.3,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 10,
            ["damageFriendly"] = true,
            ["damageRadius"] = 1,
            ["damageType"] = "Normal",
        },
    },
}
