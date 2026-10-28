-- uss1601: Hyalatoh
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoGameplayT1ExtractorVision"] = "1.1.0",
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.5,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 1,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 100,
            },
        },
    },
    ["adjacency"] = "AlloyExtractorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2110",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.5,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.75,
            ["y"] = 1,
            ["z"] = 0.75,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
        ["buildableOnResources"] = {
            [1] = "alloys",
        },
        ["canBuild"] = "(Tags.uss2601) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "uss2601",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 600,
            ["regen"] = 0,
            ["value"] = 600,
        },
    },
    ["economy"] = {
        ["buildTime"] = 60,
        ["cost"] = {
            ["alloys"] = 36,
            ["energy"] = 360,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 2,
        },
        ["production"] = {
            ["alloys"] = 2,
        },
    },
    ["footprint"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimAlloyExtractor",
        },
        ["displayName"] = "Hyalatoh",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t1",
        },
        ["iconUI"] = "tech1_structure1_alloy.png",
        ["iconUIBuildSortPriority"] = 370,
        ["iconUIType"] = "amphibious",
        ["name"] = "Hyalatoh",
        ["orders"] = {
            ["Pause"] = false,
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
        ["tpId"] = "uss1601",
        ["unitTypeName"] = "UnknownT1AlloyExtractor",
    },
    ["intel"] = {
        ["visionRadius"] = 15,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 15,
        },
    },
    ["skirtSize"] = {
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "ALLOYS_EXTRACTION",
        [2] = "BUILDABLE_BY_T1_ENGINEER",
        [3] = "BUILDABLE_BY_T2_ENGINEER",
        [4] = "BUILDABLE_BY_T3_ENGINEER",
        [5] = "SERAPHIM",
        [6] = "CONSTRUCTION",
        [7] = "ECONOMIC",
        [8] = "STRUCTURE",
        [9] = "TECH1",
        [10] = "SCFA_ALLUNITS",
        [11] = "SCFA_BUILTBYCOMMANDER",
        [12] = "SCFA_BUILTBYTIER1ENGINEER",
        [13] = "SCFA_BUILTBYTIER2ENGINEER",
        [14] = "SCFA_BUILTBYTIER3ENGINEER",
        [15] = "SCFA_ECONOMIC",
        [16] = "SCFA_MASSEXTRACTION",
        [17] = "SCFA_MASSPRODUCTION",
        [18] = "SCFA_PRODUCTFA",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SERAPHIM",
        [22] = "SCFA_SHOWQUEUE",
        [23] = "SCFA_SIZE4",
        [24] = "SCFA_SORTECONOMY",
        [25] = "SCFA_STRUCTURE",
        [26] = "SCFA_TECH1",
        [27] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss1601/LOD0/uss1601.sananimation",
            },
            ["source_rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss1601/LOD0/uss1601.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "AnimPump",
                ["playbackMode"] = 1,
                ["sanAnimationPath"] = "Units/uss1601/LOD0/uss1601.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.4,
                ["y"] = 0.4,
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
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 0.75,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 0.6799999999999999,
                    ["z"] = 0.135,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.15000000000000002,
                    ["y"] = 0.78,
                    ["z"] = 0.12,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 0.9199999999999999,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 0.9,
                    ["z"] = 0.135,
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
                ["y"] = 0.5,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
    ["weapons"] = {
        [1] = {
            ["category"] = "DeathExplosion",
            ["damage"] = 400,
            ["damageFriendly"] = true,
            ["damageRadius"] = 2,
            ["damageType"] = "Normal",
        },
    },
}
