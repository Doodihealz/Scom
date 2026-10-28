-- uss3501: Iathu-uhthe
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["buildBeamBones"] = {
            [1] = "Attachpoint01",
        },
        ["buildBeamEffectName"] = "beam1",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.5,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.15,
                ["y"] = 2.15,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 2.6666667461395264,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 1,
            },
        },
    },
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.5,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 2.75,
            ["y"] = 1,
            ["z"] = 2.75,
        },
    },
    ["construction"] = {
        ["beam"] = {
            ["boneName"] = "Attachpoint01",
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0,
                ["z"] = 0,
            },
            ["shrink"] = 0.4,
        },
        ["canBuild"] = "(Tags.SERAPHIM * Tags.BUILDABLE_BY_T3_ENGINEER) * Tags.SCFA_ALLUNITS",
        ["range"] = 20,
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 500,
            ["regen"] = 0,
            ["value"] = 500,
        },
    },
    ["economy"] = {
        ["buildTime"] = 350,
        ["cost"] = {
            ["alloys"] = 175,
            ["energy"] = 2100,
        },
    },
    ["footprint"] = {
        ["x"] = 6,
        ["y"] = 6,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimEngineeringStation",
        },
        ["displayName"] = "Iathu-uhthe",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "engineer",
            ["tech"] = "t3",
        },
        ["iconUI"] = "tech3_structure1_engineer.png",
        ["iconUIBuildSortPriority"] = 380,
        ["iconUIType"] = "land",
        ["name"] = "Iathu-uhthe",
        ["orders"] = {
            ["Assist"] = true,
            ["Harvest"] = true,
            ["Pause"] = false,
            ["Repair"] = true,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
        },
        ["tpId"] = "uss3501",
        ["unitTypeName"] = "UnknownT3EngineeringStation",
    },
    ["intel"] = {
        ["visionRadius"] = 0,
    },
    ["ranges"] = {
        [0] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
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
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T3_ENGINEER",
        [2] = "CONSTRUCTION",
        [3] = "ENGINEERING_STATION",
        [4] = "LAND",
        [5] = "SCFA_AIRSTAGINGPLATFORM",
        [6] = "SCFA_ALLUNITS",
        [7] = "SCFA_BUILTBYTIER2COMMANDER",
        [8] = "SCFA_BUILTBYTIER2ENGINEER",
        [9] = "SCFA_BUILTBYTIER3COMMANDER",
        [10] = "SCFA_BUILTBYTIER3ENGINEER",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_OVERLAYMISC",
        [13] = "SCFA_PRODUCTFA",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SERAPHIM",
        [17] = "SCFA_SIZE12",
        [18] = "SCFA_SORTSTRATEGIC",
        [19] = "SCFA_STRATEGIC",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH2",
        [22] = "SCFA_VISIBLETORECON",
        [23] = "SERAPHIM",
        [24] = "STRUCTURE",
        [25] = "TECH3",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3501/LOD0/uss3501.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss3501/LOD0/uss3501.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 1,
                ["y"] = 1,
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
                    ["audioName"] = "unit_death_land_eda_small",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vcd2101_death_building_small.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.495,
                    ["y"] = 0.75,
                    ["z"] = -0.55,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.605,
                    ["y"] = 0.6799999999999999,
                    ["z"] = 0.495,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.55,
                    ["y"] = 0.78,
                    ["z"] = 0.44,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.495,
                    ["y"] = 0.9199999999999999,
                    ["z"] = -0.55,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.605,
                    ["y"] = 0.9,
                    ["z"] = 0.495,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 81,
            ["lod1distance"] = 211,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.5,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 2.15,
                ["y"] = 2.15,
            },
        },
    },
}
