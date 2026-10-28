-- uss2401: Atha
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["scoFieldFixAeonSeraphim"] = "1.0.0",
        ["scoFieldFixShieldGeneratorPalette"] = {
            ["effect"] = "VFX/SCOM/FieldFixes/Shields/seraphim_core_t2.sanvfx",
            ["faction"] = "seraphim",
            ["positionOffset"] = {
                ["x"] = 0,
                ["y"] = -3.5,
                ["z"] = 0,
            },
            ["sourceEffect"] = "VFX/Unit/vcu1222_active_shield_generator.sanvfx",
            ["tier"] = 2,
            ["version"] = "1.0.0",
        },
        ["scoFieldFixShieldLifecycle"] = {
            ["activationAnimationKey"] = "source_animactivate",
            ["restAnimationKey"] = "walk",
            ["runtimeShieldLifecycleConsumerRequired"] = true,
            ["version"] = "1.0.0",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.55,
                ["y"] = 1.55,
            },
        },
        ["seraphimDeathAnimations"] = {
            [1] = {
                ["durationSeconds"] = 1,
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
            ["y"] = 1,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 1.75,
            ["y"] = 2.5,
            ["z"] = 1.75,
        },
    },
    ["construction"] = {
        ["buildPower"] = 10,
        ["canBuild"] = "(Tags.uss3401) * Tags.SCFA_ALLUNITS",
        ["upgradesTo"] = "uss3401",
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 400,
            ["regen"] = 0,
            ["value"] = 400,
        },
        ["shields"] = {
            [1] = {
                ["audio"] = {
                    ["active"] = {
                        ["looping"] = true,
                        ["name"] = "aclu2120",
                    },
                    ["onImpact"] = {
                        ["looping"] = false,
                        ["name"] = "acoi0025",
                    },
                },
                ["boneName"] = "Root",
                ["effectsPersistent"] = {
                    [1] = {
                        ["boneName"] = "Orb",
                        ["particleName"] = "VFX/SCOM/FieldFixes/Shields/seraphim_core_t2.sanvfx",
                        ["positionOffset"] = {
                            ["x"] = 0,
                            ["y"] = -3.5,
                            ["z"] = 0,
                        },
                    },
                },
                ["max"] = 13000,
                ["name"] = "Bubble Shield",
                ["offset"] = {
                    ["x"] = 0,
                    ["y"] = -3,
                    ["z"] = 0,
                },
                ["radii"] = {
                    ["x"] = 14,
                    ["y"] = 14,
                    ["z"] = 14,
                },
                ["rechargeHPRatio"] = 0.5,
                ["rechargeTime"] = 17,
                ["regen"] = 153,
                ["regenDelay"] = 1,
                ["type"] = 0,
                ["value"] = 13000,
            },
        },
    },
    ["economy"] = {
        ["buildTime"] = 700,
        ["cost"] = {
            ["alloys"] = 700,
            ["energy"] = 7000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 250,
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
        ["displayName"] = "Atha",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "shield",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_shield.png",
        ["iconUIBuildSortPriority"] = 300,
        ["iconUIType"] = "land",
        ["name"] = "Atha",
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Pause"] = false,
            ["Shield"] = true,
        },
        ["tpId"] = "uss2401",
        ["unitTypeName"] = "UnknownT2Shield",
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
        [3] = "CONSTRUCTION",
        [4] = "DEFENCE",
        [5] = "SCFA_ALLUNITS",
        [6] = "SCFA_BUILTBYTIER2COMMANDER",
        [7] = "SCFA_BUILTBYTIER2ENGINEER",
        [8] = "SCFA_BUILTBYTIER3COMMANDER",
        [9] = "SCFA_BUILTBYTIER3ENGINEER",
        [10] = "SCFA_DEFENSE",
        [11] = "SCFA_DRAGBUILD",
        [12] = "SCFA_OVERLAYDEFENSE",
        [13] = "SCFA_PRODUCTFA",
        [14] = "SCFA_RECLAIMABLE",
        [15] = "SCFA_SELECTABLE",
        [16] = "SCFA_SERAPHIM",
        [17] = "SCFA_SHIELD",
        [18] = "SCFA_SIZE12",
        [19] = "SCFA_SORTDEFENSE",
        [20] = "SCFA_STRUCTURE",
        [21] = "SCFA_TECH2",
        [22] = "SCFA_VISIBLETORECON",
        [23] = "SERAPHIM",
        [24] = "SHIELD",
        [25] = "STRUCTURE",
        [26] = "TECH2",
    },
    ["visuals"] = {
        ["animations"] = {
            ["source_animactivate"] = {
                ["clipName"] = "AnimActivate",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2401/LOD0/uss2401.sananimation",
            },
            ["source_animadeath"] = {
                ["clipName"] = "AnimAdeath",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2401/LOD0/uss2401.sananimation",
            },
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2401/LOD0/uss2401.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 1.625,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 1.45,
                    ["z"] = 0.315,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.35000000000000003,
                    ["y"] = 1.7000000000000002,
                    ["z"] = 0.28,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.315,
                    ["y"] = 2.05,
                    ["z"] = -0.35000000000000003,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_medium.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.385,
                    ["y"] = 2,
                    ["z"] = 0.315,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 99,
            ["lod1distance"] = 257,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 1,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 1.55,
                ["y"] = 1.55,
            },
        },
    },
}
