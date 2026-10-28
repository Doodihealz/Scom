-- uss2711: Sele-ioz
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 2.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 1,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 1.5,
                ["key"] = "source_animadeath",
                ["rateMaxTenths"] = 10,
                ["rateMinTenths"] = 10,
                ["weight"] = 1,
            },
        },
    },
    ["audio"] = {
        ["active"] = {
            ["looping"] = true,
            ["name"] = "aclu2620",
        },
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 2.35,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.5,
            ["y"] = 5.2,
            ["z"] = 1.5,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 200,
            ["regen"] = 0,
            ["value"] = 200,
        },
    },
    ["economy"] = {
        ["buildTime"] = 420,
        ["cost"] = {
            ["alloys"] = 378,
            ["energy"] = 5670,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 125,
        },
    },
    ["footprint"] = {
        ["x"] = 3,
        ["y"] = 3,
    },
    ["general"] = {
        ["class"] = {
            [1] = "unitsDefaultSeraphim",
            [2] = "SeraphimStructure",
        },
        ["displayName"] = "Sele-ioz",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "shield",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_shield.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "Sele-ioz",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["tpId"] = "uss2711",
        ["unitTypeName"] = "UnknownT2StealthField",
    },
    ["intel"] = {
        ["visionRadius"] = 20,
    },
    ["ranges"] = {
        [33] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
        [34] = {
            ["innerRadius"] = 0,
            ["outerRadius"] = 20,
        },
    },
    ["skirtSize"] = {
        ["x"] = 6,
        ["y"] = 6,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "DEFENCE",
        [4] = "SCFA_ALLUNITS",
        [5] = "SCFA_BUILTBYTIER2COMMANDER",
        [6] = "SCFA_BUILTBYTIER2ENGINEER",
        [7] = "SCFA_BUILTBYTIER3COMMANDER",
        [8] = "SCFA_BUILTBYTIER3ENGINEER",
        [9] = "SCFA_COUNTERINTELLIGENCE",
        [10] = "SCFA_DRAGBUILD",
        [11] = "SCFA_INTELLIGENCE",
        [12] = "SCFA_OVERLAYCOUNTERINTEL",
        [13] = "SCFA_PRODUCTFA",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SERAPHIM",
        [17] = "SCFA_SIZE12",
        [18] = "SCFA_SORTINTEL",
        [19] = "SCFA_STRUCTURE",
        [20] = "SCFA_TECH2",
        [21] = "SCFA_VISIBLETORECON",
        [22] = "SERAPHIM",
        [23] = "STEALTH_FIELD",
        [24] = "STRUCTURE",
        [25] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animactivate"] = {
                ["clipName"] = "AnimActivate",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2711/LOD0/uss2711.sananimation",
            },
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2711/LOD0/uss2711.sananimation",
            },
            ["source_rest"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2711/LOD0/uss2711.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2711/LOD0/uss2711.sananimation",
            },
        },
        ["display"] = {
            ["mainBarDisplayScale"] = {
                ["x"] = 0.7,
                ["y"] = 0.7,
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
                    ["audioName"] = "unit_death_land_eda_large",
                    ["boneName"] = "Root",
                    ["particleName"] = "VFX/Death/vgd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27,
                    ["y"] = 3.6500000000000004,
                    ["z"] = -0.30000000000000004,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 3.286,
                    ["z"] = 0.27,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.30000000000000004,
                    ["y"] = 3.806,
                    ["z"] = 0.24,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.27,
                    ["y"] = 4.534000000000001,
                    ["z"] = -0.30000000000000004,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_large.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.33,
                    ["y"] = 4.43,
                    ["z"] = 0.27,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 74,
            ["lod1distance"] = 193,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 2.35,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1,
                ["y"] = 1,
            },
        },
    },
}
