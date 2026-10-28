-- uss2806: Hyaliya
-- Editable full authoring data; shared code converts it into engine components.
-- Explicit ranges control range rings; coordinate them with weapon range edits.
-- host.lua and client.lua own behavior and class inheritance.
UnitTemplate = {
    ["additions"] = {
        ["faSourceContract"] = {
            ["sourceBlueprint"] = "units/XSB1104/XSB1104_unit.bp",
            ["sourceBlueprintSha256"] = "06804bda7421af1fbb486f8da89c561c423e2951631d93dbf4e3915b64929514",
            ["sourceId"] = "XSB1104",
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1588,
                ["entry"] = "units/XSB1104/XSB1104_Script.lua",
                ["sha256"] = "e63b85f5154811e8f8db6b158ed5d0a7481fa8ccf7dfaac8b1792663e8cce2e6",
            },
            ["targetId"] = "uss2806",
        },
        ["scoFaAdjacency"] = {
            ["nativeAdjacency"] = "T1AlloyFabricatorAdjacencyBuff",
            ["parityLimitation"] = "Native T1 alloy-fabricator adjacency uses one factory/station discount instead of FA footprint scaling.",
            ["sourceAdjacency"] = "T1MassFabricatorAdjacencyBuffs",
            ["sourceBlueprintSha256"] = "06804bda7421af1fbb486f8da89c561c423e2951631d93dbf4e3915b64929514",
            ["sourceId"] = "XSB1104",
        },
        ["scoSourceSecondaryVisuals"] = {
            ["effects"] = {},
            ["forceSimulatedRotators"] = true,
            ["legacyTemplateClass"] = "SeraphimAlloyExtractor",
            ["legacyTemplateModule"] = "unitsDefaultSeraphim",
            ["meshes"] = {},
            ["rotators"] = {
                [1] = {
                    ["acceleration"] = 50,
                    ["axis"] = "y",
                    ["bone"] = "Blades",
                    ["condition"] = "production",
                    ["delay"] = 0,
                    ["disabledAcceleration"] = 50,
                    ["initialSpeed"] = 0,
                    ["speed"] = 180,
                },
            },
            ["sourceBlueprint"] = "units/XSB1104/XSB1104_unit.bp",
            ["sourceBlueprintSha256"] = "06804bda7421af1fbb486f8da89c561c423e2951631d93dbf4e3915b64929514",
            ["sourceId"] = "XSB1104",
            ["sourceModel"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 50055,
                ["entry"] = "units/XSB1104/XSB1104_lod0.scm",
                ["sha256"] = "76735cdf84cfa0f31d997637f45a65d0fabac9b280ebee052d910343e7760157",
            },
            ["sourceScript"] = {
                ["archive"] = "units.scd",
                ["bytes"] = 1588,
                ["entry"] = "units/XSB1104/XSB1104_Script.lua",
                ["sha256"] = "e63b85f5154811e8f8db6b158ed5d0a7481fa8ccf7dfaac8b1792663e8cce2e6",
            },
            ["targetId"] = "uss2806",
        },
        ["selectionHit"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.175,
                ["z"] = 0,
            },
            ["size"] = {
                ["x"] = 0.65,
                ["y"] = 0.65,
            },
        },
    },
    ["adjacency"] = "T1AlloyFabricatorAdjacencyBuff",
    ["audio"] = {
        ["onDestroyed"] = {
            ["looping"] = false,
            ["name"] = "acod2120",
        },
    },
    ["collisionInfo"] = {
        ["centerOffset"] = {
            ["x"] = 0,
            ["y"] = 0.175,
            ["z"] = 0,
        },
        ["collisionSize"] = {
            ["x"] = 0.75,
            ["y"] = 0.35,
            ["z"] = 0.75,
        },
    },
    ["defence"] = {
        ["health"] = {
            ["max"] = 360,
            ["regen"] = 0,
            ["value"] = 360,
        },
    },
    ["economy"] = {
        ["buildTime"] = 500,
        ["cost"] = {
            ["alloys"] = 100,
            ["energy"] = 4000,
        },
        ["maintenanceConsumption"] = {
            ["energy"] = 150,
        },
        ["production"] = {
            ["alloys"] = 1,
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
        ["displayName"] = "Hyaliya",
        ["icon"] = {
            ["shape"] = "structure1",
            ["symbol"] = "alloy",
            ["tech"] = "t2",
        },
        ["iconUI"] = "tech2_structure1_engineer.png",
        ["iconUIBuildSortPriority"] = 380,
        ["iconUIType"] = "land",
        ["name"] = "Hyaliya",
        ["orders"] = {
            ["Assist"] = true,
            ["Pause"] = false,
            ["Stop"] = true,
        },
        ["threatByLayer"] = {
            ["Air"] = 0,
            ["Land"] = 0,
            ["WaterSurface"] = 0,
        },
        ["toggles"] = {
            ["Production"] = true,
        },
        ["tpId"] = "uss2806",
        ["unitTypeName"] = "UnknownT2AlloyFurnace",
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
        ["x"] = 2,
        ["y"] = 2,
    },
    ["tags"] = {
        [1] = "BUILDABLE_BY_T2_ENGINEER",
        [2] = "BUILDABLE_BY_T3_ENGINEER",
        [3] = "SERAPHIM",
        [4] = "LAND",
        [5] = "STRUCTURE",
        [6] = "TECH2",
        [7] = "ALLOYS_PRODUCTION",
        [8] = "ECONOMIC",
        [9] = "SCFA_ALLUNITS",
        [10] = "SCFA_BUILTBYTIER2COMMANDER",
        [11] = "SCFA_BUILTBYTIER2ENGINEER",
        [12] = "SCFA_BUILTBYTIER3COMMANDER",
        [13] = "SCFA_BUILTBYTIER3ENGINEER",
        [14] = "SCFA_DRAGBUILD",
        [15] = "SCFA_ECONOMIC",
        [16] = "SCFA_MASSFABRICATION",
        [17] = "SCFA_MASSPRODUCTION",
        [18] = "SCFA_PRODUCTFA",
        [19] = "SCFA_RECLAIMABLE",
        [20] = "SCFA_SELECTABLE",
        [21] = "SCFA_SERAPHIM",
        [22] = "SCFA_SIZE4",
        [23] = "SCFA_SORTECONOMY",
        [24] = "SCFA_STRUCTURE",
        [25] = "SCFA_TECH2",
        [26] = "SCFA_VISIBLETORECON",
    },
    ["visuals"] = {
        ["animations"] = {
            ["walk"] = {
                ["clipName"] = "Rest",
                ["playbackMode"] = 0,
                ["sanAnimationPath"] = "Units/uss2806/LOD0/uss2806.sananimation",
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
                    ["particleName"] = "VFX/Death/vcd2201_death_building_medium.sanvfx",
                },
            },
        },
        ["effectsPersistent"] = {
            [1] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 0.26249999999999996,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageSmoke"] = 0.75,
            },
            [2] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 0.238,
                    ["z"] = 0.135,
                },
                ["scoDamageSmoke"] = 0.5,
            },
            [3] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_smoke_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.15000000000000002,
                    ["y"] = 0.273,
                    ["z"] = 0.12,
                },
                ["scoDamageSmoke"] = 0.25,
            },
            [4] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = 0.135,
                    ["y"] = 0.32199999999999995,
                    ["z"] = -0.15000000000000002,
                },
                ["scoDamageFire"] = 0.25,
            },
            [5] = {
                ["boneName"] = "__Head",
                ["particleName"] = "VFX/SCOM/DamageSmoke/scom_damage_fire_small.sanvfx",
                ["positionOffset"] = {
                    ["x"] = -0.165,
                    ["y"] = 0.31499999999999995,
                    ["z"] = 0.135,
                },
                ["scoDamageFire"] = 0.1,
            },
        },
        ["mesh"] = {
            ["lod0distance"] = 78,
            ["lod1distance"] = 203,
        },
        ["selection"] = {
            ["offset"] = {
                ["x"] = 0,
                ["y"] = 0.175,
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
            ["damage"] = 370,
            ["damageFriendly"] = true,
            ["damageRadius"] = 5,
            ["damageType"] = "Normal",
            ["scoFaMissingWeapon"] = {
                ["sourceBlueprintSha256"] = "06804bda7421af1fbb486f8da89c561c423e2951631d93dbf4e3915b64929514",
                ["sourceId"] = "XSB1104",
                ["sourceIndex"] = 1,
                ["sourceLabel"] = "DeathWeapon",
            },
            ["scoFaSourceWeaponIndex"] = 1,
        },
    },
}

-- These fields intentionally share runtime animation/audio state.
UnitTemplate["additions"]["scoSourceSecondaryVisuals"]["sourceScript"] = UnitTemplate["additions"]["faSourceContract"]["sourceScript"]
