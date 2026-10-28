-- ucs2801: Aeon Quantum Gate Beacon
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["constructionSurfaceModelEntry"] = "",
            ["constructionSurfaceModelSha256"] = "",
            ["intel"] = {
                ["provenanceOnly"] = {},
                ["runtimeSupported"] = {
                    ["visionRadius"] = 0,
                },
            },
            ["movementCompatibility"] = "",
            ["placement"] = {
                ["footprint"] = {
                    ["x"] = 1,
                    ["z"] = 1,
                },
                ["footprintSource"] = "Physics.SkirtSizeFallback",
                ["sourceSkirt"] = {
                    ["offsetX"] = 0,
                    ["offsetZ"] = 0,
                    ["sizeX"] = 1,
                    ["sizeZ"] = 1,
                },
                ["sourceSkirtPresent"] = true,
            },
            ["shield"] = {
                ["enabled"] = false,
            },
            ["sourceArchiveSha256"] = "c23a48d6b47043144baafc4c7f47b5a470392264f1bbaf962896923d58899c26",
            ["sourceBlueprint"] = "units/UAB5103/UAB5103_unit.bp",
            ["sourceBlueprintSha256"] = "ba6bfa88f60e79b2bcc76dcb1b8ee6ad12558ef7cfaa13e10be20a27dbc072af",
            ["sourceCategories"] = {
                [1] = "AEON",
                [2] = "PRODUCTSC1",
                [3] = "SIZE4",
                [4] = "STRUCTURE",
                [5] = "TECH3",
                [6] = "TELEPORTBEACON",
                [7] = "VISIBLETORECON",
            },
            ["sourceConstructionSurfaceClearance"] = 0,
            ["sourceElevation"] = 0,
            ["sourceId"] = "UAB5103",
            ["sourceKLift"] = 0,
            ["sourceKLiftDamping"] = 0,
            ["sourceLiftFactor"] = 0,
            ["sourceMotionType"] = "RULEUMT_None",
            ["sourceUpgradeFrom"] = "",
            ["sourceUpgradeTo"] = "",
            ["targetId"] = "ucs2801",
            ["weapons"] = {},
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.3,
                ["y"] = 0.3,
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
            ["y"] = 0.25,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1,
            ["y"] = 1,
            ["z"] = 1,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 10,
            ["regen"] = 0,
            ["value"] = 10,
        },
    },
    ["economy"] = {
        ["buildTime"] = 50,
        ["cost"] = {
            ["alloys"] = 5,
            ["energy"] = 50,
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
        ["displayName"] = "Aeon Quantum Gate Beacon",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "direct",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_direct.png",
        ["iconUIBuildSortPriority"] = 320,
        ["iconUIType"] = "land",
        ["name"] = "Aeon Quantum Gate Beacon",
        ["orders"] = {
            ["Stop"] = true,
        },
        ["tpId"] = "ucs2801",
        ["unitTypeName"] = "Aeon Quantum Gate Beacon",
    },
    ["intel"] = {
        ["visionRadius"] = 0,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 0,
        },
    },
    ["skirtSize"] = {
        ["x"] = 1,
        ["y"] = 1,
    },
    ["tags"] = {
        [1] = "CHOSEN",
        [2] = "STRUCTURE",
        [3] = "TECH3",
        [4] = "SCFA_AEON",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_PRODUCTSC1",
        [7] = "SCFA_SIZE4",
        [8] = "SCFA_STRUCTURE",
        [9] = "SCFA_TECH3",
        [10] = "SCFA_TELEPORTBEACON",
        [11] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/ucs2801/LOD0/ucs2801.sananimation",
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.5,
                    ["z"] = -0.2,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.43,
                    ["z"] = 0.18,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.2,
                    ["y"] = 0.53,
                    ["z"] = 0.16,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.18,
                    ["y"] = 0.6699999999999999,
                    ["z"] = -0.2,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.22,
                    ["y"] = 0.65,
                    ["z"] = 0.18,
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
                ["y"] = 0.25,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.3,
                ["y"] = 0.3,
            },
        },
    },
}
