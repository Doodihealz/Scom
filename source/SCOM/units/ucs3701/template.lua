-- ucs3701: Oculus
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["aeonStructureMotion"] = {
            ["aimBoneOwnership"] = "Sanctuary runtime only",
            ["kind"] = "intel_rotor_triple",
            ["mapping"] = "UAB3104 -> ucs3701",
            ["rotatorCount"] = 3,
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB3104/UAB3104_unit.bp",
            ["sourceBlueprintSha256"] = "8516e303d6a5eebc125dff13ec3ab8d11f036d44c46c5b565f56ddd47daea626",
            ["sourceClips"] = {},
            ["sourceLuaArchiveSha256"] = "3632a3294fc01a07ebe017dfd12ce4ff655c2d019934f1d7a784fbc1d4f314bb",
            ["sourceModelSha256"] = "5e2d3e6a20232a4fe9d1dc7ee0a4ed8e7de33713b1c72b443e1cdee6c9f7da59",
            ["sourceScript"] = "units/UAB3104/UAB3104_script.lua",
            ["sourceScriptSha256"] = "7e977e976318a472f9891d1887128118a7b2fbe1cfc2f31943f2f61c17011e66",
            ["stateOwner"] = "Effective radarDetector enabled y-speeds accelerate at 20 to 30/60/120 in source creation order; player toggle or energy outage spins all three down at 20.",
            ["targetAnimation"] = {
                ["bytes"] = 4385,
                ["path"] = "Units/ucs3701/LOD0/ucs3701.sananimation",
                ["sha256"] = "2b543294b5bbc631b428caee4804e79bdfebc90516fe1cdd707e37dd37b106b3",
            },
            ["targetClipCount"] = 1,
            ["targetModel"] = {
                ["bytes"] = 317593,
                ["path"] = "Units/ucs3701/LOD0/ucs3701_lod0.sanmodel",
                ["sha256"] = "77ad5065b7f6fd89636198014e6f015f86139f2f5555c52f58e33a93a9277e87",
            },
            ["targetSkeleton"] = {
                ["bytes"] = 5989,
                ["path"] = "Units/ucs3701/LOD0/ucs3701.sanskeleton",
                ["sha256"] = "b858779b442c3f00cbcdafa571157e04f014dba750f595088c8ae08fa82344f1",
            },
            ["version"] = "1.0.2",
        },
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {
                    ["omniRadius"] = 200,
                    ["reactivateTime"] = 5,
                    ["showIntelOnSelect"] = true,
                },
                ["runtimeSupported"] = {
                    ["radarRadius"] = 600,
                    ["visionRadius"] = 30,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 1,
                    ["z"] = 1,
                },
                ["footprintSource"] = "Footprint.Size",
                ["sourceSkirt"] = {
                    ["offsetX"] = -0.5,
                    ["offsetZ"] = -0.5,
                    ["sizeX"] = 2,
                    ["sizeZ"] = 2,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB3104/UAB3104_unit.bp",
            ["sourceBlueprintSha256"] = "8516e303d6a5eebc125dff13ec3ab8d11f036d44c46c5b565f56ddd47daea626",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "BUILTBYTIER3COMMANDER",
                [3] = "BUILTBYTIER3ENGINEER",
                [4] = "DRAGBUILD",
                [5] = "INTELLIGENCE",
                [6] = "OMNI",
                [7] = "OVERLAYOMNI",
                [8] = "OVERLAYRADAR",
                [9] = "PRODUCTSC1",
                [10] = "RECLAIMABLE",
                [11] = "SELECTABLE",
                [12] = "SIZE4",
                [13] = "SORTINTEL",
                [14] = "STRUCTURE",
                [15] = "TECH3",
                [16] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB3104",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "UAB3201",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs3701",
            ["weapons"] = {},
        },
        ["rotators"] = {
            [1] = {
                ["boneName"] = "B03",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
            [2] = {
                ["boneName"] = "B02",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
            [3] = {
                ["boneName"] = "B01",
                ["isVelocityScalingEnabled"] = false,
                ["speed"] = {
                    ["x"] = 0,
                    ["y"] = 0,
                    ["z"] = 0,
                },
            },
        },
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixAeonUpgradeRouting"] = {
            ["target"] = "terminal",
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.15,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
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
            ["y"] = 1.15,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.5,
            ["y"] = 2.8,
            ["z"] = 0.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 100,
            ["regen"] = 0,
            ["value"] = 100,
        },
    },
    ["economy"] = {
        ["buildTime"] = 1800,
        ["cost"] = {
            ["alloys"] = 2400,
            ["energy"] = 30000,
        },
        ["maintenanceConsumption"] = {
            ["alloys"] = 0,
            ["energy"] = 2000,
        },
    },
    ["footprint"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultChosen",
            [2] = "AeonPortStructure",
        },
        ["displayName"] = "Oculus",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Oculus",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["tpId"] = "ucs3701",
        ["unitTypeName"] = "Oculus",
    },
    ["intel"] = {
        ["radarRadius"] = 600,
        ["visionRadius"] = 30,
    },
    ["ranges"] = {
        [2] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 600,
        },
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 30,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 30,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "CHOSEN",
        [3] = "INTEL",
        [4] = "RADAR",
        [5] = "STRUCTURE",
        [6] = "TECH3",
        [7] = "SCFA_AEON",
        [8] = "SCFA_ALLUNITS",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_INTELLIGENCE",
        [13] = "SCFA_OMNI",
        [14] = "SCFA_OVERLAYOMNI",
        [15] = "SCFA_OVERLAYRADAR",
        [16] = "SCFA_PRODUCTSC1",
        [17] = "SCFA_RECLAIMABLE",
        [18] = "SCFA_SELECTABLE",
        [19] = "SCFA_SIZE4",
        [20] = "SCFA_SORTINTEL",
        [21] = "SCFA_STRUCTURE",
        [22] = "SCFA_TECH3",
        [23] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs3701/LOD0/ucs3701.sananimation",
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
                    ["particleName"] = "VFX/SCOM/FieldFixes/AeonDeathSmoke/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 1.8499999999999999,
                    ["z"] = -0.1,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 1.654,
                    ["z"] = 0.09,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.1,
                    ["y"] = 1.934,
                    ["z"] = 0.08,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.09,
                    ["y"] = 2.3259999999999996,
                    ["z"] = -0.1,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.11,
                    ["y"] = 2.2699999999999996,
                    ["z"] = 0.09,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 67,
            ["lod1distance"] = 175,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1.15,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.75,
                ["y"] = 0.75,
            },
        },
    },
}
